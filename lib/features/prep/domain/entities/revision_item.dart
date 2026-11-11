import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Immutable domain entity representing a flagged item queued for spaced
/// repetition (`public.revision_items`).
@immutable
class RevisionItem {
  /// Creates a [RevisionItem].
  const RevisionItem({
    required this.subjectId,
    required this.referenceLabel,
    required this.dueOn,
    this.id = '',
    this.userId = '',
    this.materialId,
    this.topicId,
    this.pageNumber,
    this.note,
    this.reason = RevisionReason.tricky,
    this.source = RevisionSource.manual,
    this.progressLogId,
    this.mockTestId,
    this.status = RevisionStatus.pending,
    this.reviewCount = 0,
    this.lastReviewedOn,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`revision_items.id`).
  final String id;

  /// Owner user identifier (`revision_items.user_id`).
  final String userId;

  /// Optional linked study material identifier (`revision_items.material_id`).
  final String? materialId;

  /// Owning subject identifier (`revision_items.subject_id`).
  final String subjectId;

  /// Optional syllabus topic identifier (`revision_items.topic_id`).
  final String? topicId;

  /// Concise reference highlighted to revise (`p. 128`, `Problem 14`, topic).
  final String referenceLabel;

  /// Optional numeric page number used to show flag pins on book views.
  final int? pageNumber;

  /// Optional quick reminder note explaining what felt tricky or missed.
  final String? note;

  /// Why the item was flagged (`tricky`, `forgot`, `important`, or `mistake`).
  final RevisionReason reason;

  /// Origin entry point (`log`, `mock_test`, or `manual`).
  final RevisionSource source;

  /// Optional triggering progress log ID (`revision_items.progress_log_id`).
  final String? progressLogId;

  /// Optional triggering mock test ID (`revision_items.mock_test_id`).
  final String? mockTestId;

  /// Queue lifecycle status (`pending`, `revised`, `mastered`, `dismissed`).
  final RevisionStatus status;

  /// Next scheduled review date (`revision_items.due_on`).
  final DateTime dueOn;

  /// Count of completed Easy spacing passes (`0 .. 5+`).
  final int reviewCount;

  /// Most recent calendar date when the item was reviewed.
  final DateTime? lastReviewedOn;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Whether this item sits in a terminal Done bucket (`mastered`/`dismissed`).
  bool get isDone =>
      status == RevisionStatus.mastered || status == RevisionStatus.dismissed;

  /// Whether this item remains active in spaced repetition (`pending`/`revised`).
  bool get isActive => !isDone;

  /// Returns a copy with specified fields overridden.
  RevisionItem copyWith({
    String? id,
    String? userId,
    Object? materialId = _unset,
    String? subjectId,
    Object? topicId = _unset,
    String? referenceLabel,
    Object? pageNumber = _unset,
    Object? note = _unset,
    RevisionReason? reason,
    RevisionSource? source,
    Object? progressLogId = _unset,
    Object? mockTestId = _unset,
    RevisionStatus? status,
    DateTime? dueOn,
    int? reviewCount,
    Object? lastReviewedOn = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return RevisionItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      materialId: identical(materialId, _unset)
          ? this.materialId
          : materialId as String?,
      subjectId: subjectId ?? this.subjectId,
      topicId: identical(topicId, _unset) ? this.topicId : topicId as String?,
      referenceLabel: referenceLabel ?? this.referenceLabel,
      pageNumber:
          identical(pageNumber, _unset) ? this.pageNumber : pageNumber as int?,
      note: identical(note, _unset) ? this.note : note as String?,
      reason: reason ?? this.reason,
      source: source ?? this.source,
      progressLogId: identical(progressLogId, _unset)
          ? this.progressLogId
          : progressLogId as String?,
      mockTestId: identical(mockTestId, _unset)
          ? this.mockTestId
          : mockTestId as String?,
      status: status ?? this.status,
      dueOn: dueOn ?? this.dueOn,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewedOn: identical(lastReviewedOn, _unset)
          ? this.lastReviewedOn
          : lastReviewedOn as DateTime?,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevisionItem &&
        other.id == id &&
        other.userId == userId &&
        other.materialId == materialId &&
        other.subjectId == subjectId &&
        other.topicId == topicId &&
        other.referenceLabel == referenceLabel &&
        other.pageNumber == pageNumber &&
        other.note == note &&
        other.reason == reason &&
        other.source == source &&
        other.progressLogId == progressLogId &&
        other.mockTestId == mockTestId &&
        other.status == status &&
        other.dueOn == dueOn &&
        other.reviewCount == reviewCount &&
        other.lastReviewedOn == lastReviewedOn &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        materialId,
        subjectId,
        topicId,
        referenceLabel,
        pageNumber,
        note,
        reason,
        source,
        progressLogId,
        mockTestId,
        status,
        dueOn,
        reviewCount,
        lastReviewedOn,
        createdAt,
        updatedAt,
      );
}
