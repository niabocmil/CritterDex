import 'package:flutter/material.dart';

import '../data/database.dart';

class ToolSlot extends StatelessWidget {
  const ToolSlot({
    super.key,
    required this.tool,
    this.isGhost = false,
  });

  final Tool tool;
  final bool isGhost;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color(tool.colorArgb);
    return Container(
      decoration: BoxDecoration(
        color: isGhost ? color.withValues(alpha: 0.55) : color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline, width: isGhost ? 2 : 1),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          tool.name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
