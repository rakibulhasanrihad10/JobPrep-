import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Schedule comparison status against the ideal progress line from `startDate`.
enum StudyScheduleStatus {
  /// User completed more units than expected by the ideal pace line.
  ahead,

  /// User is matching or currently on pace with the ideal progress line.
  onTrack,

  /// User has fallen behind the ideal line or passed the finish window.
  behind;

  /// Database / serialization string identifier.
  String get value => switch (this) {
        StudyScheduleStatus.ahead => 'ahead',
        StudyScheduleStatus.onTrack => 'on_track',
        StudyScheduleStatus.behind => 'behind',
      };
}

/// Immutable domain entity representing a user's exam study plan
/// (`public.study_plans`).
@immutable
class StudyPlan {
  /// Creates a [StudyPlan].
  const StudyPlan({
    required this.startDate,
    required this.targetDate,
    this.id = '',
    this.userId = '',
    this.subjectId,
    this.circularId,
    this.examDateId,
    this.finishBufferDays = 7,
    this.restDaysPerWeek = 0,
    this.extraStudyDays = 0,
    this.maxDailyPace,
    this.initialCompletedUnits = 0,
    this.postponedMaterialIds = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`study_plans.id`).
  final String id;

  /// Owner user identifier (`study_plans.user_id`).
  final String userId;

  /// Target subject identifier (`null` denotes an all-subjects combined plan).
  final String? subjectId;

  /// Optional linked circular identifier (`study_plans.circular_id`).
  final String? circularId;

  /// Optional linked exam date identifier (`study_plans.exam_date_id`).
  final String? examDateId;

  /// Calendar start date of the plan (`study_plans.start_date`).
  final DateTime startDate;

  /// Target exam date (`study_plans.target_date`).
  final DateTime targetDate;

  /// Buffer days reserved before the exam date for revision (default `7`).
  final int finishBufferDays;

  /// Planned rest days per 7-day week (`0..6`, default `0`).
  final int restDaysPerWeek;

  /// Scheduled rest days converted into study days to absorb pace spikes.
  final int extraStudyDays;

  /// Optional maximum comfortable daily pace limit (`> 0`).
  final int? maxDailyPace;

  /// Baseline completed units captured when creating the plan (`>= 0`).
  final int initialCompletedUnits;

  /// Per-plan list of lower-priority material IDs temporarily postponed.
  final List<String> postponedMaterialIds;

  /// Record creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Record update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Whether this plan tracks all subjects combined (`subjectId == null`).
  bool get isAllSubjects => subjectId == null || subjectId!.trim().isEmpty;

  /// Returns a copy with specified fields replaced cleanly.
  StudyPlan copyWith({
    String? id,
    String? userId,
    Object? subjectId = _unset,
    Object? circularId = _unset,
    Object? examDateId = _unset,
    DateTime? startDate,
    DateTime? targetDate,
    int? finishBufferDays,
    int? restDaysPerWeek,
    int? extraStudyDays,
    Object? maxDailyPace = _unset,
    int? initialCompletedUnits,
    List<String>? postponedMaterialIds,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId:
          identical(subjectId, _unset) ? this.subjectId : subjectId as String?,
      circularId: identical(circularId, _unset)
          ? this.circularId
          : circularId as String?,
      examDateId: identical(examDateId, _unset)
          ? this.examDateId
          : examDateId as String?,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      finishBufferDays: finishBufferDays ?? this.finishBufferDays,
      restDaysPerWeek: restDaysPerWeek ?? this.restDaysPerWeek,
      extraStudyDays: extraStudyDays ?? this.extraStudyDays,
      maxDailyPace: identical(maxDailyPace, _unset)
          ? this.maxDailyPace
          : maxDailyPace as int?,
      initialCompletedUnits:
          initialCompletedUnits ?? this.initialCompletedUnits,
      postponedMaterialIds: postponedMaterialIds ?? this.postponedMaterialIds,
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
    return other is StudyPlan &&
        other.id == id &&
        other.userId == userId &&
        other.subjectId == subjectId &&
        other.circularId == circularId &&
        other.examDateId == examDateId &&
        other.startDate == startDate &&
        other.targetDate == targetDate &&
        other.finishBufferDays == finishBufferDays &&
        other.restDaysPerWeek == restDaysPerWeek &&
        other.extraStudyDays == extraStudyDays &&
        other.maxDailyPace == maxDailyPace &&
        other.initialCompletedUnits == initialCompletedUnits &&
        listEquals(other.postponedMaterialIds, postponedMaterialIds) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        subjectId,
        circularId,
        examDateId,
        startDate,
        targetDate,
        finishBufferDays,
        restDaysPerWeek,
        extraStudyDays,
        maxDailyPace,
        initialCompletedUnits,
        Object.hashAll(postponedMaterialIds),
        createdAt,
        updatedAt,
      );
}
