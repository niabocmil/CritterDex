import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/terrarium_layout.dart';
import '../services/species_lookup_service.dart';
import '../widgets/specimen_avatar.dart';
import '../widgets/specimen_icon_picker_dialog.dart';
import '../widgets/species_search_field.dart';
import '../widgets/species_unlocked_dialog.dart';
import '../widgets/terrarium_picker_sheet.dart';
import 'species_detail_screen.dart';
import 'terrarium_form_screen.dart';

/// Single-flow 4-step specimen creation/editing, also reused for batch
/// creation (e.g. "+ > Batch create" on the Specimens tab, and "Batch create
/// offspring" from a completed breeding log). In batch mode the first three
/// steps act as a shared template applied to every created specimen; only
/// step 4 (terrarium) and the name pattern/count are batch-specific.
class SpecimenFormScreen extends StatefulWidget {
  const SpecimenFormScreen({
    super.key,
    this.existing,
    this.isBatch = false,
    this.prefillSpecies,
    this.prefillIcon,
    this.prefillMotherId,
    this.prefillFatherId,
    this.sourceBreedingEventId,
    this.prefillTerrariumId,
  });

  final Specimen? existing;
  final bool isBatch;
  final String? prefillSpecies;
  final SpecimenIconType? prefillIcon;
  final int? prefillMotherId;
  final int? prefillFatherId;
  final int? sourceBreedingEventId;
  final int? prefillTerrariumId;

  @override
  State<SpecimenFormScreen> createState() => _SpecimenFormScreenState();
}

class _SpecimenFormScreenState extends State<SpecimenFormScreen> {
  int _step = 0;

  final _nameController = TextEditingController();
  final _namePatternController = TextEditingController();
  final _countController = TextEditingController(text: '2');
  final _speciesController = TextEditingController();
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _notesController = TextEditingController();
  final _foundingGenerationController = TextEditingController();

  SpecimenIconType _iconType = SpecimenIconType.other;
  SpecimenSex _sex = SpecimenSex.unknown;
  SpecimenOrigin _origin = SpecimenOrigin.unknown;
  SpecimenStatus _status = SpecimenStatus.alive;
  DateTime? _dateAcquired;
  bool _ageUnknown = true;
  DateTime? _dateOfBirth;
  BeetleLifeStage? _lifeStage;
  BeetleFamily? _beetleFamily;
  String? _photoPath;
  int? _motherId;
  int? _fatherId;
  int? _terrariumId;
  // Loaded once (not via a per-build FutureBuilder) so the Bloodline
  // dropdowns' initialValue is only baked in once real data is available —
  // see _ParentDropdown's key.
  List<Specimen> _allSpecimens = const [];
  bool _specimensLoaded = false;
  Map<int, String> _terrariumLabels = const {};
  final _replenishIntervalController = TextEditingController();
  final _replenishNoteController = TextEditingController();
  DateTime? _lastReplenishedAt;
  final _growthReminderIntervalController = TextEditingController();
  DateTime? _lastGrowthEntryAt;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;
  bool get _isBatch => widget.isBatch && !_isEditing;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name ?? '';
      _speciesController.text = existing.species;
      _notesController.text = existing.notes ?? '';
      _iconType = SpecimenIconType.fromValue(existing.speciesIconKey);
      _sex = SpecimenSex.fromValue(existing.sex);
      _origin = SpecimenOrigin.fromValue(existing.origin);
      _foundingGenerationController.text =
          existing.foundingGeneration == 0 ? '' : '${existing.foundingGeneration}';
      _status = SpecimenStatus.fromValue(existing.status);
      _dateAcquired = existing.dateAcquired;
      _dateOfBirth = existing.dateOfBirth;
      _ageUnknown = existing.dateOfBirth == null;
      _weightController.text = existing.weightGrams?.toString() ?? '';
      _sizeController.text = existing.sizeMm?.toString() ?? '';
      _lifeStage = BeetleLifeStage.fromValue(existing.lifeStage);
      _beetleFamily = BeetleFamily.fromValue(existing.beetleFamily);
      _photoPath = existing.photoPath;
      _motherId = existing.motherId;
      _fatherId = existing.fatherId;
      _terrariumId = existing.terrariumId;
      _replenishIntervalController.text =
          existing.replenishIntervalDays?.toString() ?? '';
      _replenishNoteController.text = existing.replenishNote ?? '';
      _lastReplenishedAt = existing.lastReplenishedAt;
      _growthReminderIntervalController.text =
          existing.growthReminderIntervalDays?.toString() ?? '';
      _lastGrowthEntryAt = existing.lastGrowthEntryAt;
    } else {
      _speciesController.text = widget.prefillSpecies ?? '';
      _iconType = widget.prefillIcon ?? SpecimenIconType.other;
      _motherId = widget.prefillMotherId;
      _fatherId = widget.prefillFatherId;
      _terrariumId = widget.prefillTerrariumId;
    }
    _loadBloodlineOptions();
    _loadTerrariumLabels();
  }

  Future<void> _loadBloodlineOptions() async {
    final db = context.read<AppDatabase>();
    final all = await db.getAllSpecimens();
    if (!mounted) return;
    setState(() {
      _allSpecimens = all;
      _specimensLoaded = true;
    });
  }

  Future<void> _loadTerrariumLabels() async {
    final db = context.read<AppDatabase>();
    final terrariums = await db.getAllTerrariums();
    final shelves = await db.getAllShelves();
    final tools = await db.getAllTools();
    if (!mounted) return;
    setState(() {
      _terrariumLabels = computeAllTerrariumLabels(shelves, terrariums, tools);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _namePatternController.dispose();
    _countController.dispose();
    _speciesController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    _foundingGenerationController.dispose();
    _replenishIntervalController.dispose();
    _replenishNoteController.dispose();
    _growthReminderIntervalController.dispose();
    super.dispose();
  }

  Future<void> _openIconPicker() async {
    final result = await showDialog<SpecimenIconType>(
      context: context,
      builder: (_) => SpecimenIconPickerDialog(selected: _iconType),
    );
    if (result != null && mounted) {
      setState(() {
        _iconType = result;
        if (result != SpecimenIconType.beetle) {
          _beetleFamily = null;
          _lifeStage = null;
        }
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'photos'));
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final ext = p.extension(picked.path);
    final newPath = p.join(photosDir.path, '${const Uuid().v4()}$ext');
    await File(picked.path).copy(newPath);
    if (mounted) setState(() => _photoPath = newPath);
  }

  Future<void> _pickDate({required bool isBirth}) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: (isBirth ? _dateOfBirth : _dateAcquired) ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: now,
    );
    if (result == null || !mounted) return;
    setState(() {
      if (isBirth) {
        _dateOfBirth = result;
      } else {
        _dateAcquired = result;
      }
    });
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_speciesController.text.trim().isEmpty) return false;
      if (_isBatch && (int.tryParse(_countController.text.trim()) ?? 0) < 1) {
        return false;
      }
    }
    return true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = context.read<AppDatabase>();
    final species = _speciesController.text.trim();
    final weight = double.tryParse(_weightController.text.trim());
    final size = double.tryParse(_sizeController.text.trim());
    final notes =
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final lifeStage =
        _iconType == SpecimenIconType.beetle ? _lifeStage?.name : null;
    final beetleFamily =
        _iconType == SpecimenIconType.beetle ? _beetleFamily?.name : null;
    final replenishIntervalDays =
        int.tryParse(_replenishIntervalController.text.trim());
    final replenishNote = _replenishNoteController.text.trim().isEmpty
        ? null
        : _replenishNoteController.text.trim();
    // A founder acquired already labelled (e.g. a friend's "this is WF1" or
    // "CBF2", or someone starting to use the app with beetles they've had
    // for a while) isn't necessarily generation 0 even though it has no
    // recorded parents in-app.
    final parsedFoundingGeneration =
        int.tryParse(_foundingGenerationController.text.trim()) ?? 0;
    final foundingGeneration =
        parsedFoundingGeneration < 0 ? 0 : parsedFoundingGeneration;
    var lastReplenishedAt = _lastReplenishedAt;
    if (!_isEditing && replenishIntervalDays != null && lastReplenishedAt == null) {
      // Seed the countdown anchor immediately so it's meaningful right away.
      lastReplenishedAt = _dateAcquired ?? DateTime.now();
    }
    final growthReminderIntervalDays =
        int.tryParse(_growthReminderIntervalController.text.trim());
    var lastGrowthEntryAt = _lastGrowthEntryAt;
    if (!_isEditing &&
        growthReminderIntervalDays != null &&
        lastGrowthEntryAt == null) {
      lastGrowthEntryAt = _dateAcquired ?? DateTime.now();
    }
    final dob = _ageUnknown ? null : _dateOfBirth;

    try {
      if (_isEditing) {
        await db.updateSpecimen(widget.existing!.copyWith(
          name: Value(_nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim()),
          species: species,
          speciesIconKey: _iconType.name,
          sex: _sex.name,
          origin: _origin.name,
          foundingGeneration: foundingGeneration,
          status: _status.name,
          dateAcquired: Value(_dateAcquired),
          dateOfBirth: Value(dob),
          weightGrams: Value(weight),
          sizeMm: Value(size),
          lifeStage: Value(lifeStage),
          beetleFamily: Value(beetleFamily),
          replenishIntervalDays: Value(replenishIntervalDays),
          replenishNote: Value(replenishNote),
          lastReplenishedAt: Value(lastReplenishedAt),
          growthReminderIntervalDays: Value(growthReminderIntervalDays),
          lastGrowthEntryAt: Value(lastGrowthEntryAt),
          notes: Value(notes),
          photoPath: Value(_photoPath),
          motherId: Value(_motherId),
          fatherId: Value(_fatherId),
          terrariumId: Value(_terrariumId),
        ));
      } else if (_isBatch) {
        final count = int.parse(_countController.text.trim());
        final pattern = _namePatternController.text.trim();
        final entries = [
          for (var i = 1; i <= count; i++)
            SpecimensCompanion.insert(
              name: Value(
                  pattern.isEmpty ? null : pattern.replaceAll('%n', '$i')),
              species: species,
              speciesIconKey: Value(_iconType.name),
              sex: Value(_sex.name),
              origin: Value(_origin.name),
              foundingGeneration: Value(foundingGeneration),
              status: Value(_status.name),
              dateAcquired: Value(_dateAcquired),
              dateOfBirth: Value(dob),
              weightGrams: Value(weight),
              sizeMm: Value(size),
              lifeStage: Value(lifeStage),
              beetleFamily: Value(beetleFamily),
              replenishIntervalDays: Value(replenishIntervalDays),
              replenishNote: Value(replenishNote),
              lastReplenishedAt: Value(lastReplenishedAt),
              growthReminderIntervalDays: Value(growthReminderIntervalDays),
              lastGrowthEntryAt: Value(lastGrowthEntryAt),
              notes: Value(notes),
              motherId: Value(_motherId),
              fatherId: Value(_fatherId),
              terrariumId: Value(_terrariumId),
              sourceBreedingEventId: Value(widget.sourceBreedingEventId),
            ),
        ];
        await db.insertSpecimensBatch(entries,
            title: 'Batch-created $count specimens ($species)');
      } else {
        await db.insertSpecimen(SpecimensCompanion.insert(
          name: Value(_nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim()),
          species: species,
          speciesIconKey: Value(_iconType.name),
          sex: Value(_sex.name),
          origin: Value(_origin.name),
          foundingGeneration: Value(foundingGeneration),
          status: Value(_status.name),
          dateAcquired: Value(_dateAcquired),
          dateOfBirth: Value(dob),
          weightGrams: Value(weight),
          sizeMm: Value(size),
          lifeStage: Value(lifeStage),
          beetleFamily: Value(beetleFamily),
          replenishIntervalDays: Value(replenishIntervalDays),
          replenishNote: Value(replenishNote),
          lastReplenishedAt: Value(lastReplenishedAt),
          growthReminderIntervalDays: Value(growthReminderIntervalDays),
          lastGrowthEntryAt: Value(lastGrowthEntryAt),
          notes: Value(notes),
          photoPath: Value(_photoPath),
          motherId: Value(_motherId),
          fatherId: Value(_fatherId),
          terrariumId: Value(_terrariumId),
          sourceBreedingEventId: Value(widget.sourceBreedingEventId),
        ));
      }
      final isNewSpecies = await db.discoverSpeciesIfNew(species);
      if (isNewSpecies) {
        // Fire-and-forget: the celebration below never waits on this, and
        // the species page picks up the result reactively whenever it
        // finishes (or silently stays "Not recorded yet" if it finds
        // nothing / there's no connectivity).
        unawaited(SpeciesLookupService().fillFromWiki(db, species));
      }
      if (mounted) {
        // Captured before any popping — a NavigatorState stays valid to
        // push/pop on even after the route that fetched it is gone, unlike
        // the BuildContext itself.
        final navigator = Navigator.of(context);
        var wantsSpeciesView = false;
        if (isNewSpecies) {
          wantsSpeciesView = await SpeciesUnlockedDialog.show(
            context,
            species: species,
            iconType: _iconType,
            beetleFamily: _beetleFamily,
            lifeStage: _lifeStage,
          );
        }
        if (mounted) navigator.pop(true);
        // Pushed only *after* popping the form itself — otherwise this
        // screen's own pop (above) would immediately close it again, since
        // both share the same navigator.
        if (wantsSpeciesView) {
          navigator.push(MaterialPageRoute(
            builder: (_) => SpeciesDetailScreen(species: species),
          ));
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step(
        title: const Text('Basic'),
        isActive: _step >= 0,
        state: _step > 0 ? StepState.complete : StepState.indexed,
        content: _buildBasicStep(),
      ),
      Step(
        title: const Text('Bloodline'),
        isActive: _step >= 1,
        state: _step > 1 ? StepState.complete : StepState.indexed,
        content: _buildBloodlineStep(),
      ),
      Step(
        title: const Text('Status'),
        isActive: _step >= 2,
        state: _step > 2 ? StepState.complete : StepState.indexed,
        content: _buildStatusStep(),
      ),
      Step(
        title: const Text('Terrarium'),
        isActive: _step >= 3,
        content: _buildTerrariumStep(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? 'Edit specimen'
            : _isBatch
                ? 'Batch create specimens'
                : 'New specimen'),
      ),
      body: Stepper(
        currentStep: _step,
        onStepTapped: (i) => setState(() => _step = i),
        onStepContinue: () {
          if (!_validateStep(_step)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Please fill in the required fields.')));
            return;
          }
          if (_step == steps.length - 1) {
            _save();
          } else {
            setState(() => _step += 1);
          }
        },
        onStepCancel: _step == 0 ? null : () => setState(() => _step -= 1),
        controlsBuilder: (context, details) {
          final isLast = _step == steps.length - 1;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: _saving ? null : details.onStepContinue,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isLast
                          ? (_isEditing
                              ? 'Save changes'
                              : _isBatch
                                  ? 'Create batch'
                                  : 'Create specimen')
                          : 'Next'),
                ),
                if (details.onStepCancel != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back')),
                ],
              ],
            ),
          );
        },
        steps: steps,
      ),
    );
  }

  Widget _buildBasicStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _openIconPicker,
                child: Stack(
                  children: [
                    SpecimenAvatar(
                      iconType: _iconType,
                      beetleFamily: _beetleFamily,
                      lifeStage: _lifeStage,
                      radius: 40,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(Icons.edit,
                            size: 14,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(_iconType.label,
                  style: Theme.of(context).textTheme.labelLarge),
              if (!_isBatch) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label:
                      Text(_photoPath == null ? 'Add photo' : 'Change photo'),
                ),
              ],
            ],
          ),
        ),
        if (_iconType == SpecimenIconType.beetle) ...[
          const SizedBox(height: 8),
          Text('Family', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<BeetleFamily>(
            segments: BeetleFamily.values
                .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                .toList(),
            selected: _beetleFamily == null ? {} : {_beetleFamily!},
            emptySelectionAllowed: true,
            onSelectionChanged: (s) =>
                setState(() => _beetleFamily = s.isEmpty ? null : s.first),
          ),
        ],
        const SizedBox(height: 18),
        if (_isBatch) ...[
          TextFormField(
            controller: _namePatternController,
            decoration: const InputDecoration(
                labelText: 'Name pattern (optional)',
                hintText: 'e.g. "Clutch A %n" — %n becomes 1, 2, 3...'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _countController,
            decoration: const InputDecoration(labelText: 'How many? *'),
            keyboardType: TextInputType.number,
          ),
        ] else
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name / nickname'),
          ),
        const SizedBox(height: 14),
        SpeciesSearchField(controller: _speciesController),
        const SizedBox(height: 18),
        Text('Sex', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<SpecimenSex>(
          segments: SpecimenSex.values
              .map((s) =>
                  ButtonSegment(value: s, label: Text(s.label), icon: Icon(s.icon)))
              .toList(),
          selected: {_sex},
          onSelectionChanged: (s) => setState(() => _sex = s.first),
        ),
      ],
    );
  }

  Widget _buildBloodlineStep() {
    final all = _allSpecimens.where((s) => s.id != widget.existing?.id).toList();
    final mothers =
        all.where((s) => s.sex == SpecimenSex.female.name).toList();
    final fathers =
        all.where((s) => s.sex == SpecimenSex.male.name).toList();
    return Column(
      children: [
        _ParentDropdown(
          // DropdownButtonFormField's initialValue is a one-shot seed read
          // only in its State's initState — it never re-syncs on rebuild.
          // Keying on _specimensLoaded forces the field to remount (and
          // re-seed) the moment the real specimen list arrives, instead of
          // being permanently stuck showing "None" from the first
          // (pre-load) build.
          key: ValueKey('mother_$_specimensLoaded'),
          label: 'Mother',
          options: mothers,
          value: _motherId,
          onChanged: (id) => setState(() => _motherId = id),
        ),
        const SizedBox(height: 12),
        _ParentDropdown(
          key: ValueKey('father_$_specimensLoaded'),
          label: 'Father',
          options: fathers,
          value: _fatherId,
          onChanged: (id) => setState(() => _fatherId = id),
        ),
        if (_motherId == null && _fatherId == null) ...[
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child:
                Text('Origin', style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'No parents recorded, so this one\'s a lineage founder — used '
              'to label its future offspring as WF#/CBF# in the app.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<SpecimenOrigin>(
            segments: SpecimenOrigin.values
                .map((o) => ButtonSegment(value: o, label: Text(o.label)))
                .toList(),
            selected: {_origin},
            onSelectionChanged: (s) => setState(() => _origin = s.first),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _foundingGenerationController,
            decoration: const InputDecoration(
              labelText: 'Already labelled generation (optional)',
              hintText:
                  'e.g. bought/given already labelled "WF1" or "CBF2" — enter 1 or 2',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }

  Widget _buildStatusStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<SpecimenStatus>(
          initialValue: _status,
          items: SpecimenStatus.values
              .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
              .toList(),
          onChanged: (s) => setState(() => _status = s ?? _status),
        ),
        const SizedBox(height: 14),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Date acquired'),
          subtitle: Text(_dateAcquired == null
              ? 'Not set'
              : _formatDate(_dateAcquired!)),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickDate(isBirth: false),
        ),
        const Divider(height: 24),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Age unknown'),
          value: _ageUnknown,
          onChanged: (v) => setState(() => _ageUnknown = v),
        ),
        if (!_ageUnknown)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date of birth'),
            subtitle: Text(_dateOfBirth == null
                ? 'Not set'
                : _formatDate(_dateOfBirth!)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () => _pickDate(isBirth: true),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (g)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Size (mm)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        if (_iconType == SpecimenIconType.beetle) ...[
          const SizedBox(height: 14),
          Text('Life stage', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Not set'),
                selected: _lifeStage == null,
                onSelected: (_) => setState(() => _lifeStage = null),
              ),
              for (final stage in BeetleLifeStage.values)
                ChoiceChip(
                  label: Text(stage.label),
                  selected: _lifeStage == stage,
                  onSelected: (_) => setState(() => _lifeStage = stage),
                ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Text('Replenish (substrate/food)',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: _replenishIntervalController,
          decoration: const InputDecoration(
              labelText: 'Replenish every (days)',
              hintText: 'Leave blank to not track'),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        if (_replenishIntervalController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Last replenished'),
            subtitle: Text(_lastReplenishedAt == null
                ? 'Not started'
                : _formatDate(_lastReplenishedAt!)),
            trailing: TextButton(
              onPressed: () =>
                  setState(() => _lastReplenishedAt = DateTime.now()),
              child: const Text('Mark today'),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _replenishNoteController,
            decoration: const InputDecoration(
                labelText: 'Replenish note',
                hintText: 'e.g. "change substrate, mist daily"'),
            minLines: 1,
            maxLines: 3,
          ),
        ],
        const SizedBox(height: 14),
        Text('Growth check-in reminder',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: _growthReminderIntervalController,
          decoration: const InputDecoration(
              labelText: 'Remind me every (days)',
              hintText: 'Leave blank to not track'),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        if (_growthReminderIntervalController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _lastGrowthEntryAt == null
                ? 'Starts counting once you save'
                : 'Last growth entry: ${_formatDate(_lastGrowthEntryAt!)}',
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 14),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(labelText: 'Notes'),
          minLines: 3,
          maxLines: 6,
        ),
      ],
    );
  }

  Widget _buildTerrariumStep() {
    final db = context.read<AppDatabase>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign to a terrarium now, or skip and assign later.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () async {
            final id = await showTerrariumPickerSheet(context, db);
            if (id != _terrariumId) setState(() => _terrariumId = id);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Terrarium',
              suffixIcon: Icon(Icons.search),
            ),
            child: Text(_terrariumId == null
                ? 'None'
                : (_terrariumLabels[_terrariumId] ?? '—')),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () async {
            final id = await Navigator.of(context).push<int>(
              MaterialPageRoute(
                  builder: (_) => const TerrariumFormScreen()),
            );
            if (id != null) {
              setState(() => _terrariumId = id);
              await _loadTerrariumLabels();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('New terrarium'),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _ParentDropdown extends StatelessWidget {
  const _ParentDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<Specimen> options;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final validValue = options.any((o) => o.id == value) ? value : null;
    return DropdownButtonFormField<int?>(
      initialValue: validValue,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('None')),
        ...options.map((o) => DropdownMenuItem<int?>(
              value: o.id,
              child: Text(o.name?.isNotEmpty == true ? o.name! : o.species),
            )),
      ],
      onChanged: onChanged,
    );
  }
}
