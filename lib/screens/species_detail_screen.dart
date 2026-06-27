import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/specimen_avatar.dart';
import 'specimen_detail_screen.dart';
import 'species_info_form_screen.dart';

const _gold = Color(0xFFFFD54F);
const _onGold = Colors.black87;

class SpeciesDetailScreen extends StatefulWidget {
  const SpeciesDetailScreen({super.key, required this.species});

  final String species;

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  bool _showAllSpecimens = false;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.species)),
      body: StreamBuilder<List<Specimen>>(
        stream: db.watchAllSpecimens(),
        builder: (context, snapshot) {
          final specimens = (snapshot.data ?? const <Specimen>[])
              .where((s) => s.species == widget.species)
              .toList();
          if (specimens.isEmpty) {
            return const Center(child: Text('No specimens recorded.'));
          }
          final iconType =
              SpecimenIconType.fromValue(specimens.first.speciesIconKey);
          final isBeetle = iconType == SpecimenIconType.beetle;

          Specimen? weightRecord;
          Specimen? lengthRecord;
          if (isBeetle) {
            for (final s in specimens) {
              if (BeetleLifeStage.fromValue(s.lifeStage) != BeetleLifeStage.l3 ||
                  s.weightGrams == null) {
                continue;
              }
              if (weightRecord == null || s.weightGrams! > weightRecord.weightGrams!) {
                weightRecord = s;
              }
            }
            for (final s in specimens) {
              if (BeetleLifeStage.fromValue(s.lifeStage) != BeetleLifeStage.adult ||
                  s.sizeCm == null) {
                continue;
              }
              if (lengthRecord == null || s.sizeCm! > lengthRecord.sizeCm!) {
                lengthRecord = s;
              }
            }
          } else {
            for (final s in specimens) {
              if (s.weightGrams == null) continue;
              if (weightRecord == null || s.weightGrams! > weightRecord.weightGrams!) {
                weightRecord = s;
              }
            }
            for (final s in specimens) {
              if (s.sizeCm == null) continue;
              if (lengthRecord == null || s.sizeCm! > lengthRecord.sizeCm!) {
                lengthRecord = s;
              }
            }
          }
          final recordIds = {
            if (weightRecord != null) weightRecord.id,
            if (lengthRecord != null) lengthRecord.id,
          };

          return StreamBuilder<SpeciesInfo?>(
            stream: db.watchSpeciesInfo(widget.species),
            builder: (context, infoSnapshot) {
              final info = infoSnapshot.data;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      SpecimenAvatar(iconType: iconType, radius: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(widget.species,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit species info',
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SpeciesInfoFormScreen(
                              species: widget.species, existing: info),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Description', value: info?.description),
                  _InfoRow(label: "What's special", value: info?.specialNotes),
                  _InfoRow(label: 'Found in', value: info?.region),
                  _InfoRow(
                      label: 'Usual length range', value: info?.lengthRangeText),
                  _InfoRow(
                      label: 'Temperature range',
                      value: info?.temperatureRangeText),
                  const Divider(height: 32),
                  Text('Best records',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  if (weightRecord == null && lengthRecord == null)
                    Text('No weight/length records yet.',
                        style: TextStyle(color: scheme.onSurfaceVariant))
                  else ...[
                    if (weightRecord != null)
                      _RecordTile(
                        label: isBeetle ? 'Heaviest (L3)' : 'Heaviest',
                        specimen: weightRecord,
                        valueText:
                            '${weightRecord.weightGrams!.toStringAsFixed(1)} g',
                      ),
                    if (lengthRecord != null)
                      _RecordTile(
                        label: isBeetle ? 'Longest (Adult)' : 'Longest',
                        specimen: lengthRecord,
                        valueText: '${lengthRecord.sizeCm!.toStringAsFixed(1)} cm',
                      ),
                  ],
                  const Divider(height: 32),
                  InkWell(
                    onTap: () =>
                        setState(() => _showAllSpecimens = !_showAllSpecimens),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('All specimens (${specimens.length})',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Icon(_showAllSpecimens
                            ? Icons.expand_less
                            : Icons.expand_more),
                      ],
                    ),
                  ),
                  if (_showAllSpecimens) ...[
                    const SizedBox(height: 8),
                    for (final s in specimens)
                      _SpecimenRow(
                        specimen: s,
                        isRecordHolder: recordIds.contains(s.id),
                      ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant)),
          Text(value?.isNotEmpty == true ? value! : 'Not recorded yet'),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.label,
    required this.specimen,
    required this.valueText,
  });

  final String label;
  final Specimen specimen;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    final status = SpecimenStatus.fromValue(specimen.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _gold,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SpecimenDetailScreen(specimenId: specimen.id),
        )),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: _onGold),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(fontSize: 12, color: _onGold)),
                    Text(
                        specimen.name?.isNotEmpty == true
                            ? specimen.name!
                            : specimen.species,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: _onGold)),
                  ],
                ),
              ),
              Text(valueText,
                  style:
                      const TextStyle(fontWeight: FontWeight.w700, color: _onGold)),
              const SizedBox(width: 10),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(status.label, style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecimenRow extends StatelessWidget {
  const _SpecimenRow({required this.specimen, required this.isRecordHolder});

  final Specimen specimen;
  final bool isRecordHolder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = SpecimenStatus.fromValue(specimen.status);
    final textColor = isRecordHolder ? _onGold : scheme.onSurface;
    final subtitleColor = isRecordHolder ? _onGold : scheme.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRecordHolder ? _gold : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SpecimenDetailScreen(specimenId: specimen.id),
        )),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SpecimenAvatar(
                    iconType: SpecimenIconType.fromValue(specimen.speciesIconKey),
                    beetleFamily: BeetleFamily.fromValue(specimen.beetleFamily),
                    lifeStage: BeetleLifeStage.fromValue(specimen.lifeStage),
                    radius: 20,
                  ),
                  if (isRecordHolder)
                    const Positioned(
                      top: -6,
                      right: -6,
                      child: Icon(Icons.emoji_events, size: 16, color: _onGold),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        specimen.name?.isNotEmpty == true
                            ? specimen.name!
                            : specimen.species,
                        style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
                    Text(
                        [
                          if (specimen.weightGrams != null)
                            '${specimen.weightGrams!.toStringAsFixed(1)} g',
                          if (specimen.sizeCm != null)
                            '${specimen.sizeCm!.toStringAsFixed(1)} cm',
                        ].join(' · '),
                        style: TextStyle(fontSize: 12, color: subtitleColor)),
                  ],
                ),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(status.label, style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
