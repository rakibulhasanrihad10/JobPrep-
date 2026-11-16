import 'package:flutter/foundation.dart' show immutable;

/// Immutable domain entity representing a syllabus chapter (`public.chapters`).
@immutable
class Chapter {
  /// Creates a [Chapter].
  const Chapter({
    required this.title,
    this.id = '',
    this.userId = '',
    this.subjectId = '',
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`chapters.id`).
  final String id;

  /// Owner user identifier (`chapters.user_id`).
  final String userId;

  /// Parent subject identifier (`chapters.subject_id`).
  final String subjectId;

  /// Chapter display title.
  final String title;

  /// Relative sort order within parent subject.
  final int sortOrder;

  /// Creation timestamp managed by database.
  final DateTime? createdAt;

  /// Last update timestamp managed by database.
  final DateTime? updatedAt;

  /// Returns a copy of this [Chapter] with specified fields overridden.
  Chapter copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? title,
    int? sortOrder,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Chapter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
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
    return other is Chapter &&
        other.id == id &&
        other.userId == userId &&
        other.subjectId == subjectId &&
        other.title == title &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        subjectId,
        title,
        sortOrder,
        createdAt,
        updatedAt,
      );
}
