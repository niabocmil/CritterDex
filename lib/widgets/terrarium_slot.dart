import 'package:flutter/material.dart';

import '../data/database.dart';

class TerrariumSlot extends StatelessWidget {
  const TerrariumSlot({
    super.key,
    required this.terrarium,
    required this.label,
    this.isGhost = false,
  });

  final Terrarium terrarium;
  final String label;
  final bool isGhost;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: isGhost
            ? scheme.primary.withValues(alpha: 0.55)
            : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline, width: isGhost ? 2 : 1),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
