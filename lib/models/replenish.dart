import '../data/database.dart';

/// Days remaining until the next replenish is due, computed at display time
/// (never stored) from [Specimen.lastReplenishedAt] + replenishIntervalDays.
/// <= 0 means it's due now. Only meaningful when both fields are set.
int replenishDaysLeft(Specimen specimen) {
  final last = specimen.lastReplenishedAt!;
  final due = DateTime(last.year, last.month, last.day)
      .add(Duration(days: specimen.replenishIntervalDays!));
  final today = DateTime.now();
  final todayDateOnly = DateTime(today.year, today.month, today.day);
  return due.difference(todayDateOnly).inDays;
}

bool isReplenishDue(Specimen specimen) =>
    specimen.replenishIntervalDays != null &&
    specimen.lastReplenishedAt != null &&
    replenishDaysLeft(specimen) <= 0;
