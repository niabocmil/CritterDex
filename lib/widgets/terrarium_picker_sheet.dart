import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/terrarium_layout.dart';

/// Searchable bottom sheet for picking a terrarium (or "None"). Shared by
/// the specimen form's terrarium-assignment step and the specimen detail
/// screen's "Assign to terrarium" action. Pops with the chosen terrarium id,
/// `null` for "None", or returns `null` (unresolved future value) if
/// dismissed without a selection — callers should compare against the
/// specimen's current terrariumId to detect "dismissed vs explicitly None"
/// only if that distinction matters; for assignment flows it usually
/// doesn't.
Future<int?> showTerrariumPickerSheet(
    BuildContext context, AppDatabase db) async {
  final terrariums = await db.getAllTerrariums();
  final shelves = await db.getAllShelves();
  final tools = await db.getAllTools();
  final labels = computeAllTerrariumLabels(shelves, terrariums, tools);

  if (!context.mounted) return null;
  return showModalBottomSheet<int?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      var query = '';
      return StatefulBuilder(builder: (context, setSheetState) {
        final filtered = terrariums.where((t) {
          if (query.isEmpty) return true;
          final label = labels[t.id] ?? '';
          return label.toLowerCase().contains(query.toLowerCase()) ||
              t.shape.toLowerCase().contains(query.toLowerCase());
        }).toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select a terrarium',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search terrarium label',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setSheetState(() => query = v),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.block),
                          title: const Text('None'),
                          onTap: () => Navigator.of(context).pop(null),
                        ),
                        for (final t in filtered)
                          ListTile(
                            leading: const Icon(Icons.crop_square_outlined),
                            title: Text(labels[t.id] ?? '—'),
                            subtitle: Text(
                                '${t.volumeLitres.toStringAsFixed(1)} L · ${t.shape}'),
                            onTap: () => Navigator.of(context).pop(t.id),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      });
    },
  );
}
