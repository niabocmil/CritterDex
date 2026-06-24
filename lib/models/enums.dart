import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SpecimenIconType {
  snake,
  lizard,
  frog,
  spider,
  beetle,
  fish,
  bird,
  mammal,
  other;

  String get label => switch (this) {
        SpecimenIconType.snake => 'Snake',
        SpecimenIconType.lizard => 'Lizard',
        SpecimenIconType.frog => 'Frog / Amphibian',
        SpecimenIconType.spider => 'Spider',
        SpecimenIconType.beetle => 'Beetle / Insect',
        SpecimenIconType.fish => 'Fish',
        SpecimenIconType.bird => 'Bird',
        SpecimenIconType.mammal => 'Mammal',
        SpecimenIconType.other => 'Other',
      };

  FaIconData get faIcon => switch (this) {
        SpecimenIconType.snake => FontAwesomeIcons.worm,
        SpecimenIconType.lizard => FontAwesomeIcons.dragon,
        SpecimenIconType.frog => FontAwesomeIcons.frog,
        SpecimenIconType.spider => FontAwesomeIcons.spider,
        SpecimenIconType.beetle => FontAwesomeIcons.bug,
        SpecimenIconType.fish => FontAwesomeIcons.fish,
        SpecimenIconType.bird => FontAwesomeIcons.kiwiBird,
        SpecimenIconType.mammal => FontAwesomeIcons.paw,
        SpecimenIconType.other => FontAwesomeIcons.question,
      };

  static SpecimenIconType fromValue(String value) => SpecimenIconType.values
      .firstWhere((e) => e.name == value, orElse: () => SpecimenIconType.other);
}

enum BeetleLifeStage {
  egg,
  l1,
  l2,
  l3,
  pupa,
  adult;

  String get label => switch (this) {
        BeetleLifeStage.egg => 'Egg',
        BeetleLifeStage.l1 => 'L1',
        BeetleLifeStage.l2 => 'L2',
        BeetleLifeStage.l3 => 'L3',
        BeetleLifeStage.pupa => 'Pupa',
        BeetleLifeStage.adult => 'Adult',
      };

  static BeetleLifeStage? fromValue(String? value) {
    if (value == null) return null;
    return BeetleLifeStage.values
        .firstWhere((e) => e.name == value, orElse: () => BeetleLifeStage.egg);
  }
}

enum BreedingStage {
  mating,
  eggLaying,
  incubating,
  complete;

  String get label => switch (this) {
        BreedingStage.mating => 'Mating',
        BreedingStage.eggLaying => 'Eggs Laid',
        BreedingStage.incubating => 'Incubating',
        BreedingStage.complete => 'Complete',
      };

  BreedingStage? get next => switch (this) {
        BreedingStage.mating => BreedingStage.eggLaying,
        BreedingStage.eggLaying => BreedingStage.incubating,
        BreedingStage.incubating => BreedingStage.complete,
        BreedingStage.complete => null,
      };

  static BreedingStage fromValue(String value) => BreedingStage.values
      .firstWhere((e) => e.name == value, orElse: () => BreedingStage.mating);
}

enum SpecimenSex {
  male,
  female,
  unknown;

  String get label => switch (this) {
        SpecimenSex.male => 'Male',
        SpecimenSex.female => 'Female',
        SpecimenSex.unknown => 'Unknown',
      };

  IconData get icon => switch (this) {
        SpecimenSex.male => Icons.male,
        SpecimenSex.female => Icons.female,
        SpecimenSex.unknown => Icons.question_mark,
      };

  static SpecimenSex fromValue(String value) => SpecimenSex.values
      .firstWhere((e) => e.name == value, orElse: () => SpecimenSex.unknown);
}

enum SpecimenStatus {
  alive,
  deceased,
  sold,
  givenAway;

  String get label => switch (this) {
        SpecimenStatus.alive => 'Alive',
        SpecimenStatus.deceased => 'Deceased',
        SpecimenStatus.sold => 'Sold',
        SpecimenStatus.givenAway => 'Given away',
      };

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (this) {
      SpecimenStatus.alive => scheme.primary,
      SpecimenStatus.deceased => scheme.error,
      SpecimenStatus.sold => scheme.tertiary,
      SpecimenStatus.givenAway => scheme.secondary,
    };
  }

  static SpecimenStatus fromValue(String value) => SpecimenStatus.values
      .firstWhere((e) => e.name == value, orElse: () => SpecimenStatus.alive);
}
