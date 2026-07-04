import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/lineage_utils.dart';
import '../models/replenish.dart';
import '../models/terrarium_layout.dart';
import '../widgets/growth_chart.dart';
import '../widgets/specimen_avatar.dart';
import '../widgets/terrarium_picker_sheet.dart';
import 'lineage_screen.dart';
import 'specimen_form_screen.dart';
import 'terrarium_form_screen.dart';

/// A single row in the merged timeline: either a free-text note
/// ([SpecimenLogEntry]) or a weight/size record ([SpecimenMeasurement]),
/// shown together sorted by [timestamp].
class _TimelineEntry {
  _TimelineEntry.note(SpecimenLogEntry entry)
      : timestamp = entry.timestamp,
        icon = Icons.notes,
        title = entry.note;

  _TimelineEntry.measurement(SpecimenMeasurement entry)
      : timestamp = entry.timestamp,
        icon = Icons.monitor_weight_outlined,
        title = [
          if (entry.weightGrams != null)
            '${entry.weightGrams!.toStringAsFixed(1)} g',
          if (entry.sizeMm != null) '${entry.sizeMm!.toStringAsFixed(1)} mm',
        ].join(' · ');

  final DateTime timestamp;
  final IconData icon;
  final String title;
}

Future<(Terrarium, String)?> _loadAssignedTerrarium(
    AppDatabase db, int terrariumId) async {
  final terrarium = await db.getTerrariumById(terrariumId);
  final shelves = await db.getAllShelves();
  final terrariums = await db.getAllTerrariums();
  final tools = await db.getAllTools();
  final label =
      computeAllTerrariumLabels(shelves, terrariums, tools)[terrarium.id] ?? '?';
  return (terrarium, label);
}

String? _formatAge(DateTime? dob) {
  if (dob == null) return null;
  final now = DateTime.now();
  var months = (now.year - dob.year) * 12 + now.month - dob.month;
  if (now.day < dob.day) months -= 1;
  if (months < 1) return '< 1 month';
  if (months < 24) return '$months month${months == 1 ? '' : 's'}';
  final years = months ~/ 12;
  return '$years year${years == 1 ? '' : 's'}';
}

class SpecimenDetailScreen extends StatefulWidget {
  const SpecimenDetailScreen({super.key, required this.specimenId});

  final int specimenId;

  @override
  State<SpecimenDetailScreen> createState() => _SpecimenDetailScreenState();
}

class _SpecimenDetailScreenState extends State<SpecimenDetailScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addNote(AppDatabase db) async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    await db.insertSpecimenLogEntry(SpecimenLogEntriesCompanion.insert(
      specimenId: widget.specimenId,
      note: note,
    ));
    _noteController.clear();
    setState(() {});
  }

  Future<void> _recordMeasurement(
      BuildContext context, AppDatabase db, Specimen specimen) async {
    final weightController = TextEditingController(
        text: specimen.weightGrams?.toString() ?? '');
    final sizeController =
        TextEditingController(text: specimen.sizeMm?.toString() ?? '');
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Record weight & size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (g)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: 'Size (mm)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (result != true) return;
      final weight = double.tryParse(weightController.text.trim());
      final size = double.tryParse(sizeController.text.trim());
      if (weight == null && size == null) return;
      await db.recordSpecimenMeasurement(specimen,
          weightGrams: weight, sizeMm: size);
    } finally {
      weightController.dispose();
      sizeController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      body: StreamBuilder<Specimen>(
        stream: db.watchSpecimenById(widget.specimenId),
        builder: (context, snapshot) {
          final specimen = snapshot.data;
          if (specimen == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final status = SpecimenStatus.fromValue(specimen.status);
          final sex = SpecimenSex.fromValue(specimen.sex);

          return FutureBuilder<List<Specimen>>(
            future: db.getAllSpecimens(),
            builder: (context, allSnapshot) {
              final all = allSnapshot.data ?? const [];
              final byId = {for (final s in all) s.id: s};
              final generation = computeGeneration(specimen.id, byId);
              final parents = directParentsOf(specimen, byId);
              final children = directChildrenOf(specimen.id, all);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 220,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SpecimenFormScreen(existing: specimen),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, db, specimen),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        child: Center(
                          child: SpecimenAvatar(
                            iconType: SpecimenIconType.fromValue(
                                specimen.speciesIconKey),
                            beetleFamily:
                                BeetleFamily.fromValue(specimen.beetleFamily),
                            lifeStage:
                                BeetleLifeStage.fromValue(specimen.lifeStage),
                            radius: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (specimen.name?.isNotEmpty ?? false)
                                ? specimen.name!
                                : specimen.species,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(specimen.species,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                avatar: Icon(sex.icon, size: 16),
                                label: Text(sex.label),
                              ),
                              Chip(
                                avatar: const Icon(Icons.layers_outlined, size: 16),
                                label: Text('Generation $generation'),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () =>
                                    _showStatusPicker(context, db, specimen),
                                child: Chip(
                                  backgroundColor: status
                                      .color(context)
                                      .withValues(alpha: 0.15),
                                  label: Text(status.label,
                                      style: TextStyle(
                                          color: status.color(context))),
                                  avatar: Icon(Icons.arrow_drop_down,
                                      size: 16, color: status.color(context)),
                                ),
                              ),
                              if (specimen.dateAcquired != null)
                                Chip(
                                  avatar: const Icon(Icons.event, size: 16),
                                  label: Text(DateFormat.yMMMd()
                                      .format(specimen.dateAcquired!)),
                                ),
                              Chip(
                                avatar: const Icon(Icons.cake_outlined, size: 16),
                                label: Text(
                                    _formatAge(specimen.dateOfBirth) ??
                                        'Unknown age'),
                              ),
                              if (specimen.weightGrams != null)
                                Chip(
                                  avatar:
                                      const Icon(Icons.scale_outlined, size: 16),
                                  label: Text(
                                      '${specimen.weightGrams!.toStringAsFixed(1)} g'),
                                ),
                              if (specimen.sizeMm != null)
                                Chip(
                                  avatar: const Icon(Icons.straighten, size: 16),
                                  label: Text(
                                      '${specimen.sizeMm!.toStringAsFixed(1)} mm'),
                                ),
                              if (specimen.lifeStage != null)
                                Chip(
                                  avatar: const Icon(Icons.timeline, size: 16),
                                  label: Text(BeetleLifeStage.fromValue(
                                          specimen.lifeStage)!
                                      .label),
                                ),
                            ],
                          ),
                          if (specimen.photoPath != null) ...[
                            const SizedBox(height: 20),
                            Text('Photo',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(specimen.photoPath!),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LineageScreen(specimenId: specimen.id),
                                    ),
                                  ),
                                  icon: const Icon(Icons.account_tree_outlined),
                                  label: const Text('View family tree'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _recordMeasurement(context, db, specimen),
                                  icon: const Icon(Icons.monitor_weight_outlined),
                                  label: const Text('Record weight & size'),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<List<SpecimenMeasurement>>(
                            stream: db.watchMeasurementsForSpecimen(specimen.id),
                            builder: (context, measurementSnapshot) {
                              final measurements = measurementSnapshot.data ??
                                  const <SpecimenMeasurement>[];
                              if (measurements.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  Text('Growth',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 12),
                                  GrowthChart(measurements: measurements),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          if (specimen.terrariumId != null)
                            FutureBuilder<(Terrarium, String)?>(
                              future: _loadAssignedTerrarium(
                                  db, specimen.terrariumId!),
                              builder: (context, snapshot) {
                                final data = snapshot.data;
                                if (data == null) return const SizedBox.shrink();
                                final (terrarium, label) = data;
                                return ActionChip(
                                  avatar: const Icon(
                                      Icons.crop_square_outlined,
                                      size: 16),
                                  label: Text('Terrarium: $label'),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TerrariumFormScreen(
                                          existing: terrarium),
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () async {
                                final id =
                                    await showTerrariumPickerSheet(context, db);
                                if (id != null) {
                                  await db.updateSpecimen(specimen.copyWith(
                                      terrariumId: Value(id)));
                                }
                              },
                              icon: const Icon(Icons.crop_square_outlined),
                              label: const Text('Assign to terrarium'),
                            ),
                          if (specimen.replenishIntervalDays != null) ...[
                            const SizedBox(height: 24),
                            Text('Replenish',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            if (specimen.lastReplenishedAt == null)
                              FilledButton.tonalIcon(
                                onPressed: () => db.updateSpecimen(
                                    specimen.copyWith(
                                        lastReplenishedAt:
                                            Value(DateTime.now()))),
                                icon: const Icon(Icons.water_drop_outlined),
                                label: const Text(
                                    'Start tracking (mark replenished today)'),
                              )
                            else
                              Builder(builder: (context) {
                                final daysLeft = replenishDaysLeft(specimen);
                                final due = daysLeft <= 0;
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Chip(
                                      avatar: Icon(
                                          due
                                              ? Icons.warning_amber
                                              : Icons.water_drop_outlined,
                                          size: 16),
                                      backgroundColor: due
                                          ? Theme.of(context)
                                              .colorScheme
                                              .errorContainer
                                          : null,
                                      label: Text(due
                                          ? 'Replenish now!'
                                          : '$daysLeft day${daysLeft == 1 ? '' : 's'} left'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await db.updateSpecimen(
                                            specimen.copyWith(
                                                lastReplenishedAt: Value(
                                                    DateTime.now())));
                                        await db.logActivity(
                                          type: ActivityType.replenished,
                                          title:
                                              'Replenished ${specimen.name?.isNotEmpty == true ? specimen.name! : specimen.species}',
                                          entityId: specimen.id,
                                        );
                                      },
                                      child:
                                          const Text('Mark replenished today'),
                                    ),
                                  ],
                                );
                              }),
                            if (specimen.replenishNote?.isNotEmpty ??
                                false) ...[
                              const SizedBox(height: 8),
                              Text(
                                specimen.replenishNote!,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                            ],
                          ],
                          if (specimen.notes?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 24),
                            Text('Notes',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(specimen.notes!),
                          ],
                          if (parents.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text('Parents',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ..._relativeList(context, parents),
                          ],
                          if (children.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text('Offspring (${children.length})',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ..._relativeList(context, children),
                          ],
                          const Divider(height: 32),
                          Text('Add a note',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _noteController,
                                  decoration:
                                      const InputDecoration(hintText: 'Note'),
                                  minLines: 1,
                                  maxLines: 3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () => _addNote(db),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Text('Timeline',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          StreamBuilder<List<SpecimenLogEntry>>(
                            stream:
                                db.watchLogEntriesForSpecimen(specimen.id),
                            builder: (context, logSnapshot) {
                              final notes =
                                  logSnapshot.data ?? const <SpecimenLogEntry>[];
                              return StreamBuilder<List<SpecimenMeasurement>>(
                                stream: db
                                    .watchMeasurementsForSpecimen(specimen.id),
                                builder: (context, measurementSnapshot) {
                                  final measurements =
                                      measurementSnapshot.data ??
                                          const <SpecimenMeasurement>[];
                                  final items = [
                                    for (final note in notes)
                                      _TimelineEntry.note(note),
                                    for (final m in measurements)
                                      _TimelineEntry.measurement(m),
                                  ]..sort((a, b) =>
                                      b.timestamp.compareTo(a.timestamp));
                                  if (items.isEmpty) {
                                    return const Text('No timeline entries yet.');
                                  }
                                  return Column(
                                    children: [
                                      for (final entry in items)
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(entry.icon),
                                          title: Text(entry.title),
                                          subtitle: Text(DateFormat.yMMMd()
                                              .add_jm()
                                              .format(entry.timestamp)),
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _relativeList(BuildContext context, List<Specimen> relatives) {
    return relatives
        .map((r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: SpecimenAvatar(
                  iconType: SpecimenIconType.fromValue(r.speciesIconKey),
                  beetleFamily: BeetleFamily.fromValue(r.beetleFamily),
                  lifeStage: BeetleLifeStage.fromValue(r.lifeStage),
                  radius: 18),
                title: Text(r.name?.isNotEmpty == true ? r.name! : r.species),
                subtitle: Text(r.species),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SpecimenDetailScreen(specimenId: r.id),
                  ),
                ),
              ),
            ))
        .toList();
  }

  void _showStatusPicker(
      BuildContext context, AppDatabase db, Specimen specimen) {
    final current = SpecimenStatus.fromValue(specimen.status);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            for (final status in SpecimenStatus.values)
              ListTile(
                leading: Icon(Icons.circle, color: status.color(context), size: 16),
                title: Text(status.label),
                trailing: status == current ? const Icon(Icons.check) : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  if (status == current) return;
                  await db.updateSpecimen(
                      specimen.copyWith(status: status.name));
                  await db.logActivity(
                    type: ActivityType.statusChanged,
                    title:
                        '${specimen.name?.isNotEmpty == true ? specimen.name! : specimen.species} marked ${status.label.toLowerCase()}',
                    entityId: specimen.id,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppDatabase db, Specimen specimen) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Move to bin?'),
        content: Text(
            '${specimen.name?.isNotEmpty == true ? specimen.name! : specimen.species} will be moved to the bin. '
            'You can restore it from More > Bin within 30 days, after which it is permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await db.softDeleteSpecimen(specimen.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Move to bin'),
          ),
        ],
      ),
    );
  }
}
