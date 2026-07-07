import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../screens/batch_activity_screen.dart';
import '../screens/breeding_log_screen.dart';
import '../screens/species_detail_screen.dart';
import '../screens/specimen_detail_screen.dart';
import '../screens/terrarium_form_screen.dart';

/// One row in "Recently added" / "All Activities", shared by both so the
/// rendering + tap-through-by-type logic only lives in one place.
class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.entry});

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final type = ActivityType.fromValue(entry.type);
    return ListTile(
      leading: Icon(type.icon),
      title: Text(entry.title),
      subtitle: Text(DateFormat.yMMMd().add_jm().format(entry.timestamp)),
      onTap: () => _open(context, type),
    );
  }

  Future<void> _open(BuildContext context, ActivityType type) async {
    final db = context.read<AppDatabase>();
    switch (type) {
      case ActivityType.specimenAdded:
      case ActivityType.statusChanged:
      case ActivityType.replenished:
        final id = entry.entityId;
        if (id == null) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SpecimenDetailScreen(specimenId: id),
        ));
        return;
      case ActivityType.terrariumAdded:
      case ActivityType.terrariumDuplicated:
        final id = entry.entityId;
        if (id == null) return;
        Terrarium? terrarium;
        try {
          terrarium = await db.getTerrariumById(id);
        } catch (_) {
          // Soft-deleted and since hard-purged (30+ days in the bin) —
          // the activity log entry itself is kept forever, so this can be
          // tapped long after the terrarium it refers to is gone.
          terrarium = null;
        }
        if (!context.mounted) return;
        if (terrarium == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('This terrarium no longer exists.')));
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TerrariumFormScreen(existing: terrarium),
        ));
        return;
      case ActivityType.breedingEventAdded:
      case ActivityType.breedingReminderSet:
        final id = entry.entityId;
        if (id == null) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BreedingLogScreen(breedingEventId: id),
        ));
        return;
      case ActivityType.specimensBatchAdded:
      case ActivityType.terrariumsBatchAdded:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BatchActivityScreen(entry: entry),
        ));
        return;
      case ActivityType.speciesDiscovered:
        final id = entry.entityId;
        if (id == null) return;
        final info = await db.getSpeciesInfoById(id);
        if (!context.mounted) return;
        if (info == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('This species entry no longer exists.')));
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SpeciesDetailScreen(species: info.speciesName),
        ));
        return;
    }
  }
}
