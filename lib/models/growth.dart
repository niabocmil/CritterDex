import '../data/database.dart';

/// Days remaining until the next growth check-in is due, computed at display
/// time (never stored) from [Specimen.lastGrowthEntryAt] +
/// growthReminderIntervalDays. <= 0 means it's due now. Only meaningful when
/// both fields are set. Mirrors replenish.dart's replenishDaysLeft.
int growthEntryDaysLeft(Specimen specimen) {
  final last = specimen.lastGrowthEntryAt!;
  final due = DateTime(last.year, last.month, last.day)
      .add(Duration(days: specimen.growthReminderIntervalDays!));
  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  return due.difference(todayDateOnly).inDays;
}

bool isGrowthEntryDue(Specimen specimen) =>
    specimen.growthReminderIntervalDays != null &&
    specimen.lastGrowthEntryAt != null &&
    growthEntryDaysLeft(specimen) <= 0;
