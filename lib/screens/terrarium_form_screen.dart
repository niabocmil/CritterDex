import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/terrarium_layout.dart';
import '../models/terrarium_placement.dart';
import 'terrarium_placement_picker_screen.dart';

enum _Placement { individual, shelf }

/// Reusable add/edit-terrarium flow: shape/dimensions -> live volume ->
/// individual-or-shelf placement. Pops with the new/edited terrarium's id on
/// success, or null if cancelled. Used both from the Shelf tab and from
/// specimen creation's terrarium-assignment step.
class TerrariumFormScreen extends StatefulWidget {
  const TerrariumFormScreen({super.key, this.existing, this.preselectedShelfId});

  final Terrarium? existing;
  final int? preselectedShelfId;

  @override
  State<TerrariumFormScreen> createState() => _TerrariumFormScreenState();
}

class _TerrariumFormScreenState extends State<TerrariumFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _diameterController = TextEditingController();
  final _heightController = TextEditingController();
  final _locationController = TextEditingController();

  String _shape = 'rectangular';
  TerrariumPurpose _purpose = TerrariumPurpose.general;
  _Placement _placement = _Placement.individual;
  int? _shelfId;
  bool _useAutoPlace = true;
  PlacementChoice? _manualChoice;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _shape = existing.shape;
      _lengthController.text = existing.lengthCm?.toString() ?? '';
      _widthController.text = existing.widthCm?.toString() ?? '';
      _diameterController.text = existing.diameterCm?.toString() ?? '';
      _heightController.text = existing.heightCm.toString();
      _locationController.text = existing.location ?? '';
      _placement = existing.shelfId == null ? _Placement.individual : _Placement.shelf;
      _shelfId = existing.shelfId;
      _purpose = TerrariumPurpose.fromValue(existing.purpose);
    } else if (widget.preselectedShelfId != null) {
      _placement = _Placement.shelf;
      _shelfId = widget.preselectedShelfId;
    }
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _diameterController.dispose();
    _heightController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  double? get _volumeLitres {
    final height = double.tryParse(_heightController.text.trim());
    if (height == null) return null;
    if (_shape == 'cylinder') {
      final diameter = double.tryParse(_diameterController.text.trim());
      if (diameter == null) return null;
      return computeVolumeLitres(
          shape: _shape, diameterCm: diameter, heightCm: height);
    }
    final length = double.tryParse(_lengthController.text.trim());
    final width = double.tryParse(_widthController.text.trim());
    if (length == null || width == null) return null;
    return computeVolumeLitres(
        shape: _shape, lengthCm: length, widthCm: width, heightCm: height);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<AppDatabase>();
    final height = double.parse(_heightController.text.trim());
    final length = _shape == 'rectangular'
        ? double.parse(_lengthController.text.trim())
        : null;
    final width = _shape == 'rectangular'
        ? double.parse(_widthController.text.trim())
        : null;
    final diameter = _shape == 'cylinder'
        ? double.parse(_diameterController.text.trim())
        : null;
    final volume = computeVolumeLitres(
        shape: _shape,
        lengthCm: length,
        widthCm: width,
        diameterCm: diameter,
        heightCm: height);
    final footprintWidth = _shape == 'cylinder' ? diameter! : length!;

    setState(() => _saving = true);
    try {
      if (_placement == _Placement.individual) {
        final sequence = await db.nextIndividualSequence();
        if (_isEditing) {
          final existing = widget.existing!;

          Future<void> convert() => db.updateTerrarium(existing.copyWith(
                shape: _shape,
                lengthCm: Value(length),
                widthCm: Value(width),
                diameterCm: Value(diameter),
                heightCm: height,
                volumeLitres: volume,
                shelfId: const Value(null),
                level: const Value(null),
                positionXCm: const Value(null),
                supportId: const Value(null),
                supportKind: const Value(null),
                purpose: _purpose.name,
                location: Value(_locationController.text.trim().isEmpty
                    ? null
                    : _locationController.text.trim()),
                individualSequence:
                    Value(existing.individualSequence ?? sequence),
              ));

          // Anything resting directly on this terrarium drops to the floor
          // instead of blocking the individual-conversion.
          if (existing.shelfId != null) {
            final shelf = await db.getShelfById(existing.shelfId!);
            final shelfTerrariums =
                await db.getTerrariumsForShelf(existing.shelfId!);
            final shelfTools = await db.getToolsForShelf(existing.shelfId!);
            final shelfItems = <ShelfItem>[
              ...shelfTerrariums.map(TerrariumShelfItem.new),
              ...shelfTools.map(ToolShelfItem.new),
            ];
            final detachUpdates = planDetach(
              removed: TerrariumShelfItem(existing),
              shelf: shelf,
              shelfItems: shelfItems,
            );
            await db.transaction(() async {
              for (final u in detachUpdates) {
                if (u.kind == ShelfItemKind.terrarium) {
                  final t = shelfTerrariums.firstWhere((t) => t.id == u.id);
                  await db.updateTerrarium(t.copyWith(
                    positionXCm: Value(u.positionXCm),
                    supportId: const Value(null),
                    supportKind: const Value(null),
                  ));
                } else {
                  final tool = shelfTools.firstWhere((t) => t.id == u.id);
                  await db.updateTool(tool.copyWith(
                    positionXCm: u.positionXCm,
                    supportId: const Value(null),
                    supportKind: const Value(null),
                  ));
                }
              }
              await convert();
            });
          } else {
            await convert();
          }
          if (mounted) Navigator.of(context).pop(existing.id);
        } else {
          final id = await db.insertTerrarium(TerrariumsCompanion.insert(
            shape: _shape,
            lengthCm: Value(length),
            widthCm: Value(width),
            diameterCm: Value(diameter),
            heightCm: height,
            volumeLitres: volume,
            purpose: Value(_purpose.name),
            location: Value(_locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim()),
            individualSequence: Value(sequence),
          ));
          if (mounted) Navigator.of(context).pop(id);
        }
      } else {
        final shelfId = _shelfId;
        if (shelfId == null) {
          setState(() => _saving = false);
          return;
        }
        final shelf = await db.getShelfById(shelfId);
        final existingTerrariums = (await db.getTerrariumsForShelf(shelfId))
            .where((t) => t.id != widget.existing?.id)
            .toList();
        final existingTools = await db.getToolsForShelf(shelfId);
        final existingOnShelf = <ShelfItem>[
          ...existingTerrariums.map(TerrariumShelfItem.new),
          ...existingTools.map(ToolShelfItem.new),
        ];

        int level;
        double positionXCm;
        int? supportId;
        String? supportKind;
        var siblingUpdates = const <ShelfPlacementUpdate>[];
        if (_useAutoPlace) {
          try {
            final placement = findAutoPlacement(
              shelf: shelf,
              newFootprintWidthCm: footprintWidth,
              newHeightCm: height,
              existingOnShelf: existingOnShelf,
            );
            level = placement.level;
            positionXCm = placement.positionXCm;
          } on PlacementException catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.message)));
            }
            setState(() => _saving = false);
            return;
          }
        } else {
          final choice = _manualChoice;
          if (choice == null) {
            setState(() => _saving = false);
            return;
          }
          level = choice.level;
          positionXCm = choice.positionXCm;
          supportId = choice.supportId;
          supportKind = choice.supportKind;
          siblingUpdates = choice.siblingUpdates;
        }

        Future<void> applySiblingUpdates() async {
          for (final u in siblingUpdates) {
            if (u.kind == ShelfItemKind.terrarium) {
              final t = existingTerrariums.firstWhere((t) => t.id == u.id);
              await db.updateTerrarium(t.copyWith(
                positionXCm: Value(u.positionXCm),
                supportId: Value(u.supportId),
                supportKind: Value(u.supportKind),
              ));
            } else {
              final tool = existingTools.firstWhere((t) => t.id == u.id);
              await db.updateTool(tool.copyWith(
                positionXCm: u.positionXCm,
                supportId: Value(u.supportId),
                supportKind: Value(u.supportKind),
              ));
            }
          }
        }

        if (_isEditing) {
          await db.transaction(() async {
            await applySiblingUpdates();
            await db.updateTerrarium(widget.existing!.copyWith(
              shape: _shape,
              lengthCm: Value(length),
              widthCm: Value(width),
              diameterCm: Value(diameter),
              heightCm: height,
              volumeLitres: volume,
              shelfId: Value(shelfId),
              level: Value(level),
              positionXCm: Value(positionXCm),
              supportId: Value(supportId),
              supportKind: Value(supportKind),
              purpose: _purpose.name,
              location: const Value(null),
            ));
          });
          if (mounted) Navigator.of(context).pop(widget.existing!.id);
        } else {
          var id = -1;
          await db.transaction(() async {
            await applySiblingUpdates();
            id = await db.insertTerrarium(TerrariumsCompanion.insert(
              shape: _shape,
              lengthCm: Value(length),
              widthCm: Value(width),
              diameterCm: Value(diameter),
              heightCm: height,
              volumeLitres: volume,
              shelfId: Value(shelfId),
              level: Value(level),
              positionXCm: Value(positionXCm),
              supportId: Value(supportId),
              supportKind: Value(supportKind),
              purpose: Value(_purpose.name),
            ));
          });
          if (mounted) Navigator.of(context).pop(id);
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Enter a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final volume = _volumeLitres;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit terrarium' : 'New terrarium'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Shape', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'rectangular', label: Text('Rectangular')),
                ButtonSegment(value: 'cylinder', label: Text('Cylinder')),
              ],
              selected: {_shape},
              onSelectionChanged: (s) => setState(() => _shape = s.first),
            ),
            const SizedBox(height: 18),
            if (_shape == 'rectangular') ...[
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(labelText: 'Length (cm) *'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _requiredNumber,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(labelText: 'Width (cm) *'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _requiredNumber,
                onChanged: (_) => setState(() {}),
              ),
            ] else
              TextFormField(
                controller: _diameterController,
                decoration: const InputDecoration(labelText: 'Diameter (cm) *'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _requiredNumber,
                onChanged: (_) => setState(() {}),
              ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm) *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _requiredNumber,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Text(
              volume == null
                  ? 'Volume: --'
                  : 'Volume: ${volume.toStringAsFixed(1)} L',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            Text('Purpose', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<TerrariumPurpose>(
              segments: TerrariumPurpose.values
                  .map((p) => ButtonSegment(value: p, label: Text(p.label)))
                  .toList(),
              selected: {_purpose},
              onSelectionChanged: (s) => setState(() => _purpose = s.first),
            ),
            const Divider(height: 32),
            Text('Placement', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<_Placement>(
              segments: const [
                ButtonSegment(
                    value: _Placement.individual, label: Text('Individual')),
                ButtonSegment(value: _Placement.shelf, label: Text('On a shelf')),
              ],
              selected: {_placement},
              onSelectionChanged: (s) => setState(() => _placement = s.first),
            ),
            const SizedBox(height: 14),
            if (_placement == _Placement.individual)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'e.g. "office desk"'),
              )
            else
              FutureBuilder<List<Shelf>>(
                future: db.getAllShelves(),
                builder: (context, snapshot) {
                  final shelves = snapshot.data ?? const <Shelf>[];
                  if (shelves.isEmpty) {
                    return Text(
                      'No shelves yet — create one from the Shelf tab first.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _shelfId,
                        decoration: const InputDecoration(labelText: 'Shelf *'),
                        items: shelves
                            .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text('${s.label} — ${s.name}')))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _shelfId = v;
                          _manualChoice = null;
                        }),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Auto-place in next empty space'),
                        value: _useAutoPlace,
                        onChanged: (v) => setState(() => _useAutoPlace = v),
                      ),
                      if (!_useAutoPlace) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _shelfId == null
                              ? null
                              : () async {
                                  final shelf =
                                      shelves.firstWhere((s) => s.id == _shelfId);
                                  final height = double.tryParse(
                                          _heightController.text.trim()) ??
                                      0;
                                  final footprint = _shape == 'cylinder'
                                      ? double.tryParse(
                                              _diameterController.text.trim()) ??
                                          0
                                      : double.tryParse(
                                              _lengthController.text.trim()) ??
                                          0;
                                  final result = await Navigator.of(context)
                                      .push<PlacementChoice>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TerrariumPlacementPickerScreen(
                                        shelf: shelf,
                                        newFootprintWidthCm: footprint,
                                        newHeightCm: height,
                                        excludeTerrariumId: widget.existing?.id,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() => _manualChoice = result);
                                  }
                                },
                          icon: const Icon(Icons.grid_view),
                          label: Text(_manualChoice == null
                              ? 'Choose position'
                              : 'Level ${levelDisplayLabel(_manualChoice!.level)}, '
                                  '${_manualChoice!.stackOnTarget != null ? "stacked" : "new column at ${_manualChoice!.positionXCm.toStringAsFixed(1)}cm"}'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Save changes' : 'Create terrarium'),
            ),
          ],
        ),
      ),
    );
  }
}
