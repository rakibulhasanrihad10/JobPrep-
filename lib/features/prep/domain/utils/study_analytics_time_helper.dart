import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_analytics_calculator.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';

/// Aggregates completed [StudySession] durations across local calendar dates
/// and subject scopes for Phase 6E/6H Study Analytics.
abstract final class StudyAnalyticsTimeHelper {
  /// Aggregates session duration seconds per local calendar day alongside
  /// the set of dates containing at least one session contributing `>= 10 min`
  /// (`600` seconds).
  static ({
    Map<DateTime, int> secondsByDay,
    Set<DateTime> qualifyingDays,
  }) groupSessionsByLocalDay(
    Iterable<StudySession> sessions, {
    Duration? localOffset,
  }) {
    final secondsByDay = <DateTime, int>{};
    final qualifyingDays = <DateTime>{};

    for (final session in sessions) {
      if (!session.isCompleted || session.durationSeconds <= 0) continue;
      final split = StudyTimerCalculator.splitSessionByLocalDate(
        session,
        localOffset: localOffset,
      );
      for (final entry in split.entries) {
        secondsByDay[entry.key] = (secondsByDay[entry.key] ?? 0) + entry.value;
        if (entry.value >= kMinimumQualifyingSessionSeconds) {
          qualifyingDays.add(entry.key);
        }
      }
    }

    return (
      secondsByDay: Map<DateTime, int>.unmodifiable(secondsByDay),
      qualifyingDays: Set<DateTime>.unmodifiable(qualifyingDays),
    );
  }

  /// Sums study session seconds per subject within `[startDate, endDate]`.
  static Map<String, int> groupSubjectSecondsInRange(
    Iterable<StudySession> sessions, {
    required DateTime startDate,
    required DateTime endDate,
    Duration? localOffset,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    if (end.isBefore(start)) return const <String, int>{};

    final totals = <String, int>{};
    for (final session in sessions) {
      if (!session.isCompleted || session.durationSeconds <= 0) continue;
      final split = StudyTimerCalculator.splitSessionByLocalDate(
        session,
        localOffset: localOffset,
      );
      var rangeSeconds = 0;
      for (final entry in split.entries) {
        if (!entry.key.isBefore(start) && !entry.key.isAfter(end)) {
          rangeSeconds += entry.value;
        }
      }
      if (rangeSeconds > 0 && session.subjectId.trim().isNotEmpty) {
        totals[session.subjectId] =
            (totals[session.subjectId] ?? 0) + rangeSeconds;
      }
    }

    return Map<String, int>.unmodifiable(totals);
  }

  /// Computes combined consecutive-day streaks across [logs] (`units >= 1`)
  /// and [sessions] (`>= 10 min` on that local day).
  static ({int current, int longest}) calculateCombinedStreaks({
    required Iterable<ProgressLog> logs,
    required Iterable<StudySession> sessions,
    required DateTime today,
    Iterable<PrepMaterial> materials = const <PrepMaterial>[],
    String? subjectId,
    Duration? localOffset,
  }) {
    final activeSubject =
        (subjectId != null && subjectId.trim().isNotEmpty) ? subjectId : null;
    final materialSubjectById = <String, String>{
      for (final m in materials) m.id: m.subjectId,
    };
    final scopedLogs = activeSubject == null
        ? logs
        : logs
            .where((l) => materialSubjectById[l.materialId] == activeSubject)
            .toList(growable: false);
    final scopedSessions = activeSubject == null
        ? sessions
        : sessions
            .where((s) => s.subjectId == activeSubject)
            .toList(growable: false);

    final unitsByDay = StudyAnalyticsCalculator.groupUnitsByLocalDay(
      scopedLogs,
      localOffset: localOffset,
    );
    final sessionStats = groupSessionsByLocalDay(
      scopedSessions,
      localOffset: localOffset,
    );

    return StudyAnalyticsCalculator.calculateStreaks(
      unitsByDay,
      today: today,
      extraStudiedDays: sessionStats.qualifyingDays,
    );
  }
}
