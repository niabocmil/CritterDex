import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';

class BreedingFormScreen extends StatefulWidget {
  const BreedingFormScreen({super.key});

  @override
  State<BreedingFormScreen> createState() => _BreedingFormScreenState();
}

class _BreedingFormScreenState extends State<BreedingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  int? _motherId;
  int? _fatherId;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 50),
      lastDate: DateTime.now(),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_motherId == null || _fatherId == null) return;
    setState(() => _saving = true);
    final db = context.read<AppDatabase>();
    try {
      await db.insertBreedingEvent(BreedingEventsCompanion.insert(
        motherId: _motherId!,
        fatherId: _fatherId!,
        date: _date,
        notes: Value(_notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim()),
      ));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log breeding event'),
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
      body: FutureBuilder<List<Specimen>>(
        future: db.getAllSpecimens(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <Specimen>[];
          final mothers =
              all.where((s) => s.sex == SpecimenSex.female.name).toList();
          final fathers =
              all.where((s) => s.sex == SpecimenSex.male.name).toList();

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (mothers.isEmpty || fathers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'You need at least one specimen marked Female and one '
                      'marked Male before logging a breeding event.',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ),
                DropdownButtonFormField<int>(
                  initialValue: _motherId,
                  decoration: const InputDecoration(labelText: 'Mother *'),
                  items: mothers
                      .map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name?.isNotEmpty == true
                              ? m.name!
                              : m.species)))
                      .toList(),
                  onChanged: (v) => setState(() => _motherId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: _fatherId,
                  decoration: const InputDecoration(labelText: 'Father *'),
                  items: fathers
                      .map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.name?.isNotEmpty == true
                              ? f.name!
                              : f.species)))
                      .toList(),
                  onChanged: (v) => setState(() => _fatherId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save event'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
