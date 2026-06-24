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
/// remaining width (and a tall-enough level) for a new item. Throws
/// [PlacementException] if nothing fits anywhere on the shelf.
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
    final columns = columnsForLevel(existingOnShelf, level);
    var cursor = 0.0;
    for (final column in columns) {
      final start = column.first.positionXCm!;
      if (start - cursor >= newFootprintWidthCm) {
        return PlacementResult(level: level, positionXCm: cursor);
      }
      final footprint =
          column.map((i) => i.footprintCm).reduce((a, b) => a > b ? a : b);
      cursor = start + footprint + minGapCm;
    }
    if (shelf.lengthCm - cursor >= newFootprintWidthCm) {
      return PlacementResult(level: level, positionXCm: cursor);
    }
  }

  throw PlacementException('Not enough space on this shelf.');
}

/// A single item's placement, as a plan to be written to the DB. [kind]
/// tells the caller whether to dispatch to updateTerrarium or updateTool.
class ShelfPlacementUpdate {
  ShelfPlacementUpdate({
    required this.kind,
    required this.id,
    required this.shelfId,
    required this.level,
    required this.positionXCm,
    required this.stackOrder,
  });
  final ShelfItemKind kind;
  final int id;
  final int shelfId;
  final int level;
  final double positionXCm;
  final int stackOrder;
}

/// Computes the full set of placement updates needed to move [moving] to
/// (targetShelf, targetLevel, targetPositionXCm), either inserting it as a
/// new column (cascading a rightward-only shift to later columns if needed)
/// or stacking it on top of [stackOnTarget]'s column. Throws [MoveException]
/// (with *nothing* written by the caller) if the move is invalid — too tall,
/// has items stacked on top of it, stacking would exceed the level height,
/// or it doesn't fit even after cascading.
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

  final stackAboveMoving = sourceShelfItems
      .where((i) =>
          !isMoving(i) &&
          i.level == moving.level &&
          i.positionXCm == moving.positionXCm &&
          (i.stackOrder ?? 0) > (moving.stackOrder ?? 0))
      .toList();
  if (stackAboveMoving.isNotEmpty) {
    throw MoveException('Move the item(s) stacked on top of this one first.');
  }

  final updates = <ShelfPlacementUpdate>[];

  if (stackOnTarget != null) {
    final column = columnsForLevel(targetShelfItems, targetLevel).firstWhere(
        (col) => col.any(
            (i) => i.id == stackOnTarget.id && i.kind == stackOnTarget.kind));
    final existingStack = column.where((i) => !isMoving(i)).toList();
    final stackHeight =
        existingStack.fold<double>(0.0, (sum, i) => sum + i.itemHeightCm);
    if (stackHeight + moving.itemHeightCm > targetShelf.levelHeightCm) {
      throw MoveException('Stacking here would exceed the level height.');
    }

    updates.add(ShelfPlacementUpdate(
      kind: moving.kind,
      id: moving.id,
      shelfId: targetShelf.id,
      level: targetLevel,
      positionXCm: column.first.positionXCm!,
      stackOrder: existingStack.length,
    ));
  } else {
    final existingColumns = columnsForLevel(targetShelfItems, targetLevel)
        .map((col) => col.where((i) => !isMoving(i)).toList())
        .where((col) => col.isNotEmpty)
        .toList();

    var movingX = targetPositionXCm.clamp(
        0.0,
        (targetShelf.lengthCm - moving.footprintCm)
            .clamp(0.0, targetShelf.lengthCm));

    var insertIndex = existingColumns.length;
    for (var i = 0; i < existingColumns.length; i++) {
      if (movingX < existingColumns[i].first.positionXCm!) {
        insertIndex = i;
        break;
      }
    }

    if (insertIndex > 0) {
      final prev = existingColumns[insertIndex - 1];
      final prevFootprint =
          prev.map((i) => i.footprintCm).reduce((a, b) => a > b ? a : b);
      final prevEnd = prev.first.positionXCm! + prevFootprint;
      if (movingX < prevEnd + minGapCm) movingX = prevEnd + minGapCm;
    }

    updates.add(ShelfPlacementUpdate(
      kind: moving.kind,
      id: moving.id,
      shelfId: targetShelf.id,
      level: targetLevel,
      positionXCm: movingX,
      stackOrder: 0,
    ));

    // Cascade a rightward-only shift to any later column the moving item's
    // new footprint now overlaps. No leftward compaction happens here, by
    // design — repeated drops into a crowded area can only grow total used
    // width over time; the user can drag items left to reclaim space.
    var lastEnd = movingX + moving.footprintCm;
    var cursor = lastEnd + minGapCm;
    for (var i = insertIndex; i < existingColumns.length; i++) {
      final col = existingColumns[i];
      final colX = col.first.positionXCm!;
      if (colX >= cursor) break;
      final colFootprint =
          col.map((it) => it.footprintCm).reduce((a, b) => a > b ? a : b);
      for (final item in col) {
        updates.add(ShelfPlacementUpdate(
          kind: item.kind,
          id: item.id,
          shelfId: targetShelf.id,
          level: targetLevel,
          positionXCm: cursor,
          stackOrder: item.stackOrder ?? 0,
        ));
      }
      lastEnd = cursor + colFootprint;
      cursor = lastEnd + minGapCm;
    }

    if (lastEnd > targetShelf.lengthCm) {
      throw MoveException('Not enough space on this level.');
    }
  }

  return updates;
}
