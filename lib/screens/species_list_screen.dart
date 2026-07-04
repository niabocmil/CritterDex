import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/specimen_avatar.dart';
import 'species_detail_screen.dart';

/// One card per distinct species name within [iconFilter] (or every species
/// when null), showing the highest recorded length and the status of the
/// most recently added specimen.
class SpeciesListScreen extends StatelessWidget {
  const SpeciesListScreen({super.key, this.iconFilter});

  final SpecimenIconType? iconFilter;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: Text(iconFilter?.label ?? 'All species')),
      body: StreamBuilder<List<Specimen>>(
        stream: db.watchAllSpecimens(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <Specimen>[];
          final scoped = iconFilter == null
              ? all
              : all
                  .where((s) =>
                      SpecimenIconType.fromValue(s.speciesIconKey) ==
                      iconFilter)
                  .toList();
          final bySpecies = <String, List<Specimen>>{};
          for (final s in scoped) {
            bySpecies.putIfAbsent(s.species, () => []).add(s);
          }
          final speciesNames = bySpecies.keys.toList()..sort();

          if (speciesNames.isEmpty) {
            return Center(
              child: Text('No species collected here yet.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: speciesNames.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final species = speciesNames[index];
              final specimens = bySpecies[species]!;
              double? longest;
              for (final s in specimens) {
                if (s.sizeMm != null && (longest == null || s.sizeMm! > longest)) {
                  longest = s.sizeMm!;
                }
              }
              final latest = specimens
                  .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
              final latestStatus = SpecimenStatus.fromValue(latest.status);
              final repr = specimens.first;

              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SpeciesDetailScreen(species: species),
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        SpecimenAvatar(
                          iconType:
                              SpecimenIconType.fromValue(repr.speciesIconKey),
                          beetleFamily: BeetleFamily.fromValue(repr.beetleFamily),
                          radius: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(species,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                longest == null
                                    ? '${specimens.length} specimen(s)'
                                    : 'Longest: ${longest.toStringAsFixed(1)} mm · ${specimens.length} specimen(s)',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(latestStatus.label,
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
