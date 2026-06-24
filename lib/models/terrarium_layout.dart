import '../data/database.dart';

double computeVolumeLitres({
  required String shape,
  double? lengthCm,
  double? widthCm,
  double? diameterCm,
  required double heightCm,
}) {
  const cm3PerLitre = 1000.0;
  if (shape == 'cylinder') {
    final r = diameterCm! / 2;
    return (3.141592653589793 * r * r * heightCm) / cm3PerLitre;
  }
  return (lengthCm! * widthCm! * heightCm) / cm3PerLitre;
}

/// The terrarium's horizontal extent along the shelf's length axis.
double footprintWidthCm(Terrarium t) =>
    t.shape == 'cylinder' ? t.diameterCm! : t.lengthCm!;

/// Minimum required gap (cm) between two side-by-side items on a shelf level.
const double minGapCm = 0.5;

enum ShelfItemKind { terrarium, tool }

/// Common shape shared by Terrariums and Tools so the placement/layout
/// algorithms and the shelf visualization operate once, generically, over
/// both kinds of shelf occupant.
abstract class ShelfItem {
  int get id;
  ShelfItemKind get kind;
  double get footprintCm;
  double get itemHeightCm;
  int? get level;
  double? get positionXCm;
  int? get stackOrder;
}

class TerrariumShelfItem implements ShelfItem {
  TerrariumShelfItem(this.terrarium);
  final Terrarium terrarium;

  @override
  int get id => terrarium.id;
  @override
  ShelfItemKind get kind => ShelfItemKind.terrarium;
  @override
  double get footprintCm => footprintWidthCm(terrarium);
  @override
  double get itemHeightCm => terrarium.heightCm;
  @override
  int? get level => terrarium.level;
  @override
  double? get positionXCm => terrarium.positionXCm;
  @override
  int? get stackOrder => terrarium.stackOrder;
}

class ToolShelfItem implements ShelfItem {
  ToolShelfItem(this.tool);
  final Tool tool;

  @override
  int get id => tool.id;
  @override
  ShelfItemKind get kind => ShelfItemKind.tool;
  @override
  double get footprintCm => tool.lengthCm;
  @override
  double get itemHeightCm => tool.heightCm;
  @override
  int? get level => tool.level;
  @override
  double? get positionXCm => tool.positionXCm;
  @override
  int? get stackOrder => tool.stackOrder;
}

/// Groups all items in [all] that sit on [level] into ordered columns (left
/// to right, by positionXCm); each column itself ordered bottom-to-top (by
/// stackOrder). Used both for rendering and for the move/placement
/// algorithms.
List<List<ShelfItem>> columnsForLevel(List<ShelfItem> all, int level) {
  final inLevel = all.where((i) => i.level == level).toList();
  if (inLevel.isEmpty) return [];
  final byX = <double, List<ShelfItem>>{};
  for (final item in inLevel) {
    byX.putIfAbsent(item.positionXCm!, () => []).add(item);
  }
  final sortedX = byX.keys.toList()..sort();
  return [
    for (final x in sortedX)
      byX[x]!
        ..sort((a, b) => (a.stackOrder ?? 0).compareTo(b.stackOrder ?? 0)),
  ];
}

/// G for the bottom (ground) level, then 1, 2, 3... going up.
String levelDisplayLabel(int level) => level == 1 ? 'G' : '${level - 1}';

String shelfLabelFor(Terrarium t, Shelf shelf, List<ShelfItem> allOnShelf) {
  final columns = columnsForLevel(allOnShelf, t.level!);
  final columnIndex = columns.indexWhere((col) =>
      col.any((i) => i.id == t.id && i.kind == ShelfItemKind.terrarium));
  final stackLetter = String.fromCharCode(97 + (t.stackOrder ?? 0)); // 0->'a'
  return '${shelf.label}${levelDisplayLabel(t.level!)}-${columnIndex + 1}$stackLetter';
}

String individualLabelFor(Terrarium t) => 'T${t.individualSequence}';

String labelFor(Terrarium t, Shelf? shelf, List<ShelfItem> allOnShelf) =>
    t.shelfId == null
        ? individualLabelFor(t)
        : shelfLabelFor(t, shelf!, allOnShelf);
