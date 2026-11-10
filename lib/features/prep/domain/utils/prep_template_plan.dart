import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

/// Result summary emitted after applying a study preparation template pack.
@immutable
class PrepTemplateApplyResult {
  /// Creates a [PrepTemplateApplyResult].
  const PrepTemplateApplyResult({
    required this.templateTitle,
    required this.subjectsCreated,
    required this.materialsCreated,
    required this.subjectsSkipped,
    required this.materialsSkipped,
  });

  /// Display title of the applied template.
  final String templateTitle;

  /// Number of newly inserted subjects.
  final int subjectsCreated;

  /// Number of newly inserted materials.
  final int materialsCreated;

  /// Number of subjects already present and skipped to avoid duplicates.
  final int subjectsSkipped;

  /// Number of materials already present and skipped to avoid duplicates.
  final int materialsSkipped;

  /// True when every subject and material already existed (double-apply no-op).
  bool get alreadyApplied => subjectsCreated == 0 && materialsCreated == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrepTemplateApplyResult &&
        other.templateTitle == templateTitle &&
        other.subjectsCreated == subjectsCreated &&
        other.materialsCreated == materialsCreated &&
        other.subjectsSkipped == subjectsSkipped &&
        other.materialsSkipped == materialsSkipped;
  }

  @override
  int get hashCode => Object.hash(
        templateTitle,
        subjectsCreated,
        materialsCreated,
        subjectsSkipped,
        materialsSkipped,
      );
}

/// Planned subject copy along with the missing starter materials to insert.
@immutable
class PrepTemplateSubjectCopyOp {
  /// Creates a [PrepTemplateSubjectCopyOp].
  const PrepTemplateSubjectCopyOp({
    required this.materialsToCreate,
    this.existingSubjectId,
    this.subjectToCreate,
  });

  /// Existing user subject ID to reuse when subject already exists.
  final String? existingSubjectId;

  /// New user subject to create when none matches yet.
  final Subject? subjectToCreate;

  /// Missing materials to create under the resolved subject ID.
  final List<PrepMaterial> materialsToCreate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrepTemplateSubjectCopyOp &&
        other.existingSubjectId == existingSubjectId &&
        other.subjectToCreate == subjectToCreate &&
        listEquals(other.materialsToCreate, materialsToCreate);
  }

  @override
  int get hashCode => Object.hash(
        existingSubjectId,
        subjectToCreate,
        Object.hashAll(materialsToCreate),
      );
}

/// Pure deterministic execution plan produced by `PrepTemplatePlanner`.
@immutable
class PrepTemplateCopyPlan {
  /// Creates a [PrepTemplateCopyPlan].
  const PrepTemplateCopyPlan({
    required this.operations,
    required this.summary,
  });

  /// Ordered subject/material creation steps.
  final List<PrepTemplateSubjectCopyOp> operations;

  /// Counts describing what will be created vs. deduplicated.
  final PrepTemplateApplyResult summary;

  /// Whether at least one new subject or material needs to be created.
  bool get hasChanges => !summary.alreadyApplied;
}
