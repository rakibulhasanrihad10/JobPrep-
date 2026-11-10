import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Immutable domain entity representing a study material (`public.materials`).
@immutable
class PrepMaterial {
  /// Creates a [PrepMaterial].
  const PrepMaterial({
    required this.title,
    this.id = '',
    this.userId = '',
    this.subjectId = '',
    this.kind = MaterialKind.book,
    this.unitLabel = 'pages',
    this.totalUnits = 0,
    this.completedUnits = 0,
    this.coverImagePath,
    this.coverImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`materials.id`).
  final String id;

  /// Owner user identifier (`materials.user_id`).
  final String userId;

  /// Parent subject identifier (`materials.subject_id`).
  final String subjectId;

  /// Display title (e.g. book or course name).
  final String title;

  /// Kind of study resource.
  final MaterialKind kind;

  /// Unit label (e.g. `pages`, `lectures`, `chapters`).
  final String unitLabel;

  /// Planned total units (`>= 0`).
  final int totalUnits;

  /// Current completed units maintained from progress logs (`0..totalUnits`).
  final int completedUnits;

  /// Optional private Storage path of the uploaded cover image.
  final String? coverImagePath;

  /// Optional external cover image URL.
  final String? coverImageUrl;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Returns a copy of this [PrepMaterial] with specified fields overridden.
  PrepMaterial copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? title,
    MaterialKind? kind,
    String? unitLabel,
    int? totalUnits,
    int? completedUnits,
    Object? coverImagePath = _unset,
    Object? coverImageUrl = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return PrepMaterial(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      unitLabel: unitLabel ?? this.unitLabel,
      totalUnits: totalUnits ?? this.totalUnits,
      completedUnits: completedUnits ?? this.completedUnits,
      coverImagePath: identical(coverImagePath, _unset)
          ? this.coverImagePath
          : coverImagePath as String?,
      coverImageUrl: identical(coverImageUrl, _unset)
          ? this.coverImageUrl
          : coverImageUrl as String?,
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
    return other is PrepMaterial &&
        other.id == id &&
        other.userId == userId &&
        other.subjectId == subjectId &&
        other.title == title &&
        other.kind == kind &&
        other.unitLabel == unitLabel &&
        other.totalUnits == totalUnits &&
        other.completedUnits == completedUnits &&
        other.coverImagePath == coverImagePath &&
        other.coverImageUrl == coverImageUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        subjectId,
        title,
        kind,
        unitLabel,
        totalUnits,
        completedUnits,
        coverImagePath,
        coverImageUrl,
        createdAt,
        updatedAt,
      );
}
