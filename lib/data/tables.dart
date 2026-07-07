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
  // Millimetres. Was centimetres (`size_cm`) through schema v7; v8's
  // migration backfills this from the old column via raw SQL since the
  // column itself is no longer declared here.
  RealColumn get sizeMm => real().nullable()();
  TextColumn get lifeStage => text().nullable()();
  TextColumn get beetleFamily => text().nullable()();
  IntColumn get replenishIntervalDays => integer().nullable()();
  DateTimeColumn get lastReplenishedAt => dateTime().nullable()();
  TextColumn get replenishNote => text().nullable()();
  // Per-specimen growth check-in cadence — how often the keeper wants to be
  // reminded to log a new growth entry (weight/size/life stage). Null means
  // not tracked, same nullable-pair convention as replenishIntervalDays /
  // lastReplenishedAt above.
  IntColumn get growthReminderIntervalDays => integer().nullable()();
  DateTimeColumn get lastGrowthEntryAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('alive'))();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  // Wild caught / captive bred / unknown — only meaningful when this
  // specimen has no recorded mother/father (a lineage "founder"). Descendant
  // specimens derive their WF#/CBF# lineage label from their founder
  // ancestor's origin instead of carrying their own.
  TextColumn get origin =>
      text().withDefault(const Constant('unknown'))();
  // A founder's already-known generation number, for a specimen bought or
  // given away already labelled (e.g. a friend hands over something they
  // call "CBF2"): there are no parents to record in-app, but it's not
  // actually generation 0 either. 0 for a true wild-caught individual or an
  // ordinary unlabelled founder. Ignored for non-founders, whose generation
  // is always derived from their recorded parents.
  IntColumn get foundingGeneration =>
      integer().withDefault(const Constant(0))();
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

/// One row per "record weight/size" entry for a specimen, kept forever so
/// the specimen detail page can chart growth over time. Distinct from
/// [SpecimenLogEntries] (free-text notes) even though both feed the same
/// on-screen timeline.
@DataClassName('SpecimenMeasurement')
class SpecimenMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get specimenId => integer().references(Specimens, #id)();
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get weightGrams => real().nullable()();
  RealColumn get sizeMm => real().nullable()();
  // Set only when this entry also advanced the specimen's life stage (stores
  // BeetleLifeStage.name) — mirrors BreedingLogEntries.stageAtEntry's
  // "nullable unless this entry is a stage change" convention.
  TextColumn get lifeStageAtEntry => text().nullable()();
}

class BreedingEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motherId => integer().references(Specimens, #id)();
  IntColumn get fatherId => integer().references(Specimens, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get clutchSize => integer().nullable()();
  TextColumn get stage => text().withDefault(const Constant('mating'))();
  TextColumn get notes => text().nullable()();
  // The breeding terrarium currently holding both parents, if assigned via
  // "Assign breeding terrarium". Null when no assignment is active.
  IntColumn get terrariumId =>
      integer().nullable().references(Terrariums, #id)();
  // Each parent's terrariumId captured at the moment of assignment above, so
  // "Move parents back to their terrarium" has somewhere to restore to.
  IntColumn get motherPreviousTerrariumId => integer().nullable()();
  IntColumn get fatherPreviousTerrariumId => integer().nullable()();
  // Null = not failed. Set when the user marks this breeding attempt as
  // failed — mirrors BreedingReminders.completedAt's nullable-timestamp
  // convention.
  DateTimeColumn get failedAt => dateTime().nullable()();
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
  // Legacy v3 sibling-ordinal within a shared-x "column". No longer written
  // by any code path as of v5 — kept declared only so the v4->v5 migration
  // backfill can read it via the typed query API. Use [supportId]/
  // [supportKind] for all stacking going forward.
  IntColumn get stackOrder => integer().nullable()();
  // What this terrarium rests on, if anything: null means it sits directly
  // on the shelf level's floor. Not declared with .references() — it can
  // point at either Terrariums or Tools (see [supportKind]), a polymorphic
  // reference drift can't express as a table constraint, so it's validated
  // at the app layer only (same reasoning as Specimens.sourceBreedingEventId).
  IntColumn get supportId => integer().nullable()();
  // 'terrarium' | 'tool' (matches ShelfItemKind.name) — which table
  // [supportId] points into. Null iff [supportId] is null.
  TextColumn get supportKind => text().nullable()();
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
  // Legacy v3 sibling-ordinal within a shared-x "column". No longer
  // meaningful as of v5 (use [supportId]/[supportKind] for stacking going
  // forward) — kept NOT NULL (can't relax a live SQLite NOT NULL
  // constraint without a risky table-rebuild migration) and still written
  // as 0 on every insert/update purely to satisfy that constraint.
  IntColumn get stackOrder => integer()();
  // What this tool rests on, if anything: null means it sits directly on
  // the shelf level's floor. See Terrariums.supportId for why this isn't a
  // declared .references() constraint.
  IntColumn get supportId => integer().nullable()();
  TextColumn get supportKind => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ActivityLogEntry')
class ActivityLogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // matches ActivityType.name
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get title => text()();
  IntColumn get entityId => integer().nullable()();
  // JSON-encoded list of ids for a batch entry (e.g. every specimen id
  // created in one batch-create). Null for non-batch entries. Kept as a TEXT
  // blob rather than a child table since it's only ever read back as a whole
  // list for the batch-detail screen -- no per-id querying is needed.
  TextColumn get relatedIds => text().nullable()();
}

@DataClassName('BreedingReminder')
class BreedingReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get breedingEventId =>
      integer().references(BreedingEvents, #id)();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  // Null = still active. Set when the user dismisses it via "Mark done" --
  // the breeding-reminder equivalent of replenish's lastReplenishedAt
  // update; without this, an overdue one-off reminder could never leave the
  // high-contrast "missed" state once it passed its due date.
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// Reference info about a species as a concept (not any one specimen) — one
/// row per species name. A row's mere existence is this app's "species
/// unlocked" ledger: it's created the moment the first specimen of that
/// species is ever saved (see `AppDatabase.discoverSpeciesIfNew`), which is
/// also when [description]/[region]/[lengthRangeText]/[temperatureRangeText]/
/// [photoPath]/[sourceUrl]/[gbifUrl] get a best-effort automatic fill from
/// open wiki/taxonomic lookups. [specialNotes] (care/husbandry specifics
/// with no real wiki equivalent) is the one field that stays manual-only,
/// same as before this table also became the discovery ledger.
@DataClassName('SpeciesInfo')
class SpeciesInfos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get speciesName => text()();
  TextColumn get description => text().nullable()();
  TextColumn get specialNotes => text().nullable()();
  TextColumn get region => text().nullable()();
  TextColumn get lengthRangeText => text().nullable()();
  TextColumn get temperatureRangeText => text().nullable()();
  // Locally-cached copy of the wiki's thumbnail image (same "download once,
  // store a local path" convention as Specimens.photoPath) — never re-fetched
  // automatically, only via the species page's manual "Refresh from wiki".
  TextColumn get photoPath => text().nullable()();
  // The wiki article URL the description/photo/region came from, shown as a
  // credit/attribution link (Wikipedia's CC BY-SA license expects this).
  TextColumn get sourceUrl => text().nullable()();
  // GBIF's own species page for this name (resolved via their taxonomic
  // name-match API), shown as a second reference link alongside Wikipedia.
  TextColumn get gbifUrl => text().nullable()();
  DateTimeColumn get wikiFetchedAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
