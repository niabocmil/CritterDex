import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../models/enums.dart';
import 'specimen_avatar.dart';

class SpecimenCard extends StatelessWidget {
  const SpecimenCard({super.key, required this.specimen, required this.onTap});

  final Specimen specimen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = SpecimenStatus.fromValue(specimen.status);
    final sex = SpecimenSex.fromValue(specimen.sex);
    final title = (specimen.name?.trim().isNotEmpty ?? false)
        ? specimen.name!
        : specimen.species;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SpecimenAvatar(
                iconType: SpecimenIconType.fromValue(specimen.speciesIconKey),
                beetleFamily: BeetleFamily.fromValue(specimen.beetleFamily),
                lifeStage: BeetleLifeStage.fromValue(specimen.lifeStage),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specimen.species,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(sex.icon, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(sex.label,
                            style: TextStyle(
                                fontSize: 12, color: scheme.onSurfaceVariant)),
                        if (specimen.dateAcquired != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.event, size: 14, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.yMMMd().format(specimen.dateAcquired!),
                            style: TextStyle(
                                fontSize: 12, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status.color(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.color(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
