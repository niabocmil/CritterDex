import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/lineage_utils.dart';
import '../widgets/specimen_avatar.dart';
import 'specimen_detail_screen.dart';

const double _cardWidth = 120;
const double _cardHeight = 118;
const double _hGap = 24;
const double _vGap = 56;

/// Every ancestor/descendant of [focal], as a hop-distance from it (negative
/// going up to parents, positive going down to children, 0 for focal
/// itself) — BFS guarantees the first depth recorded for a given id is the
/// shortest one, so a specimen reachable via two paths (e.g. a grandparent
/// shared by both parents) still gets exactly one, unambiguous row.
Map<int, int> _computeDepths(
    Specimen focal, Map<int, Specimen> byId, List<Specimen> all) {
  final depths = <int, int>{focal.id: 0};

  final ancestorQueue = <Specimen>[focal];
  while (ancestorQueue.isNotEmpty) {
    final current = ancestorQueue.removeAt(0);
    final depth = depths[current.id]!;
    for (final parent in directParentsOf(current, byId)) {
      if (depths.containsKey(parent.id)) continue;
      depths[parent.id] = depth - 1;
      ancestorQueue.add(parent);
    }
  }

  final descendantQueue = <int>[focal.id];
  while (descendantQueue.isNotEmpty) {
    final currentId = descendantQueue.removeAt(0);
    final depth = depths[currentId]!;
    for (final child in directChildrenOf(currentId, all)) {
      if (depths.containsKey(child.id)) continue;
      depths[child.id] = depth + 1;
      descendantQueue.add(child.id);
    }
  }

  return depths;
}

class LineageScreen extends StatelessWidget {
  const LineageScreen({super.key, required this.specimenId});

  final int specimenId;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Family tree')),
      body: FutureBuilder<List<Specimen>>(
        future: db.getAllSpecimens(),
        builder: (context, snapshot) {
          final all = snapshot.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final byId = {for (final s in all) s.id: s};
          final focal = byId[specimenId];
          if (focal == null) {
            return const Center(child: Text('Specimen not found.'));
          }

          final depths = _computeDepths(focal, byId, all);
          if (depths.length == 1) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No recorded parents or offspring for this specimen yet.\n'
                  'Add parents when creating a specimen, or log a breeding '
                  'event, to build out the family tree.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            );
          }
          final included = {for (final id in depths.keys) id: byId[id]!};

          // Group ids into rows by depth, most-ancestral row first (matches
          // the old top-to-bottom orientation), each row ordered by id for a
          // deterministic, stable layout.
          final rowsByDepth = <int, List<int>>{};
          for (final entry in depths.entries) {
            rowsByDepth.putIfAbsent(entry.value, () => []).add(entry.key);
          }
          final sortedDepths = rowsByDepth.keys.toList()..sort();
          for (final ids in rowsByDepth.values) {
            ids.sort();
          }

          final rowWidths = <int, double>{
            for (final depth in sortedDepths)
              depth: rowsByDepth[depth]!.length * _cardWidth +
                  (rowsByDepth[depth]!.length - 1) * _hGap,
          };
          final totalWidth =
              rowWidths.values.fold<double>(0, (a, b) => a > b ? a : b);

          final rects = <int, Rect>{};
          for (var rowIndex = 0; rowIndex < sortedDepths.length; rowIndex++) {
            final depth = sortedDepths[rowIndex];
            final ids = rowsByDepth[depth]!;
            final rowWidth = rowWidths[depth]!;
            final startX = (totalWidth - rowWidth) / 2;
            final top = rowIndex * (_cardHeight + _vGap);
            for (var col = 0; col < ids.length; col++) {
              final left = startX + col * (_cardWidth + _hGap);
              rects[ids[col]] = Rect.fromLTWH(left, top, _cardWidth, _cardHeight);
            }
          }
          final totalHeight =
              sortedDepths.length * _cardHeight + (sortedDepths.length - 1) * _vGap;

          final edges = <(int, int)>[];
          for (final s in included.values) {
            if (s.motherId != null && included.containsKey(s.motherId)) {
              edges.add((s.motherId!, s.id));
            }
            if (s.fatherId != null && included.containsKey(s.fatherId)) {
              edges.add((s.fatherId!, s.id));
            }
          }

          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(80),
            minScale: 0.3,
            maxScale: 2.5,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: totalWidth,
                height: totalHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LineagePainter(
                          rects: rects,
                          edges: edges,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    for (final entry in rects.entries)
                      Positioned.fromRect(
                        rect: entry.value,
                        child: _LineageNodeCard(
                          specimen: included[entry.key]!,
                          highlighted: entry.key == specimenId,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LineagePainter extends CustomPainter {
  _LineagePainter({
    required this.rects,
    required this.edges,
    required this.color,
  });

  final Map<int, Rect> rects;
  final List<(int, int)> edges;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final (parentId, childId) in edges) {
      final parentRect = rects[parentId];
      final childRect = rects[childId];
      if (parentRect == null || childRect == null) continue;
      final start = parentRect.bottomCenter;
      final end = childRect.topCenter;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx,
          start.dy + (end.dy - start.dy) / 2,
          end.dx,
          start.dy + (end.dy - start.dy) / 2,
          end.dx,
          end.dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LineagePainter oldDelegate) =>
      oldDelegate.rects != rects ||
      oldDelegate.edges != edges ||
      oldDelegate.color != color;
}

class _LineageNodeCard extends StatelessWidget {
  const _LineageNodeCard({required this.specimen, required this.highlighted});

  final Specimen specimen;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SpecimenDetailScreen(specimenId: specimen.id),
        ),
      ),
      child: Container(
        width: _cardWidth,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: highlighted ? scheme.primaryContainer : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: highlighted
              ? Border.all(color: scheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpecimenAvatar(
                iconType: SpecimenIconType.fromValue(specimen.speciesIconKey),
                beetleFamily: BeetleFamily.fromValue(specimen.beetleFamily),
                lifeStage: BeetleLifeStage.fromValue(specimen.lifeStage),
                radius: 22),
            const SizedBox(height: 6),
            Text(
              specimen.name?.isNotEmpty == true
                  ? specimen.name!
                  : specimen.species,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            Text(
              specimen.species,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
