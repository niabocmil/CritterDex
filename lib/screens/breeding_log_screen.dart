import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
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

  @override
  void dispose() {
    _noteController.dispose();
    _clutchController.dispose();
    super.dispose();
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
  }

  Future<void> _addNote(AppDatabase db, BreedingEvent event) async {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    await db.insertLogEntry(BreedingLogEntriesCompanion.insert(
      breedingEventId: event.id,
      note: Value(note),
    ));
    _noteController.clear();
    setState(() {});
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
        if (_clutchController.text.isEmpty && event.clutchSize != null) {
          _clutchController.text = event.clutchSize.toString();
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
                    },
                    itemBuilder: (context) => [
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
                  if (stage.next != null)
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
