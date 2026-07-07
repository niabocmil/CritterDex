import 'package:flutter/material.dart' show DateUtils;

import '../data/database.dart';
import 'growth.dart';
import 'replenish.dart';
import 'terrarium_layout.dart';

enum ReminderSource { replenish, breeding, growth }

/// A single thing the user should pay attention to, computed at display
/// time (never stored) by merging generalized per-terrarium replenish due
/// dates with one-off [BreedingReminder] rows. Mirrors `replenish.dart`'s
/// existing "compute, don't materialize" philosophy.
class ReminderItem {
  ReminderItem({
    required this.source,
    required this.dueDate,
    required this.title,
    this.subtitle,
    required this.isMissed,
    this.terrariumId,
    this.breedingReminderId,
    this.breedingEventId,
    this.specimenId,
  });

  final ReminderSource source;
  final DateTime dueDate;
  final String title;
  final String? subtitle;

  /// True if [dueDate] is strictly before today — i.e. actually overdue, not
  /// just due today.
  final bool isMissed;

  final int? terrariumId;
  final int? breedingReminderId;
  final int? breedingEventId;
  final int? specimenId;
}

List<ReminderItem> computeReminders({
  required List<Specimen> specimens,
  required List<Terrarium> terrariums,
  required List<Shelf> shelves,
  required List<Tool> tools,
  required List<BreedingEvent> breedingEvents,
  required List<BreedingReminder> breedingReminders,
}) {
  final today = DateUtils.dateOnly(DateTime.now());
  final items = <ReminderItem>[];

  final labels = computeAllTerrariumLabels(shelves, terrariums, tools);
  // [terrariums] already excludes soft-deleted (binned) ones, so intersecting
  // against it keeps a specimen's stale terrariumId (left over from before
  // its terrarium was moved to the bin or purged) from resurrecting a
  // "Replenish ?" reminder for a terrarium that's no longer around.
  final activeTerrariumIds = terrariums.map((t) => t.id).toSet();
  final specimensByTerrarium = <int, List<Specimen>>{};
  for (final s in specimens) {
    final terrariumId = s.terrariumId;
    if (terrariumId == null ||
        !activeTerrariumIds.contains(terrariumId) ||
        !isReplenishDue(s)) {
      continue;
    }
    specimensByTerrarium.putIfAbsent(terrariumId, () => []).add(s);
  }
  for (final entry in specimensByTerrarium.entries) {
    final terrariumId = entry.key;
    final dueSpecimens = entry.value;
    final missed = dueSpecimens.any((s) => replenishDaysLeft(s) < 0);
    final label = labels[terrariumId] ?? '?';
    items.add(ReminderItem(
      source: ReminderSource.replenish,
      dueDate: today,
      title: 'Replenish $label',
      subtitle: dueSpecimens.length == 1
          ? dueSpecimens.first.species
          : '${dueSpecimens.length} specimens',
      isMissed: missed,
      terrariumId: terrariumId,
    ));
  }

  // Terrariums not yet due get a forward-looking reminder on their real
  // projected due date, so they show up in the calendar in advance instead
  // of only appearing the day they become due.
  final dueTerrariumIds = specimensByTerrarium.keys.toSet();
  final upcomingByTerrarium = <int, List<Specimen>>{};
  for (final s in specimens) {
    final terrariumId = s.terrariumId;
    if (terrariumId == null || dueTerrariumIds.contains(terrariumId)) continue;
    if (!activeTerrariumIds.contains(terrariumId)) continue;
    if (s.replenishIntervalDays == null || s.lastReplenishedAt == null) continue;
    if (isReplenishDue(s)) continue;
    upcomingByTerrarium.putIfAbsent(terrariumId, () => []).add(s);
  }
  for (final entry in upcomingByTerrarium.entries) {
    final terrariumId = entry.key;
    final candidates = entry.value;
    final soonest =
        candidates.reduce((a, b) => replenishDaysLeft(a) < replenishDaysLeft(b) ? a : b);
    final dueDate = today.add(Duration(days: replenishDaysLeft(soonest)));
    final label = labels[terrariumId] ?? '?';
    items.add(ReminderItem(
      source: ReminderSource.replenish,
      dueDate: dueDate,
      title: 'Replenish $label',
      subtitle: candidates.length == 1
          ? candidates.first.species
          : '${candidates.length} specimens',
      isMissed: false,
      terrariumId: terrariumId,
    ));
  }

  for (final s in specimens) {
    if (s.deletedAt != null || !isGrowthEntryDue(s)) continue;
    items.add(ReminderItem(
      source: ReminderSource.growth,
      dueDate: today,
      title: 'Log growth entry — ${s.name?.isNotEmpty == true ? s.name! : s.species}',
      subtitle: '${-growthEntryDaysLeft(s)} day${-growthEntryDaysLeft(s) == 1 ? '' : 's'} since last entry',
      isMissed: growthEntryDaysLeft(s) < 0,
      specimenId: s.id,
    ));
  }
  for (final s in specimens) {
    if (s.deletedAt != null) continue;
    if (s.growthReminderIntervalDays == null || s.lastGrowthEntryAt == null) continue;
    if (isGrowthEntryDue(s)) continue;
    final daysLeft = growthEntryDaysLeft(s);
    items.add(ReminderItem(
      source: ReminderSource.growth,
      dueDate: today.add(Duration(days: daysLeft)),
      title: 'Log growth entry — ${s.name?.isNotEmpty == true ? s.name! : s.species}',
      subtitle: null,
      isMissed: false,
      specimenId: s.id,
    ));
  }

  final specimensById = {for (final s in specimens) s.id: s};
  final eventsById = {for (final e in breedingEvents) e.id: e};
  for (final reminder in breedingReminders) {
    if (reminder.completedAt != null) continue;
    final event = eventsById[reminder.breedingEventId];
    final mother = event == null ? null : specimensById[event.motherId];
    final father = event == null ? null : specimensById[event.fatherId];
    final pairLabel = mother == null && father == null
        ? 'Breeding log'
        : '${mother?.name ?? mother?.species ?? 'Unknown'} × '
            '${father?.name ?? father?.species ?? 'Unknown'}';
    final dueDate = DateUtils.dateOnly(reminder.dueDate);
    items.add(ReminderItem(
      source: ReminderSource.breeding,
      dueDate: dueDate,
      title: pairLabel,
      subtitle: reminder.note,
      isMissed: dueDate.isBefore(today),
      breedingReminderId: reminder.id,
      breedingEventId: reminder.breedingEventId,
    ));
  }

  items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return items;
}
