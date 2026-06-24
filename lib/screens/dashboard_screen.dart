import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/replenish.dart';
import '../widgets/specimen_card.dart';
import 'replenish_due_screen.dart';
import 'specimen_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('CritterDex')),
      body: StreamBuilder<List<Specimen>>(
        stream: db.watchAllSpecimens(),
        builder: (context, specimenSnapshot) {
          final specimens = specimenSnapshot.data ?? const <Specimen>[];
          final alive = specimens
              .where((s) => SpecimenStatus.fromValue(s.status) == SpecimenStatus.alive)
              .length;
          final speciesCount = specimens.map((s) => s.species.toLowerCase()).toSet().length;
          final recent = [...specimens]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return StreamBuilder<List<BreedingEvent>>(
            stream: db.watchAllBreedingEvents(),
            builder: (context, eventSnapshot) {
              final events = eventSnapshot.data ?? const <BreedingEvent>[];
              final replenishDueCount =
                  terrariumIdsNeedingReplenish(specimens).length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.pets,
                          label: 'Specimens',
                          value: '${specimens.length}',
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite,
                          label: 'Alive',
                          value: '$alive',
                          color: scheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.category_outlined,
                          label: 'Species',
                          value: '$speciesCount',
                          color: scheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.account_tree_outlined,
                          label: 'Breeding events',
                          value: '${events.length}',
                          color: scheme.error,
                        ),
                      ),
                    ],
                  ),
                  if (replenishDueCount > 0) ...[
                    const SizedBox(height: 28),
                    Text('Notifications',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.water_drop_outlined,
                            color: scheme.error),
                        title: Text(
                            '$replenishDueCount terrarium${replenishDueCount == 1 ? '' : 's'} need${replenishDueCount == 1 ? 's' : ''} replenishing today'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ReplenishDueScreen())),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text('Recently added', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Nothing here yet — head to the Specimens tab to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ...recent.take(5).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SpecimenCard(
                            specimen: s,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SpecimenDetailScreen(specimenId: s.id),
                              ),
                            ),
                          ),
                        )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
