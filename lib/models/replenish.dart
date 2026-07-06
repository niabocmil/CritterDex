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

/// Terrarium ids with at least one specimen due for replenishing today.
/// Counted per terrarium, not per specimen — a terrarium with several
/// overdue specimens still counts once.
///
/// [activeTerrariumIds] should be every currently-active (non-deleted)
/// terrarium id. A specimen can keep pointing at a terrarium that's been
/// moved to the bin or purged — filtering against this set stops that stale
/// reference from resurrecting a due-count for a terrarium that's gone.
Set<int> terrariumIdsNeedingReplenish(
  List<Specimen> specimens, {
  required Set<int> activeTerrariumIds,
}) =>
    specimens
        .where(isReplenishDue)
        .map((s) => s.terrariumId)
        .whereType<int>()
        .where(activeTerrariumIds.contains)
        .toSet();
