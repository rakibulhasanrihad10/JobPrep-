import 'package:job_prep/features/prep/data/mappers/prep_json_helpers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';

/// Maps between PostgreSQL `public.study_sessions` JSON rows and
/// [StudySession].
abstract final class StudySessionMapper {
  /// Deserializes a single `study_sessions` JSON row.
  static StudySession fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: PrepJsonHelpers.readRequiredString(json, 'id'),
      userId: PrepJsonHelpers.readRequiredString(json, 'user_id'),
      subjectId: PrepJsonHelpers.readRequiredString(json, 'subject_id'),
      materialId: PrepJsonHelpers.readOptionalString(
        json,
        'material_id',
        trimEmptyToNull: true,
      ),
      startedAt: PrepJsonHelpers.readOptionalDateTime(json, 'started_at') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endedAt: PrepJsonHelpers.readOptionalDateTime(json, 'ended_at'),
      durationSeconds: PrepJsonHelpers.readRequiredInt(
        json,
        'duration_seconds',
      ).clamp(0, 100000000),
      mode: StudySessionMode.fromValue(
        PrepJsonHelpers.readOptionalString(json, 'mode'),
      ),
      note: PrepJsonHelpers.readOptionalString(
        json,
        'note',
        trimEmptyToNull: true,
      ),
      pauseIntervals: _readPauseIntervals(json['pause_intervals']),
      phaseStartedAt:
          PrepJsonHelpers.readOptionalDateTime(json, 'phase_started_at'),
      targetDurationSeconds:
          PrepJsonHelpers.readOptionalInt(json, 'target_duration_seconds'),
      pomodoroRound: PrepJsonHelpers.readOptionalInt(json, 'pomodoro_round'),
      pomodoroPhase: PomodoroPhase.tryParse(
        PrepJsonHelpers.readOptionalString(json, 'pomodoro_phase'),
      ),
      focusMinutes: PrepJsonHelpers.readRequiredInt(
        json,
        'focus_minutes',
        fallback: 25,
      ).clamp(1, 240),
      shortBreakMinutes: PrepJsonHelpers.readRequiredInt(
        json,
        'short_break_minutes',
        fallback: 5,
      ).clamp(1, 120),
      longBreakMinutes: PrepJsonHelpers.readRequiredInt(
        json,
        'long_break_minutes',
        fallback: 15,
      ).clamp(1, 180),
      createdAt: PrepJsonHelpers.readOptionalDateTime(json, 'created_at'),
      updatedAt: PrepJsonHelpers.readOptionalDateTime(json, 'updated_at'),
    );
  }

  /// Deserializes a list of `study_sessions` JSON rows.
  static List<StudySession> fromJsonList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const <StudySession>[];
    return List<StudySession>.unmodifiable(rows.map(fromJson));
  }

  /// Serializes full [session] into a JSON map.
  static Map<String, dynamic> toJson(StudySession session) {
    return <String, dynamic>{
      'id': session.id,
      'user_id': session.userId,
      'subject_id': session.subjectId,
      'material_id': _nullableTrim(session.materialId),
      'started_at': session.startedAt.toUtc().toIso8601String(),
      'ended_at': session.endedAt?.toUtc().toIso8601String(),
      'duration_seconds': session.durationSeconds,
      'mode': session.mode.value,
      'note': _nullableTrim(session.note),
      'pause_intervals': _intervalsToJson(session.pauseIntervals),
      'phase_started_at': session.phaseStartedAt?.toUtc().toIso8601String(),
      'target_duration_seconds': session.targetDurationSeconds,
      'pomodoro_round': session.pomodoroRound,
      'pomodoro_phase': session.pomodoroPhase?.value,
      'focus_minutes': session.focusMinutes,
      'short_break_minutes': session.shortBreakMinutes,
      'long_break_minutes': session.longBreakMinutes,
      'created_at': session.createdAt?.toUtc().toIso8601String(),
      'updated_at': session.updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Serializes fields for `INSERT` into `public.study_sessions`.
  static Map<String, dynamic> toInsertJson(
    StudySession session, {
    String? userId,
  }) {
    final effectiveUser =
        _nullableTrim(userId) ?? _nullableTrim(session.userId);
    return <String, dynamic>{
      if (effectiveUser != null) 'user_id': effectiveUser,
      ...toUpdateJson(session),
    };
  }

  /// Serializes mutable fields for `UPDATE` in `public.study_sessions`.
  static Map<String, dynamic> toUpdateJson(StudySession session) {
    return <String, dynamic>{
      'subject_id': session.subjectId,
      'material_id': _nullableTrim(session.materialId),
      'started_at': session.startedAt.toUtc().toIso8601String(),
      'ended_at': session.endedAt?.toUtc().toIso8601String(),
      'duration_seconds': session.durationSeconds,
      'mode': session.mode.value,
      'note': _nullableTrim(session.note),
      'pause_intervals': _intervalsToJson(session.pauseIntervals),
      'phase_started_at': session.phaseStartedAt?.toUtc().toIso8601String(),
      'target_duration_seconds': session.targetDurationSeconds,
      'pomodoro_round': session.pomodoroRound,
      'pomodoro_phase': session.pomodoroPhase?.value,
      'focus_minutes': session.focusMinutes,
      'short_break_minutes': session.shortBreakMinutes,
      'long_break_minutes': session.longBreakMinutes,
    };
  }

  static List<PauseInterval> _readPauseIntervals(Object? raw) {
    if (raw is! List) return const <PauseInterval>[];
    final parsed = <PauseInterval>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);
      final pausedAt = PrepJsonHelpers.readOptionalDateTime(map, 'paused_at');
      if (pausedAt == null) continue;
      final resumedAt = PrepJsonHelpers.readOptionalDateTime(map, 'resumed_at');
      final isBreakOnly =
          map['is_break_only'] == true || map['scope'] == 'break';
      parsed.add(
        PauseInterval(
          pausedAt: pausedAt,
          resumedAt: resumedAt,
          isBreakOnly: isBreakOnly,
        ),
      );
    }
    return List<PauseInterval>.unmodifiable(parsed);
  }

  static List<Map<String, dynamic>> _intervalsToJson(
    List<PauseInterval> intervals,
  ) {
    return [
      for (final item in intervals)
        <String, dynamic>{
          'paused_at': item.pausedAt.toUtc().toIso8601String(),
          'resumed_at': item.resumedAt?.toUtc().toIso8601String(),
          if (item.isBreakOnly) 'is_break_only': true,
        },
    ];
  }

  static String? _nullableTrim(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
