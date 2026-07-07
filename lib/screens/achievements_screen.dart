import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/specimen_avatar.dart';
import 'species_detail_screen.dart';

/// Trophy case of every species ever unlocked (see [SpeciesInfos] doc for
/// what "unlocked" means) — separate from Collected Species' browse-by-
/// category view, this is purely a chronological "look what you've found"
/// gallery, most recently unlocked first.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: StreamBuilder<List<SpeciesInfo>>(
        stream: db.watchAllSpeciesInfo(),
        builder: (context, infoSnapshot) {
          final infos = infoSnapshot.data ?? const <SpeciesInfo>[];
          if (infos.isEmpty) {
            return Center(
              child: Text('No species unlocked yet.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            );
          }
          return StreamBuilder<List<Specimen>>(
            stream: db.watchAllSpecimens(),
            builder: (context, specimenSnapshot) {
              final specimens = specimenSnapshot.data ?? const <Specimen>[];
              // A species can still be "unlocked" long after every specimen
              // of it is gone (deleted, purged) — this map just gives
              // whichever ones are still around a matching icon instead of
              // the generic trophy fallback.
              final iconBySpecies = <String, Specimen>{
                for (final s in specimens) s.species: s,
              };
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: infos.length,
                itemBuilder: (context, i) {
                  final info = infos[i];
                  final match = iconBySpecies[info.speciesName];
                  return _TrophyCard(info: info, matchingSpecimen: match);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TrophyCard extends StatelessWidget {
  const _TrophyCard({required this.info, this.matchingSpecimen});

  final SpeciesInfo info;
  final Specimen? matchingSpecimen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final specimen = matchingSpecimen;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SpeciesDetailScreen(species: info.speciesName),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: specimen == null
                    ? Icon(Icons.emoji_events,
                        size: 28, color: scheme.onPrimaryContainer)
                    : SpecimenAvatar(
                        iconType:
                            SpecimenIconType.fromValue(specimen.speciesIconKey),
                        beetleFamily:
                            BeetleFamily.fromValue(specimen.beetleFamily),
                        lifeStage:
                            BeetleLifeStage.fromValue(specimen.lifeStage),
                        radius: 28,
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                info.speciesName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 4),
              Text(
                'Unlocked ${DateFormat.yMMMd().format(info.createdAt)}',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
