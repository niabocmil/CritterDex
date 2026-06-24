import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/reminders.dart';
import 'breeding_log_screen.dart';
import 'replenish_due_screen.dart';

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
      _focusedDay = _view == _CalendarView.month
          ? DateUtils.addMonthsToMonthDate(_focusedDay, direction)
          : _focusedDay.add(Duration(days: 7 * direction));
    });
  }

  List<DateTime> _gridDays() {
    if (_view == _CalendarView.week) {
      final monday = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
      return [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
    }
    final firstOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final leading = firstOfMonth.weekday - 1; // Monday-first grid
    final gridStart = firstOfMonth.subtract(Duration(days: leading));
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
    return [for (var i = 0; i < totalCells; i++) gridStart.add(Duration(days: i))];
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
                        leading: Icon(item.source == ReminderSource.replenish
                            ? Icons.water_drop_outlined
                            : Icons.favorite_outline),
                        title: Text(item.title),
                        subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                        onTap: () {
                          Navigator.of(context).pop();
                          if (item.source == ReminderSource.replenish) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const ReplenishDueScreen()));
                          } else if (item.breedingEventId != null) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => BreedingLogScreen(
                                    breedingEventId: item.breedingEventId!)));
                          }
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
    final days = _gridDays();
    final today = DateUtils.dateOnly(DateTime.now());
    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedButton<_CalendarView>(
            segments: const [
              ButtonSegment(value: _CalendarView.month, label: Text('Month')),
              ButtonSegment(value: _CalendarView.week, label: Text('Week')),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left), onPressed: () => _shift(-1)),
              Text(
                _view == _CalendarView.month
                    ? MaterialLocalizations.of(context)
                        .formatMonthYear(_focusedDay)
                    : '${MaterialLocalizations.of(context).formatShortDate(days.first)} - ${MaterialLocalizations.of(context).formatShortDate(days.last)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                  icon: const Icon(Icons.chevron_right), onPressed: () => _shift(1)),
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
              for (final day in days)
                _DayCell(
                  day: day,
                  inFocusedMonth:
                      _view == _CalendarView.week || day.month == _focusedDay.month,
                  isToday: day == today,
                  items: byDay[day] ?? const [],
                  onTap: (items) => items.isEmpty
                      ? null
                      : _showDaySheet(context, day, items),
                ),
            ],
          ),
        ),
      ],
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
