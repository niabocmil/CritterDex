import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/replenish.dart';
import '../models/terrarium_layout.dart';
import '../models/terrarium_placement.dart';
import '../widgets/shelf_visualization.dart';
import '../widgets/specimen_avatar.dart';
import 'shelf_form_screen.dart';
import 'specimen_detail_screen.dart';
import 'specimen_form_screen.dart';
import 'terrarium_form_screen.dart';
import 'tool_form_screen.dart';

class ShelfDetailScreen extends StatefulWidget {
  const ShelfDetailScreen({super.key, required this.shelfId});

  final int shelfId;

  @override
  State<ShelfDetailScreen> createState() => _ShelfDetailScreenState();
}

class _ShelfDetailScreenState extends State<ShelfDetailScreen> {
  SpecimenIconType? _highlightIconType;

  void _showHighlightSheet(
      BuildContext context, Set<SpecimenIconType> presentTypes) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Highlight by species',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (presentTypes.isEmpty)
                  Text('No specimens on this shelf yet.',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in presentTypes)
                        ChoiceChip(
                          label: Text(type.label),
                          selected: _highlightIconType == type,
                          onSelected: (_) {
                            setState(() => _highlightIconType = type);
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  ),
                if (_highlightIconType != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() => _highlightIconType = null);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear highlight'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMove(
    BuildContext context,
    Shelf shelf,
    List<Terrarium> terrariums,
    List<Tool> tools, {
    required ShelfItem moving,
    required int targetLevel,
    required double targetPositionXCm,
    ShelfItem? stackOnTarget,
  }) async {
    final db = context.read<AppDatabase>();
    final allItems = <ShelfItem>[
      ...terrariums.map(TerrariumShelfItem.new),
      ...tools.map(ToolShelfItem.new),
    ];
    try {
      final updates = planMove(
        moving: moving,
        targetShelf: shelf,
        targetLevel: targetLevel,
        targetPositionXCm: targetPositionXCm,
        stackOnTarget: stackOnTarget,
        sourceShelfItems: allItems,
        targetShelfItems: allItems,
      );
      await db.transaction(() async {
        for (final u in updates) {
          if (u.kind == ShelfItemKind.terrarium) {
            final t = terrariums.firstWhere((t) => t.id == u.id);
            await db.updateTerrarium(t.copyWith(
              shelfId: drift.Value(u.shelfId),
              level: drift.Value(u.level),
              positionXCm: drift.Value(u.positionXCm),
              supportId: drift.Value(u.supportId),
              supportKind: drift.Value(u.supportKind),
            ));
          } else {
            final tool = tools.firstWhere((t) => t.id == u.id);
            await db.updateTool(tool.copyWith(
              shelfId: u.shelfId,
              level: u.level,
              positionXCm: u.positionXCm,
              supportId: drift.Value(u.supportId),
              supportKind: drift.Value(u.supportKind),
            ));
          }
        }
      });
    } on MoveException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _showTerrariumSheet(BuildContext context, Shelf shelf,
      Terrarium terrarium, List<ShelfItem> allOnShelf) {
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
                if (specimens.isEmpty) {
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Empty terrarium',
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_outlined),
                            tooltip: 'Duplicate',
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => TerrariumFormScreen(
                                    duplicateFrom: terrarium),
                              ));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Move to bin',
                            onPressed: () => _confirmDeleteTerrarium(
                                context, db, shelf, terrarium, allOnShelf, 0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('Assign existing specimen'),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showAssignSpecimenSheet(context, terrarium);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Add new specimen'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SpecimenFormScreen(
                                prefillTerrariumId: terrarium.id),
                          ));
                        },
                      ),
                    ],
                  );
                }
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            labelFor(terrarium, shelf, allOnShelf),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_outlined),
                          tooltip: 'Duplicate',
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  TerrariumFormScreen(duplicateFrom: terrarium),
                            ));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Move to bin',
                          onPressed: () => _confirmDeleteTerrarium(context, db,
                              shelf, terrarium, allOnShelf, specimens.length),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${terrarium.volumeLitres.toStringAsFixed(1)} L · ${terrarium.shape}'),
                    const Divider(height: 24),
                    for (final s in specimens)
                      ListTile(
                        leading: SpecimenAvatar(
                          iconType: SpecimenIconType.fromValue(s.speciesIconKey),
                          beetleFamily: BeetleFamily.fromValue(s.beetleFamily),
                          lifeStage: BeetleLifeStage.fromValue(s.lifeStage),
                        ),
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

  void _confirmDeleteTerrarium(
      BuildContext context,
      AppDatabase db,
      Shelf shelf,
      Terrarium terrarium,
      List<ShelfItem> allOnShelf,
      int specimenCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Move to bin?'),
        content: Text(specimenCount > 0
            ? 'This terrarium will be moved to the bin. Its $specimenCount assigned '
                'specimen${specimenCount == 1 ? '' : 's'} will stay assigned to it. '
                'You can restore it from More > Bin within 30 days, after which it is '
                'permanently deleted.'
            : 'This terrarium will be moved to the bin. You can restore it from '
                'More > Bin within 30 days, after which it is permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              // Anything resting directly on this terrarium drops to the
              // floor instead of blocking the delete.
              final detachUpdates = planDetach(
                removed: TerrariumShelfItem(terrarium),
                shelf: shelf,
                shelfItems: allOnShelf,
              );
              await db.transaction(() async {
                for (final u in detachUpdates) {
                  if (u.kind == ShelfItemKind.terrarium) {
                    final t = allOnShelf
                        .whereType<TerrariumShelfItem>()
                        .firstWhere((i) => i.id == u.id)
                        .terrarium;
                    await db.updateTerrarium(t.copyWith(
                      positionXCm: drift.Value(u.positionXCm),
                      supportId: const drift.Value(null),
                      supportKind: const drift.Value(null),
                    ));
                  } else {
                    final tool = allOnShelf
                        .whereType<ToolShelfItem>()
                        .firstWhere((i) => i.id == u.id)
                        .tool;
                    await db.updateTool(tool.copyWith(
                      positionXCm: u.positionXCm,
                      supportId: const drift.Value(null),
                      supportKind: const drift.Value(null),
                    ));
                  }
                }
                await db.softDeleteTerrarium(terrarium.id);
              });
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Move to bin'),
          ),
        ],
      ),
    );
  }

  void _showAssignSpecimenSheet(BuildContext context, Terrarium terrarium) {
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
            return FutureBuilder<List<Specimen>>(
              future: db.getAllSpecimens(),
              builder: (context, snapshot) {
                final unassigned = (snapshot.data ?? const [])
                    .where((s) => s.terrariumId == null)
                    .toList();
                if (unassigned.isEmpty) {
                  return const Center(
                      child: Text('No unassigned specimens available.'));
                }
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Assign a specimen',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final s in unassigned)
                      ListTile(
                        leading: SpecimenAvatar(
                          iconType: SpecimenIconType.fromValue(s.speciesIconKey),
                          beetleFamily: BeetleFamily.fromValue(s.beetleFamily),
                          lifeStage: BeetleLifeStage.fromValue(s.lifeStage),
                        ),
                        title: Text(s.name?.isNotEmpty == true ? s.name! : s.species),
                        subtitle: Text(s.species),
                        onTap: () async {
                          await db.updateSpecimen(
                              s.copyWith(terrariumId: drift.Value(terrarium.id)));
                          if (context.mounted) Navigator.of(context).pop();
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
      stream: db.watchShelfById(widget.shelfId),
      builder: (context, shelfSnapshot) {
        if (!shelfSnapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final shelf = shelfSnapshot.data!;
        return Scaffold(
          body: StreamBuilder<List<Terrarium>>(
            stream: db.watchTerrariumsForShelf(widget.shelfId),
            builder: (context, terrariumSnapshot) {
              if (!terrariumSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final terrariums = terrariumSnapshot.data!;
              return StreamBuilder<List<Tool>>(
                stream: db.watchToolsForShelf(widget.shelfId),
                builder: (context, toolSnapshot) {
                  final tools = toolSnapshot.data ?? const <Tool>[];
                  return StreamBuilder<List<Specimen>>(
                    stream: db.watchSpecimensForShelf(widget.shelfId),
                    builder: (context, specimenSnapshot) {
                      final specimens =
                          specimenSnapshot.data ?? const <Specimen>[];
                      final specimensByTerrariumId = <int, List<Specimen>>{};
                      for (final s in specimens) {
                        specimensByTerrariumId
                            .putIfAbsent(s.terrariumId!, () => [])
                            .add(s);
                      }
                      final allOnShelf = <ShelfItem>[
                        ...terrariums.map(TerrariumShelfItem.new),
                        ...tools.map(ToolShelfItem.new),
                      ];
                      final replenishDueCount =
                          specimens.where(isReplenishDue).length;
                      final presentIconTypes = specimens
                          .map((s) =>
                              SpecimenIconType.fromValue(s.speciesIconKey))
                          .toSet();

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: SizedBox.expand(
                              child: ShelfVisualization(
                                shelf: shelf,
                                terrariums: terrariums,
                                tools: tools,
                                specimensByTerrariumId: specimensByTerrariumId,
                                highlightIconType: _highlightIconType,
                                onMove: ({
                                  required moving,
                                  required targetLevel,
                                  required targetPositionXCm,
                                  stackOnTarget,
                                }) =>
                                    _handleMove(
                                  context,
                                  shelf,
                                  terrariums,
                                  tools,
                                  moving: moving,
                                  targetLevel: targetLevel,
                                  targetPositionXCm: targetPositionXCm,
                                  stackOnTarget: stackOnTarget,
                                ),
                                onTapTerrarium: (t) => _showTerrariumSheet(
                                    context, shelf, t, allOnShelf),
                                onTapTool: (tool) => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (_) => ToolFormScreen(
                                            existing: tool))),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: _ShelfOverlayHeader(
                                  shelf: shelf,
                                  terrariumCount: terrariums.length,
                                  replenishDueCount: replenishDueCount,
                                  highlightActive: _highlightIconType != null,
                                  onBack: () => Navigator.of(context).pop(),
                                  onEdit: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => ShelfFormScreen(
                                              existing: shelf))),
                                  onHighlight: () => _showHighlightSheet(
                                      context, presentIconTypes),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TerrariumFormScreen(preselectedShelfId: widget.shelfId),
            )),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

/// Floating translucent pill replacing the old [AppBar] for the immersive
/// fullscreen shelf view: back button, shelf name + compact occupancy
/// caption, edit button.
class _ShelfOverlayHeader extends StatelessWidget {
  const _ShelfOverlayHeader({
    required this.shelf,
    required this.terrariumCount,
    required this.replenishDueCount,
    required this.highlightActive,
    required this.onBack,
    required this.onEdit,
    required this.onHighlight,
  });

  final Shelf shelf;
  final int terrariumCount;
  final int replenishDueCount;
  final bool highlightActive;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onHighlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final caption = replenishDueCount > 0
        ? '$terrariumCount terrarium(s) · $replenishDueCount to replenish today'
        : '$terrariumCount terrarium(s) in use';
    return Material(
      color: scheme.surface.withValues(alpha: 0.9),
      elevation: 2,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(shelf.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    caption,
                    style: TextStyle(
                      fontSize: 12,
                      color: replenishDueCount > 0
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                      fontWeight:
                          replenishDueCount > 0 ? FontWeight.w600 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_alt_outlined,
                  color: highlightActive ? scheme.primary : null),
              tooltip: 'Highlight by species',
              onPressed: onHighlight,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
