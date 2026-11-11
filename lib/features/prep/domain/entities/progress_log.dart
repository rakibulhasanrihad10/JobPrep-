import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';

/// Immutable domain entity representing a study session progress log
/// (`public.progress_logs`).
@immutable
class ProgressLog {
  /// Creates a [ProgressLog].
  const ProgressLog({
    required this.loggedOn,
    this.id = '',
    this.userId = '',
    this.materialId = '',
    this.unitsDone = 0,
    this.entryType = ProgressLogEntryType.study,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`progress_logs.id`).
  final String id;

  /// Owner user identifier (`progress_logs.user_id`).
  final String userId;

  /// Parent material identifier (`progress_logs.material_id`).
  final String materialId;

  /// Units completed (or negative delta correction) recorded in this entry.
  final int unitsDone;

  /// Whether this entry counts as `study` work or a `correction` adjustment.
  final ProgressLogEntryType entryType;

  /// Calendar date (`progress_logs.logged_on`) when units were logged.
  final DateTime loggedOn;

  /// Optional study note or chapter reference.
  final String? note;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Whether this log represents studied units (`entryType == study`).
  bool get isStudy => entryType == ProgressLogEntryType.study;

  /// Whether this log represents a position correction
  /// (`entryType == correction`).
  bool get isCorrection => entryType == ProgressLogEntryType.correction;

  /// Returns a copy of this [ProgressLog] with specified fields overridden.
  ProgressLog copyWith({
    String? id,
    String? userId,
    String? materialId,
    int? unitsDone,
    ProgressLogEntryType? entryType,
    DateTime? loggedOn,
    Object? note = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return ProgressLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      materialId: materialId ?? this.materialId,
      unitsDone: unitsDone ?? this.unitsDone,
      entryType: entryType ?? this.entryType,
      loggedOn: loggedOn ?? this.loggedOn,
      note: identical(note, _unset) ? this.note : note as String?,
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
    return other is ProgressLog &&
        other.id == id &&
        other.userId == userId &&
        other.materialId == materialId &&
        other.unitsDone == unitsDone &&
        other.entryType == entryType &&
        other.loggedOn == loggedOn &&
        other.note == note &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        materialId,
        unitsDone,
        entryType,
        loggedOn,
        note,
        createdAt,
        updatedAt,
      );
}
