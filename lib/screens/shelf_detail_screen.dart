import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';
import '../models/terrarium_placement.dart';
import '../widgets/shelf_visualization.dart';
import '../widgets/specimen_avatar.dart';
import '../models/enums.dart';
import 'shelf_form_screen.dart';
import 'specimen_detail_screen.dart';
import 'terrarium_form_screen.dart';

class ShelfDetailScreen extends StatelessWidget {
  const ShelfDetailScreen({super.key, required this.shelfId});

  final int shelfId;

  Future<void> _handleMove(
    BuildContext context,
    Shelf shelf,
    List<Terrarium> all, {
    required Terrarium moving,
    required int targetLevel,
    required int targetPositionInLevel,
    required bool stackOnTarget,
  }) async {
    final db = context.read<AppDatabase>();
    try {
      final updates = planMove(
        moving: moving,
        targetShelf: shelf,
        targetLevel: targetLevel,
        targetPositionInLevel: targetPositionInLevel,
        stackOnTarget: stackOnTarget,
        sourceShelfTerrariums: all,
        targetShelfTerrariums: all,
      );
      await db.transaction(() async {
        for (final u in updates) {
          final t = all.firstWhere((t) => t.id == u.terrariumId);
          await db.updateTerrarium(t.copyWith(
            shelfId: drift.Value(u.shelfId),
            level: drift.Value(u.level),
            positionInLevel: drift.Value(u.positionInLevel),
            stackOrder: drift.Value(u.stackOrder),
          ));
        }
      });
    } on MoveException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _showTerrariumSheet(
      BuildContext context, Shelf shelf, Terrarium terrarium) {
    final db = context.read<AppDatabase>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return StreamBuilder<List<Specimen>>(
              stream: db.watchSpecimensForTerrarium(terrarium.id),
              builder: (context, snapshot) {
                final specimens = snapshot.data ?? const <Specimen>[];
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      labelFor(terrarium, shelf),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${terrarium.volumeLitres.toStringAsFixed(1)} L · ${terrarium.shape}'),
                    const Divider(height: 24),
                    if (specimens.isEmpty)
                      const Text('No specimens assigned to this terrarium.')
                    else
                      for (final s in specimens)
                        ListTile(
                          leading: SpecimenAvatar(
                              iconType:
                                  SpecimenIconType.fromValue(s.speciesIconKey)),
                          title: Text(s.name?.isNotEmpty == true ? s.name! : s.species),
                          subtitle: Text([
                            if (s.species.isNotEmpty) s.species,
                            if (s.sizeCm != null)
                              '${s.sizeCm!.toStringAsFixed(1)} cm',
                            if (s.weightGrams != null)
                              '${s.weightGrams!.toStringAsFixed(1)} g',
                          ].join(' · ')),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  SpecimenDetailScreen(specimenId: s.id),
                            ));
                          },
                        ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return StreamBuilder<Shelf>(
      stream: db.watchShelfById(shelfId),
      builder: (context, shelfSnapshot) {
        if (!shelfSnapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final shelf = shelfSnapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(shelf.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ShelfFormScreen(existing: shelf),
                )),
              ),
            ],
          ),
          body: StreamBuilder<List<Terrarium>>(
            stream: db.watchTerrariumsForShelf(shelfId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final terrariums = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ShelfVisualization(
                  shelf: shelf,
                  terrariums: terrariums,
                  onMove: ({
                    required moving,
                    required targetLevel,
                    required targetPositionInLevel,
                    required stackOnTarget,
                  }) =>
                      _handleMove(
                    context,
                    shelf,
                    terrariums,
                    moving: moving,
                    targetLevel: targetLevel,
                    targetPositionInLevel: targetPositionInLevel,
                    stackOnTarget: stackOnTarget,
                  ),
                  onTapTerrarium: (t) => _showTerrariumSheet(context, shelf, t),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TerrariumFormScreen(preselectedShelfId: shelfId),
            )),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
