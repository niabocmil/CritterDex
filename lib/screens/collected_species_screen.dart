import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/icon_resolver.dart';
import 'species_list_screen.dart';

/// Entry point for the "Collected Species" section: one card per icon
/// category that has at least one specimen, plus an "All" card, each
/// showing how many distinct species names fall under it.
class CollectedSpeciesScreen extends StatelessWidget {
  const CollectedSpeciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Collected Species')),
      body: StreamBuilder<List<Specimen>>(
        stream: db.watchAllSpecimens(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <Specimen>[];
          if (all.isEmpty) {
            return Center(
              child: Text('No specimens recorded yet.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            );
          }
          final presentTypes = all
              .map((s) => SpecimenIconType.fromValue(s.speciesIconKey))
              .toSet()
              .toList()
            ..sort((a, b) => a.label.compareTo(b.label));
          final totalSpecies = all.map((s) => s.species).toSet().length;

          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _CategoryCard(
                icon: const ResolvedFaIcon(FontAwesomeIcons.paw),
                label: 'All',
                count: totalSpecies,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SpeciesListScreen(),
                )),
              ),
              for (final type in presentTypes)
                _CategoryCard(
                  icon: resolveSpecimenIcon(type: type),
                  label: type.label,
                  count: all
                      .where((s) =>
                          SpecimenIconType.fromValue(s.speciesIconKey) == type)
                      .map((s) => s.species)
                      .toSet()
                      .length,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SpeciesListScreen(iconFilter: type),
                  )),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final ResolvedIcon icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              switch (icon) {
                ResolvedFaIcon(icon: final i) =>
                  FaIcon(i, size: 28, color: scheme.primary),
                ResolvedAssetIcon(assetPath: final path) =>
                  Image.asset(path, width: 32, height: 32),
              },
              const SizedBox(height: 10),
              Text(label,
                  style:
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text('$count species',
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
