import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';

/// Plain edit form for a species' reference info (description, special
/// notes, region, usual length range, temperature range) — one row per
/// species name, created on first save.
class SpeciesInfoFormScreen extends StatefulWidget {
  const SpeciesInfoFormScreen({super.key, required this.species, this.existing});

  final String species;
  final SpeciesInfo? existing;

  @override
  State<SpeciesInfoFormScreen> createState() => _SpeciesInfoFormScreenState();
}

class _SpeciesInfoFormScreenState extends State<SpeciesInfoFormScreen> {
  late final _descriptionController =
      TextEditingController(text: widget.existing?.description);
  late final _specialNotesController =
      TextEditingController(text: widget.existing?.specialNotes);
  late final _regionController =
      TextEditingController(text: widget.existing?.region);
  late final _lengthRangeController =
      TextEditingController(text: widget.existing?.lengthRangeText);
  late final _temperatureRangeController =
      TextEditingController(text: widget.existing?.temperatureRangeText);

  @override
  void dispose() {
    _descriptionController.dispose();
    _specialNotesController.dispose();
    _regionController.dispose();
    _lengthRangeController.dispose();
    _temperatureRangeController.dispose();
    super.dispose();
  }

  String? _orNull(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _save(AppDatabase db) async {
    await db.upsertSpeciesInfo(
      widget.species,
      description: Value(_orNull(_descriptionController.text)),
      specialNotes: Value(_orNull(_specialNotesController.text)),
      region: Value(_orNull(_regionController.text)),
      lengthRangeText: Value(_orNull(_lengthRangeController.text)),
      temperatureRangeText: Value(_orNull(_temperatureRangeController.text)),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.species}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _specialNotesController,
            decoration: const InputDecoration(labelText: "What's special"),
            minLines: 1,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regionController,
            decoration: const InputDecoration(labelText: 'Found in region'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lengthRangeController,
            decoration: const InputDecoration(labelText: 'Usual length range'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _temperatureRangeController,
            decoration: const InputDecoration(labelText: 'Temperature range'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _save(db),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
