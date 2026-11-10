import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Computes normalized ratio (`0.0` to `1.0`) for [completedUnits] out of
/// [totalUnits], guarding against division by zero and negative inputs.
double calculateUnitRatioProgress({
  required num completedUnits,
  required num totalUnits,
}) {
  if (!totalUnits.isFinite || !completedUnits.isFinite || totalUnits <= 0) {
    return 0;
  }
  if (completedUnits <= 0) {
    return 0;
  }
  return (completedUnits / totalUnits).clamp(0, 1).toDouble();
}

/// Computes normalized progress (`0.0` to `1.0`) for a single [material]
/// (`completedUnits / totalUnits`), guarding against division by zero and
/// clamping between `0.0` and `1.0`.
double calculateMaterialProgress(PrepMaterial material) {
  return calculateUnitRatioProgress(
    completedUnits: material.completedUnits,
    totalUnits: material.totalUnits,
  );
}

/// Computes normalized progress (`0.0` to `1.0`) for a subject from the sum of
/// completed units divided by the sum of total units across [materials].
///
/// Guards against division by zero (e.g. an empty subject or zero-unit
/// materials) and clamps strictly between `0.0` and `1.0`.
double calculateSubjectProgress(Iterable<PrepMaterial> materials) {
  var totalCompleted = 0;
  var totalPlanned = 0;

  for (final material in materials) {
    if (material.totalUnits > 0) {
      totalPlanned += material.totalUnits;
      if (material.completedUnits > 0) {
        // Clamp each material's completed units to its planned total so an
        // over-logged item cannot falsely advance unfinished sibling materials.
        final capped = material.completedUnits > material.totalUnits
            ? material.totalUnits
            : material.completedUnits;
        totalCompleted += capped;
      }
    }
  }

  return calculateUnitRatioProgress(
    completedUnits: totalCompleted,
    totalUnits: totalPlanned,
  );
}

/// Computes overall progress (`0.0` to `1.0`) across all [subjects] by
/// averaging each subject's normalized progress (`calculateSubjectProgress`)
/// across all subjects, guarding against empty subject lists (`0.0`) and
/// clamping cleanly between `0.0` and `1.0`.
double calculateOverallProgress({
  required Iterable<Subject> subjects,
  required Iterable<PrepMaterial> materials,
}) {
  final subjectList = subjects.toList(growable: false);
  if (subjectList.isEmpty) {
    return 0;
  }

  final bySubject = <String, List<PrepMaterial>>{};
  for (final material in materials) {
    bySubject.putIfAbsent(material.subjectId, () => <PrepMaterial>[]).add(
          material,
        );
  }

  var sumProgress = 0.0;
  for (final subject in subjectList) {
    final subjectMaterials = bySubject[subject.id] ?? const <PrepMaterial>[];
    sumProgress += calculateSubjectProgress(subjectMaterials);
  }

  return (sumProgress / subjectList.length).clamp(0, 1).toDouble();
}
