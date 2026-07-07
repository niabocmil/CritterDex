import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    this.isHighlighted = false,
    this.isDimmed = false,
  });

  final Terrarium terrarium;
  final String label;
  final List<Specimen> assignedSpecimens;
  final bool isGhost;
  // Species-highlight mode (shelf detail screen): rings this box when it
  // holds a specimen of the selected icon type, dims it otherwise.
  final bool isHighlighted;
  final bool isDimmed;

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

    return Opacity(
      opacity: isDimmed ? 0.35 : 1.0,
      child: Container(
      decoration: BoxDecoration(
        color: isGhost ? baseColor.withValues(alpha: 0.55) : baseColor,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: scheme.primary, width: 3)
            : Border.all(color: scheme.outline, width: isGhost ? 2 : 1),
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
                color: onBaseColor,
              ),
            ),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildSpecimenContent(onBaseColor, isBreeding),
            ),
          ),
          if (isBreeding && assignedSpecimens.length < 2)
            Positioned(
              right: -2,
              top: -2,
              child: Icon(Icons.favorite, size: 14, color: _breedingPink),
            ),
          if (_overflowCount > 0)
            Positioned(
              right: -2,
              bottom: -2,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: scheme.tertiaryContainer,
                child: Text(
                  '+$_overflowCount',
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
      ),
    );
  }

  /// Specimens beyond the ones already rendered as full columns — one for a
  /// regular/single-occupant terrarium, two for a breeding pair.
  int get _overflowCount {
    final shown = isBreedingWithPair ? 2 : 1;
    return (assignedSpecimens.length - shown).clamp(0, assignedSpecimens.length);
  }

  bool get isBreedingWithPair =>
      TerrariumPurpose.fromValue(terrarium.purpose) == TerrariumPurpose.breeding &&
      assignedSpecimens.length >= 2;

  Widget _buildSpecimenContent(Color onBaseColor, bool isBreeding) {
    if (assignedSpecimens.isEmpty) {
      return Icon(Icons.add, size: 18, color: onBaseColor);
    }
    if (isBreeding && assignedSpecimens.length >= 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _specimenColumn(assignedSpecimens[0], onBaseColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text('×',
                style: TextStyle(fontSize: 9, color: onBaseColor)),
          ),
          _specimenColumn(assignedSpecimens[1], onBaseColor),
        ],
      );
    }
    return _specimenColumn(assignedSpecimens.first, onBaseColor);
  }

  Widget _specimenColumn(Specimen s, Color onBaseColor) {
    final resolved = resolveSpecimenIcon(
      type: SpecimenIconType.fromValue(s.speciesIconKey),
      family: BeetleFamily.fromValue(s.beetleFamily),
      lifeStage: BeetleLifeStage.fromValue(s.lifeStage),
    );
    final sex = SpecimenSex.fromValue(s.sex);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (resolved) {
          ResolvedFaIcon(icon: final icon) =>
            FaIcon(icon, size: 16, color: onBaseColor),
          // Image.asset can't decode SVG XML (it only understands raster
          // formats) — it was silently failing to render anything at all
          // for stag/rhino specimens here. SvgPicture.asset is the correct
          // widget for this, same as everywhere else these assets are used.
          ResolvedAssetIcon(assetPath: final path) => SvgPicture.asset(
              path,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(onBaseColor, BlendMode.srcIn),
            ),
        },
        Text(
          s.name?.isNotEmpty == true ? s.name! : s.species,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 8, fontWeight: FontWeight.w700, color: onBaseColor),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.species,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 7, color: onBaseColor),
            ),
            const SizedBox(width: 1),
            Icon(sex.icon, size: 7, color: onBaseColor),
          ],
        ),
      ],
    );
  }
}
