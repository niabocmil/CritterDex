import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/occupancy.dart';
import '../models/replenish.dart';
import '../models/terrarium_layout.dart';
import 'replenish_due_screen.dart';
import 'shelf_detail_screen.dart';
import 'shelf_form_screen.dart';
import 'terrarium_form_screen.dart';
import 'tool_form_screen.dart';

enum _ShelfTabView { shelves, terrariums }

class ShelfListScreen extends StatefulWidget {
  const ShelfListScreen({super.key});

  @override
  State<ShelfListScreen> createState() => _ShelfListScreenState();
}

class _ShelfListScreenState extends State<ShelfListScreen> {
  _ShelfTabView _view = _ShelfTabView.shelves;

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.view_module_outlined),
              title: const Text('New shelf'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ShelfFormScreen(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop_square_outlined),
              title: const Text('New terrarium'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TerrariumFormScreen(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_comfy_outlined),
              title: const Text('Batch create terrariums'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TerrariumFormScreen(isBatch: true),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.build_outlined),
              title: const Text('New tool'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ToolFormScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Shelf')),
      body: StreamBuilder<List<Shelf>>(
        stream: db.watchAllShelves(),
        builder: (context, shelfSnapshot) {
          final shelves = shelfSnapshot.data ?? const <Shelf>[];
          return StreamBuilder<List<Terrarium>>(
            stream: db.watchAllTerrariums(),
            builder: (context, terrariumSnapshot) {
              final terrariums = terrariumSnapshot.data ?? const <Terrarium>[];
              return StreamBuilder<List<Tool>>(
                stream: db.watchAllTools(),
                builder: (context, toolSnapshot) {
                  final tools = toolSnapshot.data ?? const <Tool>[];
                  return StreamBuilder<List<Specimen>>(
                    stream: db.watchAllSpecimens(),
                    builder: (context, specimenSnapshot) {
                      final specimens =
                          specimenSnapshot.data ?? const <Specimen>[];
                      final replenishDueCount = terrariumIdsNeedingReplenish(
                              specimens,
                              activeTerrariumIds:
                                  terrariums.map((t) => t.id).toSet())
                          .length;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: _OccupancyCard(
                              shelves: shelves,
                              terrariums: terrariums,
                              tools: tools,
                              replenishDueCount: replenishDueCount,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: SegmentedButton<_ShelfTabView>(
                              segments: const [
                                ButtonSegment(
                                    value: _ShelfTabView.shelves,
                                    label: Text('Shelves')),
                                ButtonSegment(
                                    value: _ShelfTabView.terrariums,
                                    label: Text('Terrariums')),
                              ],
                              selected: {_view},
                              onSelectionChanged: (s) =>
                                  setState(() => _view = s.first),
                            ),
                          ),
                          Expanded(
                            child: _view == _ShelfTabView.shelves
                                ? _ShelvesView(shelves: shelves, terrariums: terrariums, tools: tools)
                                : _TerrariumsView(
                                    terrariums: terrariums,
                                    shelves: shelves,
                                    tools: tools,
                                  ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Occupancy summary — rendered once, above the Shelves/Terrariums toggle,
/// so switching that toggle never changes these numbers.
class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({
    required this.shelves,
    required this.terrariums,
    required this.tools,
    required this.replenishDueCount,
  });

  final List<Shelf> shelves;
  final List<Terrarium> terrariums;
  final List<Tool> tools;
  final int replenishDueCount;

  @override
  Widget build(BuildContext context) {
    double totalUsedCm = 0;
    double totalCapacityCm = 0;
    for (final shelf in shelves) {
      final shelfTerrariums =
          terrariums.where((t) => t.shelfId == shelf.id).toList();
      final shelfTools = tools.where((t) => t.shelfId == shelf.id).toList();
      final fraction = occupancyFractionFor(shelf, shelfTerrariums, shelfTools);
      totalCapacityCm += shelf.lengthCm * shelf.levelCount;
      totalUsedCm += fraction * shelf.lengthCm * shelf.levelCount;
    }
    final aggregateFraction =
        totalCapacityCm == 0 ? 0.0 : (totalUsedCm / totalCapacityCm).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Space occupied',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '${(aggregateFraction * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: occupancyColor(aggregateFraction),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: aggregateFraction,
                minHeight: 8,
                color: occupancyColor(aggregateFraction),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _OccupancyStatBlock(
                    value: '${terrariums.length}',
                    label: 'Total terrariums',
                  ),
                ),
                Expanded(
                  child: _OccupancyStatBlock(
                    value: '$replenishDueCount',
                    label: 'To replenish',
                    color: replenishDueCount > 0 ? Colors.orange : null,
                    onTap: replenishDueCount > 0
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ReplenishDueScreen()))
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelvesView extends StatelessWidget {
  const _ShelvesView({
    required this.shelves,
    required this.terrariums,
    required this.tools,
  });

  final List<Shelf> shelves;
  final List<Terrarium> terrariums;
  final List<Tool> tools;

  @override
  Widget build(BuildContext context) {
    if (shelves.isEmpty) {
      return Center(
        child: Text(
          'No shelves yet.\nTap + to add one.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final fractionByShelfId = <int, double>{};
    for (final shelf in shelves) {
      final shelfTerrariums =
          terrariums.where((t) => t.shelfId == shelf.id).toList();
      final shelfTools = tools.where((t) => t.shelfId == shelf.id).toList();
      fractionByShelfId[shelf.id] =
          occupancyFractionFor(shelf, shelfTerrariums, shelfTools);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final shelf in shelves)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.view_module_outlined),
                title: Text(shelf.name),
                subtitle: Text(
                    '${shelf.label} · ${shelf.levelCount} level(s) · ${shelf.lengthCm.toStringAsFixed(0)} cm'),
                trailing: Builder(builder: (context) {
                  final fraction = fractionByShelfId[shelf.id] ?? 0.0;
                  return Text(
                    '${(fraction * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: occupancyColor(fraction),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  );
                }),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShelfDetailScreen(shelfId: shelf.id),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OccupancyStatBlock extends StatelessWidget {
  const _OccupancyStatBlock({
    required this.value,
    required this.label,
    this.color,
    this.onTap,
  });

  final String value;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color ?? scheme.onSurface,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: color ?? scheme.onSurfaceVariant,
            fontWeight: color != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: content);
  }
}

class _TerrariumsView extends StatelessWidget {
  const _TerrariumsView({
    required this.terrariums,
    required this.shelves,
    required this.tools,
  });

  final List<Terrarium> terrariums;
  final List<Shelf> shelves;
  final List<Tool> tools;

  @override
  Widget build(BuildContext context) {
    if (terrariums.isEmpty) {
      return Center(
        child: Text(
          'No terrariums yet.\nTap + to add one.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final labels = computeAllTerrariumLabels(shelves, terrariums, tools);
    final shelfById = {for (final s in shelves) s.id: s};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final t in terrariums)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.crop_square_outlined),
                title: Text(labels[t.id] ?? '?'),
                subtitle: Text([
                  '${t.volumeLitres.toStringAsFixed(1)} L · ${t.shape}',
                  t.shelfId == null
                      ? (t.location?.isNotEmpty == true
                          ? t.location!
                          : 'Individual')
                      : shelfById[t.shelfId]?.name ?? 'Shelf',
                ].join(' · ')),
                onTap: () => _showTerrariumActions(context, t),
              ),
            ),
          ),
      ],
    );
  }

  void _showTerrariumActions(BuildContext context, Terrarium terrarium) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => TerrariumFormScreen(existing: terrarium),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      TerrariumFormScreen(duplicateFrom: terrarium),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
