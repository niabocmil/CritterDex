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
  PlacementResult({required this.level, required this.positionInLevel});
  final int level;
  final int positionInLevel;
}

/// Scans the shelf's levels in order and returns the first slot with enough
/// remaining width (and a tall-enough level) for a new terrarium. Throws
/// [PlacementException] if nothing fits anywhere on the shelf.
PlacementResult findAutoPlacement({
  required Shelf shelf,
  required double newFootprintWidthCm,
  required double newHeightCm,
  required List<Terrarium> existingOnShelf,
}) {
  if (newHeightCm > shelf.levelHeightCm) {
    throw PlacementException("Terrarium is too tall for this shelf's levels.");
  }

  for (var level = 1; level <= shelf.levelCount; level++) {
    final slots = slotsForLevel(existingOnShelf, level);
    final usedWidth =
        slots.fold<double>(0.0, (sum, slot) => sum + footprintWidthCm(slot[0]));
    final remaining = shelf.lengthCm - usedWidth;
    if (remaining >= newFootprintWidthCm) {
      return PlacementResult(level: level, positionInLevel: slots.length);
    }
  }

  throw PlacementException('Not enough space on this shelf.');
}

/// A single terrarium's placement, as a plan to be written to the DB.
class TerrariumPlacementUpdate {
  TerrariumPlacementUpdate({
    required this.terrariumId,
    required this.shelfId,
    required this.level,
    required this.positionInLevel,
    required this.stackOrder,
  });
  final int terrariumId;
  final int shelfId;
  final int level;
  final int positionInLevel;
  final int stackOrder;
}

/// Computes the full set of placement updates needed to move [moving] to
/// (targetShelf, targetLevel, targetPositionInLevel), either inserting it as
/// a new slot (shifting later slots in that level) or stacking it on top of
/// whatever already occupies that slot. Throws [MoveException] (with
/// *nothing* written by the caller) if the move is invalid - too tall, has
/// stacked items on top of it, or doesn't fit after shifting.
///
/// [sourceShelfTerrariums] and [targetShelfTerrariums] are all terrariums
/// currently on [moving]'s current shelf and on the target shelf
/// respectively (the same list, if it's the same shelf).
List<TerrariumPlacementUpdate> planMove({
  required Terrarium moving,
  required Shelf targetShelf,
  required int targetLevel,
  required int targetPositionInLevel,
  required bool stackOnTarget,
  required List<Terrarium> sourceShelfTerrariums,
  required List<Terrarium> targetShelfTerrariums,
}) {
  if (moving.heightCm > targetShelf.levelHeightCm) {
    throw MoveException("Terrarium is too tall for this shelf's levels.");
  }

  final stackAboveMoving = sourceShelfTerrariums.where((t) =>
      t.id != moving.id &&
      t.level == moving.level &&
      t.positionInLevel == moving.positionInLevel &&
      t.stackOrder! > moving.stackOrder!).toList();
  if (stackAboveMoving.isNotEmpty) {
    throw MoveException(
        'Move the terrarium(s) stacked on top of this one first.');
  }

  final movingWithinSameLevel =
      moving.shelfId == targetShelf.id && moving.level == targetLevel;

  final updates = <TerrariumPlacementUpdate>[];

  if (stackOnTarget) {
    final allSlots = slotsForLevel(targetShelfTerrariums, targetLevel);
    final targetSlot = targetPositionInLevel < allSlots.length
        ? allSlots[targetPositionInLevel]
            .where((t) => t.id != moving.id)
            .toList()
        : <Terrarium>[];

    updates.add(TerrariumPlacementUpdate(
      terrariumId: moving.id,
      shelfId: targetShelf.id,
      level: targetLevel,
      positionInLevel: targetPositionInLevel,
      stackOrder: targetSlot.length,
    ));
  } else {
    var workingSlots = slotsForLevel(targetShelfTerrariums, targetLevel)
        .map((slot) => slot.where((t) => t.id != moving.id).toList())
        .where((slot) => slot.isNotEmpty)
        .toList();

    final insertIndex = targetPositionInLevel.clamp(0, workingSlots.length);
    workingSlots.insert(insertIndex, [moving]);

    final totalWidth = workingSlots.fold<double>(
        0.0, (sum, slot) => sum + footprintWidthCm(slot[0]));
    if (totalWidth > targetShelf.lengthCm) {
      throw MoveException('Not enough space on this level.');
    }

    for (var i = 0; i < workingSlots.length; i++) {
      final slot = workingSlots[i];
      for (var j = 0; j < slot.length; j++) {
        updates.add(TerrariumPlacementUpdate(
          terrariumId: slot[j].id,
          shelfId: targetShelf.id,
          level: targetLevel,
          positionInLevel: i,
          stackOrder: j,
        ));
      }
    }
  }

  // If the source slot is now empty and it's a different level/shelf than
  // the target, compact the old level's remaining slots to stay contiguous.
  if (!movingWithinSameLevel) {
    final oldLevelSlots = slotsForLevel(sourceShelfTerrariums, moving.level!)
        .map((slot) => slot.where((t) => t.id != moving.id).toList())
        .where((slot) => slot.isNotEmpty)
        .toList();
    for (var i = 0; i < oldLevelSlots.length; i++) {
      final slot = oldLevelSlots[i];
      for (var j = 0; j < slot.length; j++) {
        // Skip if this terrarium is already part of the target-level updates
        // (shouldn't happen since old level != target level here, but guard
        // against duplicate entries just in case of bad input).
        if (updates.any((u) => u.terrariumId == slot[j].id)) continue;
        updates.add(TerrariumPlacementUpdate(
          terrariumId: slot[j].id,
          shelfId: moving.shelfId!,
          level: moving.level!,
          positionInLevel: i,
          stackOrder: j,
        ));
      }
    }
  }

  return updates;
}
