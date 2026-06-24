import 'package:drift/drift.dart';

class Specimens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get species => text()();
  TextColumn get speciesIconKey => text().withDefault(const Constant('other'))();
  TextColumn get sex => text().withDefault(const Constant('unknown'))();
  DateTimeColumn get dateAcquired => dateTime().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  RealColumn get weightGrams => real().nullable()();
  RealColumn get sizeCm => real().nullable()();
  TextColumn get lifeStage => text().nullable()();
  TextColumn get beetleFamily => text().nullable()();
  IntColumn get replenishIntervalDays => integer().nullable()();
  DateTimeColumn get lastReplenishedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('alive'))();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get motherId => integer().nullable().references(Specimens, #id)();
  IntColumn get fatherId => integer().nullable().references(Specimens, #id)();
  IntColumn get terrariumId =>
      integer().nullable().references(Terrariums, #id)();
  // Not declared as a formal FK reference: Specimens already participates in
  // a self-reference (mother/father), and BreedingEvents references Specimens
  // too, so a Specimens -> BreedingEvents reference would form an illegal
  // table cycle in drift's generator. The link is still fully usable for
  // queries/joins, just without a declared REFERENCES constraint.
  IntColumn get sourceBreedingEventId => integer().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  // Soft-delete: non-null means "in the bin". Hidden from all normal
  // queries; purged for good 30 days after this is set.
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('SpecimenLogEntry')
class SpecimenLogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get specimenId => integer().references(Specimens, #id)();
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text()();
}

class BreedingEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motherId => integer().references(Specimens, #id)();
  IntColumn get fatherId => integer().references(Specimens, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get clutchSize => integer().nullable()();
  TextColumn get stage => text().withDefault(const Constant('mating'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BreedingLogEntry')
class BreedingLogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get breedingEventId =>
      integer().references(BreedingEvents, #id)();
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
  TextColumn get stageAtEntry => text().nullable()();
}

@DataClassName('Shelf')
class Shelves extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get label => text()();
  RealColumn get lengthCm => real()();
  IntColumn get levelCount => integer()();
  RealColumn get levelHeightCm => real()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Terrariums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get shape => text()(); // 'rectangular' | 'cylinder'
  RealColumn get lengthCm => real().nullable()();
  RealColumn get widthCm => real().nullable()();
  RealColumn get diameterCm => real().nullable()();
  RealColumn get heightCm => real()();
  RealColumn get volumeLitres => real()();
  IntColumn get shelfId => integer().nullable().references(Shelves, #id)();
  IntColumn get level => integer().nullable()();
  // Legacy slot index from the v2 discrete slot-grid layout. No longer
  // written by any code path — kept declared only so the one-time v3
  // migration backfill can read it via the typed query API. Use
  // [positionXCm] for all placement going forward.
  IntColumn get positionInLevel => integer().nullable()();
  RealColumn get positionXCm => real().nullable()();
  IntColumn get stackOrder => integer().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get individualSequence => integer().nullable()();
  TextColumn get purpose => text().withDefault(const Constant('general'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('Tool')
class Tools extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get lengthCm => real()();
  RealColumn get heightCm => real()();
  IntColumn get colorArgb => integer()();
  IntColumn get shelfId => integer().references(Shelves, #id)();
  IntColumn get level => integer()();
  RealColumn get positionXCm => real()();
  IntColumn get stackOrder => integer()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
