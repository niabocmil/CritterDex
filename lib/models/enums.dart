import 'package:flutter/material.dart';

enum SpecimenIconType {
  snake,
  lizard,
  frog,
  spider,
  insect,
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
        SpecimenIconType.insect => 'Insect',
        SpecimenIconType.beetle => 'Beetle',
        SpecimenIconType.fish => 'Fish',
        SpecimenIconType.bird => 'Bird',
        SpecimenIconType.mammal => 'Mammal',
        SpecimenIconType.other => 'Other',
      };

  static SpecimenIconType fromValue(String value) => SpecimenIconType.values
      .firstWhere((e) => e.name == value, orElse: () => SpecimenIconType.other);
}

enum BeetleFamily {
  stag,
  dynastinae;

  String get label => switch (this) {
        BeetleFamily.stag => 'Stag beetle',
        BeetleFamily.dynastinae => 'Dynastinae (rhino/scarab)',
      };

  static BeetleFamily? fromValue(String? value) {
    if (value == null) return null;
    return BeetleFamily.values
        .firstWhere((e) => e.name == value, orElse: () => BeetleFamily.stag);
  }
}

enum TerrariumPurpose {
  general,
  breeding;

  String get label => switch (this) {
        TerrariumPurpose.general => 'General',
        TerrariumPurpose.breeding => 'Breeding enclosure',
      };

  static TerrariumPurpose fromValue(String value) => TerrariumPurpose.values
      .firstWhere((e) => e.name == value, orElse: () => TerrariumPurpose.general);
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

enum ActivityType {
  specimenAdded,
  specimensBatchAdded,
  terrariumAdded,
  terrariumDuplicated,
  terrariumsBatchAdded,
  statusChanged,
  replenished,
  breedingEventAdded,
  breedingReminderSet;

  String get label => switch (this) {
        ActivityType.specimenAdded => 'Specimen added',
        ActivityType.specimensBatchAdded => 'Batch of specimens added',
        ActivityType.terrariumAdded => 'Terrarium added',
        ActivityType.terrariumDuplicated => 'Terrarium duplicated',
        ActivityType.terrariumsBatchAdded => 'Batch of terrariums added',
        ActivityType.statusChanged => 'Status changed',
        ActivityType.replenished => 'Replenished',
        ActivityType.breedingEventAdded => 'Breeding log started',
        ActivityType.breedingReminderSet => 'Reminder set',
      };

  IconData get icon => switch (this) {
        ActivityType.specimenAdded => Icons.pets,
        ActivityType.specimensBatchAdded => Icons.layers_outlined,
        ActivityType.terrariumAdded => Icons.crop_square_outlined,
        ActivityType.terrariumDuplicated => Icons.copy_outlined,
        ActivityType.terrariumsBatchAdded => Icons.view_comfy_outlined,
        ActivityType.statusChanged => Icons.swap_horiz,
        ActivityType.replenished => Icons.water_drop_outlined,
        ActivityType.breedingEventAdded => Icons.favorite_outline,
        ActivityType.breedingReminderSet => Icons.notifications_outlined,
      };

  static ActivityType fromValue(String value) => ActivityType.values
      .firstWhere((e) => e.name == value, orElse: () => ActivityType.specimenAdded);
}

enum ActivityCategory {
  specimen,
  terrarium,
  breedingLog,
  reminder;

  String get label => switch (this) {
        ActivityCategory.specimen => 'Specimen',
        ActivityCategory.terrarium => 'Terrarium',
        ActivityCategory.breedingLog => 'Breeding log',
        ActivityCategory.reminder => 'Reminder',
      };
}

extension ActivityTypeCategory on ActivityType {
  ActivityCategory get category => switch (this) {
        ActivityType.specimenAdded ||
        ActivityType.specimensBatchAdded ||
        ActivityType.statusChanged ||
        ActivityType.replenished =>
          ActivityCategory.specimen,
        ActivityType.terrariumAdded ||
        ActivityType.terrariumDuplicated ||
        ActivityType.terrariumsBatchAdded =>
          ActivityCategory.terrarium,
        ActivityType.breedingEventAdded => ActivityCategory.breedingLog,
        ActivityType.breedingReminderSet => ActivityCategory.reminder,
      };
}
