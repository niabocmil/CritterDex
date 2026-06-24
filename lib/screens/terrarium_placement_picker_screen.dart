import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';

class PlacementChoice {
  PlacementChoice({
    required this.level,
    required this.positionXCm,
    this.stackOnTarget,
  });
  final int level;
  final double positionXCm;

  /// The existing item whose column to stack on, or null for a fresh column
  /// appended after the last occupied one.
  final ShelfItem? stackOnTarget;
}

String _itemKey(ShelfItem item) => '${item.kind.name}_${item.id}';

/// Lets the user manually choose a level, and either "add a new column at
/// the end of that level" or "stack on top of an existing column". Pops
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
  /// "stack on" choices and from column calculations.
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

  double _stackHeight(List<ShelfItem> column) =>
      column.fold<double>(0.0, (sum, i) => sum + i.itemHeightCm);

  String _columnLabel(List<ShelfItem> column, List<ShelfItem> allOnShelf) {
    final bottom = column.first;
    if (bottom is TerrariumShelfItem) {
      return shelfLabelFor(bottom.terrarium, widget.shelf, allOnShelf);
    }
    return (bottom as ToolShelfItem).tool.name;
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
          final columns = columnsForLevel(all, _level);
          final stackOnColumn = _stackOnKey == null
              ? null
              : columns.firstWhere(
                  (col) => col.any((i) => _itemKey(i) == _stackOnKey),
                  orElse: () => const []);

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
                }),
              ),
              const SizedBox(height: 18),
              Text(
                columns.isEmpty
                    ? 'This level is currently empty.'
                    : '${columns.length} occupied column(s) in this level.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              SegmentedButton<bool>(
                segments: [
                  const ButtonSegment(
                      value: false, label: Text('Add to end of level')),
                  ButtonSegment(
                      value: true,
                      label: const Text('Stack on existing'),
                      enabled: columns.isNotEmpty),
                ],
                selected: {_stackOnKey != null},
                onSelectionChanged: (selection) => setState(() {
                  _stackOnKey =
                      selection.first ? _itemKey(columns.first.first) : null;
                }),
              ),
              if (_stackOnKey != null) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _stackOnKey,
                  decoration: const InputDecoration(labelText: 'Stack on'),
                  items: [
                    for (final column in columns)
                      DropdownMenuItem(
                        value: _itemKey(column.first),
                        enabled: _stackHeight(column) + widget.newHeightCm <=
                            widget.shelf.levelHeightCm,
                        child: Text(_stackHeight(column) + widget.newHeightCm >
                                widget.shelf.levelHeightCm
                            ? '${_columnLabel(column, all)} (too tall)'
                            : _columnLabel(column, all)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _stackOnKey = v),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (stackOnColumn != null && stackOnColumn.isNotEmpty) {
                    Navigator.of(context).pop(PlacementChoice(
                      level: _level,
                      positionXCm: stackOnColumn.first.positionXCm!,
                      stackOnTarget: stackOnColumn.first,
                    ));
                  } else {
                    final lastEnd = columns.isEmpty
                        ? 0.0
                        : columns.last.first.positionXCm! +
                            columns.last
                                .map((i) => i.footprintCm)
                                .reduce((a, b) => a > b ? a : b) +
                            minGapCm;
                    Navigator.of(context).pop(PlacementChoice(
                      level: _level,
                      positionXCm: lastEnd,
                    ));
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
