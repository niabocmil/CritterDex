import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/specimen_card.dart';
import 'specimen_detail_screen.dart';
import 'specimen_form_screen.dart';

class SpecimenListScreen extends StatefulWidget {
  const SpecimenListScreen({super.key});

  @override
  State<SpecimenListScreen> createState() => _SpecimenListScreenState();
}

class _SpecimenListScreenState extends State<SpecimenListScreen> {
  String _query = '';
  SpecimenStatus? _statusFilter;

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add specimen'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SpecimenFormScreen(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: const Text('Batch create'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SpecimenFormScreen(isBatch: true),
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
    final db = context.watch<AppDatabase>();

    return Scaffold(
      appBar: AppBar(title: const Text('Specimens')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or species',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip(null, 'All'),
                const SizedBox(width: 8),
                for (final status in SpecimenStatus.values) ...[
                  _filterChip(status, status.label),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Specimen>>(
              stream: db.watchAllSpecimens(),
              builder: (context, snapshot) {
                final all = snapshot.data ?? const [];
                final filtered = all.where((s) {
                  final matchesQuery = _query.isEmpty ||
                      s.species.toLowerCase().contains(_query) ||
                      (s.name?.toLowerCase().contains(_query) ?? false);
                  final matchesStatus = _statusFilter == null ||
                      SpecimenStatus.fromValue(s.status) == _statusFilter;
                  return matchesQuery && matchesStatus;
                }).toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      all.isEmpty
                          ? 'No specimens yet.\nTap + to add your first one.'
                          : 'No matches.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final specimen = filtered[index];
                    return SpecimenCard(
                      specimen: specimen,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SpecimenDetailScreen(specimenId: specimen.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(SpecimenStatus? status, String label) {
    final selected = _statusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _statusFilter = status),
    );
  }
}
