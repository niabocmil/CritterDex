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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

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
        },
      );

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
}
