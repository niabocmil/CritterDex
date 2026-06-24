import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/specimen_avatar.dart';
import 'breeding_form_screen.dart';
import 'breeding_log_screen.dart';

class BreedingListScreen extends StatelessWidget {
  const BreedingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Breeding log')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BreedingFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Specimen>>(
        stream: db.watchAllSpecimens(),
        builder: (context, specimenSnapshot) {
          final byId = {
            for (final s in specimenSnapshot.data ?? const <Specimen>[])
              s.id: s
          };
          return StreamBuilder<List<BreedingEvent>>(
            stream: db.watchAllBreedingEvents(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final events = snapshot.data!;
              if (events.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No breeding events logged yet.\nTap + to log a pairing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final event = events[index];
                  final mother = byId[event.motherId];
                  final father = byId[event.fatherId];
                  final stage = BreedingStage.fromValue(event.stage);
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              BreedingLogScreen(breedingEventId: event.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SpecimenAvatar(
                                iconType: mother == null
                                    ? SpecimenIconType.other
                                    : SpecimenIconType.fromValue(
                                        mother.speciesIconKey),
                                beetleFamily: BeetleFamily.fromValue(
                                    mother?.beetleFamily),
                                lifeStage: BeetleLifeStage.fromValue(
                                    mother?.lifeStage),
                                radius: 22),
                            const SizedBox(width: 4),
                            Icon(Icons.favorite,
                                size: 16,
                                color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 4),
                            SpecimenAvatar(
                                iconType: father == null
                                    ? SpecimenIconType.other
                                    : SpecimenIconType.fromValue(
                                        father.speciesIconKey),
                                beetleFamily: BeetleFamily.fromValue(
                                    father?.beetleFamily),
                                lifeStage: BeetleLifeStage.fromValue(
                                    father?.lifeStage),
                                radius: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${mother?.name ?? mother?.species ?? 'Unknown'} '
                                    '× ${father?.name ?? father?.species ?? 'Unknown'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(DateFormat.yMMMd().format(event.date),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                  const SizedBox(height: 6),
                                  Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(stage.label,
                                        style: const TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
