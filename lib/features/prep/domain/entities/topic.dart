import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Immutable domain entity representing a syllabus topic (`public.topics`).
@immutable
class Topic {
  /// Creates a [Topic].
  const Topic({
    required this.name,
    this.id = '',
    this.userId = '',
    this.subjectId = '',
    this.status = TopicStatus.notStarted,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`topics.id`).
  final String id;

  /// Owner user identifier (`topics.user_id`).
  final String userId;

  /// Parent subject identifier (`topics.subject_id`).
  final String subjectId;

  /// Topic title within the subject syllabus.
  final String name;

  /// Study progression status for this topic.
  final TopicStatus status;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Returns a copy of this [Topic] with specified fields overridden.
  Topic copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? name,
    TopicStatus? status,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Topic(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
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
        other.name == name &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        subjectId,
        name,
        status,
        createdAt,
        updatedAt,
      );
}
