import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/specimen_card.dart';
import 'specimen_detail_screen.dart';
import 'specimen_form_screen.dart';

enum _SortOption {
  latest,
  name,
  age,
  weight;

  String get label => switch (this) {
        _SortOption.latest => 'Latest',
        _SortOption.name => 'Name',
        _SortOption.age => 'Age',
        _SortOption.weight => 'Weight',
      };
}

class SpecimenListScreen extends StatefulWidget {
  const SpecimenListScreen({super.key});

  @override
  State<SpecimenListScreen> createState() => _SpecimenListScreenState();
}

class _SpecimenListScreenState extends State<SpecimenListScreen> {
  String _query = '';
  SpecimenStatus? _statusFilter;
  _SortOption _sort = _SortOption.latest;
  Set<String> _speciesFilter = {};
  Set<SpecimenSex> _sexFilter = {};

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

  void _showFilterSheet(BuildContext context, List<String> allSpecies) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Species', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final species in allSpecies)
                        FilterChip(
                          label: Text(species),
                          selected: _speciesFilter.contains(species),
                          onSelected: (sel) => setSheetState(() => setState(() {
                            if (sel) {
                              _speciesFilter.add(species);
                            } else {
                              _speciesFilter.remove(species);
                            }
                          })),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Sex', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sex in SpecimenSex.values)
                        FilterChip(
                          label: Text(sex.label),
                          selected: _sexFilter.contains(sex),
                          onSelected: (sel) => setSheetState(() => setState(() {
                            if (sel) {
                              _sexFilter.add(sex);
                            } else {
                              _sexFilter.remove(sex);
                            }
                          })),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setSheetState(() => setState(() {
                        _speciesFilter = {};
                        _sexFilter = {};
                      })),
                      child: const Text('Clear filters'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  List<Specimen> _sortSpecimens(List<Specimen> list) {
    final sorted = [...list];
    switch (_sort) {
      case _SortOption.latest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.name:
        sorted.sort((a, b) =>
            (a.name?.isNotEmpty == true ? a.name! : a.species)
                .toLowerCase()
                .compareTo((b.name?.isNotEmpty == true ? b.name! : b.species)
                    .toLowerCase()));
      case _SortOption.age:
        sorted.sort((a, b) {
          if (a.dateOfBirth == null && b.dateOfBirth == null) return 0;
          if (a.dateOfBirth == null) return 1; // unknown age always last
          if (b.dateOfBirth == null) return -1;
          return a.dateOfBirth!.compareTo(b.dateOfBirth!); // oldest first
        });
      case _SortOption.weight:
        sorted.sort((a, b) {
          if (a.weightGrams == null && b.weightGrams == null) return 0;
          if (a.weightGrams == null) return 1; // unknown weight always last
          if (b.weightGrams == null) return -1;
          return b.weightGrams!.compareTo(a.weightGrams!); // heaviest first
        });
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specimens'),
        actions: [
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            initialValue: _sort,
            onSelected: (option) => setState(() => _sort = option),
            itemBuilder: (context) => [
              for (final option in _SortOption.values)
                PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      if (_sort == option) ...[
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 8),
                      ] else
                        const SizedBox(width: 26),
                      Text(option.label),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name or species',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) =>
                        setState(() => _query = v.trim().toLowerCase()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: StreamBuilder<List<Specimen>>(
              stream: db.watchAllSpecimens(),
              builder: (context, snapshot) {
                final all = snapshot.data ?? const [];
                final allSpecies = all.map((s) => s.species).toSet().toList()
                  ..sort();
                final filtersActive =
                    _speciesFilter.isNotEmpty || _sexFilter.isNotEmpty;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _filterChip(null, 'All'),
                    const SizedBox(width: 8),
                    for (final status in SpecimenStatus.values) ...[
                      _filterChip(status, status.label),
                      const SizedBox(width: 8),
                    ],
                    const SizedBox(width: 4),
                    ActionChip(
                      avatar: Icon(Icons.filter_list,
                          size: 16,
                          color: filtersActive
                              ? Theme.of(context).colorScheme.primary
                              : null),
                      label: const Text('Categories'),
                      onPressed: () => _showFilterSheet(context, allSpecies),
                    ),
                  ],
                );
              },
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
                  final matchesSpecies = _speciesFilter.isEmpty ||
                      _speciesFilter.contains(s.species);
                  final matchesSex = _sexFilter.isEmpty ||
                      _sexFilter.contains(SpecimenSex.fromValue(s.sex));
                  return matchesQuery &&
                      matchesStatus &&
                      matchesSpecies &&
                      matchesSex;
                }).toList();
                final sorted = _sortSpecimens(filtered);

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (sorted.isEmpty) {
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
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final specimen = sorted[index];
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
