import '../data/database.dart';
import 'enums.dart';

/// Generation 0 = a specimen with no recorded parents.
int computeGeneration(int specimenId, Map<int, Specimen> byId, {int depth = 0}) {
  if (depth > 64) return depth; // guard against accidental cycles
  final specimen = byId[specimenId];
  if (specimen == null) return 0;
  final motherGen =
      specimen.motherId != null && byId.containsKey(specimen.motherId)
          ? computeGeneration(specimen.motherId!, byId, depth: depth + 1)
          : -1;
  final fatherGen =
      specimen.fatherId != null && byId.containsKey(specimen.fatherId)
          ? computeGeneration(specimen.fatherId!, byId, depth: depth + 1)
          : -1;
  final maxParentGen = motherGen > fatherGen ? motherGen : fatherGen;
  return maxParentGen + 1;
}

/// Hobbyist WC/CB/WF#/CBF# shorthand for a specimen's lineage, derived from
/// its founder ancestors' recorded [Specimen.origin] plus [computeGeneration].
/// A founder (no resolvable parents) is labelled straight from its own
/// origin: 'WC', 'CB', or null if that origin was never recorded — there's
/// nothing meaningful to show beyond the plain "Generation 0" already
/// displayed elsewhere. A non-founder is `WF<gen>` if either parent's line
/// traces back to a wild-caught founder, otherwise `CBF<gen>` (mirrors
/// [computeGeneration]'s "wilder/higher side wins" resolution for specimens
/// whose two parents disagree).
String? lineageLabel(int specimenId, Map<int, Specimen> byId) {
  final specimen = byId[specimenId];
  if (specimen == null) return null;
  final motherResolved =
      specimen.motherId != null && byId.containsKey(specimen.motherId);
  final fatherResolved =
      specimen.fatherId != null && byId.containsKey(specimen.fatherId);
  if (!motherResolved && !fatherResolved) {
    return switch (SpecimenOrigin.fromValue(specimen.origin)) {
      SpecimenOrigin.wildCaught => 'WC',
      SpecimenOrigin.captiveBred => 'CB',
      SpecimenOrigin.unknown => null,
    };
  }
  final generation = computeGeneration(specimenId, byId);
  final wild = (motherResolved && _tracesToWildCaught(specimen.motherId!, byId)) ||
      (fatherResolved && _tracesToWildCaught(specimen.fatherId!, byId));
  return wild ? 'WF$generation' : 'CBF$generation';
}

bool _tracesToWildCaught(int specimenId, Map<int, Specimen> byId,
    {int depth = 0}) {
  if (depth > 64) return false; // guard against accidental cycles
  final specimen = byId[specimenId];
  if (specimen == null) return false;
  final motherResolved =
      specimen.motherId != null && byId.containsKey(specimen.motherId);
  final fatherResolved =
      specimen.fatherId != null && byId.containsKey(specimen.fatherId);
  if (!motherResolved && !fatherResolved) {
    return SpecimenOrigin.fromValue(specimen.origin) ==
        SpecimenOrigin.wildCaught;
  }
  return (motherResolved &&
          _tracesToWildCaught(specimen.motherId!, byId, depth: depth + 1)) ||
      (fatherResolved &&
          _tracesToWildCaught(specimen.fatherId!, byId, depth: depth + 1));
}

List<Specimen> directChildrenOf(int specimenId, List<Specimen> all) {
  return all
      .where((s) => s.motherId == specimenId || s.fatherId == specimenId)
      .toList();
}

/// All descendants (children, grandchildren, ...) of [specimenId].
List<Specimen> allDescendantsOf(int specimenId, List<Specimen> all) {
  final result = <Specimen>[];
  final queue = <int>[specimenId];
  final visited = <int>{};
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (!visited.add(current)) continue;
    final children = directChildrenOf(current, all);
    for (final child in children) {
      result.add(child);
      queue.add(child.id);
    }
  }
  return result;
}

/// Direct parents of a specimen, if recorded and present in [byId].
List<Specimen> directParentsOf(Specimen specimen, Map<int, Specimen> byId) {
  final parents = <Specimen>[];
  if (specimen.motherId != null && byId.containsKey(specimen.motherId)) {
    parents.add(byId[specimen.motherId]!);
  }
  if (specimen.fatherId != null && byId.containsKey(specimen.fatherId)) {
    parents.add(byId[specimen.fatherId]!);
  }
  return parents;
}

/// All ancestors (parents, grandparents, ...) of a specimen.
List<Specimen> allAncestorsOf(Specimen specimen, Map<int, Specimen> byId) {
  final result = <Specimen>[];
  final queue = <Specimen>[specimen];
  final visited = <int>{};
  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (!visited.add(current.id)) continue;
    final parents = directParentsOf(current, byId);
    for (final parent in parents) {
      result.add(parent);
      queue.add(parent);
    }
  }
  return result;
}
