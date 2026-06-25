import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../models/enums.dart';
import '../models/icon_resolver.dart';
import '../theme/theme_controller.dart';

const _breedingPink = Color(0xFFEC407A);

class TerrariumSlot extends StatelessWidget {
  const TerrariumSlot({
    super.key,
    required this.terrarium,
    required this.label,
    this.assignedSpecimens = const [],
    this.isGhost = false,
  });

  final Terrarium terrarium;
  final String label;
  final List<Specimen> assignedSpecimens;
  final bool isGhost;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final boxColor = context.watch<ThemeController>().boxColor;
    final isBreeding =
        TerrariumPurpose.fromValue(terrarium.purpose) == TerrariumPurpose.breeding;
    final baseColor = isBreeding ? _breedingPink : (boxColor ?? scheme.primaryContainer);
    final onBaseColor = isBreeding
        ? Colors.white
        : boxColor == null
            ? scheme.onPrimaryContainer
            : ThemeData.estimateBrightnessForColor(boxColor) == Brightness.dark
                ? Colors.white
                : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: isGhost ? baseColor.withValues(alpha: 0.55) : baseColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline, width: isGhost ? 2 : 1),
      ),
      padding: const EdgeInsets.all(3),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: onBaseColor.withValues(alpha: 0.85),
              ),
            ),
          ),
          Center(child: _buildSpecimenContent(onBaseColor)),
          if (isBreeding)
            Positioned(
              right: -2,
              top: -2,
              child: Icon(Icons.favorite, size: 14, color: _breedingPink),
            ),
          if (assignedSpecimens.length > 1)
            Positioned(
              right: -2,
              bottom: -2,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: scheme.tertiaryContainer,
                child: Text(
                  '+${assignedSpecimens.length - 1}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecimenContent(Color onBaseColor) {
    if (assignedSpecimens.isEmpty) {
      return Icon(Icons.add, size: 18, color: onBaseColor.withValues(alpha: 0.5));
    }
    final first = assignedSpecimens.first;
    final resolved = resolveSpecimenIcon(
      type: SpecimenIconType.fromValue(first.speciesIconKey),
      family: BeetleFamily.fromValue(first.beetleFamily),
      lifeStage: BeetleLifeStage.fromValue(first.lifeStage),
    );
    return switch (resolved) {
      ResolvedFaIcon(icon: final icon) => FaIcon(icon, size: 20, color: onBaseColor),
      ResolvedAssetIcon(assetPath: final path) => Image.asset(path, width: 22, height: 22),
    };
  }
}
