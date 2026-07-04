import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';
import '../models/terrarium_placement.dart';

/// A not-yet-created item, used only as [planMove]'s `moving` argument so
/// the picker can reuse the exact same validation/collision logic the drag
/// canvas uses instead of duplicating it. Its id (`-1`) never collides with
/// a real row (autoincrement ids start at 1), so every "exclude the mover
/// from its own siblings" / "who rests on the mover" check in [planMove]
/// naturally finds nothing — there's nothing on the shelf yet for a
/// not-yet-inserted item to conflict with itself over. Which [ShelfItemKind]
/// is reported is therefore inert; terrarium is used unconditionally.
class _NewShelfItem implements ShelfItem {
  _NewShelfItem({required this.footprintCm, required this.itemHeightCm});

  @override
  final double footprintCm;
  @override
  final double itemHeightCm;
  @override
  int get id => -1;
  @override
  ShelfItemKind get kind => ShelfItemKind.terrarium;
  @override
  int? get level => null;
  @override
  double? get positionXCm => null;
  @override
  int? get supportId => null;
  @override
  String? get supportKind => null;
}

/// The chosen placement for a new (not-yet-inserted) terrarium/tool.
/// [siblingUpdates] are cascaded position changes for *existing* items that
/// had to move to make room — apply these in the same transaction as
/// inserting/updating the new item itself.
class PlacementChoice {
  PlacementChoice({
    required this.level,
    required this.positionXCm,
    required this.supportId,
    required this.supportKind,
    required this.stackOnTarget,
    required this.siblingUpdates,
  });
  final int level;
  final double positionXCm;
  final int? supportId;
  final String? supportKind;
  final ShelfItem? stackOnTarget;
  final List<ShelfPlacementUpdate> siblingUpdates;
}

/// Lets the user manually choose a level, an item to rest on (or the shelf
/// floor), and a precise horizontal offset within that span — full manual X
/// control, mirroring drag-and-drop's precision without a drag canvas. Pops
/// with a [PlacementChoice], or null if cancelled. Genericized over
/// [ShelfItem] so it serves both Terrarium and Tool placement.
class TerrariumPlacementPickerScreen extends StatefulWidget {
  const TerrariumPlacementPickerScreen({
    super.key,
    required this.shelf,
    required this.newFootprintWidthCm,
    required this.newHeightCm,
    this.excludeTerrariumId,
    this.excludeToolId,
  });

  final Shelf shelf;
  final double newFootprintWidthCm;
  final double newHeightCm;

  /// When repositioning an existing terrarium/tool, exclude it from the
  /// "rest on" choices and from collision calculations.
  final int? excludeTerrariumId;
  final int? excludeToolId;

  @override
  State<TerrariumPlacementPickerScreen> createState() =>
      _TerrariumPlacementPickerScreenState();
}

class _TerrariumPlacementPickerScreenState
    extends State<TerrariumPlacementPickerScreen> {
  int _level = 1;
  String? _stackOnKey;
  final _offsetController = TextEditingController(text: '0');

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }

  Future<List<ShelfItem>> _loadItems(AppDatabase db) async {
    final terrariums = (await db.getTerrariumsForShelf(widget.shelf.id))
        .where((t) => t.id != widget.excludeTerrariumId)
        .toList();
    final tools = (await db.getToolsForShelf(widget.shelf.id))
        .where((t) => t.id != widget.excludeToolId)
        .toList();
    return [
      ...terrariums.map(TerrariumShelfItem.new),
      ...tools.map(ToolShelfItem.new),
    ];
  }

  String _itemLabel(ShelfItem item, List<ShelfItem> all) {
    if (item is TerrariumShelfItem) {
      return shelfLabelFor(item.terrarium, widget.shelf, all);
    }
    return (item as ToolShelfItem).tool.name;
  }

  PlacementChoice _buildChoice(
      List<ShelfItem> all, ShelfItem? stackTarget, double offsetCm) {
    final mover = _NewShelfItem(
      footprintCm: widget.newFootprintWidthCm,
      itemHeightCm: widget.newHeightCm,
    );
    final updates = planMove(
      moving: mover,
      targetShelf: widget.shelf,
      targetLevel: _level,
      targetPositionXCm: offsetCm,
      stackOnTarget: stackTarget,
      sourceShelfItems: all,
      targetShelfItems: all,
    );
    final moverUpdate = updates.firstWhere(
      (u) => u.id == -1,
      // planMove should always include the mover's own update; falling back
      // to a MoveException (already handled by the caller) instead of an
      // uncaught StateError if that assumption is ever wrong.
      orElse: () =>
          throw MoveException('Could not compute a valid position here.'),
    );
    final siblingUpdates = updates.where((u) => u.id != -1).toList();
    return PlacementChoice(
      level: moverUpdate.level,
      positionXCm: moverUpdate.positionXCm,
      supportId: moverUpdate.supportId,
      supportKind: moverUpdate.supportKind,
      stackOnTarget: stackTarget,
      siblingUpdates: siblingUpdates,
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose position')),
      body: FutureBuilder<List<ShelfItem>>(
        future: _loadItems(db),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          final itemsAtLevel = all.where((i) => i.level == _level).toList();
          final geometry = resolveLevelGeometry(itemsAtLevel);

          ShelfItem? stackTarget;
          if (_stackOnKey != null) {
            for (final item in itemsAtLevel) {
              if (shelfItemKey(item) == _stackOnKey) {
                stackTarget = item;
                break;
              }
            }
          }

          final maxOffset = stackTarget != null
              ? (stackTarget.footprintCm - widget.newFootprintWidthCm)
                  .clamp(0.0, double.infinity)
              : (widget.shelf.lengthCm - widget.newFootprintWidthCm)
                  .clamp(0.0, double.infinity);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<int>(
                initialValue: _level,
                decoration: const InputDecoration(labelText: 'Level'),
                items: [
                  for (var l = 1; l <= widget.shelf.levelCount; l++)
                    DropdownMenuItem(
                        value: l, child: Text(levelDisplayLabel(l))),
                ],
                onChanged: (v) => setState(() {
                  _level = v ?? 1;
                  _stackOnKey = null;
                  _offsetController.text = '0';
                }),
              ),
              const SizedBox(height: 18),
              Text(
                itemsAtLevel.isEmpty
                    ? 'This level is currently empty.'
                    : '${itemsAtLevel.length} item(s) on this level.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String?>(
                initialValue: _stackOnKey,
                decoration: const InputDecoration(labelText: 'Rest on'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Shelf floor')),
                  for (final item in itemsAtLevel)
                    DropdownMenuItem(
                      value: shelfItemKey(item),
                      enabled: item.footprintCm >= widget.newFootprintWidthCm &&
                          (geometry[shelfItemKey(item)]?.topHeightCm ?? 0) +
                                  widget.newHeightCm <=
                              widget.shelf.levelHeightCm,
                      child: Text(
                        item.footprintCm < widget.newFootprintWidthCm
                            ? '${_itemLabel(item, all)} (too small)'
                            : (geometry[shelfItemKey(item)]?.topHeightCm ??
                                            0) +
                                        widget.newHeightCm >
                                    widget.shelf.levelHeightCm
                                ? '${_itemLabel(item, all)} (too tall)'
                                : _itemLabel(item, all),
                      ),
                    ),
                ],
                onChanged: (v) => setState(() {
                  _stackOnKey = v;
                  _offsetController.text = '0';
                }),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _offsetController,
                decoration: InputDecoration(
                  labelText: stackTarget == null
                      ? 'Position on shelf (cm)'
                      : 'Position on ${_itemLabel(stackTarget, all)} (cm)',
                  helperText: 'Up to ${maxOffset.toStringAsFixed(1)} cm',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  final raw =
                      double.tryParse(_offsetController.text.trim()) ?? 0.0;
                  final offset = raw.clamp(0.0, maxOffset);
                  try {
                    Navigator.of(context)
                        .pop(_buildChoice(all, stackTarget, offset));
                  } on MoveException catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.message)));
                  }
                },
                child: const Text('Confirm position'),
              ),
            ],
          );
        },
      ),
    );
  }
}
