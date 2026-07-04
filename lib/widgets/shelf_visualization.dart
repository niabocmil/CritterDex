import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/terrarium_layout.dart';
import '../models/terrarium_placement.dart';
import '../theme/theme_controller.dart';
import 'terrarium_slot.dart';
import 'tool_slot.dart';

typedef ShelfMoveCallback = Future<void> Function({
  required ShelfItem moving,
  required int targetLevel,
  required double targetPositionXCm,
  ShelfItem? stackOnTarget,
});

/// Fixed cm:px ratio (rather than scaling to fit the viewport) so a 100cm
/// shelf renders at a readable 800px — comfortably requiring scrolling past
/// ~45cm of shelf on a typical phone width.
const double cmToPx = 6.0;
const _levelGapPx = 14.0;
// Room for the level label (G / 1 / 2 / ...), baked into the canvas itself
// so it pans together with everything else under one gesture.
const _gutterPx = 26.0;
// Reserves blank space above the topmost level so it never renders directly
// under the floating overlay header in the immersive fullscreen shelf
// screen. Baked into the canvas itself (rather than, say, top-padding the
// InteractiveViewer) because InteractiveViewer won't pan past the content's
// own edges by default — on a short shelf whose content already fits the
// viewport, there'd be no way to scroll the top level out from under the
// header otherwise.
const _topInsetPx = 96.0;
// Extra blank scroll space (in shelf cm) above the topmost level and below
// the "G" level, so a user can scroll either end away from the very top/
// bottom edge of the phone — those edges are awkward to reach a thumb to
// while operating a level near them.
const _extraScrollCm = 30.0;
const _extraScrollPx = _extraScrollCm * cmToPx;
// Extra blank scroll space (in shelf cm) to the left and right of the
// shelf row itself, for the same reason as [_extraScrollPx] but along the
// horizontal axis.
const _extraSideCm = 5.0;
const _extraSidePx = _extraSideCm * cmToPx;
// InteractiveViewer's scale floor/ceiling: pinch-zoom can go out to half
// the canvas's normal cm:px size, but never in past it (the fixed ratio in
// [cmToPx] is already tuned to be comfortably readable).
const _minScale = 0.5;
const _maxScale = 1.0;

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
    this.highlightIconType,
  });

  final Shelf shelf;
  final List<Terrarium> terrariums;
  final List<Tool> tools;
  final Map<int, List<Specimen>> specimensByTerrariumId;
  final ShelfMoveCallback onMove;
  final ValueChanged<Terrarium> onTapTerrarium;
  final ValueChanged<Tool> onTapTool;
  // When set, terrariums holding a specimen of this icon type are ringed and
  // everything else is dimmed (the shelf detail screen's "highlight by
  // species" filter).
  final SpecimenIconType? highlightIconType;

  @override
  State<ShelfVisualization> createState() => _ShelfVisualizationState();
}

class _ShelfVisualizationState extends State<ShelfVisualization> {
  final GlobalKey _canvasKey = GlobalKey();
  String? _draggingKey;
  Offset? _dragLocalPosition;
  _DropTarget? _previewTarget;
  // InteractiveViewer's own pan recognizer claims the gesture arena eagerly,
  // as soon as a pointer moves past a small threshold — which can beat an
  // item's LongPressGestureRecognizer (which only wins after its ~500ms
  // timer fires) if the canvas pan sees movement first. Flipping this the
  // instant any finger touches an item — via Listener.onPointerDown, which
  // fires immediately and doesn't wait for arena resolution — takes the
  // canvas pan out of the running for that whole gesture, so the item's own
  // long-press is the only drag-style recognizer left to win.
  bool _pointerDownOnItem = false;
  // Drives manual panning for a gesture that starts on a box: InteractiveViewer's
  // own pan is disabled for the whole gesture (see [_pointerDownOnItem] above),
  // so a quick drag that was meant to pan the canvas — not long-press-drag the
  // box — has no recognizer left to do it. This replays the same translation
  // InteractiveViewer would have applied, from the raw pointer stream, only
  // while no box-drag has actually started yet ([_draggingKey] is null).
  final TransformationController _transformController =
      TransformationController();
  Offset? _lastPanPointerPosition;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Offset? _globalToLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.globalToLocal(global);
  }

  List<ShelfItem> _baseItems() => [
        ...widget.terrariums.map(TerrariumShelfItem.new),
        ...widget.tools.map(ToolShelfItem.new),
      ];

  /// While a drag is in progress, applies the in-flight [planMove] result
  /// (computed against [_previewTarget]) to cloned items, so every affected
  /// box — not just the one under the finger — previews its prospective
  /// position before the user releases. The actual database write only
  /// happens once, in [onMove], on release.
  List<ShelfItem> _previewItems(List<ShelfItem> base) {
    final draggingKey = _draggingKey;
    final target = _previewTarget;
    if (draggingKey == null || target == null) return base;
    final moving = base.firstWhere(
      (i) => shelfItemKey(i) == draggingKey,
      orElse: () => base.first,
    );
    try {
      final updates = planMove(
        moving: moving,
        targetShelf: widget.shelf,
        targetLevel: target.level,
        targetPositionXCm: target.positionXCm,
        stackOnTarget: target.stackOnTarget,
        sourceShelfItems: base,
        targetShelfItems: base,
      );
      final byKey = {for (final u in updates) '${u.kind.name}_${u.id}': u};
      return [
        for (final item in base)
          if (byKey[shelfItemKey(item)] case final u?)
            _PreviewShelfItem(item,
                level: u.level,
                positionXCm: u.positionXCm,
                supportId: u.supportId,
                supportKind: u.supportKind)
          else
            item,
      ];
    } on MoveException {
      return base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shelfColor = context.watch<ThemeController>().shelfColor;
    final baseItems = _baseItems();
    final baseGeo = _computeGeometry(widget.shelf, baseItems);
    final dragging = _draggingKey != null;
    final geo =
        dragging ? _computeGeometry(widget.shelf, _previewItems(baseItems)) : baseGeo;
    final baseByKey = {for (final i in baseItems) shelfItemKey(i): i};

    final draggingRect = dragging ? baseGeo.rects[_draggingKey] : null;

    final canvas = SizedBox(
      width: baseGeo.totalWidthPx,
      height: baseGeo.totalHeightPx,
      child: Stack(
        key: _canvasKey,
        clipBehavior: Clip.none,
        children: [
          for (final entry in baseGeo.levelRowRects.entries)
            Positioned.fromRect(
              key: ValueKey('row_${entry.key}'),
              rect: entry.value,
              child: Container(
                decoration: BoxDecoration(
                  color: shelfColor ?? scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outlineVariant),
                ),
              ),
            ),
          for (final entry in baseGeo.levelRowRects.entries)
            Positioned(
              key: ValueKey('label_${entry.key}'),
              left: _extraSidePx + 4,
              top: entry.value.top + entry.value.height / 2 - 8,
              child: Text(
                levelDisplayLabel(entry.key),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: shelfColor == null
                      ? scheme.onSurfaceVariant
                      : ThemeData.estimateBrightnessForColor(shelfColor) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ),
          // Every item — including the one currently being dragged — goes
          // through this exact same loop, producing the exact same widget
          // type (AnimatedPositioned wrapping a GestureDetector) on every
          // build. Branching the dragged item into a *different* widget
          // type (as a previous version of this code did, to dim it or pin
          // it in place) made Flutter unmount and remount its
          // GestureDetector the instant a drag started — which silently
          // killed the in-flight long-press gesture and "hung" the drag.
          // Only the rect/opacity passed to the same widget type vary: the
          // dragged item stays pinned at its original spot (dimmed) while
          // everything else animates to its live preview position.
          for (final item in baseItems)
            Builder(builder: (context) {
              final key = shelfItemKey(item);
              final isDragging = key == _draggingKey;
              // No rect means this item's level didn't fall in 1..levelCount
              // (e.g. bad/partial data) — skip it rather than crash the
              // whole shelf view.
              final rect = isDragging ? baseGeo.rects[key] : geo.rects[key];
              if (rect == null) return const SizedBox.shrink();
              return AnimatedPositioned(
                key: ValueKey(key),
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: rect.left,
                top: rect.top,
                width: rect.width,
                height: rect.height,
                child: Opacity(
                  opacity: isDragging ? 0.35 : 1.0,
                  child: _buildItemGesture(item, baseItems),
                ),
              );
            }),
          if (dragging && _dragLocalPosition != null && draggingRect != null)
            Positioned(
              left: _dragLocalPosition!.dx - draggingRect.width / 2,
              top: _dragLocalPosition!.dy - draggingRect.height / 2,
              width: draggingRect.width,
              height: draggingRect.height,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.9,
                  child: _buildItemVisual(
                      baseByKey[_draggingKey]!, baseItems,
                      isGhost: true),
                ),
              ),
            ),
        ],
      ),
    );

    // Fills whatever space the parent gives it (the parent is responsible
    // for bounding that, e.g. an Expanded/SizedBox.expand in an immersive
    // fullscreen shelf screen) rather than clamping to a fixed height
    // itself.
    return SizedBox.expand(
      child: InteractiveViewer(
        transformationController: _transformController,
        panEnabled: !dragging && !_pointerDownOnItem,
        scaleEnabled: !dragging && !_pointerDownOnItem,
        minScale: _minScale,
        maxScale: _maxScale,
        constrained: false,
        child: canvas,
      ),
    );
  }

  Widget _buildItemVisual(ShelfItem item, List<ShelfItem> allItems,
      {bool isGhost = false}) {
    if (item is TerrariumShelfItem) {
      final t = item.terrarium;
      final assigned = widget.specimensByTerrariumId[t.id] ?? const [];
      final highlightType = widget.highlightIconType;
      final matchesHighlight = highlightType != null &&
          assigned.any(
              (s) => SpecimenIconType.fromValue(s.speciesIconKey) == highlightType);
      return TerrariumSlot(
        terrarium: t,
        label: labelFor(t, widget.shelf, allItems),
        assignedSpecimens: assigned,
        isGhost: isGhost,
        isHighlighted: matchesHighlight,
        isDimmed: highlightType != null && !matchesHighlight,
      );
    }
    final tool = (item as ToolShelfItem).tool;
    return ToolSlot(tool: tool, isGhost: isGhost);
  }

  Widget _buildItemGesture(ShelfItem item, List<ShelfItem> baseItems) {
    return Listener(
      onPointerDown: (event) {
        _lastPanPointerPosition = event.position;
        setState(() => _pointerDownOnItem = true);
      },
      onPointerMove: (event) {
        // Only pan manually while no box-drag has started yet — once
        // onLongPressStart fires, the existing drag-preview flow owns this
        // gesture instead.
        final last = _lastPanPointerPosition;
        _lastPanPointerPosition = event.position;
        if (_draggingKey != null || last == null) return;
        final screenDelta = event.position - last;
        final scale = _transformController.value.getMaxScaleOnAxis();
        final localDelta = screenDelta / scale;
        _transformController.value = Matrix4.copy(_transformController.value)
          ..multiply(Matrix4.translationValues(localDelta.dx, localDelta.dy, 0));
      },
      onPointerUp: (_) {
        _lastPanPointerPosition = null;
        setState(() => _pointerDownOnItem = false);
      },
      onPointerCancel: (_) {
        _lastPanPointerPosition = null;
        setState(() => _pointerDownOnItem = false);
      },
      child: _buildItemGestureDetector(item, baseItems),
    );
  }

  Widget _buildItemGestureDetector(ShelfItem item, List<ShelfItem> baseItems) {
    return GestureDetector(
      onTap: () {
        if (item is TerrariumShelfItem) {
          widget.onTapTerrarium(item.terrarium);
        } else {
          widget.onTapTool((item as ToolShelfItem).tool);
        }
      },
      onLongPressStart: (details) {
        final local = _globalToLocal(details.globalPosition);
        setState(() {
          _draggingKey = shelfItemKey(item);
          _dragLocalPosition = local;
          _previewTarget = null;
        });
      },
      onLongPressMoveUpdate: (details) {
        final local = _globalToLocal(details.globalPosition);
        if (local == null) return;
        // Recomputed fresh against the un-perturbed layout every move, never
        // against a captured `geo` from some earlier build — otherwise a
        // mid-drag rebuild (which happens on every move update) could hit
        // test against a stale or already-shifted layout and resolve the
        // drop to the wrong spot.
        final baseGeo = _computeGeometry(widget.shelf, _baseItems());
        final target = _hitTest(
            baseGeo, local, item.footprintCm * cmToPx, shelfItemKey(item));
        setState(() {
          _dragLocalPosition = local;
          _previewTarget = target;
        });
      },
      onLongPressEnd: (details) {
        final target = _previewTarget;
        setState(() {
          _draggingKey = null;
          _dragLocalPosition = null;
          _previewTarget = null;
        });
        if (target == null) return; // dropped outside any level: cancel
        widget.onMove(
          moving: item,
          targetLevel: target.level,
          targetPositionXCm: target.positionXCm,
          stackOnTarget: target.stackOnTarget,
        );
      },
      child: _buildItemVisual(item, baseItems),
    );
  }
}

/// A read-only [ShelfItem] view with [level]/[positionXCm]/[supportId]/
/// [supportKind] overridden to a prospective value, used only to drive the
/// live preview geometry while a drag is in progress — never written to
/// the database.
class _PreviewShelfItem implements ShelfItem {
  _PreviewShelfItem(this._inner,
      {required this.level,
      required this.positionXCm,
      required this.supportId,
      required this.supportKind});

  final ShelfItem _inner;

  @override
  final int? level;
  @override
  final double? positionXCm;
  @override
  final int? supportId;
  @override
  final String? supportKind;

  @override
  int get id => _inner.id;
  @override
  ShelfItemKind get kind => _inner.kind;
  @override
  double get footprintCm => _inner.footprintCm;
  @override
  double get itemHeightCm => _inner.itemHeightCm;
}

class _ShelfGeometry {
  _ShelfGeometry({
    required this.rects,
    required this.levelRowRects,
    required this.levelItems,
    required this.totalWidthPx,
    required this.totalHeightPx,
  });

  final Map<String, Rect> rects;
  final Map<int, Rect> levelRowRects;
  final Map<int, List<ShelfItem>> levelItems;
  final double totalWidthPx;
  final double totalHeightPx;
}

_ShelfGeometry _computeGeometry(Shelf shelf, List<ShelfItem> items) {
  final rects = <String, Rect>{};
  final levelRowRects = <int, Rect>{};
  final levelItems = <int, List<ShelfItem>>{};
  final rowWidthPx = shelf.lengthCm * cmToPx;
  final rowHeightPx = shelf.levelHeightCm * cmToPx;

  // Level 1 ("G", ground) renders at the BOTTOM of the stack; higher levels
  // stack upward above it — so we lay rows out from the top of the canvas
  // down, walking levels from the highest to the lowest.
  final rowLeftPx = _gutterPx + _extraSidePx;
  var cursorY = _topInsetPx + _extraScrollPx;
  for (var level = shelf.levelCount; level >= 1; level--) {
    final rowTop = cursorY;
    levelRowRects[level] =
        Rect.fromLTWH(rowLeftPx, rowTop, rowWidthPx, rowHeightPx);

    final itemsAtLevel = items.where((i) => i.level == level).toList();
    levelItems[level] = itemsAtLevel;
    final geometry = resolveLevelGeometry(itemsAtLevel);

    for (final item in itemsAtLevel) {
      final resolved = geometry[shelfItemKey(item)]!;
      // Each item keeps its OWN footprint width here — never a shared
      // "column" width — so a smaller box resting on a bigger one (or two
      // side-by-side on one larger box) is never stretched to match it.
      final wPx = item.footprintCm * cmToPx;
      final hPx = item.itemHeightCm * cmToPx;
      final leftPx = rowLeftPx + resolved.absoluteXCm * cmToPx;
      // topHeightCm is the height of this item's own top surface above the
      // floor; subtracting its own height gives how far its bottom sits
      // above the floor (0 for a floor item, the support's topHeightCm for
      // anything resting on something else).
      final bottomFromFloorPx =
          (resolved.topHeightCm - item.itemHeightCm) * cmToPx;
      final bottomPx = rowTop + rowHeightPx - bottomFromFloorPx;
      rects[shelfItemKey(item)] = Rect.fromLTWH(leftPx, bottomPx - hPx, wPx, hPx);
    }

    cursorY += rowHeightPx + _levelGapPx;
  }

  return _ShelfGeometry(
    rects: rects,
    levelRowRects: levelRowRects,
    levelItems: levelItems,
    totalWidthPx: rowLeftPx + rowWidthPx + _extraSidePx,
    totalHeightPx:
        (cursorY - _levelGapPx + _extraScrollPx).clamp(0, double.infinity),
  );
}

class _DropTarget {
  _DropTarget({required this.level, required this.positionXCm, this.stackOnTarget});
  final int level;
  final double positionXCm;
  final ShelfItem? stackOnTarget;
}

/// [draggingWidthPx] is the width (in px) of the item being dragged — the
/// floating ghost preview is centered on the pointer (see [build]), so any
/// drop must use that same centered anchor when converting the pointer's
/// raw position back into a cm offset, or the box would land somewhere
/// visibly different from where its ghost was shown hovering.
///
/// Stacking only triggers when the point falls inside another item's
/// *actual rendered rect* (real 2D containment) — not merely somewhere in
/// the same column's row, which is what previously let a drop land on a
/// stack just by being dropped anywhere near it. [excludeKey] omits the
/// dragged item itself from being a candidate stack target.
_DropTarget? _hitTest(_ShelfGeometry geo, Offset point, double draggingWidthPx,
    String excludeKey) {
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

  final itemsAtLevel = geo.levelItems[bestLevel] ?? const [];
  for (final item in itemsAtLevel) {
    if (shelfItemKey(item) == excludeKey) continue;
    final rect = geo.rects[shelfItemKey(item)];
    if (rect != null && rect.contains(point)) {
      final draggingWidthCm = draggingWidthPx / cmToPx;
      final rawRelX = (point.dx - draggingWidthPx / 2 - rect.left) / cmToPx;
      final maxStart = item.footprintCm - draggingWidthCm;
      return _DropTarget(
        level: bestLevel,
        positionXCm: rawRelX.clamp(0.0, maxStart < 0 ? 0.0 : maxStart),
        stackOnTarget: item,
      );
    }
  }

  final rawXCm =
      (point.dx - draggingWidthPx / 2 - _gutterPx - _extraSidePx) / cmToPx;
  return _DropTarget(level: bestLevel, positionXCm: rawXCm.clamp(0.0, double.infinity));
}
