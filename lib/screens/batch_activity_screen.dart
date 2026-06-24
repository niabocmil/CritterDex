import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/terrarium_layout.dart';
import '../widgets/specimen_avatar.dart';
import 'specimen_detail_screen.dart';
import 'terrarium_form_screen.dart';

/// Drill-down for a single batch-create [ActivityLogEntry] (a batch of
/// specimens or a batch of terrariums created together) — lists every item
/// in the batch, each tapping through to its own detail/edit screen.
class BatchActivityScreen extends StatelessWidget {
  const BatchActivityScreen({super.key, required this.entry});

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final type = ActivityType.fromValue(entry.type);
    final ids = (jsonDecode(entry.relatedIds ?? '[]') as List)
        .map((e) => e as int)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: type == ActivityType.specimensBatchAdded
          ? _SpecimensList(db: db, ids: ids)
          : _TerrariumsList(db: db, ids: ids),
    );
  }
}

class _SpecimensList extends StatelessWidget {
  const _SpecimensList({required this.db, required this.ids});

  final AppDatabase db;
  final Set<int> ids;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Specimen>>(
      future: db.getAllSpecimens(),
      builder: (context, snapshot) {
        final specimens =
            (snapshot.data ?? const <Specimen>[]).where((s) => ids.contains(s.id)).toList();
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final s in specimens)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: SpecimenAvatar(
                    iconType: SpecimenIconType.fromValue(s.speciesIconKey),
                    beetleFamily: BeetleFamily.fromValue(s.beetleFamily),
                    lifeStage: BeetleLifeStage.fromValue(s.lifeStage),
                  ),
                  title: Text(s.name?.isNotEmpty == true ? s.name! : s.species),
                  subtitle: Text(s.species),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SpecimenDetailScreen(specimenId: s.id),
                  )),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TerrariumsList extends StatelessWidget {
  const _TerrariumsList({required this.db, required this.ids});

  final AppDatabase db;
  final Set<int> ids;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Terrarium>>(
      future: db.getAllTerrariums(),
      builder: (context, terrariumSnapshot) {
        if (!terrariumSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final terrariums = terrariumSnapshot.data!
            .where((t) => ids.contains(t.id))
            .toList();
        return FutureBuilder<List<Shelf>>(
          future: db.getAllShelves(),
          builder: (context, shelfSnapshot) {
            final shelves = shelfSnapshot.data ?? const <Shelf>[];
            return FutureBuilder<List<Tool>>(
              future: db.getAllTools(),
              builder: (context, toolSnapshot) {
                final tools = toolSnapshot.data ?? const <Tool>[];
                final labels =
                    computeAllTerrariumLabels(shelves, terrariums, tools);
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final t in terrariums)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.crop_square_outlined),
                          title: Text(labels[t.id] ?? '?'),
                          subtitle: Text(
                              '${t.volumeLitres.toStringAsFixed(1)} L · ${t.shape}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TerrariumFormScreen(existing: t),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
