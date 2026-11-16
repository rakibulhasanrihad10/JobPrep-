import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Immutable domain entity representing a syllabus topic (`public.topics`).
@immutable
class Topic {
  /// Creates a [Topic].
  const Topic({
    String? title,
    String? name,
    this.id = '',
    this.userId = '',
    this.subjectId = '',
    this.chapterId,
    this.sortOrder = 0,
    this.weight = 1,
    this.studyDoneAt,
    this.practiceDoneAt,
    this.modelTestDoneAt,
    this.revisionDoneAt,
    this.notes,
    this.status = TopicStatus.notStarted,
    this.createdAt,
    this.updatedAt,
  }) : title = title ?? name ?? '';

  static const Object _unset = Object();

  /// Unique identifier (`topics.id`).
  final String id;

  /// Owner user identifier (`topics.user_id`).
  final String userId;

  /// Parent subject identifier (`topics.subject_id`).
  final String subjectId;

  /// Optional parent chapter identifier (`topics.chapter_id`).
  final String? chapterId;

  /// Topic title within the syllabus (`topics.title`).
  final String title;

  /// Backwards-compatible alias for [title].
  String get name => title;

  /// Relative sort order within parent chapter or subject.
  final int sortOrder;

  /// Relative importance weight for chapter/subject progress (default 1).
  final int weight;

  /// Timestamp when study checkpoint was marked completed.
  final DateTime? studyDoneAt;

  /// Timestamp when practice checkpoint was marked completed.
  final DateTime? practiceDoneAt;

  /// Timestamp when model test checkpoint was marked completed.
  final DateTime? modelTestDoneAt;

  /// Timestamp when revision checkpoint was marked completed.
  final DateTime? revisionDoneAt;

  /// Optional personal note or focus instructions for this topic.
  final String? notes;

  /// Legacy study progression status for this topic.
  final TopicStatus status;

  /// Creation timestamp managed by database.
  final DateTime? createdAt;

  /// Last update timestamp managed by database.
  final DateTime? updatedAt;

  /// Returns a copy of this [Topic] with specified fields overridden.
  Topic copyWith({
    String? id,
    String? userId,
    String? subjectId,
    Object? chapterId = _unset,
    String? title,
    String? name,
    int? sortOrder,
    int? weight,
    Object? studyDoneAt = _unset,
    Object? practiceDoneAt = _unset,
    Object? modelTestDoneAt = _unset,
    Object? revisionDoneAt = _unset,
    Object? notes = _unset,
    TopicStatus? status,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Topic(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      chapterId:
          identical(chapterId, _unset) ? this.chapterId : chapterId as String?,
      title: title ?? name ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      weight: weight ?? this.weight,
      studyDoneAt: identical(studyDoneAt, _unset)
          ? this.studyDoneAt
          : studyDoneAt as DateTime?,
      practiceDoneAt: identical(practiceDoneAt, _unset)
          ? this.practiceDoneAt
          : practiceDoneAt as DateTime?,
      modelTestDoneAt: identical(modelTestDoneAt, _unset)
          ? this.modelTestDoneAt
          : modelTestDoneAt as DateTime?,
      revisionDoneAt: identical(revisionDoneAt, _unset)
          ? this.revisionDoneAt
          : revisionDoneAt as DateTime?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      status: status ?? this.status,
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
    return other is Topic &&
        other.id == id &&
        other.userId == userId &&
        other.subjectId == subjectId &&
        other.chapterId == chapterId &&
        other.title == title &&
        other.sortOrder == sortOrder &&
        other.weight == weight &&
        other.studyDoneAt == studyDoneAt &&
        other.practiceDoneAt == practiceDoneAt &&
        other.modelTestDoneAt == modelTestDoneAt &&
        other.revisionDoneAt == revisionDoneAt &&
        other.notes == notes &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        subjectId,
        chapterId,
        title,
        sortOrder,
        weight,
        studyDoneAt,
        practiceDoneAt,
        modelTestDoneAt,
        revisionDoneAt,
        notes,
        status,
        createdAt,
        updatedAt,
      );
}
