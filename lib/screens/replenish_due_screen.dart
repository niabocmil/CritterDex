import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/replenish.dart';
import '../models/terrarium_layout.dart';
import '../widgets/specimen_avatar.dart';
import 'specimen_detail_screen.dart';

/// Lists every terrarium with at least one specimen due for replenishing
/// today. Tapping a terrarium opens a sheet listing just its due specimens,
/// each with a one-tap "mark replenished" action.
class ReplenishDueScreen extends StatelessWidget {
  const ReplenishDueScreen({super.key});

  void _showDueSpecimensSheet(BuildContext context, AppDatabase db,
      Terrarium terrarium, String label, List<Specimen> dueSpecimens) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                final remaining =
                    dueSpecimens.where((s) => !s.lastReplenishedAt.isToday).toList();

                Future<void> markAllReplenished() async {
                  final ids = <int>[];
                  await db.transaction(() async {
                    for (final s in remaining) {
                      await db.updateSpecimen(s.copyWith(
                        lastReplenishedAt: Value(DateTime.now()),
                      ));
                      ids.add(s.id);
                    }
                  });
                  if (ids.isNotEmpty) {
                    await db.logActivity(
                      type: ActivityType.replenished,
                      title: ids.length == 1
                          ? 'Replenished $label'
                          : 'Replenished ${ids.length} specimens in $label',
                      relatedIds: ids,
                    );
                  }
                  if (context.mounted) setSheetState(() {});
                }

                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('${terrarium.volumeLitres.toStringAsFixed(1)} L · ${terrarium.shape}'),
                    const Divider(height: 24),
                    if (remaining.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('All caught up for this terrarium.'),
                      )
                    else ...[
                      FilledButton.icon(
                        onPressed: markAllReplenished,
                        icon: const Icon(Icons.water_drop_outlined),
                        label: const Text('Replenished'),
                      ),
                      const SizedBox(height: 8),
                      for (final s in remaining)
                        ListTile(
                          leading: SpecimenAvatar(
                            iconType: SpecimenIconType.fromValue(s.speciesIconKey),
                            beetleFamily: BeetleFamily.fromValue(s.beetleFamily),
                            lifeStage: BeetleLifeStage.fromValue(s.lifeStage),
                          ),
                          title: Text(s.name?.isNotEmpty == true ? s.name! : s.species),
                          subtitle: Text(s.species),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  SpecimenDetailScreen(specimenId: s.id),
                            ));
                          },
                        ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('To replenish')),
      body: StreamBuilder<List<Specimen>>(
        stream: db.watchAllSpecimens(),
        builder: (context, specimenSnapshot) {
          final specimens = specimenSnapshot.data ?? const <Specimen>[];

          return StreamBuilder<List<Terrarium>>(
            stream: db.watchAllTerrariums(),
            builder: (context, terrariumSnapshot) {
              final terrariums = terrariumSnapshot.data ?? const <Terrarium>[];
              final dueTerrariumIds = terrariumIdsNeedingReplenish(specimens,
                  activeTerrariumIds: terrariums.map((t) => t.id).toSet());
              final dueTerrariums =
                  terrariums.where((t) => dueTerrariumIds.contains(t.id)).toList();

              return StreamBuilder<List<Shelf>>(
                stream: db.watchAllShelves(),
                builder: (context, shelfSnapshot) {
                  final shelves = shelfSnapshot.data ?? const <Shelf>[];

                  return StreamBuilder<List<Tool>>(
                    stream: db.watchAllTools(),
                    builder: (context, toolSnapshot) {
                      final tools = toolSnapshot.data ?? const <Tool>[];
                      final labels =
                          computeAllTerrariumLabels(shelves, terrariums, tools);
                      final shelfById = {for (final s in shelves) s.id: s};

                      if (dueTerrariums.isEmpty) {
                        return Center(
                          child: Text(
                            'Nothing due for replenishing today.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final t in dueTerrariums)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Card(
                                child: ListTile(
                                  leading: const Icon(Icons.water_drop_outlined),
                                  title: Text(labels[t.id] ?? '?'),
                                  subtitle: Text(t.shelfId == null
                                      ? 'Individual'
                                      : shelfById[t.shelfId]?.name ?? 'Shelf'),
                                  onTap: () {
                                    final dueSpecimens = specimens
                                        .where((s) =>
                                            s.terrariumId == t.id &&
                                            isReplenishDue(s))
                                        .toList();
                                    _showDueSpecimensSheet(context, db, t,
                                        labels[t.id] ?? '?', dueSpecimens);
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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

extension on DateTime? {
  /// True if this timestamp falls on today's calendar date — used to filter
  /// a just-replenished specimen out of the due sheet immediately, without
  /// waiting for the underlying stream to re-deliver a fresh snapshot.
  bool get isToday {
    final v = this;
    if (v == null) return false;
    final now = DateTime.now();
    return v.year == now.year && v.month == now.month && v.day == now.day;
  }
}
