import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';

class ShelfFormScreen extends StatefulWidget {
  const ShelfFormScreen({super.key, this.existing});

  final Shelf? existing;

  @override
  State<ShelfFormScreen> createState() => _ShelfFormScreenState();
}

class _ShelfFormScreenState extends State<ShelfFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  final _lengthController = TextEditingController();
  final _levelCountController = TextEditingController(text: '1');
  final _levelHeightController = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _labelController.text = existing.label;
      _lengthController.text = existing.lengthCm.toString();
      _levelCountController.text = existing.levelCount.toString();
      _levelHeightController.text = existing.levelHeightCm.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _lengthController.dispose();
    _levelCountController.dispose();
    _levelHeightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final db = context.read<AppDatabase>();
    final length = double.parse(_lengthController.text.trim());
    final levelCount = int.parse(_levelCountController.text.trim());
    final levelHeight = double.parse(_levelHeightController.text.trim());
    try {
      if (_isEditing) {
        await db.updateShelf(widget.existing!.copyWith(
          name: _nameController.text.trim(),
          label: _labelController.text.trim(),
          lengthCm: length,
          levelCount: levelCount,
          levelHeightCm: levelHeight,
        ));
      } else {
        await db.insertShelf(ShelvesCompanion.insert(
          name: _nameController.text.trim(),
          label: _labelController.text.trim(),
          lengthCm: length,
          levelCount: levelCount,
          levelHeightCm: levelHeight,
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Enter a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit shelf' : 'New shelf'),
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
              decoration: const InputDecoration(labelText: 'Shelf name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                  labelText: 'Shelf label *',
                  hintText: 'Short code, e.g. "A"'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lengthController,
              decoration:
                  const InputDecoration(labelText: 'Shelf length (cm) *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _levelCountController,
              decoration: const InputDecoration(labelText: 'Number of levels *'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = int.tryParse(v.trim());
                if (n == null || n < 1) return 'Enter a whole number >= 1';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _levelHeightController,
              decoration: const InputDecoration(
                  labelText: 'Level height (cm) *',
                  hintText: 'Same height applied to every level'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _requiredNumber,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEditing ? 'Save changes' : 'Create shelf'),
            ),
          ],
        ),
      ),
    );
  }
}
