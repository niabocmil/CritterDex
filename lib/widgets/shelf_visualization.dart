import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';
import 'terrarium_slot.dart';
import 'tool_slot.dart';

typedef ShelfMoveCallback = Future<void> Function({
  required ShelfItem moving,
  required int targetLevel,
  required double targetPositionXCm,
  ShelfItem? stackOnTarget,
});

/// Fixed cm:px ratio (rather than scaling to fit the viewport) so a 100cm
/// shelf renders at a readable 800px — comfortably requiring horizontal
/// scroll past ~45cm of shelf on a typical phone width.
const double cmToPx = 8.0;
const _levelGapPx = 14.0;
const _levelLabelWidthPx = 20.0;

String _itemKey(ShelfItem item) => '${item.kind.name}_${item.id}';

class ShelfVisualization extends StatefulWidget {
  const ShelfVisualization({
    super.key,
    required this.shelf,
    required this.terrariums,
    required this.tools,
    required this.onMove,
    required this.onTapTerrarium,
    required this.onTapTool,
    this.specimensByTerrariumId = const {},
  });

  final Shelf shelf;
  final List<Terrarium> terrariums;
  final List<Tool> tools;
  final Map<int, List<Specimen>> specimensByTerrariumId;
  final ShelfMoveCallback onMove;
  final ValueChanged<Terrarium> onTapTerrarium;
  final ValueChanged<Tool> onTapTool;

  @override
  State<ShelfVisualization> createState() => _ShelfVisualizationState();
}

class _ShelfVisualizationState extends State<ShelfVisualization> {
  final GlobalKey _canvasKey = GlobalKey();
  String? _draggingKey;
  Offset? _dragLocalPosition;

  Offset? _globalToLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <ShelfItem>[
      ...widget.terrariums.map(TerrariumShelfItem.new),
      ...widget.tools.map(ToolShelfItem.new),
    ];
    final geo = _computeGeometry(widget.shelf, items);
    final byKey = {for (final i in items) _itemKey(i): i};
    final draggingItem = _draggingKey != null ? byKey[_draggingKey] : null;
    final draggingRect = _draggingKey != null ? geo.rects[_draggingKey] : null;

    final canvas = SizedBox(
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
            if (entry.key != _draggingKey)
              Positioned.fromRect(
                rect: entry.value,
                child: _buildItemGesture(byKey[entry.key]!, geo, items),
              ),
          if (draggingItem != null &&
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
                  child: _buildItemVisual(draggingItem, items, isGhost: true),
                ),
              ),
            ),
        ],
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _levelLabelWidthPx,
            height: geo.totalHeightPx,
            child: Stack(
              children: [
                for (final entry in geo.levelRowRects.entries)
                  Positioned(
                    left: 0,
                    top: entry.value.top + entry.value.height / 2 - 8,
                    child: Text(
                      levelDisplayLabel(entry.key),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: canvas,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemVisual(ShelfItem item, List<ShelfItem> allItems,
      {bool isGhost = false}) {
    if (item is TerrariumShelfItem) {
      final t = item.terrarium;
      return TerrariumSlot(
        terrarium: t,
        label: labelFor(t, widget.shelf, allItems),
        assignedSpecimens: widget.specimensByTerrariumId[t.id] ?? const [],
        isGhost: isGhost,
      );
    }
    final tool = (item as ToolShelfItem).tool;
    return ToolSlot(tool: tool, isGhost: isGhost);
  }

  Widget _buildItemGesture(
      ShelfItem item, _ShelfGeometry geo, List<ShelfItem> allItems) {
    return GestureDetector(
      onTap: () {
        if (item is TerrariumShelfItem) {
          widget.onTapTerrarium(item.terrarium);
        } else {
          widget.onTapTool((item as ToolShelfItem).tool);
        }
      },
      onLongPressStart: (details) {
        setState(() {
          _draggingKey = _itemKey(item);
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
          _draggingKey = null;
          _dragLocalPosition = null;
        });
        if (local == null) return;
        final target = _hitTest(geo, local);
        if (target == null) return; // dropped outside any level: cancel
        widget.onMove(
          moving: item,
          targetLevel: target.level,
          targetPositionXCm: target.positionXCm,
          stackOnTarget: target.stackOnTarget,
        );
      },
      child: _buildItemVisual(item, allItems),
    );
  }
}

class _ShelfGeometry {
  _ShelfGeometry({
    required this.rects,
    required this.levelRowRects,
    required this.levelColumnRects,
    required this.levelColumns,
    required this.totalWidthPx,
    required this.totalHeightPx,
  });

  final Map<String, Rect> rects;
  final Map<int, Rect> levelRowRects;
  final Map<int, List<Rect>> levelColumnRects;
  final Map<int, List<List<ShelfItem>>> levelColumns;
  final double totalWidthPx;
  final double totalHeightPx;
}

_ShelfGeometry _computeGeometry(Shelf shelf, List<ShelfItem> items) {
  final rects = <String, Rect>{};
  final levelRowRects = <int, Rect>{};
  final levelColumnRects = <int, List<Rect>>{};
  final levelColumns = <int, List<List<ShelfItem>>>{};
  final rowWidthPx = shelf.lengthCm * cmToPx;
  final rowHeightPx = shelf.levelHeightCm * cmToPx;

  var cursorY = 0.0;
  for (var level = 1; level <= shelf.levelCount; level++) {
    final rowTop = cursorY;
    levelRowRects[level] = Rect.fromLTWH(0, rowTop, rowWidthPx, rowHeightPx);

    final columns = columnsForLevel(items, level);
    levelColumns[level] = columns;
    final columnRects = <Rect>[];
    for (final column in columns) {
      final x = column.first.positionXCm!;
      final footprint =
          column.map((i) => i.footprintCm).reduce((a, b) => a > b ? a : b);
      final widthPx = footprint * cmToPx;
      final leftPx = x * cmToPx;
      columnRects.add(Rect.fromLTWH(leftPx, rowTop, widthPx, rowHeightPx));

      var heightFromBottom = 0.0;
      for (final item in column) {
        final hPx = item.itemHeightCm * cmToPx;
        final bottom = rowTop + rowHeightPx - heightFromBottom;
        rects[_itemKey(item)] =
            Rect.fromLTWH(leftPx, bottom - hPx, widthPx, hPx);
        heightFromBottom += hPx;
      }
    }
    levelColumnRects[level] = columnRects;
    cursorY += rowHeightPx + _levelGapPx;
  }

  return _ShelfGeometry(
    rects: rects,
    levelRowRects: levelRowRects,
    levelColumnRects: levelColumnRects,
    levelColumns: levelColumns,
    totalWidthPx: rowWidthPx,
    totalHeightPx: (cursorY - _levelGapPx).clamp(0, double.infinity),
  );
}

class _DropTarget {
  _DropTarget({required this.level, required this.positionXCm, this.stackOnTarget});
  final int level;
  final double positionXCm;
  final ShelfItem? stackOnTarget;
}

_DropTarget? _hitTest(_ShelfGeometry geo, Offset point) {
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

  final columnRects = geo.levelColumnRects[bestLevel] ?? const [];
  final columns = geo.levelColumns[bestLevel] ?? const [];
  for (var i = 0; i < columnRects.length; i++) {
    if (point.dx >= columnRects[i].left && point.dx < columnRects[i].right) {
      return _DropTarget(
        level: bestLevel,
        positionXCm: columns[i].first.positionXCm!,
        stackOnTarget: columns[i].first,
      );
    }
  }

  return _DropTarget(level: bestLevel, positionXCm: point.dx / cmToPx);
}
