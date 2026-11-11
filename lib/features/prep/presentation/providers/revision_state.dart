import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';

/// Filter criteria applied across the Revision Queue tabs.
@immutable
class RevisionFilterState {
  /// Creates a [RevisionFilterState].
  const RevisionFilterState({
    this.subjectId,
    this.materialId,
  });

  static const Object _unset = Object();

  /// Optional selected subject ID (`null` means all subjects).
  final String? subjectId;

  /// Optional selected material ID (`null` means all materials).
  final String? materialId;

  /// Whether either a subject or material filter is active.
  bool get hasActiveFilters =>
      (subjectId != null && subjectId!.trim().isNotEmpty) ||
      (materialId != null && materialId!.trim().isNotEmpty);

  /// Returns a copy with overridden filter fields.
  RevisionFilterState copyWith({
    Object? subjectId = _unset,
    Object? materialId = _unset,
  }) {
    return RevisionFilterState(
      subjectId:
          identical(subjectId, _unset) ? this.subjectId : subjectId as String?,
      materialId: identical(materialId, _unset)
          ? this.materialId
          : materialId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevisionFilterState &&
        other.subjectId == subjectId &&
        other.materialId == materialId;
  }

  @override
  int get hashCode => Object.hash(subjectId, materialId);
}

/// Snapshot enabling 1-tap Undo after a queue action or dismissal.
@immutable
class RevisionUndoRecord {
  /// Creates a [RevisionUndoRecord].
  const RevisionUndoRecord({
    required this.previousItem,
    required this.updatedItem,
    required this.action,
  });

  /// Exact state before the review action ran.
  final RevisionItem previousItem;

  /// Resulting state persisted after the review action ran.
  final RevisionItem updatedItem;

  /// Action executed on [previousItem].
  final RevisionReviewAction action;
}

/// Mutation state exposed by `RevisionController`.
@immutable
class RevisionMutationState {
  /// Creates a [RevisionMutationState].
  const RevisionMutationState({
    this.isSaving = false,
    this.activeItemId,
    this.error,
    this.lastUndo,
  });

  static const Object _unset = Object();

  /// Whether a create, update, undo, or delete call is in flight.
  final bool isSaving;

  /// Active revision item identifier during row actions, if any.
  final String? activeItemId;

  /// Last validation or repository error encountered.
  final Object? error;

  /// Latest reversible queue action available for Undo.
  final RevisionUndoRecord? lastUndo;

  /// Returns a copy with overridden fields.
  RevisionMutationState copyWith({
    bool? isSaving,
    Object? activeItemId = _unset,
    Object? error = _unset,
    Object? lastUndo = _unset,
  }) {
    return RevisionMutationState(
      isSaving: isSaving ?? this.isSaving,
      activeItemId: identical(activeItemId, _unset)
          ? this.activeItemId
          : activeItemId as String?,
      error: identical(error, _unset) ? this.error : error,
      lastUndo: identical(lastUndo, _unset)
          ? this.lastUndo
          : lastUndo as RevisionUndoRecord?,
    );
  }
}
