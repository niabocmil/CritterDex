import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/enums.dart';
import 'tables.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'critterdex.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [
  Specimens,
  BreedingEvents,
  BreedingLogEntries,
  Shelves,
  Terrariums,
  Tools,
  SpecimenLogEntries,
  SpecimenMeasurements,
  ActivityLogEntries,
  BreedingReminders,
  SpeciesInfos,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(shelves);
            await m.createTable(terrariums);
            await m.createTable(breedingLogEntries);
            await m.addColumn(specimens, specimens.speciesIconKey);
            await m.addColumn(specimens, specimens.dateOfBirth);
            await m.addColumn(specimens, specimens.weightGrams);
            // size_cm no longer exists on the Specimens table (see the v8
            // migration below, which converts it to size_mm), but it still
            // needs to be created here via raw SQL for anyone upgrading
            // from v1 so that v8's conversion has a column to read from.
            await customStatement('ALTER TABLE specimens ADD COLUMN size_cm REAL');
            await m.addColumn(specimens, specimens.lifeStage);
            await m.addColumn(specimens, specimens.terrariumId);
            await m.addColumn(specimens, specimens.sourceBreedingEventId);
            await m.addColumn(breedingEvents, breedingEvents.stage);
          }
          if (from < 3) {
            await m.addColumn(specimens, specimens.beetleFamily);
            await m.addColumn(specimens, specimens.replenishIntervalDays);
            await m.addColumn(specimens, specimens.lastReplenishedAt);
            await m.addColumn(terrariums, terrariums.purpose);
            await m.addColumn(terrariums, terrariums.positionXCm);
            await m.createTable(tools);
            await _backfillPositionXCm();
          }
          if (from < 4) {
            await m.addColumn(specimens, specimens.deletedAt);
            await m.addColumn(terrariums, terrariums.deletedAt);
            await m.createTable(specimenLogEntries);
          }
          if (from < 5) {
            await m.addColumn(terrariums, terrariums.supportId);
            await m.addColumn(terrariums, terrariums.supportKind);
            await m.addColumn(tools, tools.supportId);
            await m.addColumn(tools, tools.supportKind);
            await _backfillSupportTree();
          }
          if (from < 6) {
            await m.addColumn(specimens, specimens.replenishNote);
            await m.createTable(activityLogEntries);
            await m.createTable(breedingReminders);
            await _backfillActivityLog();
          }
          if (from < 7) {
            await m.createTable(speciesInfos);
            await m.addColumn(breedingEvents, breedingEvents.terrariumId);
            await m.addColumn(
                breedingEvents, breedingEvents.motherPreviousTerrariumId);
            await m.addColumn(
                breedingEvents, breedingEvents.fatherPreviousTerrariumId);
            await m.addColumn(breedingEvents, breedingEvents.failedAt);
          }
          if (from < 8) {
            await m.addColumn(specimens, specimens.sizeMm);
            // size_cm still physically exists on upgrading databases even
            // though it's no longer declared on the Specimens table above;
            // read/write it as raw SQL to convert cm -> mm.
            await customStatement(
                'UPDATE specimens SET size_mm = size_cm * 10 WHERE size_cm IS NOT NULL');
            await m.createTable(specimenMeasurements);
            await _backfillSpecimenMeasurements();
          }
          if (from < 9) {
            await m.addColumn(specimens, specimens.origin);
          }
          if (from < 10) {
            await m.addColumn(specimens, specimens.foundingGeneration);
          }
          if (from < 11) {
            await m.addColumn(speciesInfos, speciesInfos.photoPath);
            await m.addColumn(speciesInfos, speciesInfos.sourceUrl);
            await m.addColumn(speciesInfos, speciesInfos.wikiFetchedAt);
            await m.addColumn(speciesInfos, speciesInfos.createdAt);
            await _backfillSpeciesDiscoveryLedger();
          }
          if (from < 12) {
            await m.addColumn(speciesInfos, speciesInfos.gbifUrl);
          }
        },
      );

  /// One-time v2 -> v3 migration helper: replays the old discrete slot order
  /// (positionInLevel, stackOrder) as continuous x-positions so terrariums
  /// already placed on a shelf keep their relative order/footprint instead
  /// of all collapsing to x=0. positionInLevel stays declared on the table
  /// purely so this can use the normal typed query API instead of raw SQL.
  Future<void> _backfillPositionXCm() async {
    const minGapCm = 0.5;
    final placed = await (select(terrariums)
          ..where((t) =>
              t.shelfId.isNotNull() &
              t.level.isNotNull() &
              t.positionInLevel.isNotNull()))
        .get();

    final byShelfAndLevel = <String, List<Terrarium>>{};
    for (final t in placed) {
      byShelfAndLevel
          .putIfAbsent('${t.shelfId}_${t.level}', () => [])
          .add(t);
    }

    for (final levelTerrariums in byShelfAndLevel.values) {
      final byPosition = <int, List<Terrarium>>{};
      for (final t in levelTerrariums) {
        byPosition.putIfAbsent(t.positionInLevel!, () => []).add(t);
      }
      final sortedPositions = byPosition.keys.toList()..sort();
      var cursorX = 0.0;
      for (final pos in sortedPositions) {
        final column = byPosition[pos]!;
        final footprint = column
            .map((t) => t.shape == 'cylinder' ? t.diameterCm! : t.lengthCm!)
            .reduce((a, b) => a > b ? a : b);
        for (final t in column) {
          await (update(terrariums)..where((row) => row.id.equals(t.id)))
              .write(TerrariumsCompanion(positionXCm: Value(cursorX)));
        }
        cursorX += footprint + minGapCm;
      }
    }
  }

  /// One-time v4 -> v5 migration helper: converts the old shared-positionXCm
  /// "column" stacking model into the new explicit supportId/supportKind
  /// tree. The old algorithm always left-aligned a stacked item to its
  /// column's shared x (every item in a column had byte-identical
  /// positionXCm), so every non-bottom item's new *relative* offset is
  /// always exactly 0 — no arithmetic needed, just rewiring supportId.
  Future<void> _backfillSupportTree() async {
    final terrariumRows = await (select(terrariums)
          ..where((t) =>
              t.shelfId.isNotNull() &
              t.level.isNotNull() &
              t.positionXCm.isNotNull()))
        .get();
    final toolRows = await select(tools).get();

    final items = [
      for (final t in terrariumRows)
        (
          kind: 'terrarium',
          id: t.id,
          shelfId: t.shelfId!,
          level: t.level!,
          x: t.positionXCm!,
          stackOrder: t.stackOrder ?? 0,
        ),
      for (final t in toolRows)
        (
          kind: 'tool',
          id: t.id,
          shelfId: t.shelfId,
          level: t.level,
          x: t.positionXCm,
          stackOrder: t.stackOrder,
        ),
    ];

    final byShelfAndLevel = <String,
        List<
            ({
              String kind,
              int id,
              int shelfId,
              int level,
              double x,
              int stackOrder
            })>>{};
    for (final item in items) {
      byShelfAndLevel
          .putIfAbsent('${item.shelfId}_${item.level}', () => [])
          .add(item);
    }

    for (final levelItems in byShelfAndLevel.values) {
      final byX = <double,
          List<
              ({
                String kind,
                int id,
                int shelfId,
                int level,
                double x,
                int stackOrder
              })>>{};
      for (final item in levelItems) {
        byX.putIfAbsent(item.x, () => []).add(item);
      }
      for (final column in byX.values) {
        column.sort((a, b) => a.stackOrder.compareTo(b.stackOrder));
        for (var i = 1; i < column.length; i++) {
          final below = column[i - 1];
          final item = column[i];
          if (item.kind == 'terrarium') {
            await (update(terrariums)..where((row) => row.id.equals(item.id)))
                .write(TerrariumsCompanion(
              positionXCm: const Value(0.0),
              supportId: Value(below.id),
              supportKind: Value(below.kind),
            ));
          } else {
            await (update(tools)..where((row) => row.id.equals(item.id)))
                .write(ToolsCompanion(
              positionXCm: const Value(0.0),
              supportId: Value(below.id),
              supportKind: Value(below.kind),
            ));
          }
        }
      }
    }
  }

  /// One-time v5 -> v6 migration helper: seeds the new Activity Log with one
  /// entry per pre-existing specimen/terrarium/breeding event (using each
  /// row's own createdAt) so "Recently added"/"All Activities" isn't empty
  /// right after upgrading. Pre-v6 terrariums can never be distinguished as
  /// duplicates after the fact, so they all backfill as plain terrariumAdded.
  Future<void> _backfillActivityLog() async {
    final allSpecimens = await (select(specimens)
          ..where((s) => s.deletedAt.isNull()))
        .get();
    for (final s in allSpecimens) {
      await into(activityLogEntries).insert(ActivityLogEntriesCompanion.insert(
        type: ActivityType.specimenAdded.name,
        timestamp: Value(s.createdAt),
        title: 'Added ${s.name?.isNotEmpty == true ? s.name! : s.species}',
        entityId: Value(s.id),
      ));
    }
    final allTerrariums = await (select(terrariums)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    for (final t in allTerrariums) {
      await into(activityLogEntries).insert(ActivityLogEntriesCompanion.insert(
        type: ActivityType.terrariumAdded.name,
        timestamp: Value(t.createdAt),
        title: 'Added a terrarium',
        entityId: Value(t.id),
      ));
    }
    final allEvents = await select(breedingEvents).get();
    for (final e in allEvents) {
      await into(activityLogEntries).insert(ActivityLogEntriesCompanion.insert(
        type: ActivityType.breedingEventAdded.name,
        timestamp: Value(e.createdAt),
        title: 'Started a breeding log',
        entityId: Value(e.id),
      ));
    }
  }

  /// One-time v7 -> v8 migration helper: seeds one initial growth-chart
  /// point per pre-existing specimen that already had a weight and/or size
  /// recorded, using the specimen's own createdAt, so the graph isn't empty
  /// right after upgrading.
  Future<void> _backfillSpecimenMeasurements() async {
    final allSpecimens = await select(specimens).get();
    for (final s in allSpecimens) {
      if (s.weightGrams == null && s.sizeMm == null) continue;
      await into(specimenMeasurements).insert(SpecimenMeasurementsCompanion.insert(
        specimenId: s.id,
        timestamp: Value(s.createdAt),
        weightGrams: Value(s.weightGrams),
        sizeMm: Value(s.sizeMm),
      ));
    }
  }

  /// One-time v10 -> v11 migration helper: a [SpeciesInfo] row's mere
  /// existence now doubles as this app's "species already discovered"
  /// ledger (see [_discoverSpecies]). Without this backfill, every species
  /// the user already owned before upgrading would look brand new the next
  /// time any of its specimens gets saved, flooding them with "unlocked"
  /// celebrations for beetles they've had for ages. Seeds a bare row (no
  /// wiki data — that's only ever fetched at genuine discovery time) for
  /// every distinct species name that doesn't already have one.
  Future<void> _backfillSpeciesDiscoveryLedger() async {
    final existing = await select(speciesInfos).get();
    final known = existing.map((i) => i.speciesName.trim().toLowerCase()).toSet();
    final allSpecimens = await select(specimens).get();
    for (final s in allSpecimens) {
      final normalized = s.species.trim().toLowerCase();
      if (normalized.isEmpty || !known.add(normalized)) continue;
      await into(speciesInfos)
          .insert(SpeciesInfosCompanion.insert(speciesName: s.species.trim()));
    }
  }

  // ---------- Activity log ----------

  Future<void> logActivity({
    required ActivityType type,
    required String title,
    int? entityId,
    List<int>? relatedIds,
  }) async {
    await into(activityLogEntries).insert(ActivityLogEntriesCompanion.insert(
      type: type.name,
      title: title,
      entityId: Value(entityId),
      relatedIds: Value(relatedIds == null ? null : jsonEncode(relatedIds)),
    ));
  }

  Stream<List<ActivityLogEntry>> watchRecentActivity({int limit = 20}) =>
      (select(activityLogEntries)
            ..orderBy([(e) => OrderingTerm.desc(e.timestamp)])
            ..limit(limit))
          .watch();

  Stream<List<ActivityLogEntry>> watchAllActivity({bool latestFirst = true}) =>
      (select(activityLogEntries)
            ..orderBy([
              (e) => latestFirst
                  ? OrderingTerm.desc(e.timestamp)
                  : OrderingTerm.asc(e.timestamp)
            ]))
          .watch();

  // ---------- Breeding reminders ----------

  Future<int> insertBreedingReminder(BreedingRemindersCompanion entry) =>
      into(breedingReminders).insert(entry);

  Future<void> markBreedingReminderDone(int id) async {
    await (update(breedingReminders)..where((r) => r.id.equals(id)))
        .write(BreedingRemindersCompanion(completedAt: Value(DateTime.now())));
  }

  Future<int> deleteBreedingReminder(int id) =>
      (delete(breedingReminders)..where((r) => r.id.equals(id))).go();

  /// Resolves every still-active reminder for one event — used when the
  /// event itself stops needing attention (marked failed, or advanced to
  /// [BreedingStage.complete]) so stale reminders don't keep nagging.
  Future<void> markAllRemindersDoneForEvent(int breedingEventId) async {
    await (update(breedingReminders)
          ..where((r) =>
              r.breedingEventId.equals(breedingEventId) &
              r.completedAt.isNull()))
        .write(BreedingRemindersCompanion(completedAt: Value(DateTime.now())));
  }

  Stream<List<BreedingReminder>> watchActiveBreedingReminders() =>
      (select(breedingReminders)..where((r) => r.completedAt.isNull())).watch();

  Stream<List<BreedingReminder>> watchActiveRemindersForEvent(
          int breedingEventId) =>
      (select(breedingReminders)
            ..where((r) =>
                r.breedingEventId.equals(breedingEventId) &
                r.completedAt.isNull()))
          .watch();

  // ---------- Specimens ----------

  Stream<List<Specimen>> watchAllSpecimens() =>
      (select(specimens)..where((s) => s.deletedAt.isNull())).watch();

  Future<List<Specimen>> getAllSpecimens() =>
      (select(specimens)..where((s) => s.deletedAt.isNull())).get();

  Future<Specimen> getSpecimenById(int id) =>
      (select(specimens)..where((s) => s.id.equals(id))).getSingle();

  Stream<Specimen> watchSpecimenById(int id) =>
      (select(specimens)..where((s) => s.id.equals(id))).watchSingle();

  Future<List<Specimen>> getChildrenOf(int specimenId) {
    return (select(specimens)
          ..where((s) =>
              s.deletedAt.isNull() &
              (s.motherId.equals(specimenId) | s.fatherId.equals(specimenId))))
        .get();
  }

  Stream<List<Specimen>> watchSpecimensForTerrarium(int terrariumId) =>
      (select(specimens)
            ..where((s) =>
                s.terrariumId.equals(terrariumId) & s.deletedAt.isNull()))
          .watch();

  Future<int> insertSpecimen(SpecimensCompanion entry) {
    return transaction(() async {
      final id = await into(specimens).insert(entry);
      final name = entry.name.present ? entry.name.value : null;
      await logActivity(
        type: ActivityType.specimenAdded,
        title:
            'Added ${name?.isNotEmpty == true ? name! : entry.species.value}',
        entityId: id,
      );
      return id;
    });
  }

  /// One transaction, N inserts, one `specimensBatchAdded` log entry with
  /// every created id in `relatedIds` — used by batch-create flows instead
  /// of looping [insertSpecimen] (which would log one entry per specimen).
  Future<List<int>> insertSpecimensBatch(
    List<SpecimensCompanion> entries, {
    required String title,
  }) {
    return transaction(() async {
      final ids = <int>[];
      for (final entry in entries) {
        ids.add(await into(specimens).insert(entry));
      }
      await logActivity(
        type: ActivityType.specimensBatchAdded,
        title: title,
        relatedIds: ids,
      );
      return ids;
    });
  }

  Future<bool> updateSpecimen(Specimen entry) =>
      update(specimens).replace(entry);

  Future<void> softDeleteSpecimen(int id) async {
    await (update(specimens)..where((s) => s.id.equals(id)))
        .write(SpecimensCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<void> restoreSpecimen(int id) async {
    await (update(specimens)..where((s) => s.id.equals(id)))
        .write(const SpecimensCompanion(deletedAt: Value(null)));
  }

  Future<int> deleteSpecimen(int id) =>
      (delete(specimens)..where((s) => s.id.equals(id))).go();

  Stream<List<Specimen>> watchDeletedSpecimens() => (select(specimens)
        ..where((s) => s.deletedAt.isNotNull())
        ..orderBy([(s) => OrderingTerm.desc(s.deletedAt)]))
      .watch();

  // ---------- Specimen log entries ----------

  Stream<List<SpecimenLogEntry>> watchLogEntriesForSpecimen(int specimenId) {
    return (select(specimenLogEntries)
          ..where((e) => e.specimenId.equals(specimenId))
          ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
        .watch();
  }

  Future<int> insertSpecimenLogEntry(SpecimenLogEntriesCompanion entry) =>
      into(specimenLogEntries).insert(entry);

  Future<int> deleteSpecimenLogEntry(int id) =>
      (delete(specimenLogEntries)..where((e) => e.id.equals(id))).go();

  // ---------- Specimen measurements (weight/size growth) ----------

  Stream<List<SpecimenMeasurement>> watchMeasurementsForSpecimen(
      int specimenId) {
    return (select(specimenMeasurements)
          ..where((e) => e.specimenId.equals(specimenId))
          ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
        .watch();
  }

  /// Records a new weight/size measurement and mirrors it onto the
  /// specimen's own current weightGrams/sizeMm fields, so chips elsewhere in
  /// the app that show "current" values stay in sync without re-reading the
  /// measurement history.
  Future<void> recordSpecimenMeasurement(
    Specimen specimen, {
    double? weightGrams,
    double? sizeMm,
  }) async {
    await transaction(() async {
      await into(specimenMeasurements).insert(SpecimenMeasurementsCompanion.insert(
        specimenId: specimen.id,
        weightGrams: Value(weightGrams),
        sizeMm: Value(sizeMm),
      ));
      await update(specimens).replace(specimen.copyWith(
        weightGrams:
            weightGrams != null ? Value(weightGrams) : const Value.absent(),
        sizeMm: sizeMm != null ? Value(sizeMm) : const Value.absent(),
      ));
    });
  }

  /// Removes a single measurement row. Doesn't touch the specimen's mirrored
  /// current weightGrams/sizeMm — those stay as last recorded until another
  /// measurement is taken.
  Future<int> deleteSpecimenMeasurement(int id) =>
      (delete(specimenMeasurements)..where((e) => e.id.equals(id))).go();

  // ---------- Breeding events ----------

  Stream<List<BreedingEvent>> watchAllBreedingEvents() =>
      (select(breedingEvents)..orderBy([(b) => OrderingTerm.desc(b.date)]))
          .watch();

  Future<BreedingEvent> getBreedingEventById(int id) =>
      (select(breedingEvents)..where((b) => b.id.equals(id))).getSingle();

  Stream<BreedingEvent> watchBreedingEventById(int id) =>
      (select(breedingEvents)..where((b) => b.id.equals(id))).watchSingle();

  Future<List<BreedingEvent>> getBreedingEventsForPair(
      int motherId, int fatherId) {
    return (select(breedingEvents)
          ..where((b) =>
              b.motherId.equals(motherId) & b.fatherId.equals(fatherId)))
        .get();
  }

  Future<int> insertBreedingEvent(BreedingEventsCompanion entry) {
    return transaction(() async {
      final id = await into(breedingEvents).insert(entry);
      await logActivity(
        type: ActivityType.breedingEventAdded,
        title: 'Started a breeding log',
        entityId: id,
      );
      return id;
    });
  }

  Future<bool> updateBreedingEvent(BreedingEvent entry) =>
      update(breedingEvents).replace(entry);

  /// Deleting an event has no DB-level cascade (breedingReminders/
  /// breedingLogEntries reference it by id only), so this explicitly clears
  /// its dependents first — otherwise a reminder would keep showing up
  /// forever for an event that no longer exists.
  Future<int> deleteBreedingEvent(int id) {
    return transaction(() async {
      await (delete(breedingReminders)
            ..where((r) => r.breedingEventId.equals(id)))
          .go();
      await (delete(breedingLogEntries)
            ..where((e) => e.breedingEventId.equals(id)))
          .go();
      return (delete(breedingEvents)..where((b) => b.id.equals(id))).go();
    });
  }

  // ---------- Breeding log entries ----------

  Stream<List<BreedingLogEntry>> watchLogEntriesForEvent(
      int breedingEventId) {
    return (select(breedingLogEntries)
          ..where((e) => e.breedingEventId.equals(breedingEventId))
          ..orderBy([(e) => OrderingTerm.asc(e.timestamp)]))
        .watch();
  }

  Future<int> insertLogEntry(BreedingLogEntriesCompanion entry) =>
      into(breedingLogEntries).insert(entry);

  Future<int> deleteBreedingLogEntry(int id) =>
      (delete(breedingLogEntries)..where((e) => e.id.equals(id))).go();

  // ---------- Shelves ----------

  Stream<List<Shelf>> watchAllShelves() => select(shelves).watch();

  Future<List<Shelf>> getAllShelves() => select(shelves).get();

  Future<Shelf> getShelfById(int id) =>
      (select(shelves)..where((s) => s.id.equals(id))).getSingle();

  Stream<Shelf> watchShelfById(int id) =>
      (select(shelves)..where((s) => s.id.equals(id))).watchSingle();

  Future<int> insertShelf(ShelvesCompanion entry) =>
      into(shelves).insert(entry);

  Future<bool> updateShelf(Shelf entry) => update(shelves).replace(entry);

  Future<int> deleteShelf(int id) =>
      (delete(shelves)..where((s) => s.id.equals(id))).go();

  // ---------- Terrariums ----------

  Stream<List<Terrarium>> watchAllTerrariums() =>
      (select(terrariums)..where((t) => t.deletedAt.isNull())).watch();

  Future<List<Terrarium>> getAllTerrariums() =>
      (select(terrariums)..where((t) => t.deletedAt.isNull())).get();

  Future<Terrarium> getTerrariumById(int id) =>
      (select(terrariums)..where((t) => t.id.equals(id))).getSingle();

  Stream<Terrarium> watchTerrariumById(int id) =>
      (select(terrariums)..where((t) => t.id.equals(id))).watchSingle();

  Future<List<Terrarium>> getTerrariumsForShelf(int shelfId) =>
      (select(terrariums)
            ..where((t) => t.shelfId.equals(shelfId) & t.deletedAt.isNull()))
          .get();

  Stream<List<Terrarium>> watchTerrariumsForShelf(int shelfId) =>
      (select(terrariums)
            ..where((t) => t.shelfId.equals(shelfId) & t.deletedAt.isNull()))
          .watch();

  Future<int> insertTerrarium(
    TerrariumsCompanion entry, {
    ActivityType activityTypeOverride = ActivityType.terrariumAdded,
  }) {
    return transaction(() async {
      final id = await into(terrariums).insert(entry);
      await logActivity(
        type: activityTypeOverride,
        title: activityTypeOverride == ActivityType.terrariumDuplicated
            ? 'Duplicated a terrarium'
            : 'Added a terrarium',
        entityId: id,
      );
      return id;
    });
  }

  /// One transaction, N inserts, one `terrariumsBatchAdded` log entry with
  /// every created id in `relatedIds` — used by batch-create instead of
  /// looping [insertTerrarium].
  Future<List<int>> insertTerrariumsBatch(
    List<TerrariumsCompanion> entries, {
    required String title,
  }) {
    return transaction(() async {
      final ids = <int>[];
      for (final entry in entries) {
        ids.add(await into(terrariums).insert(entry));
      }
      await logActivity(
        type: ActivityType.terrariumsBatchAdded,
        title: title,
        relatedIds: ids,
      );
      return ids;
    });
  }

  Future<bool> updateTerrarium(Terrarium entry) =>
      update(terrariums).replace(entry);

  Future<void> softDeleteTerrarium(int id) async {
    await (update(terrariums)..where((t) => t.id.equals(id)))
        .write(TerrariumsCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<void> restoreTerrarium(int id) async {
    await (update(terrariums)..where((t) => t.id.equals(id)))
        .write(const TerrariumsCompanion(deletedAt: Value(null)));
  }

  /// Permanently removes a terrarium. Any specimen still pointing at it (left
  /// over from "move to bin" keeping assignments intact for a possible
  /// restore) gets unassigned first — otherwise it'd keep a dangling
  /// terrariumId that crashes the specimen detail screen's terrarium lookup
  /// and keeps surfacing stale replenish reminders for a terrarium that no
  /// longer exists.
  Future<int> deleteTerrarium(int id) {
    return transaction(() async {
      await (update(specimens)..where((s) => s.terrariumId.equals(id)))
          .write(const SpecimensCompanion(terrariumId: Value(null)));
      return (delete(terrariums)..where((t) => t.id.equals(id))).go();
    });
  }

  Stream<List<Terrarium>> watchDeletedTerrariums() => (select(terrariums)
        ..where((t) => t.deletedAt.isNotNull())
        ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
      .watch();

  Future<int> nextIndividualSequence() async {
    final query = selectOnly(terrariums)
      ..addColumns([terrariums.individualSequence.max()]);
    final row = await query.getSingleOrNull();
    final current = row?.read(terrariums.individualSequence.max()) ?? 0;
    return current + 1;
  }

  /// All specimens currently assigned to a terrarium that sits on [shelfId] —
  /// used for the shelf detail screen's replenish-today aggregate without
  /// fanning out one stream per terrarium.
  Stream<List<Specimen>> watchSpecimensForShelf(int shelfId) {
    final query = select(specimens).join([
      innerJoin(terrariums, terrariums.id.equalsExp(specimens.terrariumId)),
    ])
      ..where(terrariums.shelfId.equals(shelfId) &
          specimens.deletedAt.isNull() &
          terrariums.deletedAt.isNull());
    return query
        .watch()
        .map((rows) => rows.map((row) => row.readTable(specimens)).toList());
  }

  // ---------- Tools ----------

  Stream<List<Tool>> watchAllTools() => select(tools).watch();

  Future<List<Tool>> getAllTools() => select(tools).get();

  Future<Tool> getToolById(int id) =>
      (select(tools)..where((t) => t.id.equals(id))).getSingle();

  Stream<Tool> watchToolById(int id) =>
      (select(tools)..where((t) => t.id.equals(id))).watchSingle();

  Future<List<Tool>> getToolsForShelf(int shelfId) =>
      (select(tools)..where((t) => t.shelfId.equals(shelfId))).get();

  Stream<List<Tool>> watchToolsForShelf(int shelfId) =>
      (select(tools)..where((t) => t.shelfId.equals(shelfId))).watch();

  Future<int> insertTool(ToolsCompanion entry) => into(tools).insert(entry);

  Future<bool> updateTool(Tool entry) => update(tools).replace(entry);

  Future<int> deleteTool(int id) =>
      (delete(tools)..where((t) => t.id.equals(id))).go();

  // ---------- Species info ----------

  Future<SpeciesInfo?> getSpeciesInfo(String species) =>
      (select(speciesInfos)..where((s) => s.speciesName.equals(species)))
          .getSingleOrNull();

  Future<SpeciesInfo?> getSpeciesInfoById(int id) =>
      (select(speciesInfos)..where((s) => s.id.equals(id))).getSingleOrNull();

  Stream<SpeciesInfo?> watchSpeciesInfo(String species) =>
      (select(speciesInfos)..where((s) => s.speciesName.equals(species)))
          .watchSingleOrNull();

  Stream<List<SpeciesInfo>> watchAllSpeciesInfo() => (select(speciesInfos)
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .watch();

  /// Partial-update upsert: every field defaults to [Value.absent], meaning
  /// "leave whatever's already there alone" rather than "clear it to null".
  /// [SpeciesInfoFormScreen] passes all fields explicitly (a full-form save,
  /// its controllers are always seeded from the current row so nothing is
  /// lost); [SpeciesLookupService.fillFromWiki] only passes whichever fields
  /// this particular fetch actually found something for, safely leaving
  /// manually-entered specialNotes — and anything else the fetch came up
  /// empty on — untouched.
  Future<void> upsertSpeciesInfo(
    String species, {
    Value<String?> description = const Value.absent(),
    Value<String?> specialNotes = const Value.absent(),
    Value<String?> region = const Value.absent(),
    Value<String?> lengthRangeText = const Value.absent(),
    Value<String?> temperatureRangeText = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> gbifUrl = const Value.absent(),
    Value<DateTime?> wikiFetchedAt = const Value.absent(),
  }) async {
    final existing = await getSpeciesInfo(species);
    final companion = SpeciesInfosCompanion(
      speciesName: Value(species),
      description: description,
      specialNotes: specialNotes,
      region: region,
      lengthRangeText: lengthRangeText,
      temperatureRangeText: temperatureRangeText,
      photoPath: photoPath,
      sourceUrl: sourceUrl,
      gbifUrl: gbifUrl,
      wikiFetchedAt: wikiFetchedAt,
    );
    if (existing == null) {
      await into(speciesInfos).insert(companion);
    } else {
      await (update(speciesInfos)..where((s) => s.id.equals(existing.id)))
          .write(companion);
    }
  }

  /// A [SpeciesInfo] row's mere existence is this app's "species already
  /// discovered" ledger (see class doc on [SpeciesInfos]). If [species] has
  /// never been recorded before (case/whitespace-insensitive), this seeds
  /// its bare ledger row, logs a [ActivityType.speciesDiscovered] entry, and
  /// returns true so the caller can show the "unlocked" celebration and
  /// kick off a best-effort wiki fetch to fill the row in. Returns false
  /// (no-op) if it's already known, or if [species] is blank.
  Future<bool> discoverSpeciesIfNew(String species) async {
    final trimmed = species.trim();
    if (trimmed.isEmpty) return false;
    final normalized = trimmed.toLowerCase();
    final all = await select(speciesInfos).get();
    if (all.any((i) => i.speciesName.trim().toLowerCase() == normalized)) {
      return false;
    }
    final id = await into(speciesInfos)
        .insert(SpeciesInfosCompanion.insert(speciesName: trimmed));
    await logActivity(
      type: ActivityType.speciesDiscovered,
      title: 'Unlocked $trimmed',
      entityId: id,
    );
    return true;
  }

  // ---------- Bin ----------

  /// Hard-deletes anything that's been sitting in the bin for 30+ days.
  /// Run once on app startup — this app has no background scheduler, so
  /// "auto delete after 30 days" means "purged the next time the app opens
  /// after the 30 days have elapsed", not a real-time background job.
  Future<void> purgeExpiredBinItems() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await transaction(() async {
      await (delete(specimens)..where((s) => s.deletedAt.isSmallerThanValue(cutoff)))
          .go();
      final expiredTerrariumIds = await (select(terrariums)
            ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
          .map((t) => t.id)
          .get();
      if (expiredTerrariumIds.isNotEmpty) {
        // A surviving specimen can still point at one of these (assignments
        // are kept while a terrarium sits in the bin, for a possible
        // restore) — clear it so purging the terrarium for good doesn't
        // leave a dangling reference behind.
        await (update(specimens)
              ..where((s) => s.terrariumId.isIn(expiredTerrariumIds)))
            .write(const SpecimensCompanion(terrariumId: Value(null)));
      }
      await (delete(terrariums)..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
          .go();
    });
  }
}
