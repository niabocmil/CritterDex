import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/enums.dart';

/// Always renders the specimen's species icon. Photos are kept as optional
/// supplementary data (shown in the specimen detail screen) but are never
/// used as the avatar.
class SpecimenAvatar extends StatelessWidget {
  const SpecimenAvatar({
    super.key,
    required this.iconType,
    this.radius = 28,
  });

  final SpecimenIconType iconType;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      child: FaIcon(
        iconType.faIcon,
        color: scheme.onSecondaryContainer,
        size: radius,
      ),
    );
  }
}
