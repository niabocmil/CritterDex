import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/activity_tile.dart';

enum _Sort { latest, oldest }

class AllActivitiesScreen extends StatefulWidget {
  const AllActivitiesScreen({super.key});

  @override
  State<AllActivitiesScreen> createState() => _AllActivitiesScreenState();
}

class _AllActivitiesScreenState extends State<AllActivitiesScreen> {
  _Sort _sort = _Sort.latest;
  Set<ActivityCategory> _categoryFilter = {...ActivityCategory.values};

  void _showFilterSheet(BuildContext context) {
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
                  Text('Categories', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in ActivityCategory.values)
                        FilterChip(
                          label: Text(category.label),
                          selected: _categoryFilter.contains(category),
                          onSelected: (sel) => setSheetState(() => setState(() {
                            if (sel) {
                              _categoryFilter.add(category);
                            } else {
                              _categoryFilter.remove(category);
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
                        _categoryFilter = {...ActivityCategory.values};
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

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final filtersActive = _categoryFilter.length < ActivityCategory.values.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All activities'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list,
                color: filtersActive ? Theme.of(context).colorScheme.primary : null),
            tooltip: 'Categories',
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: StreamBuilder<List<ActivityLogEntry>>(
        stream: db.watchAllActivity(),
        builder: (context, snapshot) {
          final entries = [...snapshot.data ?? const <ActivityLogEntry>[]];
          entries.sort((a, b) => _sort == _Sort.latest
              ? b.timestamp.compareTo(a.timestamp)
              : a.timestamp.compareTo(b.timestamp));
          final filtered = entries
              .where((e) => _categoryFilter
                  .contains(ActivityType.fromValue(e.type).category))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SegmentedButton<_Sort>(
                  segments: const [
                    ButtonSegment(value: _Sort.latest, label: Text('Latest')),
                    ButtonSegment(value: _Sort.oldest, label: Text('Oldest')),
                  ],
                  selected: {_sort},
                  onSelectionChanged: (s) => setState(() => _sort = s.first),
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text('No activity yet.',
                            style: Theme.of(context).textTheme.bodyLarge),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Text('No activity matches the selected filters.',
                                style: Theme.of(context).textTheme.bodyLarge),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) =>
                                ActivityTile(entry: filtered[i]),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
