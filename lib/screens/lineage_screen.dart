import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/lineage_utils.dart';
import '../widgets/specimen_avatar.dart';
import 'specimen_detail_screen.dart';

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

          final ancestors = allAncestorsOf(focal, byId);
          final descendants = allDescendantsOf(specimenId, all);
          final included = <int, Specimen>{
            focal.id: focal,
            for (final a in ancestors) a.id: a,
            for (final d in descendants) d.id: d,
          };

          if (included.length == 1) {
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

          final graph = Graph()..isTree = true;
          final nodeMap = <int, Node>{};
          for (final s in included.values) {
            final node = Node.Id(s.id);
            nodeMap[s.id] = node;
            graph.addNode(node);
          }
          for (final s in included.values) {
            if (s.motherId != null && nodeMap.containsKey(s.motherId)) {
              graph.addEdge(nodeMap[s.motherId]!, nodeMap[s.id]!);
            }
            if (s.fatherId != null && nodeMap.containsKey(s.fatherId)) {
              graph.addEdge(nodeMap[s.fatherId]!, nodeMap[s.id]!);
            }
          }

          final config = BuchheimWalkerConfiguration()
            ..siblingSeparation = 24
            ..levelSeparation = 48
            ..subtreeSeparation = 24
            ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(80),
            minScale: 0.3,
            maxScale: 2.5,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: GraphView(
                graph: graph,
                algorithm:
                    BuchheimWalkerAlgorithm(config, TreeEdgeRenderer(config)),
                paint: Paint()
                  ..color = Theme.of(context).colorScheme.outlineVariant
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                builder: (node) {
                  final id = node.key!.value as int;
                  final specimen = included[id]!;
                  final isFocal = id == specimenId;
                  return _LineageNodeCard(
                    specimen: specimen,
                    highlighted: isFocal,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
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
        width: 120,
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
