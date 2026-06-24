import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../models/enums.dart';

/// One-way, read-only export for sharing/printing — not used for restore.
class ExcelExportService {
  ExcelExportService(this.db);

  final AppDatabase db;

  Future<File> exportToExcel() async {
    final specimens = await db.getAllSpecimens();
    final breedingEvents = await db.select(db.breedingEvents).get();
    final byId = {for (final s in specimens) s.id: s};

    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();

    final specimensSheet = excel['Specimens'];
    specimensSheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Species'),
      TextCellValue('Sex'),
      TextCellValue('Status'),
      TextCellValue('Life stage'),
      TextCellValue('Beetle family'),
      TextCellValue('Replenish interval (days)'),
      TextCellValue('Last replenished'),
      TextCellValue('Weight (g)'),
      TextCellValue('Size (cm)'),
      TextCellValue('Date of birth'),
      TextCellValue('Date acquired'),
      TextCellValue('Notes'),
    ]);
    for (final s in specimens) {
      specimensSheet.appendRow([
        TextCellValue(s.name ?? ''),
        TextCellValue(s.species),
        TextCellValue(SpecimenSex.fromValue(s.sex).label),
        TextCellValue(SpecimenStatus.fromValue(s.status).label),
        TextCellValue(s.lifeStage ?? ''),
        TextCellValue(BeetleFamily.fromValue(s.beetleFamily)?.label ?? ''),
        if (s.replenishIntervalDays != null)
          IntCellValue(s.replenishIntervalDays!)
        else
          TextCellValue(''),
        TextCellValue(s.lastReplenishedAt?.toIso8601String() ?? ''),
        if (s.weightGrams != null)
          DoubleCellValue(s.weightGrams!)
        else
          TextCellValue(''),
        if (s.sizeCm != null) DoubleCellValue(s.sizeCm!) else TextCellValue(''),
        TextCellValue(s.dateOfBirth?.toIso8601String() ?? ''),
        TextCellValue(s.dateAcquired?.toIso8601String() ?? ''),
        TextCellValue(s.notes ?? ''),
      ]);
    }

    final breedingSheet = excel['Breeding Events'];
    breedingSheet.appendRow([
      TextCellValue('Mother'),
      TextCellValue('Father'),
      TextCellValue('Date'),
      TextCellValue('Stage'),
      TextCellValue('Clutch size'),
      TextCellValue('Notes'),
    ]);
    for (final b in breedingEvents) {
      final mother = byId[b.motherId];
      final father = byId[b.fatherId];
      breedingSheet.appendRow([
        TextCellValue(mother?.name ?? mother?.species ?? 'Unknown'),
        TextCellValue(father?.name ?? father?.species ?? 'Unknown'),
        TextCellValue(b.date.toIso8601String()),
        TextCellValue(BreedingStage.fromValue(b.stage).label),
        if (b.clutchSize != null)
          IntCellValue(b.clutchSize!)
        else
          TextCellValue(''),
        TextCellValue(b.notes ?? ''),
      ]);
    }

    excel.delete(defaultSheet!);

    final bytes = excel.encode()!;
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outFile =
        File(p.join(tempDir.path, 'critterdex_export_$timestamp.xlsx'));
    await outFile.writeAsBytes(bytes);
    return outFile;
  }

  Future<void> shareExcel(File excelFile) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(excelFile.path)], text: 'CritterDex export'),
    );
  }
}
