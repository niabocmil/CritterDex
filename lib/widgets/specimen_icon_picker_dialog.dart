import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/enums.dart';
import '../models/icon_resolver.dart';

/// Icon-only grid for choosing a [SpecimenIconType]. The species name is
/// shown by the caller after a choice is made, not inside this grid.
/// Returns the chosen type via [Navigator.pop], or null if dismissed.
class SpecimenIconPickerDialog extends StatelessWidget {
  const SpecimenIconPickerDialog({super.key, this.selected});

  final SpecimenIconType? selected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose an icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final type in SpecimenIconType.values)
                  _IconTile(
                    type: type,
                    isSelected: selected == type,
                    onTap: () => Navigator.of(context).pop(type),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.type, required this.isSelected, required this.onTap});

  final SpecimenIconType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = resolveSpecimenIcon(type: type);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: switch (resolved) {
          ResolvedFaIcon(icon: final icon) => FaIcon(
              icon,
              size: 26,
              color: isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
          ResolvedAssetIcon(assetPath: final path) => Image.asset(path, width: 30, height: 30),
        },
      ),
    );
  }
}
