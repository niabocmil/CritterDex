import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';

class PlacementChoice {
  PlacementChoice({
    required this.level,
    required this.positionInLevel,
    required this.stackOnTarget,
  });
  final int level;
  final int positionInLevel;
  final bool stackOnTarget;
}

/// Lets the user manually choose a level, and either "add to the end of
/// that level" or "stack on top of an existing terrarium in that level".
/// Pops with a [PlacementChoice], or null if cancelled.
class TerrariumPlacementPickerScreen extends StatefulWidget {
  const TerrariumPlacementPickerScreen({
    super.key,
    required this.shelf,
    this.excludeTerrariumId,
  });

  final Shelf shelf;

  /// When repositioning an existing terrarium, exclude it from the "stack on"
  /// choices and from slot-count calculations.
  final int? excludeTerrariumId;

  @override
  State<TerrariumPlacementPickerScreen> createState() =>
      _TerrariumPlacementPickerScreenState();
}

class _TerrariumPlacementPickerScreenState
    extends State<TerrariumPlacementPickerScreen> {
  int _level = 1;
  int? _stackOnTerrariumId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose position')),
      body: FutureBuilder<List<Terrarium>>(
        future: db.getTerrariumsForShelf(widget.shelf.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!
              .where((t) => t.id != widget.excludeTerrariumId)
              .toList();
          final slotsInLevel = slotsForLevel(all, _level);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<int>(
                initialValue: _level,
                decoration: const InputDecoration(labelText: 'Level'),
                items: [
                  for (var l = 1; l <= widget.shelf.levelCount; l++)
                    DropdownMenuItem(value: l, child: Text('Level $l')),
                ],
                onChanged: (v) => setState(() {
                  _level = v ?? 1;
                  _stackOnTerrariumId = null;
                }),
              ),
              const SizedBox(height: 18),
              Text(
                slotsInLevel.isEmpty
                    ? 'This level is currently empty.'
                    : '${slotsInLevel.length} occupied slot(s) in this level.',
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
                      enabled: slotsInLevel.isNotEmpty),
                ],
                selected: {_stackOnTerrariumId != null},
                onSelectionChanged: (selection) => setState(() {
                  _stackOnTerrariumId =
                      selection.first ? slotsInLevel.first.last.id : null;
                }),
              ),
              if (_stackOnTerrariumId != null) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _stackOnTerrariumId,
                  decoration: const InputDecoration(labelText: 'Stack on'),
                  items: [
                    for (final slot in slotsInLevel)
                      DropdownMenuItem(
                        value: slot.last.id,
                        child: Text(shelfLabelFor(slot.last, widget.shelf)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _stackOnTerrariumId = v),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (_stackOnTerrariumId != null) {
                    final positionInLevel = slotsInLevel.indexWhere(
                        (slot) => slot.any((t) => t.id == _stackOnTerrariumId));
                    Navigator.of(context).pop(PlacementChoice(
                      level: _level,
                      positionInLevel: positionInLevel,
                      stackOnTarget: true,
                    ));
                  } else {
                    Navigator.of(context).pop(PlacementChoice(
                      level: _level,
                      positionInLevel: slotsInLevel.length,
                      stackOnTarget: false,
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
