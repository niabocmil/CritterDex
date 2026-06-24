import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/lineage_utils.dart';
import '../models/replenish.dart';
import '../widgets/specimen_avatar.dart';
import 'lineage_screen.dart';
import 'specimen_form_screen.dart';

String? _formatAge(DateTime? dob) {
  if (dob == null) return null;
  final now = DateTime.now();
  var months = (now.year - dob.year) * 12 + now.month - dob.month;
  if (now.day < dob.day) months -= 1;
  if (months < 1) return '< 1 month';
  if (months < 24) return '$months month${months == 1 ? '' : 's'}';
  final years = months ~/ 12;
  return '$years year${years == 1 ? '' : 's'}';
}

class SpecimenDetailScreen extends StatelessWidget {
  const SpecimenDetailScreen({super.key, required this.specimenId});

  final int specimenId;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      body: StreamBuilder<Specimen>(
        stream: db.watchSpecimenById(specimenId),
        builder: (context, snapshot) {
          final specimen = snapshot.data;
          if (specimen == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final status = SpecimenStatus.fromValue(specimen.status);
          final sex = SpecimenSex.fromValue(specimen.sex);

          return FutureBuilder<List<Specimen>>(
            future: db.getAllSpecimens(),
            builder: (context, allSnapshot) {
              final all = allSnapshot.data ?? const [];
              final byId = {for (final s in all) s.id: s};
              final generation = computeGeneration(specimen.id, byId);
              final parents = directParentsOf(specimen, byId);
              final children = directChildrenOf(specimen.id, all);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 220,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SpecimenFormScreen(existing: specimen),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, db, specimen),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        child: Center(
                          child: SpecimenAvatar(
                            iconType: SpecimenIconType.fromValue(
                                specimen.speciesIconKey),
                            beetleFamily:
                                BeetleFamily.fromValue(specimen.beetleFamily),
                            lifeStage:
                                BeetleLifeStage.fromValue(specimen.lifeStage),
                            radius: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (specimen.name?.isNotEmpty ?? false)
                                ? specimen.name!
                                : specimen.species,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(specimen.species,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                avatar: Icon(sex.icon, size: 16),
                                label: Text(sex.label),
                              ),
                              Chip(
                                avatar: const Icon(Icons.layers_outlined, size: 16),
                                label: Text('Generation $generation'),
                              ),
                              Chip(
                                backgroundColor:
                                    status.color(context).withValues(alpha: 0.15),
                                label: Text(status.label,
                                    style:
                                        TextStyle(color: status.color(context))),
                              ),
                              if (specimen.dateAcquired != null)
                                Chip(
                                  avatar: const Icon(Icons.event, size: 16),
                                  label: Text(DateFormat.yMMMd()
                                      .format(specimen.dateAcquired!)),
                                ),
                              Chip(
                                avatar: const Icon(Icons.cake_outlined, size: 16),
                                label: Text(
                                    _formatAge(specimen.dateOfBirth) ??
                                        'Unknown age'),
                              ),
                              if (specimen.weightGrams != null)
                                Chip(
                                  avatar:
                                      const Icon(Icons.scale_outlined, size: 16),
                                  label: Text(
                                      '${specimen.weightGrams!.toStringAsFixed(1)} g'),
                                ),
                              if (specimen.sizeCm != null)
                                Chip(
                                  avatar: const Icon(Icons.straighten, size: 16),
                                  label: Text(
                                      '${specimen.sizeCm!.toStringAsFixed(1)} cm'),
                                ),
                              if (specimen.lifeStage != null)
                                Chip(
                                  avatar: const Icon(Icons.timeline, size: 16),
                                  label: Text(BeetleLifeStage.fromValue(
                                          specimen.lifeStage)!
                                      .label),
                                ),
                            ],
                          ),
                          if (specimen.photoPath != null) ...[
                            const SizedBox(height: 20),
                            Text('Photo',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(specimen.photoPath!),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton.tonalIcon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    LineageScreen(specimenId: specimen.id),
                              ),
                            ),
                            icon: const Icon(Icons.account_tree_outlined),
                            label: const Text('View family tree'),
                          ),
                          if (specimen.replenishIntervalDays != null) ...[
                            const SizedBox(height: 24),
                            Text('Replenish',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            if (specimen.lastReplenishedAt == null)
                              FilledButton.tonalIcon(
                                onPressed: () => db.updateSpecimen(
                                    specimen.copyWith(
                                        lastReplenishedAt:
                                            Value(DateTime.now()))),
                                icon: const Icon(Icons.water_drop_outlined),
                                label: const Text(
                                    'Start tracking (mark replenished today)'),
                              )
                            else
                              Builder(builder: (context) {
                                final daysLeft = replenishDaysLeft(specimen);
                                final due = daysLeft <= 0;
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Chip(
                                      avatar: Icon(
                                          due
                                              ? Icons.warning_amber
                                              : Icons.water_drop_outlined,
                                          size: 16),
                                      backgroundColor: due
                                          ? Theme.of(context)
                                              .colorScheme
                                              .errorContainer
                                          : null,
                                      label: Text(due
                                          ? 'Replenish now!'
                                          : '$daysLeft day${daysLeft == 1 ? '' : 's'} left'),
                                    ),
                                    TextButton(
                                      onPressed: () => db.updateSpecimen(
                                          specimen.copyWith(
                                              lastReplenishedAt:
                                                  Value(DateTime.now()))),
                                      child:
                                          const Text('Mark replenished today'),
                                    ),
                                  ],
                                );
                              }),
                          ],
                          if (specimen.notes?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 24),
                            Text('Notes',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(specimen.notes!),
                          ],
                          if (parents.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text('Parents',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ..._relativeList(context, parents),
                          ],
                          if (children.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text('Offspring (${children.length})',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ..._relativeList(context, children),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _relativeList(BuildContext context, List<Specimen> relatives) {
    return relatives
        .map((r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: SpecimenAvatar(
                  iconType: SpecimenIconType.fromValue(r.speciesIconKey),
                  beetleFamily: BeetleFamily.fromValue(r.beetleFamily),
                  lifeStage: BeetleLifeStage.fromValue(r.lifeStage),
                  radius: 18),
                title: Text(r.name?.isNotEmpty == true ? r.name! : r.species),
                subtitle: Text(r.species),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SpecimenDetailScreen(specimenId: r.id),
                  ),
                ),
              ),
            ))
        .toList();
  }

  void _confirmDelete(BuildContext context, AppDatabase db, Specimen specimen) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete specimen?'),
        content: Text(
            'This will permanently remove ${specimen.name?.isNotEmpty == true ? specimen.name! : specimen.species}. Records of this specimen as a parent will keep the link but it will no longer resolve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await db.deleteSpecimen(specimen.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
