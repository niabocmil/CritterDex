import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/reminders.dart';
import '../widgets/activity_tile.dart';
import 'all_activities_screen.dart';
import 'breeding_list_screen.dart';
import 'breeding_log_screen.dart';
import 'collected_species_screen.dart';
import 'reminder_calendar_screen.dart';
import 'replenish_due_screen.dart';
import 'specimen_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _recentExpanded = false;

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

          return StreamBuilder<List<Terrarium>>(
            stream: db.watchAllTerrariums(),
            builder: (context, terrariumSnapshot) {
              final terrariums = terrariumSnapshot.data ?? const <Terrarium>[];
              return StreamBuilder<List<Shelf>>(
                stream: db.watchAllShelves(),
                builder: (context, shelfSnapshot) {
                  final shelves = shelfSnapshot.data ?? const <Shelf>[];
                  return StreamBuilder<List<Tool>>(
                    stream: db.watchAllTools(),
                    builder: (context, toolSnapshot) {
                      final tools = toolSnapshot.data ?? const <Tool>[];
                      return StreamBuilder<List<BreedingEvent>>(
                        stream: db.watchAllBreedingEvents(),
                        builder: (context, eventSnapshot) {
                          final events =
                              eventSnapshot.data ?? const <BreedingEvent>[];
                          return StreamBuilder<List<BreedingReminder>>(
                            stream: db.watchActiveBreedingReminders(),
                            builder: (context, breedingReminderSnapshot) {
                              final breedingReminders =
                                  breedingReminderSnapshot.data ??
                                      const <BreedingReminder>[];
                              return StreamBuilder<List<ActivityLogEntry>>(
                                stream: db.watchRecentActivity(limit: 20),
                                builder: (context, activitySnapshot) {
                                  final recentActivity = activitySnapshot.data ??
                                      const <ActivityLogEntry>[];
                                  final visibleCount =
                                      _recentExpanded ? recentActivity.length : 4;
                                  final visible =
                                      recentActivity.take(visibleCount).toList();

                                  final reminders = computeReminders(
                                    specimens: specimens,
                                    terrariums: terrariums,
                                    shelves: shelves,
                                    tools: tools,
                                    breedingEvents: events,
                                    breedingReminders: breedingReminders,
                                  );
                                  final today =
                                      DateUtils.dateOnly(DateTime.now());
                                  final missedReplenishCount = reminders
                                      .where((r) =>
                                          r.source == ReminderSource.replenish &&
                                          r.isMissed)
                                      .length;
                                  // Replenish reminders that are due exactly
                                  // today — distinct from reminders.where(!isMissed),
                                  // which now also includes reminders projected for
                                  // a future date.
                                  final dueTodayReplenishCount = reminders
                                      .where((r) =>
                                          r.source == ReminderSource.replenish &&
                                          r.dueDate == today)
                                      .length;
                                  final missedBreeding = reminders
                                      .where((r) =>
                                          r.source == ReminderSource.breeding &&
                                          r.isMissed)
                                      .toList();
                                  final upcomingWindow =
                                      today.add(const Duration(days: 7));
                                  final upcomingCount = reminders
                                      .where((r) =>
                                          !r.isMissed &&
                                          !r.dueDate.isAfter(upcomingWindow))
                                      .length;

                                  return ListView(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 8, 16, 32),
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _StatCard(
                                              icon: Icons.pets,
                                              label: 'Specimens',
                                              value: '${specimens.length}',
                                              color: scheme.primary,
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (_) =>
                                                    const SpecimenListScreen(),
                                              )),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _StatCard(
                                              icon: Icons.favorite,
                                              label: 'Alive',
                                              value: '$alive',
                                              color: scheme.tertiary,
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (_) => const SpecimenListScreen(
                                                    initialStatusFilter:
                                                        SpecimenStatus.alive),
                                              )),
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
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (_) =>
                                                    const CollectedSpeciesScreen(),
                                              )),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _StatCard(
                                              icon: Icons.account_tree_outlined,
                                              label: 'Breeding events',
                                              value: '${events.length}',
                                              color: scheme.error,
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (_) =>
                                                    const BreedingListScreen(),
                                              )),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 28),
                                      Text('Notifications',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 12),
                                      if (missedReplenishCount > 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Card(
                                            color: scheme.errorContainer,
                                            child: ListTile(
                                              leading: Icon(Icons.error_outline,
                                                  color: scheme.error),
                                              title: Text(
                                                '$missedReplenishCount terrarium${missedReplenishCount == 1 ? '' : 's'} overdue for replenishing',
                                                style:
                                                    TextStyle(color: scheme.error),
                                              ),
                                              trailing: Icon(Icons.chevron_right,
                                                  color: scheme.error),
                                              onTap: () =>
                                                  Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        const ReplenishDueScreen()),
                                              ),
                                            ),
                                          ),
                                        ),
                                      for (final r in missedBreeding)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Card(
                                            color: scheme.errorContainer,
                                            child: ListTile(
                                              leading: Icon(Icons.error_outline,
                                                  color: scheme.error),
                                              title: Text(r.title,
                                                  style: TextStyle(
                                                      color: scheme.error)),
                                              subtitle: r.subtitle == null
                                                  ? null
                                                  : Text(r.subtitle!,
                                                      style: TextStyle(
                                                          color: scheme.error)),
                                              trailing: Icon(Icons.chevron_right,
                                                  color: scheme.error),
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (_) => BreedingLogScreen(
                                                    breedingEventId:
                                                        r.breedingEventId!),
                                              )),
                                            ),
                                          ),
                                        ),
                                      if (dueTodayReplenishCount > 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Card(
                                            child: ListTile(
                                              leading: const Icon(
                                                  Icons.water_drop_outlined),
                                              title: Text(
                                                  '$dueTodayReplenishCount terrarium${dueTodayReplenishCount == 1 ? '' : 's'} need${dueTodayReplenishCount == 1 ? 's' : ''} replenishing today'),
                                              trailing:
                                                  const Icon(Icons.chevron_right),
                                              onTap: () =>
                                                  Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        const ReplenishDueScreen()),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Card(
                                        child: ListTile(
                                          leading: const Icon(Icons.event_outlined),
                                          title: const Text('Upcoming reminders'),
                                          subtitle: Text(upcomingCount == 0
                                              ? 'Nothing due soon'
                                              : '$upcomingCount upcoming'),
                                          trailing: const Icon(Icons.chevron_right),
                                          onTap: () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const ReminderCalendarScreen())),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Text('Recently added',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 12),
                                      if (recentActivity.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 24),
                                          child: Center(
                                            child: Text(
                                              'Nothing here yet — head to the Specimens tab to add one.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: scheme.onSurfaceVariant),
                                            ),
                                          ),
                                        )
                                      else ...[
                                        for (final entry in visible)
                                          Card(
                                            margin:
                                                const EdgeInsets.only(bottom: 8),
                                            child: ActivityTile(entry: entry),
                                          ),
                                        if (!_recentExpanded &&
                                            recentActivity.length > 4)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: TextButton(
                                              onPressed: () => setState(
                                                  () => _recentExpanded = true),
                                              child: Text(
                                                  'Show ${(recentActivity.length - 4).clamp(0, 16)} more'),
                                            ),
                                          ),
                                        if (_recentExpanded)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () => setState(() =>
                                                      _recentExpanded = false),
                                                  icon: const Icon(
                                                      Icons.expand_less),
                                                  label: const Text('Show less'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const AllActivitiesScreen())),
                                                  child: const Text(
                                                      'View all activities'),
                                                ),
                                              ],
                                            ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 10),
              Text(value,
                  style:
                      const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
