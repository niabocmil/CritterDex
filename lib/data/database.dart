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
  ActivityLogEntries,
  BreedingReminders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

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
            await m.addColumn(specimens, specimens.sizeCm);
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

  Future<int> deleteBreedingEvent(int id) =>
      (delete(breedingEvents)..where((b) => b.id.equals(id))).go();

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

  Future<int> deleteTerrarium(int id) =>
      (delete(terrariums)..where((t) => t.id.equals(id))).go();

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

  // ---------- Bin ----------

  /// Hard-deletes anything that's been sitting in the bin for 30+ days.
  /// Run once on app startup — this app has no background scheduler, so
  /// "auto delete after 30 days" means "purged the next time the app opens
  /// after the 30 days have elapsed", not a real-time background job.
  Future<void> purgeExpiredBinItems() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    await (delete(specimens)..where((s) => s.deletedAt.isSmallerThanValue(cutoff)))
        .go();
    await (delete(terrariums)..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
