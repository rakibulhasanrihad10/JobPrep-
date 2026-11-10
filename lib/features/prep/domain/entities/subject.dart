import 'package:flutter/foundation.dart' show immutable;

/// Immutable domain entity representing a study subject (`public.subjects`).
@immutable
class Subject {
  /// Creates a [Subject].
  const Subject({
    required this.name,
    this.id = '',
    this.userId = '',
    this.color = 'gold',
    this.icon = 'menu_book',
    this.examType = 'general',
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`subjects.id`).
  final String id;

  /// Owner user identifier (`subjects.user_id`).
  final String userId;

  /// Display name of the subject.
  final String name;

  /// Semantic color key or hex string identifying the subject badge.
  final String color;

  /// Icon identifier associated with this subject.
  final String icon;

  /// Target exam track (e.g. `bcs`, `bank`, `general`).
  final String examType;

  /// Display ordering index (`>= 0`).
  final int sortOrder;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Returns a copy of this [Subject] with specified fields overridden.
  Subject copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? icon,
    String? examType,
    int? sortOrder,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return Subject(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      examType: examType ?? this.examType,
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
    return other is Subject &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.color == color &&
        other.icon == icon &&
        other.examType == examType &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        name,
        color,
        icon,
        examType,
        sortOrder,
        createdAt,
        updatedAt,
      );
}
