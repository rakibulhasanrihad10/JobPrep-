import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template_item.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_template_plan.dart';

export 'prep_template_plan.dart';

/// Pure, unit-tested planner enforcing idempotent double-apply protection when
/// copying a [PrepTemplate] into user-owned `subjects` and `materials`.
abstract final class PrepTemplatePlanner {
  /// Builds an idempotent plan copying [template] without duplicating existing
  /// [existingSubjects] (matched by normalized name) or [existingMaterials]
  /// (matched by normalized title under that subject).
  ///
  /// Optional [unitOverrides] overrides item `totalUnits` keyed by either
  /// `item.id` or `subjectMaterialOverrideKey(item)`.
  static PrepTemplateCopyPlan buildPlan({
    required PrepTemplate template,
    required List<Subject> existingSubjects,
    required List<PrepMaterial> existingMaterials,
    Map<String, int> unitOverrides = const {},
  }) {
    final subjectByKey = <String, Subject>{};
    var nextSortOrder = 0;
    for (final subject in existingSubjects) {
      final key = PrepTemplate.normalizeNameKey(subject.name);
      if (key.isNotEmpty) {
        subjectByKey.putIfAbsent(key, () => subject);
      }
      if (subject.sortOrder >= nextSortOrder) {
        nextSortOrder = subject.sortOrder + 1;
      }
    }

    final materialKeysBySubjectId = <String, Set<String>>{};
    for (final mat in existingMaterials) {
      final key = PrepTemplate.normalizeNameKey(mat.title);
      if (key.isNotEmpty) {
        materialKeysBySubjectId
            .putIfAbsent(mat.subjectId, () => <String>{})
            .add(key);
      }
    }

    final ops = <PrepTemplateSubjectCopyOp>[];
    final plannedNewSubjectKeys = <String>{};
    var subjectsCreated = 0;
    var materialsCreated = 0;
    var subjectsSkipped = 0;
    var materialsSkipped = 0;

    for (final group in template.groupedSubjects) {
      final subjectKey = PrepTemplate.normalizeNameKey(group.subjectName);
      if (subjectKey.isEmpty) continue;

      final existingSubject = subjectByKey[subjectKey];
      final existingMatKeys = existingSubject != null
          ? (materialKeysBySubjectId[existingSubject.id] ?? <String>{})
          : <String>{};
      final plannedMatKeys = Set<String>.of(existingMatKeys);

      Subject? subjectToCreate;
      if (existingSubject == null &&
          !plannedNewSubjectKeys.contains(subjectKey)) {
        plannedNewSubjectKeys.add(subjectKey);
        subjectToCreate = Subject(
          name: group.subjectName.trim(),
          color: group.subjectColor,
          icon: group.subjectIcon,
          examType: group.examType,
          sortOrder: nextSortOrder++,
        );
        subjectsCreated++;
      } else {
        subjectsSkipped++;
      }

      final materialsToCreate = <PrepMaterial>[];
      for (final item in group.materials) {
        final rawTitle = item.materialTitle?.trim();
        if (rawTitle == null || rawTitle.isEmpty) continue;
        final matKey = PrepTemplate.normalizeNameKey(rawTitle);
        if (plannedMatKeys.contains(matKey)) {
          materialsSkipped++;
          continue;
        }
        plannedMatKeys.add(matKey);

        final overrideUnits = resolveOverrideUnits(item, unitOverrides);
        final resolvedUnits = overrideUnits ?? item.totalUnits;
        final clampedUnits = resolvedUnits < 0 ? 0 : resolvedUnits;

        materialsToCreate.add(
          PrepMaterial(
            title: rawTitle,
            kind: item.materialKind,
            unitLabel:
                item.unitLabel.trim().isEmpty ? 'pages' : item.unitLabel.trim(),
            totalUnits: clampedUnits,
          ),
        );
        materialsCreated++;
      }

      if (subjectToCreate != null || materialsToCreate.isNotEmpty) {
        ops.add(
          PrepTemplateSubjectCopyOp(
            existingSubjectId: existingSubject?.id,
            subjectToCreate: subjectToCreate,
            materialsToCreate: List<PrepMaterial>.unmodifiable(
              materialsToCreate,
            ),
          ),
        );
      }
    }

    return PrepTemplateCopyPlan(
      operations: List<PrepTemplateSubjectCopyOp>.unmodifiable(ops),
      summary: PrepTemplateApplyResult(
        templateTitle: template.title,
        subjectsCreated: subjectsCreated,
        materialsCreated: materialsCreated,
        subjectsSkipped: subjectsSkipped,
        materialsSkipped: materialsSkipped,
      ),
    );
  }

  /// Returns `true` when all subjects and starter materials defined in
  /// [template] already exist inside [existingSubjects] / [existingMaterials].
  static bool isAlreadyApplied({
    required PrepTemplate template,
    required List<Subject> existingSubjects,
    required List<PrepMaterial> existingMaterials,
  }) {
    if (template.groupedSubjects.isEmpty) return false;
    return !buildPlan(
      template: template,
      existingSubjects: existingSubjects,
      existingMaterials: existingMaterials,
    ).hasChanges;
  }

  /// Canonical override key for an item combining subject and material names.
  static String subjectMaterialOverrideKey(PrepTemplateItem item) {
    final sub = PrepTemplate.normalizeNameKey(item.subjectName);
    final mat = PrepTemplate.normalizeNameKey(item.materialTitle ?? '');
    return '$sub::$mat';
  }

  /// Resolves user-edited unit count for [item] from [unitOverrides], if any.
  static int? resolveOverrideUnits(
    PrepTemplateItem item,
    Map<String, int> unitOverrides,
  ) {
    if (item.id.trim().isNotEmpty && unitOverrides.containsKey(item.id)) {
      return unitOverrides[item.id];
    }
    final composite = subjectMaterialOverrideKey(item);
    return unitOverrides[composite];
  }

  /// Returns an ordered item snapshot from [subjects] and [materials].
  static List<PrepTemplateItem> snapshotItemsFromSubjects({
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    String? fallbackExamType,
  }) {
    final orderedSubjects = List<Subject>.of(subjects)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final materialsBySubject = <String, List<PrepMaterial>>{};
    for (final mat in materials) {
      materialsBySubject.putIfAbsent(mat.subjectId, () => []).add(mat);
    }

    final items = <PrepTemplateItem>[];
    var itemSortOrder = 0;

    for (var sIndex = 0; sIndex < orderedSubjects.length; sIndex++) {
      final subject = orderedSubjects[sIndex];
      final subjectMaterials =
          materialsBySubject[subject.id] ?? const <PrepMaterial>[];
      final examType = subject.examType.trim().isNotEmpty
          ? subject.examType.trim()
          : (fallbackExamType?.trim().isNotEmpty == true
              ? fallbackExamType!.trim()
              : 'general');

      if (subjectMaterials.isEmpty) {
        items.add(
          PrepTemplateItem(
            subjectName: subject.name.trim(),
            subjectColor: subject.color,
            subjectIcon: subject.icon,
            examType: examType,
            subjectSortOrder: sIndex,
            itemSortOrder: itemSortOrder++,
          ),
        );
        continue;
      }

      for (final mat in subjectMaterials) {
        items.add(
          PrepTemplateItem(
            subjectName: subject.name.trim(),
            subjectColor: subject.color,
            subjectIcon: subject.icon,
            examType: examType,
            subjectSortOrder: sIndex,
            materialTitle: mat.title.trim(),
            materialKind: mat.kind,
            unitLabel:
                mat.unitLabel.trim().isEmpty ? 'pages' : mat.unitLabel.trim(),
            totalUnits: mat.totalUnits < 0 ? 0 : mat.totalUnits,
            itemSortOrder: itemSortOrder++,
          ),
        );
      }
    }

    return List<PrepTemplateItem>.unmodifiable(items);
  }
}
