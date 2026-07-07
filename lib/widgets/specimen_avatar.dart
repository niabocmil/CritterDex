import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/enums.dart';
import '../models/icon_resolver.dart';

/// Always renders the specimen's species icon (resolved via
/// [resolveSpecimenIcon], so beetle family/life-stage badges render
/// correctly). Photos are kept as optional supplementary data (shown in the
/// specimen detail screen) but are never used as the avatar.
class SpecimenAvatar extends StatelessWidget {
  const SpecimenAvatar({
    super.key,
    required this.iconType,
    this.beetleFamily,
    this.lifeStage,
    this.radius = 28,
  });

  final SpecimenIconType iconType;
  final BeetleFamily? beetleFamily;
  final BeetleLifeStage? lifeStage;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = resolveSpecimenIcon(
      type: iconType,
      family: beetleFamily,
      lifeStage: lifeStage,
    );

    final badge = switch (resolved) {
      ResolvedFaIcon(badge: final b) => b,
      ResolvedAssetIcon(badge: final b) => b,
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: scheme.secondaryContainer,
          child: switch (resolved) {
            ResolvedFaIcon(icon: final icon) => FaIcon(
                icon,
                color: scheme.onSecondaryContainer,
                size: radius,
              ),
            // The source artwork has a lot of internal padding around the
            // silhouette (unlike the FontAwesome glyphs, which nearly fill
            // their box), so this needs a noticeably larger box than radius
            // to read as the same visual size as ResolvedFaIcon above.
            // sizeMultiplier applies further per-asset tuning on top of that.
            ResolvedAssetIcon(assetPath: final path, sizeMultiplier: final m) =>
              SvgPicture.asset(
                path,
                width: radius * 2.0 * m,
                height: radius * 2.0 * m,
                colorFilter: ColorFilter.mode(
                    scheme.onSecondaryContainer, BlendMode.srcIn),
              ),
          },
        ),
        if (badge != null)
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: radius * 0.32,
              backgroundColor: switch (badge.colorRole) {
                ColorRole.tertiary => scheme.tertiaryContainer,
                ColorRole.secondary => scheme.secondaryContainer,
              },
              child: Text(
                badge.letter,
                style: TextStyle(
                  fontSize: radius * 0.36,
                  fontWeight: FontWeight.w800,
                  color: switch (badge.colorRole) {
                    ColorRole.tertiary => scheme.onTertiaryContainer,
                    ColorRole.secondary => scheme.onSecondaryContainer,
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
