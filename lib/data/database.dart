import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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

  // ---------- Specimens ----------

  Stream<List<Specimen>> watchAllSpecimens() => select(specimens).watch();

  Future<List<Specimen>> getAllSpecimens() => select(specimens).get();

  Future<Specimen> getSpecimenById(int id) =>
      (select(specimens)..where((s) => s.id.equals(id))).getSingle();

  Stream<Specimen> watchSpecimenById(int id) =>
      (select(specimens)..where((s) => s.id.equals(id))).watchSingle();

  Future<List<Specimen>> getChildrenOf(int specimenId) {
    return (select(specimens)
          ..where((s) =>
              s.motherId.equals(specimenId) | s.fatherId.equals(specimenId)))
        .get();
  }

  Stream<List<Specimen>> watchSpecimensForTerrarium(int terrariumId) =>
      (select(specimens)..where((s) => s.terrariumId.equals(terrariumId)))
          .watch();

  Future<int> insertSpecimen(SpecimensCompanion entry) =>
      into(specimens).insert(entry);

  Future<bool> updateSpecimen(Specimen entry) =>
      update(specimens).replace(entry);

  Future<int> deleteSpecimen(int id) =>
      (delete(specimens)..where((s) => s.id.equals(id))).go();

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

  Future<int> insertBreedingEvent(BreedingEventsCompanion entry) =>
      into(breedingEvents).insert(entry);

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

  Stream<List<Terrarium>> watchAllTerrariums() => select(terrariums).watch();

  Future<List<Terrarium>> getAllTerrariums() => select(terrariums).get();

  Future<Terrarium> getTerrariumById(int id) =>
      (select(terrariums)..where((t) => t.id.equals(id))).getSingle();

  Stream<Terrarium> watchTerrariumById(int id) =>
      (select(terrariums)..where((t) => t.id.equals(id))).watchSingle();

  Future<List<Terrarium>> getTerrariumsForShelf(int shelfId) =>
      (select(terrariums)..where((t) => t.shelfId.equals(shelfId))).get();

  Stream<List<Terrarium>> watchTerrariumsForShelf(int shelfId) =>
      (select(terrariums)..where((t) => t.shelfId.equals(shelfId))).watch();

  Future<int> insertTerrarium(TerrariumsCompanion entry) =>
      into(terrariums).insert(entry);

  Future<bool> updateTerrarium(Terrarium entry) =>
      update(terrariums).replace(entry);

  Future<int> deleteTerrarium(int id) =>
      (delete(terrariums)..where((t) => t.id.equals(id))).go();

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
      ..where(terrariums.shelfId.equals(shelfId));
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
}
