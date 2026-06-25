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
  final Set<ActivityCategory> _categoryFilter = {...ActivityCategory.values};

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('All activities')),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in ActivityCategory.values)
                      FilterChip(
                        label: Text(category.label),
                        selected: _categoryFilter.contains(category),
                        onSelected: (sel) => setState(() {
                          if (sel) {
                            _categoryFilter.add(category);
                          } else {
                            _categoryFilter.remove(category);
                          }
                        }),
                      ),
                  ],
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
