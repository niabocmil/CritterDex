import '../data/database.dart';
import 'terrarium_layout.dart';

class PlacementException implements Exception {
  PlacementException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MoveException implements Exception {
  MoveException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PlacementResult {
  PlacementResult({required this.level, required this.positionXCm});
  final int level;
  final double positionXCm;
}

/// Scans the shelf's levels in order and returns the first gap with enough
/// remaining width (and a tall-enough level) for a new item, considering
/// floor items only — a freshly-placed item always lands on the floor; the
/// user stacks it manually afterwards if they want it raised.
/// Throws [PlacementException] if nothing fits anywhere on the shelf.
PlacementResult findAutoPlacement({
  required Shelf shelf,
  required double newFootprintWidthCm,
  required double newHeightCm,
  required List<ShelfItem> existingOnShelf,
}) {
  if (newHeightCm > shelf.levelHeightCm) {
    throw PlacementException("Item is too tall for this shelf's levels.");
  }

  for (var level = 1; level <= shelf.levelCount; level++) {
    final floorItems = existingOnShelf
        .where((i) => i.level == level && i.supportId == null)
        .toList()
      ..sort((a, b) => a.positionXCm!.compareTo(b.positionXCm!));

    var cursor = 0.0;
    for (final item in floorItems) {
      final start = item.positionXCm!;
      if (start - cursor >= newFootprintWidthCm) {
        return PlacementResult(level: level, positionXCm: cursor);
      }
      cursor = start + item.footprintCm + minGapCm;
    }
    if (shelf.lengthCm - cursor >= newFootprintWidthCm) {
      return PlacementResult(level: level, positionXCm: cursor);
    }
  }

  throw PlacementException('Not enough space on this shelf.');
}

/// A single item's placement, as a plan to be written to the DB. [kind]
/// tells the caller whether to dispatch to updateTerrarium or updateTool.
/// [supportId]/[supportKind] are null for an item resting on the level's
/// floor; otherwise they identify the item it now rests on.
class ShelfPlacementUpdate {
  ShelfPlacementUpdate({
    required this.kind,
    required this.id,
    required this.shelfId,
    required this.level,
    required this.positionXCm,
    required this.supportId,
    required this.supportKind,
  });
  final ShelfItemKind kind;
  final int id;
  final int shelfId;
  final int level;
  final double positionXCm;
  final int? supportId;
  final String? supportKind;
}

/// Bidirectional 1D collision resolver shared by every placement path below
/// (floor placement against other floor items at a level, or stacking
/// against a support's other dependents). [moverX]/[moverWidth] describe
/// the mover's already-clamped desired span — this function never adjusts
/// the mover itself, only [siblings] that actually overlap it (within
/// [minGapCm]), cascading further in the same direction only if that
/// creates a new overlap with the next sibling or the [minX]/[maxX]
/// boundary. A sibling that doesn't overlap is left untouched and omitted
/// from the result — which is what makes a tiny in-place nudge of the
/// mover leave its neighbors alone instead of re-snapping them.
///
/// Returns the resolved new x for every sibling that had to move, keyed by
/// [shelfItemKey]. Throws [MoveException] if a cascade would push a sibling
/// past [minX] or [maxX].
Map<String, double> resolveRow({
  required double moverX,
  required double moverWidth,
  required List<ShelfItem> siblings,
  required double minX,
  required double maxX,
}) {
  final moverEnd = moverX + moverWidth;
  final result = <String, double>{};

  final toRight = siblings.where((s) => s.positionXCm! >= moverX).toList()
    ..sort((a, b) => a.positionXCm!.compareTo(b.positionXCm!));
  var cursor = moverEnd + minGapCm;
  for (final s in toRight) {
    if (s.positionXCm! >= cursor) break;
    final newX = cursor;
    if (newX + s.footprintCm > maxX) {
      throw MoveException('Not enough space here.');
    }
    result[shelfItemKey(s)] = newX;
    cursor = newX + s.footprintCm + minGapCm;
  }

  final toLeft = siblings.where((s) => s.positionXCm! < moverX).toList()
    ..sort((a, b) => b.positionXCm!.compareTo(a.positionXCm!));
  cursor = moverX - minGapCm;
  for (final s in toLeft) {
    final sEnd = s.positionXCm! + s.footprintCm;
    if (sEnd <= cursor) break;
    final newX = cursor - s.footprintCm;
    if (newX < minX) {
      throw MoveException('Not enough space here.');
    }
    result[shelfItemKey(s)] = newX;
    cursor = newX - minGapCm;
  }

  return result;
}

/// True if [item] transitively rests on [ancestor] anywhere along its
/// support chain (within [allItems]) — used to reject a stack target that
/// would create a cycle.
bool _restsOnTransitively(
    ShelfItem item, ShelfItem ancestor, List<ShelfItem> allItems) {
  final byKey = {for (final i in allItems) shelfItemKey(i): i};
  ShelfItem? current = item;
  var depth = 0;
  while (current != null && depth <= allItems.length) {
    final supportId = current.supportId;
    final supportKind = current.supportKind;
    if (supportId == null || supportKind == null) return false;
    if (supportId == ancestor.id && supportKind == ancestor.kind.name) {
      return true;
    }
    current = byKey['${supportKind}_$supportId'];
    depth++;
  }
  return false;
}

/// Computes the full set of placement updates needed to move [moving] to
/// (targetShelf, targetLevel, targetPositionXCm), either resting it on the
/// level's floor (collision-resolved against other floor items at that
/// level) or stacking it on [stackOnTarget] (collision-resolved against
/// that support's other dependents, free to land anywhere within the
/// support's span — not forced to its left edge). Throws [MoveException]
/// (with *nothing* written by the caller) if the move is invalid — too
/// tall, has items resting on top of it, stacking would exceed the level
/// height, stacking would create a support cycle, or it doesn't fit even
/// after cascading.
///
/// [sourceShelfItems] and [targetShelfItems] are all terrariums+tools
/// currently on [moving]'s current shelf and on the target shelf
/// respectively (the same list, if it's the same shelf).
List<ShelfPlacementUpdate> planMove({
  required ShelfItem moving,
  required Shelf targetShelf,
  required int targetLevel,
  required double targetPositionXCm,
  ShelfItem? stackOnTarget,
  required List<ShelfItem> sourceShelfItems,
  required List<ShelfItem> targetShelfItems,
}) {
  if (moving.itemHeightCm > targetShelf.levelHeightCm) {
    throw MoveException("Item is too tall for this shelf's levels.");
  }

  bool isMoving(ShelfItem i) => i.id == moving.id && i.kind == moving.kind;

  final dependents = sourceShelfItems
      .where((i) =>
          !isMoving(i) &&
          i.supportId == moving.id &&
          i.supportKind == moving.kind.name)
      .toList();
  if (dependents.isNotEmpty) {
    throw MoveException('Move the item(s) resting on top of this one first.');
  }

  final updates = <ShelfPlacementUpdate>[];

  if (stackOnTarget != null) {
    if (isMoving(stackOnTarget)) {
      throw MoveException('Cannot stack an item on itself.');
    }
    if (_restsOnTransitively(stackOnTarget, moving, targetShelfItems)) {
      throw MoveException('Cannot stack an item onto something resting on it.');
    }

    final geometry = resolveLevelGeometry(
        targetShelfItems.where((i) => i.level == targetLevel).toList());
    final supportResolved = geometry[shelfItemKey(stackOnTarget)];
    if (supportResolved == null) {
      throw MoveException('Target item not found on this level.');
    }
    if (supportResolved.topHeightCm + moving.itemHeightCm >
        targetShelf.levelHeightCm) {
      throw MoveException('Stacking here would exceed the level height.');
    }

    final dependentsOfTarget = targetShelfItems
        .where((i) =>
            !isMoving(i) &&
            i.supportId == stackOnTarget.id &&
            i.supportKind == stackOnTarget.kind.name)
        .toList();

    final maxStart = stackOnTarget.footprintCm - moving.footprintCm;
    final movingX =
        targetPositionXCm.clamp(0.0, maxStart < 0 ? 0.0 : maxStart);

    final pushes = resolveRow(
      moverX: movingX,
      moverWidth: moving.footprintCm,
      siblings: dependentsOfTarget,
      minX: 0.0,
      maxX: stackOnTarget.footprintCm,
    );

    updates.add(ShelfPlacementUpdate(
      kind: moving.kind,
      id: moving.id,
      shelfId: targetShelf.id,
      level: targetLevel,
      positionXCm: movingX,
      supportId: stackOnTarget.id,
      supportKind: stackOnTarget.kind.name,
    ));
    for (final dep in dependentsOfTarget) {
      final newX = pushes[shelfItemKey(dep)];
      if (newX != null) {
        updates.add(ShelfPlacementUpdate(
          kind: dep.kind,
          id: dep.id,
          shelfId: targetShelf.id,
          level: targetLevel,
          positionXCm: newX,
          supportId: dep.supportId,
          supportKind: dep.supportKind,
        ));
      }
    }
  } else {
    final floorSiblings = targetShelfItems
        .where((i) =>
            !isMoving(i) && i.level == targetLevel && i.supportId == null)
        .toList();

    final maxStart = targetShelf.lengthCm - moving.footprintCm;
    final movingX =
        targetPositionXCm.clamp(0.0, maxStart < 0 ? 0.0 : maxStart);

    final pushes = resolveRow(
      moverX: movingX,
      moverWidth: moving.footprintCm,
      siblings: floorSiblings,
      minX: 0.0,
      maxX: targetShelf.lengthCm,
    );

    updates.add(ShelfPlacementUpdate(
      kind: moving.kind,
      id: moving.id,
      shelfId: targetShelf.id,
      level: targetLevel,
      positionXCm: movingX,
      supportId: null,
      supportKind: null,
    ));
    for (final sib in floorSiblings) {
      final newX = pushes[shelfItemKey(sib)];
      if (newX != null) {
        updates.add(ShelfPlacementUpdate(
          kind: sib.kind,
          id: sib.id,
          shelfId: targetShelf.id,
          level: targetLevel,
          positionXCm: newX,
          supportId: null,
          supportKind: null,
        ));
      }
    }
  }

  return updates;
}

/// A floor item whose position can be amended in place, used only as
/// [planDetach]'s working state for a batch of items dropping to the floor
/// at once — so each dependent in the batch sees the others' already-
/// resolved positions instead of their stale pre-detach ones.
class _BatchFloorItem implements ShelfItem {
  _BatchFloorItem(this._inner, this.positionXCm);
  final ShelfItem _inner;
  @override
  double? positionXCm;

  @override
  int get id => _inner.id;
  @override
  ShelfItemKind get kind => _inner.kind;
  @override
  double get footprintCm => _inner.footprintCm;
  @override
  double get itemHeightCm => _inner.itemHeightCm;
  @override
  int? get level => _inner.level;
  @override
  int? get supportId => null;
  @override
  String? get supportKind => null;
}

/// For the auto-detach orphan policy: when [removed] is taken off the shelf
/// (soft-deleted, or converted to an individual terrarium), its *direct*
/// dependents drop to the shelf floor at their current resolved horizontal
/// position. Grandchildren are unaffected — their position is relative to
/// their own still-existing immediate parent, so they don't need to move.
/// Dependents are resolved in left-to-right order, each collision-resolved
/// against existing floor items *and* the other dependents already placed
/// earlier in this same batch.
///
/// [shelfItems] must be the full, pre-removal item list for [removed]'s
/// shelf (including [removed] itself). Apply the returned updates in the
/// same transaction as the removal itself.
List<ShelfPlacementUpdate> planDetach({
  required ShelfItem removed,
  required Shelf shelf,
  required List<ShelfItem> shelfItems,
}) {
  final level = removed.level;
  if (level == null) return const [];

  final dependents = shelfItems
      .where((i) =>
          !(i.id == removed.id && i.kind == removed.kind) &&
          i.supportId == removed.id &&
          i.supportKind == removed.kind.name)
      .toList();
  if (dependents.isEmpty) return const [];

  final itemsAtLevel = shelfItems.where((i) => i.level == level).toList();
  final geometry = resolveLevelGeometry(itemsAtLevel);

  dependents.sort((a, b) {
    final ax = geometry[shelfItemKey(a)]?.absoluteXCm ?? 0.0;
    final bx = geometry[shelfItemKey(b)]?.absoluteXCm ?? 0.0;
    return ax.compareTo(bx);
  });

  final processedFloor = shelfItems
      .where((i) =>
          i.level == level &&
          i.supportId == null &&
          !(i.id == removed.id && i.kind == removed.kind))
      .map((i) => _BatchFloorItem(i, i.positionXCm))
      .toList();

  final updatesByKey = <String, ShelfPlacementUpdate>{};

  for (final dep in dependents) {
    final desiredX = geometry[shelfItemKey(dep)]?.absoluteXCm ?? 0.0;
    final maxStart = shelf.lengthCm - dep.footprintCm;
    final x = desiredX.clamp(0.0, maxStart < 0 ? 0.0 : maxStart);

    final pushes = resolveRow(
      moverX: x,
      moverWidth: dep.footprintCm,
      siblings: processedFloor,
      minX: 0.0,
      maxX: shelf.lengthCm,
    );

    updatesByKey[shelfItemKey(dep)] = ShelfPlacementUpdate(
      kind: dep.kind,
      id: dep.id,
      shelfId: shelf.id,
      level: level,
      positionXCm: x,
      supportId: null,
      supportKind: null,
    );
    for (final sib in processedFloor) {
      final newX = pushes[shelfItemKey(sib)];
      if (newX != null) {
        sib.positionXCm = newX;
        updatesByKey[shelfItemKey(sib)] = ShelfPlacementUpdate(
          kind: sib.kind,
          id: sib.id,
          shelfId: shelf.id,
          level: level,
          positionXCm: newX,
          supportId: null,
          supportKind: null,
        );
      }
    }
    processedFloor.add(_BatchFloorItem(dep, x));
  }

  return updatesByKey.values.toList();
}
