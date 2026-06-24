import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show InsertMode;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';

/// Manual backup/restore, independent from Android's OS-level Auto Backup.
/// Backups are a single zip: db_backup.json (every table, with original row
/// IDs preserved so cross-table references stay valid) plus the photos/
/// directory. Import is a full replace, never a merge.
class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  Future<File> exportBackup() async {
    // Raw (unfiltered) selects here, not the deletedAt-filtered
    // getAllSpecimens()/getAllTerrariums() — a backup is meant to capture
    // everything, including anything currently sitting in the bin.
    final shelves = await db.getAllShelves();
    final terrariums = await db.select(db.terrariums).get();
    final tools = await db.getAllTools();
    final specimens = await db.select(db.specimens).get();
    final breedingEvents = await db.select(db.breedingEvents).get();
    final logEntries = await db.select(db.breedingLogEntries).get();
    final specimenLogEntries = await db.select(db.specimenLogEntries).get();

    final data = {
      'version': 1,
      'shelves': shelves.map((s) => s.toJson()).toList(),
      'terrariums': terrariums.map((t) => t.toJson()).toList(),
      'tools': tools.map((t) => t.toJson()).toList(),
      'specimens': specimens.map((s) => s.toJson()).toList(),
      'breedingEvents': breedingEvents.map((b) => b.toJson()).toList(),
      'breedingLogEntries': logEntries.map((e) => e.toJson()).toList(),
      'specimenLogEntries': specimenLogEntries.map((e) => e.toJson()).toList(),
    };

    final archive = Archive();
    final jsonBytes = utf8.encode(jsonEncode(data));
    archive.addFile(ArchiveFile('db_backup.json', jsonBytes.length, jsonBytes));

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'photos'));
    if (await photosDir.exists()) {
      for (final entity in photosDir.listSync()) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(
              'photos/${p.basename(entity.path)}', bytes.length, bytes));
        }
      }
    }

    final zipBytes = ZipEncoder().encode(archive)!;
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outFile =
        File(p.join(tempDir.path, 'critterdex_backup_$timestamp.zip'));
    await outFile.writeAsBytes(zipBytes);
    return outFile;
  }

  Future<void> shareBackup(File backupFile) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(backupFile.path)], text: 'CritterDex backup'),
    );
  }

  /// Full replace: wipes every row in dependency-safe order and re-inserts
  /// from the backup with original IDs intact, then replaces photos/.
  Future<void> importBackup(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final jsonFile = archive.files.firstWhere((f) => f.name == 'db_backup.json');
    final data = jsonDecode(utf8.decode(jsonFile.content as List<int>))
        as Map<String, dynamic>;

    final shelves = (data['shelves'] as List).cast<Map<String, dynamic>>();
    final terrariums = (data['terrariums'] as List).cast<Map<String, dynamic>>();
    // Older (pre-v3) backups won't have a 'tools' key.
    final tools =
        (data['tools'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final specimens = (data['specimens'] as List).cast<Map<String, dynamic>>();
    final breedingEvents =
        (data['breedingEvents'] as List).cast<Map<String, dynamic>>();
    final logEntries =
        (data['breedingLogEntries'] as List).cast<Map<String, dynamic>>();
    // Older (pre-v4) backups won't have a 'specimenLogEntries' key.
    final specimenLogEntries =
        (data['specimenLogEntries'] as List?)?.cast<Map<String, dynamic>>() ??
            [];

    await db.transaction(() async {
      await db.delete(db.specimenLogEntries).go();
      await db.delete(db.breedingLogEntries).go();
      await db.delete(db.breedingEvents).go();
      await db.delete(db.specimens).go();
      await db.delete(db.terrariums).go();
      await db.delete(db.tools).go();
      await db.delete(db.shelves).go();

      for (final row in shelves) {
        await db.into(db.shelves).insert(Shelf.fromJson(row), mode: InsertMode.insertOrReplace);
      }
      for (final row in terrariums) {
        await db.into(db.terrariums).insert(Terrarium.fromJson(row), mode: InsertMode.insertOrReplace);
      }
      for (final row in tools) {
        await db.into(db.tools).insert(Tool.fromJson(row), mode: InsertMode.insertOrReplace);
      }
      for (final row in specimens) {
        await db.into(db.specimens).insert(Specimen.fromJson(row), mode: InsertMode.insertOrReplace);
      }
      for (final row in breedingEvents) {
        await db.into(db.breedingEvents).insert(BreedingEvent.fromJson(row), mode: InsertMode.insertOrReplace);
      }
      for (final row in logEntries) {
        await db.into(db.breedingLogEntries).insert(BreedingLogEntry.fromJson(row), mode: InsertMode.insertOrReplace);
      }
      for (final row in specimenLogEntries) {
        await db.into(db.specimenLogEntries).insert(SpecimenLogEntry.fromJson(row), mode: InsertMode.insertOrReplace);
      }
    });

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'photos'));
    if (await photosDir.exists()) {
      await photosDir.delete(recursive: true);
    }
    await photosDir.create(recursive: true);
    for (final file in archive.files) {
      if (file.name.startsWith('photos/') && file.isFile) {
        final outPath = p.join(docsDir.path, file.name);
        final outFile = File(outPath);
        await outFile.writeAsBytes(file.content as List<int>);
      }
    }
  }
}
