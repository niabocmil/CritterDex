import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/reminders.dart';
import 'breeding_log_screen.dart';
import 'replenish_due_screen.dart';
import 'specimen_detail_screen.dart';

enum _CalendarView { month, week }

/// Hand-rolled month/week grid (no calendar package in this project, and
/// every other grid UI here — e.g. the shelf visualization — is
/// hand-rolled too) marking days that have an active [ReminderItem]. Tapping
/// a day opens a sheet with that day's reminders, with a tap-through to the
/// relevant detail screen and, for breeding reminders, a "Mark done"/delete
/// action so a reminder doesn't have to stay in the calendar forever.
class ReminderCalendarScreen extends StatefulWidget {
  const ReminderCalendarScreen({super.key});

  @override
  State<ReminderCalendarScreen> createState() => _ReminderCalendarScreenState();
}

class _ReminderCalendarScreenState extends State<ReminderCalendarScreen> {
  _CalendarView _view = _CalendarView.month;
  DateTime _focusedDay = DateUtils.dateOnly(DateTime.now());

  void _shift(int direction) {
    setState(() {
      _focusedDay = DateUtils.addMonthsToMonthDate(_focusedDay, direction);
    });
  }

  List<DateTime> _gridDays() {
    final firstOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final leading = firstOfMonth.weekday - 1; // Monday-first grid
    final gridStart = firstOfMonth.subtract(Duration(days: leading));
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
    return [for (var i = 0; i < totalCells; i++) gridStart.add(Duration(days: i))];
  }

  /// Today plus the next 6 days, always anchored to "now" — unlike the
  /// month grid, the week view isn't navigable, so this never reads
  /// [_focusedDay].
  List<DateTime> _upcomingWeekDays() {
    final today = DateUtils.dateOnly(DateTime.now());
    return [for (var i = 0; i < 7; i++) today.add(Duration(days: i))];
  }

  void _showDaySheet(BuildContext context, DateTime day, List<ReminderItem> items) {
    final db = context.read<AppDatabase>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Text(MaterialLocalizations.of(context).formatMediumDate(day),
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(height: 24),
                  for (final item in items)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: item.isMissed
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                      child: ListTile(
                        leading: Icon(switch (item.source) {
                          ReminderSource.replenish => Icons.water_drop_outlined,
                          ReminderSource.growth => Icons.monitor_weight_outlined,
                          ReminderSource.breeding => Icons.favorite_outline,
                        }),
                        title: Text(item.title),
                        subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                        onTap: () {
                          Navigator.of(context).pop();
                          _openReminder(context, item);
                        },
                        trailing: item.source == ReminderSource.breeding
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline),
                                    tooltip: 'Mark done',
                                    onPressed: () async {
                                      await db.markBreedingReminderDone(
                                          item.breedingReminderId!);
                                      if (!context.mounted) return;
                                      items.remove(item);
                                      setSheetState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete',
                                    onPressed: () async {
                                      await db.deleteBreedingReminder(
                                          item.breedingReminderId!);
                                      if (!context.mounted) return;
                                      items.remove(item);
                                      setSheetState(() {});
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                ],
              );
            },
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming reminders')),
      body: StreamBuilder<List<Specimen>>(
        stream: db.watchAllSpecimens(),
        builder: (context, specimenSnapshot) {
          final specimens = specimenSnapshot.data ?? const <Specimen>[];
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
                            builder: (context, reminderSnapshot) {
                              final breedingReminders = reminderSnapshot.data ??
                                  const <BreedingReminder>[];
                              final reminders = computeReminders(
                                specimens: specimens,
                                terrariums: terrariums,
                                shelves: shelves,
                                tools: tools,
                                breedingEvents: events,
                                breedingReminders: breedingReminders,
                              );
                              final byDay = <DateTime, List<ReminderItem>>{};
                              for (final r in reminders) {
                                byDay.putIfAbsent(r.dueDate, () => []).add(r);
                              }
                              return _buildCalendar(context, byDay);
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

  Widget _buildCalendar(
      BuildContext context, Map<DateTime, List<ReminderItem>> byDay) {
    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedButton<_CalendarView>(
            segments: const [
              ButtonSegment(value: _CalendarView.week, label: Text('Week')),
              ButtonSegment(value: _CalendarView.month, label: Text('Month')),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
        ),
        if (_view == _CalendarView.month) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _shift(-1)),
                Text(
                  MaterialLocalizations.of(context).formatMonthYear(_focusedDay),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _shift(1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (final label in weekdayLabels)
                  Expanded(
                    child: Center(
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final day in _gridDays())
                  _DayCell(
                    day: day,
                    inFocusedMonth: day.month == _focusedDay.month,
                    isToday: day == DateUtils.dateOnly(DateTime.now()),
                    items: byDay[day] ?? const [],
                    onTap: (items) => items.isEmpty
                        ? null
                        : _showDaySheet(context, day, items),
                  ),
              ],
            ),
          ),
        ] else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                for (final day in _upcomingWeekDays())
                  _WeekDayRow(
                    day: day,
                    isToday: day == DateUtils.dateOnly(DateTime.now()),
                    items: byDay[day] ?? const [],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Opens the relevant detail screen for a reminder. Shared by the month
/// view's day sheet and the week view's inline rows — the day sheet pops
/// itself first since this doesn't know whether it's being called from a
/// sheet.
void _openReminder(BuildContext context, ReminderItem item) {
  if (item.source == ReminderSource.replenish) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ReplenishDueScreen()));
  } else if (item.source == ReminderSource.growth && item.specimenId != null) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SpecimenDetailScreen(specimenId: item.specimenId!)));
  } else if (item.breedingEventId != null) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            BreedingLogScreen(breedingEventId: item.breedingEventId!)));
  }
}

class _WeekDayRow extends StatelessWidget {
  const _WeekDayRow({
    required this.day,
    required this.isToday,
    required this.items,
  });

  final DateTime day;
  final bool isToday;
  final List<ReminderItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isToday ? scheme.primaryContainer.withValues(alpha: 0.3) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isToday ? BorderSide(color: scheme.primary, width: 1.5) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MaterialLocalizations.of(context).formatMediumDate(day),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : null,
                  color: isToday ? scheme.primary : null),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Text('No reminders',
                  style: TextStyle(color: scheme.onSurfaceVariant))
            else
              for (final item in items)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openReminder(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: item.isMissed ? scheme.errorContainer : scheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          switch (item.source) {
                            ReminderSource.replenish => Icons.water_drop_outlined,
                            ReminderSource.growth => Icons.monitor_weight_outlined,
                            ReminderSource.breeding => Icons.favorite_outline,
                          },
                          size: 18,
                          color: item.isMissed ? scheme.error : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: TextStyle(
                                      color: item.isMissed ? scheme.error : null)),
                              if (item.subtitle != null)
                                Text(item.subtitle!,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: item.isMissed
                                            ? scheme.error
                                            : scheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inFocusedMonth,
    required this.isToday,
    required this.items,
    required this.onTap,
  });

  final DateTime day;
  final bool inFocusedMonth;
  final bool isToday;
  final List<ReminderItem> items;
  final void Function(List<ReminderItem> items)? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasMissed = items.any((i) => i.isMissed);
    return InkWell(
      onTap: items.isEmpty ? null : () => onTap?.call(items),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: scheme.primary, width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: inFocusedMonth
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                fontWeight: isToday ? FontWeight.w700 : null,
              ),
            ),
            if (items.isNotEmpty)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasMissed ? scheme.error : scheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
