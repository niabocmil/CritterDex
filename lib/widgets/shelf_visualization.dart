import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';
import 'terrarium_slot.dart';

typedef TerrariumMoveCallback = Future<void> Function({
  required Terrarium moving,
  required int targetLevel,
  required int targetPositionInLevel,
  required bool stackOnTarget,
});

class ShelfVisualization extends StatefulWidget {
  const ShelfVisualization({
    super.key,
    required this.shelf,
    required this.terrariums,
    required this.onMove,
    required this.onTapTerrarium,
  });

  final Shelf shelf;
  final List<Terrarium> terrariums;
  final TerrariumMoveCallback onMove;
  final ValueChanged<Terrarium> onTapTerrarium;

  @override
  State<ShelfVisualization> createState() => _ShelfVisualizationState();
}

class _ShelfVisualizationState extends State<ShelfVisualization> {
  final GlobalKey _canvasKey = GlobalKey();
  int? _draggingId;
  Offset? _dragLocalPosition;

  Offset? _globalToLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      final scale = constraints.maxWidth / widget.shelf.lengthCm;
      final layout = buildShelfLayout(widget.shelf, widget.terrariums);
      final geo = _computeGeometry(widget.shelf, layout, scale);
      final byId = {for (final t in widget.terrariums) t.id: t};
      final draggingTerrarium =
          _draggingId != null ? byId[_draggingId] : null;
      final draggingRect =
          _draggingId != null ? geo.rects[_draggingId] : null;

      return SizedBox(
        width: geo.totalWidthPx,
        height: geo.totalHeightPx,
        child: Stack(
          key: _canvasKey,
          clipBehavior: Clip.none,
          children: [
            for (final entry in geo.levelRowRects.entries)
              Positioned.fromRect(
                rect: entry.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                ),
              ),
            for (final entry in geo.rects.entries)
              if (entry.key != _draggingId)
                Positioned.fromRect(
                  rect: entry.value,
                  child:
                      _buildSlotGesture(byId[entry.key]!, geo, widget.shelf),
                ),
            if (draggingTerrarium != null &&
                _dragLocalPosition != null &&
                draggingRect != null)
              Positioned(
                left: _dragLocalPosition!.dx - draggingRect.width / 2,
                top: _dragLocalPosition!.dy - draggingRect.height / 2,
                width: draggingRect.width,
                height: draggingRect.height,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.85,
                    child: TerrariumSlot(
                      terrarium: draggingTerrarium,
                      label: labelFor(draggingTerrarium, widget.shelf),
                      isGhost: true,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSlotGesture(
      Terrarium terrarium, _TerrariumGeometry geo, Shelf shelf) {
    return GestureDetector(
      onTap: () => widget.onTapTerrarium(terrarium),
      onLongPressStart: (details) {
        setState(() {
          _draggingId = terrarium.id;
          _dragLocalPosition = _globalToLocal(details.globalPosition);
        });
      },
      onLongPressMoveUpdate: (details) {
        setState(
            () => _dragLocalPosition = _globalToLocal(details.globalPosition));
      },
      onLongPressEnd: (details) {
        final local = _dragLocalPosition;
        setState(() {
          _draggingId = null;
          _dragLocalPosition = null;
        });
        if (local == null) return;
        final target = _hitTest(geo, local);
        if (target == null) return; // dropped outside any level: cancel
        widget.onMove(
          moving: terrarium,
          targetLevel: target.level,
          targetPositionInLevel: target.positionInLevel,
          stackOnTarget: target.stack,
        );
      },
      child: TerrariumSlot(terrarium: terrarium, label: labelFor(terrarium, shelf)),
    );
  }
}

class _TerrariumGeometry {
  _TerrariumGeometry({
    required this.rects,
    required this.levelRowRects,
    required this.levelSlotColumnRects,
    required this.totalWidthPx,
    required this.totalHeightPx,
  });

  final Map<int, Rect> rects;
  final Map<int, Rect> levelRowRects;
  final Map<int, List<Rect>> levelSlotColumnRects;
  final double totalWidthPx;
  final double totalHeightPx;
}

const _levelGapPx = 14.0;

_TerrariumGeometry _computeGeometry(
    Shelf shelf, ShelfLayout layout, double scale) {
  final rects = <int, Rect>{};
  final levelRowRects = <int, Rect>{};
  final levelSlotColumnRects = <int, List<Rect>>{};
  final rowWidthPx = shelf.lengthCm * scale;
  final rowHeightPx = shelf.levelHeightCm * scale;

  var cursorY = 0.0;
  for (var level = 1; level <= shelf.levelCount; level++) {
    final rowTop = cursorY;
    levelRowRects[level] = Rect.fromLTWH(0, rowTop, rowWidthPx, rowHeightPx);

    final slots = layout.levels[level] ?? const [];
    var cursorX = 0.0;
    final slotColumns = <Rect>[];
    for (final slot in slots) {
      final widthPx = footprintWidthCm(slot[0]) * scale;
      slotColumns.add(Rect.fromLTWH(cursorX, rowTop, widthPx, rowHeightPx));

      var heightFromBottom = 0.0;
      for (final terrarium in slot) {
        final hPx = terrarium.heightCm * scale;
        final bottom = rowTop + rowHeightPx - heightFromBottom;
        rects[terrarium.id] = Rect.fromLTWH(cursorX, bottom - hPx, widthPx, hPx);
        heightFromBottom += hPx;
      }

      cursorX += widthPx;
    }
    levelSlotColumnRects[level] = slotColumns;
    cursorY += rowHeightPx + _levelGapPx;
  }

  return _TerrariumGeometry(
    rects: rects,
    levelRowRects: levelRowRects,
    levelSlotColumnRects: levelSlotColumnRects,
    totalWidthPx: rowWidthPx,
    totalHeightPx: (cursorY - _levelGapPx).clamp(0, double.infinity),
  );
}

class _DropTarget {
  _DropTarget(
      {required this.level, required this.positionInLevel, required this.stack});
  final int level;
  final int positionInLevel;
  final bool stack;
}

_DropTarget? _hitTest(_TerrariumGeometry geo, Offset point) {
  int? bestLevel;
  var bestDist = double.infinity;
  for (final entry in geo.levelRowRects.entries) {
    final r = entry.value;
    final expanded = Rect.fromLTRB(r.left, r.top - 20, r.right, r.bottom + 20);
    if (expanded.contains(point)) {
      final centerY = r.top + r.height / 2;
      final dist = (point.dy - centerY).abs();
      if (dist < bestDist) {
        bestDist = dist;
        bestLevel = entry.key;
      }
    }
  }
  if (bestLevel == null) return null;

  final columns = geo.levelSlotColumnRects[bestLevel] ?? const [];
  for (var i = 0; i < columns.length; i++) {
    if (point.dx >= columns[i].left && point.dx < columns[i].right) {
      return _DropTarget(level: bestLevel, positionInLevel: i, stack: true);
    }
  }

  var insertIndex = columns.length;
  for (var i = 0; i < columns.length; i++) {
    if (point.dx < columns[i].left) {
      insertIndex = i;
      break;
    }
  }
  return _DropTarget(
      level: bestLevel, positionInLevel: insertIndex, stack: false);
}
