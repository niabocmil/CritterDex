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

/// level -> ordered list of slots; each slot -> ordered list of terrariums,
/// bottom (stackOrder 0) to top.
class ShelfLayout {
  ShelfLayout(this.levels);
  final Map<int, List<List<Terrarium>>> levels;
}

/// Groups all terrariums in [all] that sit on level [level] into ordered
/// slots (by positionInLevel), each slot itself ordered bottom-to-top (by
/// stackOrder). Used both for rendering and for the move/placement algorithms.
List<List<Terrarium>> slotsForLevel(List<Terrarium> all, int level) {
  final inLevel = all.where((t) => t.level == level).toList();
  if (inLevel.isEmpty) return [];
  final maxPos =
      inLevel.map((t) => t.positionInLevel!).reduce((a, b) => a > b ? a : b);
  final slots = <List<Terrarium>>[];
  for (var pos = 0; pos <= maxPos; pos++) {
    final slot = inLevel.where((t) => t.positionInLevel == pos).toList()
      ..sort((a, b) => a.stackOrder!.compareTo(b.stackOrder!));
    slots.add(slot);
  }
  return slots;
}

ShelfLayout buildShelfLayout(Shelf shelf, List<Terrarium> all) {
  final levels = <int, List<List<Terrarium>>>{};
  for (var lvl = 1; lvl <= shelf.levelCount; lvl++) {
    levels[lvl] = slotsForLevel(all, lvl);
  }
  return ShelfLayout(levels);
}

String shelfLabelFor(Terrarium t, Shelf shelf) {
  final stackLetter = String.fromCharCode(97 + t.stackOrder!); // 0->'a'
  return '${shelf.label}${t.level}-${t.positionInLevel! + 1}$stackLetter';
}

String individualLabelFor(Terrarium t) => 'T${t.individualSequence}';

String labelFor(Terrarium t, Shelf? shelf) =>
    t.shelfId == null ? individualLabelFor(t) : shelfLabelFor(t, shelf!);
