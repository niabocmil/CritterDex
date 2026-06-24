import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../widgets/specimen_avatar.dart';

enum _BinCategory { specimens, terrariums }

class BinScreen extends StatefulWidget {
  const BinScreen({super.key});

  @override
  State<BinScreen> createState() => _BinScreenState();
}

class _BinScreenState extends State<BinScreen> {
  _BinCategory _category = _BinCategory.specimens;

  Future<void> _confirmPermanentDelete(
      BuildContext context, String label, Future<void> Function() action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: Text(
            '$label will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete forever')),
        ],
      ),
    );
    if (confirmed == true) {
      await action();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _showSpecimenSheet(BuildContext context, AppDatabase db, Specimen s) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SpecimenAvatar(
                    iconType: SpecimenIconType.fromValue(s.speciesIconKey),
                    beetleFamily: BeetleFamily.fromValue(s.beetleFamily),
                    lifeStage: BeetleLifeStage.fromValue(s.lifeStage),
                    radius: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            s.name?.isNotEmpty == true ? s.name! : s.species,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(s.species),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Deleted ${DateFormat.yMMMd().add_jm().format(s.deletedAt!)}',
                style: Theme.of(sheetContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await db.restoreSpecimen(s.id);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _confirmPermanentDelete(
                          sheetContext,
                          s.name?.isNotEmpty == true ? s.name! : s.species,
                          () => db.deleteSpecimen(s.id)),
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Delete forever'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTerrariumSheet(BuildContext context, AppDatabase db, Terrarium t) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t.shape == 'cylinder' ? 'Cylinder' : 'Rectangular'} terrarium',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text('${t.volumeLitres.toStringAsFixed(1)} L'),
              const SizedBox(height: 8),
              Text(
                'Deleted ${DateFormat.yMMMd().add_jm().format(t.deletedAt!)}',
                style: Theme.of(sheetContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await db.restoreTerrarium(t.id);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _confirmPermanentDelete(sheetContext,
                          'This terrarium', () => db.deleteTerrarium(t.id)),
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Delete forever'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bin')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_BinCategory>(
              segments: const [
                ButtonSegment(
                    value: _BinCategory.specimens, label: Text('Specimens')),
                ButtonSegment(
                    value: _BinCategory.terrariums, label: Text('Terrariums')),
              ],
              selected: {_category},
              onSelectionChanged: (s) => setState(() => _category = s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Items here are permanently deleted 30 days after being moved to the bin.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _category == _BinCategory.specimens
                ? StreamBuilder<List<Specimen>>(
                    stream: db.watchDeletedSpecimens(),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? const <Specimen>[];
                      if (items.isEmpty) {
                        return const Center(child: Text('Bin is empty.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final s = items[index];
                          return Card(
                            child: ListTile(
                              leading: SpecimenAvatar(
                                iconType:
                                    SpecimenIconType.fromValue(s.speciesIconKey),
                                beetleFamily:
                                    BeetleFamily.fromValue(s.beetleFamily),
                                lifeStage:
                                    BeetleLifeStage.fromValue(s.lifeStage),
                              ),
                              title: Text(s.name?.isNotEmpty == true
                                  ? s.name!
                                  : s.species),
                              subtitle: Text(
                                  'Deleted ${DateFormat.yMMMd().format(s.deletedAt!)}'),
                              onTap: () => _showSpecimenSheet(context, db, s),
                            ),
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<List<Terrarium>>(
                    stream: db.watchDeletedTerrariums(),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? const <Terrarium>[];
                      if (items.isEmpty) {
                        return const Center(child: Text('Bin is empty.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final t = items[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.crop_square_outlined),
                              title: Text(
                                  '${t.shape == 'cylinder' ? 'Cylinder' : 'Rectangular'} · ${t.volumeLitres.toStringAsFixed(1)} L'),
                              subtitle: Text(
                                  'Deleted ${DateFormat.yMMMd().format(t.deletedAt!)}'),
                              onTap: () =>
                                  _showTerrariumSheet(context, db, t),
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
}
