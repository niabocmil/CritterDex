import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/terrarium_layout.dart';
import '../widgets/specimen_avatar.dart';
import 'specimen_form_screen.dart';

class BreedingLogScreen extends StatefulWidget {
  const BreedingLogScreen({super.key, required this.breedingEventId});

  final int breedingEventId;

  @override
  State<BreedingLogScreen> createState() => _BreedingLogScreenState();
}

class _BreedingLogScreenState extends State<BreedingLogScreen> {
  final _noteController = TextEditingController();
  final _clutchController = TextEditingController();
  final _reminderDaysController = TextEditingController();
  final _reminderNoteController = TextEditingController();
  // Tracks which event's clutchSize is currently reflected in the
  // controller, so a stream re-emission triggered by an unrelated update
  // (advancing stage, setting a reminder, ...) doesn't clobber whatever the
  // user is mid-way through typing.
  int? _clutchSyncedForEventId;

  @override
  void dispose() {
    _noteController.dispose();
    _clutchController.dispose();
    _reminderDaysController.dispose();
    _reminderNoteController.dispose();
    super.dispose();
  }

  Future<void> _setReminder(AppDatabase db, BreedingEvent event) async {
    final days = int.tryParse(_reminderDaysController.text.trim());
    if (days == null) return;
    final note = _reminderNoteController.text.trim();
    final dueDate = DateTime.now().add(Duration(days: days));
    await db.insertBreedingReminder(BreedingRemindersCompanion.insert(
      breedingEventId: event.id,
      dueDate: dueDate,
      note: Value(note.isEmpty ? null : note),
    ));
    await db.logActivity(
      type: ActivityType.breedingReminderSet,
      title: 'Reminder set for breeding log',
      entityId: event.id,
    );
    _reminderDaysController.clear();
    _reminderNoteController.clear();
    if (mounted) setState(() {});
  }

  Future<void> _advanceStage(AppDatabase db, BreedingEvent event) async {
    final stage = BreedingStage.fromValue(event.stage);
    final next = stage.next;
    if (next == null) return;
    await db.updateBreedingEvent(event.copyWith(stage: next.name));
    await db.insertLogEntry(BreedingLogEntriesCompanion.insert(
      breedingEventId: event.id,
      stageAtEntry: Value(next.name),
    ));
    if (next == BreedingStage.complete) {
      await db.markAllRemindersDoneForEvent(event.id);
    }
  }

  Future<void> _addNote(AppDatabase db, BreedingEvent event) async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    await db.insertLogEntry(BreedingLogEntriesCompanion.insert(
      breedingEventId: event.id,
      note: Value(note),
    ));
    _noteController.clear();
    if (mounted) setState(() {});
  }

  Future<void> _saveClutchSize(AppDatabase db, BreedingEvent event) async {
    final clutch = int.tryParse(_clutchController.text.trim());
    if (clutch == null) return;
    await db.updateBreedingEvent(event.copyWith(clutchSize: Value(clutch)));
    await db.insertLogEntry(BreedingLogEntriesCompanion.insert(
      breedingEventId: event.id,
      note: Value('Clutch size set to $clutch'),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Clutch size saved')));
    }
  }

  Future<void> _confirmDelete(AppDatabase db, BreedingEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete breeding event?'),
        content: const Text(
            'This permanently removes this breeding event and its timeline.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await db.deleteBreedingEvent(event.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _assignTerrarium(AppDatabase db, BreedingEvent event,
      Specimen? mother, Specimen? father) async {
    if (mother == null || father == null) return;
    final shelves = await db.getAllShelves();
    final terrariums = await db.getAllTerrariums();
    final tools = await db.getAllTools();
    final allSpecimens = await db.getAllSpecimens();
    final occupied =
        allSpecimens.map((s) => s.terrariumId).whereType<int>().toSet();
    final empty = terrariums
        .where((t) =>
            TerrariumPurpose.fromValue(t.purpose) == TerrariumPurpose.breeding &&
            !occupied.contains(t.id))
        .toList();
    final labels = computeAllTerrariumLabels(shelves, terrariums, tools);

    if (!mounted) return;
    final selectedId = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            if (empty.isEmpty) {
              return const Center(
                  child: Text('No empty breeding terrariums available.'));
            }
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Text('Assign breeding terrarium',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final t in empty)
                  ListTile(
                    leading: const Icon(Icons.crop_square_outlined),
                    title: Text(labels[t.id] ?? '—'),
                    subtitle: Text(
                        '${t.volumeLitres.toStringAsFixed(1)} L · ${t.shape}'),
                    onTap: () => Navigator.of(context).pop(t.id),
                  ),
              ],
            );
          },
        );
      },
    );
    if (selectedId == null) return;

    await db.transaction(() async {
      await db.updateBreedingEvent(event.copyWith(
        terrariumId: Value(selectedId),
        motherPreviousTerrariumId: Value(mother.terrariumId),
        fatherPreviousTerrariumId: Value(father.terrariumId),
      ));
      await db.updateSpecimen(mother.copyWith(terrariumId: Value(selectedId)));
      await db.updateSpecimen(father.copyWith(terrariumId: Value(selectedId)));
    });
  }

  Future<void> _moveParentsBack(AppDatabase db, BreedingEvent event,
      Specimen? mother, Specimen? father) async {
    await db.transaction(() async {
      if (mother != null) {
        await db.updateSpecimen(mother.copyWith(
            terrariumId: Value(event.motherPreviousTerrariumId)));
      }
      if (father != null) {
        await db.updateSpecimen(father.copyWith(
            terrariumId: Value(event.fatherPreviousTerrariumId)));
      }
      await db.updateBreedingEvent(event.copyWith(
        terrariumId: const Value(null),
        motherPreviousTerrariumId: const Value(null),
        fatherPreviousTerrariumId: const Value(null),
      ));
    });
  }

  Future<void> _markFailed(AppDatabase db, BreedingEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark breeding attempt as failed?'),
        content: const Text(
            'This marks the attempt failed and stops further stage progress. '
            'You can still view its history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Mark failed')),
        ],
      ),
    );
    if (confirmed == true) {
      await db.updateBreedingEvent(event.copyWith(failedAt: Value(DateTime.now())));
      await db.markAllRemindersDoneForEvent(event.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return StreamBuilder<BreedingEvent>(
      stream: db.watchBreedingEventById(widget.breedingEventId),
      builder: (context, eventSnapshot) {
        final event = eventSnapshot.data;
        if (event == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final stage = BreedingStage.fromValue(event.stage);
        if (_clutchSyncedForEventId != event.id) {
          _clutchController.text = event.clutchSize?.toString() ?? '';
          _clutchSyncedForEventId = event.id;
        }

        return StreamBuilder<List<Specimen>>(
          stream: db.watchAllSpecimens(),
          builder: (context, specimenSnapshot) {
            final byId = {
              for (final s in specimenSnapshot.data ?? const <Specimen>[])
                s.id: s
            };
            final mother = byId[event.motherId];
            final father = byId[event.fatherId];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Breeding log'),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'delete') _confirmDelete(db, event);
                      if (v == 'fail') _markFailed(db, event);
                    },
                    itemBuilder: (context) => [
                      if (event.failedAt == null)
                        const PopupMenuItem(
                            value: 'fail',
                            child: Text('Mark failed breeding attempt')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete event')),
                    ],
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      SpecimenAvatar(
                          iconType: mother == null
                              ? SpecimenIconType.other
                              : SpecimenIconType.fromValue(
                                  mother.speciesIconKey),
                          beetleFamily:
                              BeetleFamily.fromValue(mother?.beetleFamily),
                          lifeStage:
                              BeetleLifeStage.fromValue(mother?.lifeStage),
                          radius: 26),
                      const SizedBox(width: 8),
                      Icon(Icons.favorite,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      SpecimenAvatar(
                          iconType: father == null
                              ? SpecimenIconType.other
                              : SpecimenIconType.fromValue(
                                  father.speciesIconKey),
                          beetleFamily:
                              BeetleFamily.fromValue(father?.beetleFamily),
                          lifeStage:
                              BeetleLifeStage.fromValue(father?.lifeStage),
                          radius: 26),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${mother?.name ?? mother?.species ?? 'Unknown'} '
                              '× ${father?.name ?? father?.species ?? 'Unknown'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            Text(DateFormat.yMMMd().format(event.date),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (event.failedAt != null) ...[
                    const SizedBox(height: 12),
                    Chip(
                      avatar: Icon(Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer),
                      label: const Text('Failed breeding attempt'),
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    ),
                  ],
                  const Divider(height: 32),
                  Text('Breeding terrarium',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  if (event.terrariumId == null)
                    FilledButton.tonalIcon(
                      onPressed: () => _assignTerrarium(db, event, mother, father),
                      icon: const Icon(Icons.crop_square_outlined),
                      label: const Text('Assign breeding terrarium'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: () => _moveParentsBack(db, event, mother, father),
                      icon: const Icon(Icons.undo),
                      label: const Text('Move parents back to their terrarium'),
                    ),
                  const SizedBox(height: 20),
                  Text('Progress', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final s in BreedingStage.values)
                        Chip(
                          label: Text(s.label),
                          backgroundColor: s == stage
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (stage.next != null && event.failedAt == null)
                    FilledButton.icon(
                      onPressed: () => _advanceStage(db, event),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text('Advance to ${stage.next!.label}'),
                    ),
                  if (stage == BreedingStage.complete) ...[
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SpecimenFormScreen(
                            isBatch: true,
                            prefillSpecies: mother?.species ?? father?.species,
                            prefillIcon: mother != null
                                ? SpecimenIconType.fromValue(
                                    mother.speciesIconKey)
                                : null,
                            prefillMotherId: event.motherId,
                            prefillFatherId: event.fatherId,
                            sourceBreedingEventId: event.id,
                          ),
                        ));
                      },
                      icon: const Icon(Icons.layers_outlined),
                      label: const Text('Batch create offspring'),
                    ),
                  ],
                  const Divider(height: 32),
                  Text('Clutch size', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _clutchController,
                          decoration:
                              const InputDecoration(labelText: 'Clutch size'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _saveClutchSize(db, event),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Add a note', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(hintText: 'Note'),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _addNote(db, event),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Reminder', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _reminderDaysController,
                          decoration:
                              const InputDecoration(labelText: 'In (days)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _reminderNoteController,
                          decoration:
                              const InputDecoration(labelText: 'Note (optional)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => _setReminder(db, event),
                        child: const Text('Set'),
                      ),
                    ],
                  ),
                  StreamBuilder<List<BreedingReminder>>(
                    stream: db.watchActiveRemindersForEvent(event.id),
                    builder: (context, reminderSnapshot) {
                      final activeReminders = reminderSnapshot.data ??
                          const <BreedingReminder>[];
                      if (activeReminders.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          for (final r in activeReminders)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.notifications_outlined),
                              title: Text(DateFormat.yMMMd().format(r.dueDate)),
                              subtitle: r.note == null ? null : Text(r.note!),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline),
                                    tooltip: 'Mark done',
                                    onPressed: () =>
                                        db.markBreedingReminderDone(r.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete',
                                    onPressed: () =>
                                        db.deleteBreedingReminder(r.id),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 32),
                  Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  StreamBuilder<List<BreedingLogEntry>>(
                    stream: db.watchLogEntriesForEvent(event.id),
                    builder: (context, logSnapshot) {
                      final entries = logSnapshot.data ?? const <BreedingLogEntry>[];
                      if (entries.isEmpty) {
                        return const Text('No timeline entries yet.');
                      }
                      return Column(
                        children: [
                          for (final entry in entries.toList().reversed)
                            _TimelineTile(entry: entry),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry});

  final BreedingLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final isStageChange = entry.stageAtEntry != null;
    final label = isStageChange
        ? 'Advanced to ${BreedingStage.fromValue(entry.stageAtEntry!).label}'
        : entry.note ?? '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isStageChange ? Icons.arrow_circle_right_outlined : Icons.notes,
        color: isStageChange ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(label),
      subtitle: Text(DateFormat.yMMMd().add_jm().format(entry.timestamp)),
    );
  }
}
