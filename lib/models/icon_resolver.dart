import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'enums.dart';

/// Which themed color role a badge should use, resolved against the live
/// [ColorScheme] at render time rather than a fixed hex, so badges stay
/// readable across the light/dark/custom themes.
enum ColorRole { tertiary, secondary }

class IconBadge {
  const IconBadge({required this.letter, required this.colorRole});
  final String letter;
  final ColorRole colorRole;
}

/// What [SpecimenAvatar] should actually draw. Sealed so a future swap to
/// real artwork only means: start returning [ResolvedAssetIcon] from
/// [resolveSpecimenIcon] and add one case to the avatar's switch.
sealed class ResolvedIcon {
  const ResolvedIcon();
}

class ResolvedFaIcon extends ResolvedIcon {
  const ResolvedFaIcon(this.icon, {this.badge});
  final FaIconData icon;
  final IconBadge? badge;
}

/// Not produced anywhere today — exists purely so the call sites already
/// branch on [ResolvedIcon]'s type, ready for real per-species/family
/// artwork later without touching anything but this file.
class ResolvedAssetIcon extends ResolvedIcon {
  const ResolvedAssetIcon(this.assetPath, {this.badge});
  final String assetPath;
  final IconBadge? badge;
}

/// Single entry point for "what icon represents this specimen" — every
/// render site should go through this instead of switching on the raw enum.
ResolvedIcon resolveSpecimenIcon({
  required SpecimenIconType type,
  BeetleFamily? family,
  BeetleLifeStage? lifeStage,
}) {
  if (type != SpecimenIconType.beetle) {
    return ResolvedFaIcon(_basicIconFor(type));
  }
  return _resolveBeetleIcon(family, lifeStage);
}

FaIconData _basicIconFor(SpecimenIconType type) => switch (type) {
      SpecimenIconType.snake => FontAwesomeIcons.worm,
      SpecimenIconType.lizard => FontAwesomeIcons.dragon,
      SpecimenIconType.frog => FontAwesomeIcons.frog,
      SpecimenIconType.spider => FontAwesomeIcons.spider,
      SpecimenIconType.insect => FontAwesomeIcons.locust,
      SpecimenIconType.beetle => FontAwesomeIcons.bug,
      SpecimenIconType.fish => FontAwesomeIcons.fish,
      SpecimenIconType.bird => FontAwesomeIcons.kiwiBird,
      SpecimenIconType.mammal => FontAwesomeIcons.paw,
      SpecimenIconType.other => FontAwesomeIcons.question,
    };

IconBadge? _familyBadge(BeetleFamily? family) => switch (family) {
      BeetleFamily.stag =>
        const IconBadge(letter: 'S', colorRole: ColorRole.tertiary),
      BeetleFamily.dynastinae =>
        const IconBadge(letter: 'D', colorRole: ColorRole.secondary),
      null => null,
    };

ResolvedIcon _resolveBeetleIcon(BeetleFamily? family, BeetleLifeStage? lifeStage) {
  switch (lifeStage) {
    case BeetleLifeStage.egg:
      return const ResolvedFaIcon(FontAwesomeIcons.egg);
    case BeetleLifeStage.l1:
    case BeetleLifeStage.l2:
    case BeetleLifeStage.l3:
      return const ResolvedFaIcon(FontAwesomeIcons.worm);
    case BeetleLifeStage.pupa:
      return ResolvedFaIcon(FontAwesomeIcons.bugSlash, badge: _familyBadge(family));
    case BeetleLifeStage.adult:
    case null:
      return ResolvedFaIcon(FontAwesomeIcons.bug, badge: _familyBadge(family));
  }
}
