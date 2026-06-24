import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/occupancy.dart';
import 'shelf_detail_screen.dart';
import 'shelf_form_screen.dart';
import 'terrarium_form_screen.dart';
import 'tool_form_screen.dart';

class ShelfListScreen extends StatelessWidget {
  const ShelfListScreen({super.key});

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
          if (!shelfSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shelves = shelfSnapshot.data!;
          return StreamBuilder<List<Terrarium>>(
            stream: db.watchAllTerrariums(),
            builder: (context, terrariumSnapshot) {
              final allTerrariums =
                  terrariumSnapshot.data ?? const <Terrarium>[];
              return StreamBuilder<List<Tool>>(
                stream: db.watchAllTools(),
                builder: (context, toolSnapshot) {
                  final allTools = toolSnapshot.data ?? const <Tool>[];
                  final individual =
                      allTerrariums.where((t) => t.shelfId == null).toList();

                  if (shelves.isEmpty && individual.isEmpty) {
                    return Center(
                      child: Text(
                        'No shelves or terrariums yet.\nTap + to add one.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  double totalUsedCm = 0;
                  double totalCapacityCm = 0;
                  final fractionByShelfId = <int, double>{};
                  for (final shelf in shelves) {
                    final shelfTerrariums = allTerrariums
                        .where((t) => t.shelfId == shelf.id)
                        .toList();
                    final shelfTools =
                        allTools.where((t) => t.shelfId == shelf.id).toList();
                    final fraction = occupancyFractionFor(
                        shelf, shelfTerrariums, shelfTools);
                    fractionByShelfId[shelf.id] = fraction;
                    totalCapacityCm += shelf.lengthCm * shelf.levelCount;
                    totalUsedCm += fraction * shelf.lengthCm * shelf.levelCount;
                  }
                  final aggregateFraction = totalCapacityCm == 0
                      ? 0.0
                      : (totalUsedCm / totalCapacityCm).clamp(0.0, 1.0);

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (shelves.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Space occupied',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    Text(
                                      '${(aggregateFraction * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color:
                                            occupancyColor(aggregateFraction),
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
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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
                                final fraction =
                                    fractionByShelfId[shelf.id] ?? 0.0;
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
                                  builder: (_) =>
                                      ShelfDetailScreen(shelfId: shelf.id),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (individual.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                          child: Text('Individual terrariums',
                              style: Theme.of(context).textTheme.titleSmall),
                        ),
                        for (final t in individual)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                leading:
                                    const Icon(Icons.crop_square_outlined),
                                title: Text('T${t.individualSequence}'
                                    '${t.location != null ? " — ${t.location}" : ""}'),
                                subtitle: Text(
                                    '${t.volumeLitres.toStringAsFixed(1)} L · ${t.shape}'),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TerrariumFormScreen(existing: t),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
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
