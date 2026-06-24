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
  int? get supportId;
  String? get supportKind;
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
  int? get supportId => terrarium.supportId;
  @override
  String? get supportKind => terrarium.supportKind;
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
  int? get supportId => tool.supportId;
  @override
  String? get supportKind => tool.supportKind;
}

/// Stable identity key for a [ShelfItem], used to key maps across the
/// layout/placement/visualization code (a plain id isn't unique on its own
/// since terrarium ids and tool ids are independent sequences).
String shelfItemKey(ShelfItem item) => '${item.kind.name}_${item.id}';

/// An item's resolved position within its level, walked up through its
/// support chain. [absoluteXCm] is relative to the shelf's own left edge
/// (i.e. fully resolved, regardless of how many supports deep the item
/// rests); [topHeightCm] is the height of the item's own top surface above
/// the level floor (its support's top, plus its own height).
class ResolvedItem {
  ResolvedItem({
    required this.item,
    required this.absoluteXCm,
    required this.topHeightCm,
    required this.support,
  });
  final ShelfItem item;
  final double absoluteXCm;
  final double topHeightCm;
  final ShelfItem? support;
}

/// Resolves every item's [ResolvedItem] within one level by walking each
/// item's support chain (a support must be resolved before its dependents,
/// so this recurses and memoizes). Keyed by [shelfItemKey].
///
/// Two independent guards against a bad support chain, since this is
/// read-path code that must never hang or crash the UI on bad data: a
/// `visiting` set that throws [StateError] the instant a chain revisits a
/// node (an actual cycle — should never happen if writes are validated, so
/// loud failure here is appropriate), and a hard recursion-depth cap as
/// defense-in-depth backing up that same check. A *dangling* supportId
/// (the support no longer exists at all) is a different, survivable kind of
/// bad data — it degrades the item to resting on the floor at x=0 rather
/// than throwing.
Map<String, ResolvedItem> resolveLevelGeometry(List<ShelfItem> itemsAtLevel) {
  final byKey = {for (final i in itemsAtLevel) shelfItemKey(i): i};
  final resolved = <String, ResolvedItem>{};
  final visiting = <String>{};

  ResolvedItem resolve(ShelfItem item, int depth) {
    final key = shelfItemKey(item);
    final cached = resolved[key];
    if (cached != null) return cached;
    if (depth > itemsAtLevel.length || visiting.contains(key)) {
      throw StateError('Cycle detected in shelf support chain at $key');
    }
    visiting.add(key);

    final supportId = item.supportId;
    final supportKind = item.supportKind;
    ResolvedItem result;
    if (supportId == null || supportKind == null) {
      result = ResolvedItem(
        item: item,
        absoluteXCm: item.positionXCm ?? 0.0,
        topHeightCm: item.itemHeightCm,
        support: null,
      );
    } else {
      final support = byKey['${supportKind}_$supportId'];
      if (support == null) {
        result = ResolvedItem(
          item: item,
          absoluteXCm: 0.0,
          topHeightCm: item.itemHeightCm,
          support: null,
        );
      } else {
        final resolvedSupport = resolve(support, depth + 1);
        result = ResolvedItem(
          item: item,
          absoluteXCm: resolvedSupport.absoluteXCm + (item.positionXCm ?? 0.0),
          topHeightCm: resolvedSupport.topHeightCm + item.itemHeightCm,
          support: support,
        );
      }
    }

    visiting.remove(key);
    resolved[key] = result;
    return result;
  }

  for (final item in itemsAtLevel) {
    resolve(item, 0);
  }
  return resolved;
}

/// G for the bottom (ground) level, then 1, 2, 3... going up.
String levelDisplayLabel(int level) => level == 1 ? 'G' : '${level - 1}';

/// Dotted sibling-path label per item within one level (e.g. `2`, `2.1`,
/// `2.2` for two items side-by-side on top of floor item `2`). Floor items
/// are ordered left-to-right by their (absolute, since floor positionXCm
/// already is relative to the shelf's own edge) positionXCm; each item's
/// direct dependents are ordered the same way by their own positionXCm
/// (relative to that shared parent, so directly comparable among siblings),
/// recursively.
///
/// Moving a floor item can re-rank it relative to its siblings, which
/// renumbers its leading path component and cascades into relabeling its
/// entire subtree — expected behavior, not a bug.
Map<String, String> computePathsForLevel(List<ShelfItem> itemsAtLevel) {
  final paths = <String, String>{};

  int byPositionThenId(ShelfItem a, ShelfItem b) {
    final cmp = (a.positionXCm ?? 0.0).compareTo(b.positionXCm ?? 0.0);
    return cmp != 0 ? cmp : a.id.compareTo(b.id);
  }

  void assign(List<ShelfItem> siblings, String? parentPath) {
    final sorted = [...siblings]..sort(byPositionThenId);
    for (var i = 0; i < sorted.length; i++) {
      final item = sorted[i];
      final path = parentPath == null ? '${i + 1}' : '$parentPath.${i + 1}';
      paths[shelfItemKey(item)] = path;
      final children = itemsAtLevel
          .where((c) =>
              c.supportId == item.id && c.supportKind == item.kind.name)
          .toList();
      if (children.isNotEmpty) assign(children, path);
    }
  }

  assign(itemsAtLevel.where((i) => i.supportId == null).toList(), null);
  return paths;
}

String shelfLabelFor(Terrarium t, Shelf shelf, List<ShelfItem> allOnShelf) {
  final itemsAtLevel = allOnShelf.where((i) => i.level == t.level).toList();
  final paths = computePathsForLevel(itemsAtLevel);
  final path = paths[shelfItemKey(TerrariumShelfItem(t))] ?? '?';
  return '${shelf.label}${levelDisplayLabel(t.level!)}-$path';
}

String individualLabelFor(Terrarium t) => 'T${t.individualSequence}';

String labelFor(Terrarium t, Shelf? shelf, List<ShelfItem> allOnShelf) =>
    t.shelfId == null
        ? individualLabelFor(t)
        : shelfLabelFor(t, shelf!, allOnShelf);

/// Computes every terrarium's display label (e.g. "A1-2.1" or "T3") in one
/// pass, for pickers that need to show real labels for a whole list of
/// terrariums at once rather than one at a time.
Map<int, String> computeAllTerrariumLabels(
  List<Shelf> shelves,
  List<Terrarium> terrariums,
  List<Tool> tools,
) {
  final shelfById = {for (final s in shelves) s.id: s};
  final itemsByShelfId = <int?, List<ShelfItem>>{};
  for (final t in terrariums) {
    itemsByShelfId.putIfAbsent(t.shelfId, () => []).add(TerrariumShelfItem(t));
  }
  for (final tool in tools) {
    itemsByShelfId.putIfAbsent(tool.shelfId, () => []).add(ToolShelfItem(tool));
  }
  return {
    for (final t in terrariums)
      t.id: labelFor(
        t,
        t.shelfId == null ? null : shelfById[t.shelfId],
        itemsByShelfId[t.shelfId] ?? const [],
      ),
  };
}
