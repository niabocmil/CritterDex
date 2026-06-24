import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import 'shelf_detail_screen.dart';
import 'shelf_form_screen.dart';
import 'terrarium_form_screen.dart';

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
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shelves = snapshot.data!;
          return StreamBuilder<List<Terrarium>>(
            stream: db.watchAllTerrariums(),
            builder: (context, terrariumSnapshot) {
              final terrariums = terrariumSnapshot.data ?? const <Terrarium>[];
              final individual =
                  terrariums.where((t) => t.shelfId == null).toList();

              if (shelves.isEmpty && individual.isEmpty) {
                return Center(
                  child: Text(
                    'No shelves or terrariums yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final shelf in shelves)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.view_module_outlined),
                        title: Text(shelf.name),
                        subtitle: Text(
                            '${shelf.label} · ${shelf.levelCount} level(s) · ${shelf.lengthCm.toStringAsFixed(0)} cm'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ShelfDetailScreen(shelfId: shelf.id),
                          ),
                        ),
                      ),
                    ),
                  if (individual.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: Text('Individual terrariums',
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    for (final t in individual)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.crop_square_outlined),
                          title: Text('T${t.individualSequence}'
                              '${t.location != null ? " — ${t.location}" : ""}'),
                          subtitle: Text(
                              '${t.volumeLitres.toStringAsFixed(1)} L · ${t.shape}'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TerrariumFormScreen(existing: t),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
