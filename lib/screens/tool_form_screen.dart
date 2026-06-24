import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';
import '../models/terrarium_placement.dart';
import 'terrarium_placement_picker_screen.dart';

/// Add/edit-tool flow: name + footprint + a free color, always placed on a
/// shelf (no "individual" option — tools only exist on a shelf). Pops with
/// the new/edited tool's id on success, or null if cancelled.
class ToolFormScreen extends StatefulWidget {
  const ToolFormScreen({super.key, this.existing, this.preselectedShelfId});

  final Tool? existing;
  final int? preselectedShelfId;

  @override
  State<ToolFormScreen> createState() => _ToolFormScreenState();
}

class _ToolFormScreenState extends State<ToolFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lengthController = TextEditingController();
  final _heightController = TextEditingController();

  int? _shelfId;
  bool _useAutoPlace = true;
  PlacementChoice? _manualChoice;
  Color _color = Colors.amber;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _lengthController.text = existing.lengthCm.toString();
      _heightController.text = existing.heightCm.toString();
      _shelfId = existing.shelfId;
      _color = Color(existing.colorArgb);
    } else if (widget.preselectedShelfId != null) {
      _shelfId = widget.preselectedShelfId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    var picked = _color;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _color,
            onColorChanged: (c) => picked = c,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Select')),
        ],
      ),
    );
    if (confirmed == true) setState(() => _color = picked);
  }

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Enter a number';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final shelfId = _shelfId;
    if (shelfId == null) return;
    final db = context.read<AppDatabase>();
    final length = double.parse(_lengthController.text.trim());
    final height = double.parse(_heightController.text.trim());
    final name = _nameController.text.trim();

    setState(() => _saving = true);
    try {
      final shelf = await db.getShelfById(shelfId);
      final existingTools = (await db.getToolsForShelf(shelfId))
          .where((t) => t.id != widget.existing?.id)
          .toList();
      final existingTerrariums = await db.getTerrariumsForShelf(shelfId);
      final existingOnShelf = <ShelfItem>[
        ...existingTerrariums.map(TerrariumShelfItem.new),
        ...existingTools.map(ToolShelfItem.new),
      ];

      int level;
      double positionXCm;
      int? supportId;
      String? supportKind;
      var siblingUpdates = const <ShelfPlacementUpdate>[];
      if (_useAutoPlace) {
        try {
          final placement = findAutoPlacement(
            shelf: shelf,
            newFootprintWidthCm: length,
            newHeightCm: height,
            existingOnShelf: existingOnShelf,
          );
          level = placement.level;
          positionXCm = placement.positionXCm;
        } on PlacementException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.message)));
          }
          setState(() => _saving = false);
          return;
        }
      } else {
        final choice = _manualChoice;
        if (choice == null) {
          setState(() => _saving = false);
          return;
        }
        level = choice.level;
        positionXCm = choice.positionXCm;
        supportId = choice.supportId;
        supportKind = choice.supportKind;
        siblingUpdates = choice.siblingUpdates;
      }

      Future<void> applySiblingUpdates() async {
        for (final u in siblingUpdates) {
          if (u.kind == ShelfItemKind.terrarium) {
            final t = existingTerrariums.firstWhere((t) => t.id == u.id);
            await db.updateTerrarium(t.copyWith(
              positionXCm: Value(u.positionXCm),
              supportId: Value(u.supportId),
              supportKind: Value(u.supportKind),
            ));
          } else {
            final tool = existingTools.firstWhere((t) => t.id == u.id);
            await db.updateTool(tool.copyWith(
              positionXCm: u.positionXCm,
              supportId: Value(u.supportId),
              supportKind: Value(u.supportKind),
            ));
          }
        }
      }

      if (_isEditing) {
        await db.transaction(() async {
          await applySiblingUpdates();
          await db.updateTool(widget.existing!.copyWith(
            name: name,
            lengthCm: length,
            heightCm: height,
            colorArgb: _color.toARGB32(),
            shelfId: shelfId,
            level: level,
            positionXCm: positionXCm,
            supportId: Value(supportId),
            supportKind: Value(supportKind),
          ));
        });
        if (mounted) Navigator.of(context).pop(widget.existing!.id);
      } else {
        var id = -1;
        await db.transaction(() async {
          await applySiblingUpdates();
          id = await db.insertTool(ToolsCompanion.insert(
            name: name,
            lengthCm: length,
            heightCm: height,
            colorArgb: _color.toARGB32(),
            shelfId: shelfId,
            level: level,
            positionXCm: positionXCm,
            stackOrder: 0,
            supportId: Value(supportId),
            supportKind: Value(supportKind),
          ));
        });
        if (mounted) Navigator.of(context).pop(id);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit tool' : 'New tool'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lengthController,
              decoration: const InputDecoration(labelText: 'Length (cm) *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm) *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Color'),
              trailing: GestureDetector(
                onTap: _pickColor,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _color,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                ),
              ),
              onTap: _pickColor,
            ),
            const Divider(height: 32),
            Text('Placement', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 14),
            FutureBuilder<List<Shelf>>(
              future: db.getAllShelves(),
              builder: (context, snapshot) {
                final shelves = snapshot.data ?? const <Shelf>[];
                if (shelves.isEmpty) {
                  return Text(
                    'No shelves yet — create one from the Shelf tab first.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _shelfId,
                      decoration: const InputDecoration(labelText: 'Shelf *'),
                      items: shelves
                          .map((s) => DropdownMenuItem(
                              value: s.id, child: Text('${s.label} — ${s.name}')))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _shelfId = v;
                        _manualChoice = null;
                      }),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-place in next empty space'),
                      value: _useAutoPlace,
                      onChanged: (v) => setState(() => _useAutoPlace = v),
                    ),
                    if (!_useAutoPlace) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _shelfId == null
                            ? null
                            : () async {
                                final shelf =
                                    shelves.firstWhere((s) => s.id == _shelfId);
                                final length = double.tryParse(
                                        _lengthController.text.trim()) ??
                                    0;
                                final height = double.tryParse(
                                        _heightController.text.trim()) ??
                                    0;
                                final result = await Navigator.of(context)
                                    .push<PlacementChoice>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TerrariumPlacementPickerScreen(
                                      shelf: shelf,
                                      newFootprintWidthCm: length,
                                      newHeightCm: height,
                                      excludeToolId: widget.existing?.id,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() => _manualChoice = result);
                                }
                              },
                        icon: const Icon(Icons.grid_view),
                        label: Text(_manualChoice == null
                            ? 'Choose position'
                            : 'Level ${levelDisplayLabel(_manualChoice!.level)}, '
                                '${_manualChoice!.stackOnTarget != null ? "stacked" : "new column at ${_manualChoice!.positionXCm.toStringAsFixed(1)}cm"}'),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Save changes' : 'Create tool'),
            ),
          ],
        ),
      ),
    );
  }
}
