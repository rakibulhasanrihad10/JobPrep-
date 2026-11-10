import 'package:flutter/foundation.dart' show immutable;

/// Immutable domain entity representing an exam stage date for a circular.
@immutable
class CircularExamDate {
  /// Creates a [CircularExamDate].
  const CircularExamDate({
    required this.stage,
    required this.examDate,
    this.id = '',
    this.circularId = '',
    this.userId = '',
    this.venue,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  static const _unset = Object();

  /// Unique identifier (`circular_exam_dates.id`).
  final String id;

  /// Parent circular identifier (`circular_exam_dates.circular_id`).
  final String circularId;

  /// Owner user identifier (`circular_exam_dates.user_id`).
  final String userId;

  /// Exam stage label (e.g. Preliminary, Written, Viva).
  final String stage;

  /// Scheduled date and time of the exam stage.
  final DateTime examDate;

  /// Optional exam venue or center name.
  final String? venue;

  /// Optional notes about the exam stage.
  final String? notes;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Returns a copy with specified fields overridden.
  ///
  /// Passing `null` for nullable fields such as [venue] or [notes] clears them.
  CircularExamDate copyWith({
    String? id,
    String? circularId,
    String? userId,
    String? stage,
    DateTime? examDate,
    Object? venue = _unset,
    Object? notes = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return CircularExamDate(
      id: id ?? this.id,
      circularId: circularId ?? this.circularId,
      userId: userId ?? this.userId,
      stage: stage ?? this.stage,
      examDate: examDate ?? this.examDate,
      venue: identical(venue, _unset) ? this.venue : venue as String?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
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
    return other is CircularExamDate &&
        other.id == id &&
        other.circularId == circularId &&
        other.userId == userId &&
        other.stage == stage &&
        other.examDate == examDate &&
        other.venue == venue &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        circularId,
        userId,
        stage,
        examDate,
        venue,
        notes,
        createdAt,
        updatedAt,
      );

  @override
  String toString() => 'CircularExamDate(id: $id, stage: $stage)';
}
