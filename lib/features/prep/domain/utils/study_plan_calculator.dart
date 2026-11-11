import 'dart:math' as math;

import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_snapshot_builder.dart';

/// Breakdown of remaining calendar, rest, and study days until plan finish.
typedef StudyDaysBreakdown = ({
  int calendarDaysUntilExam,
  int calendarDaysLeft,
  int restDaysLeft,
  int studyDaysLeft,
  bool isInsideBufferOrPast,
});

/// Exact fractional daily pace and whole-unit ceiling daily target.
typedef DailyTargetResult = ({
  double exact,
  int rounded,
});

/// Pure mathematical calculations for study plans, missed-day redistribution,
/// schedule status tracking, and pace-limit warning recovery options.
abstract final class StudyPlanCalculator {
  static const double _comparisonEpsilon = 1e-6;

  /// Strips time components so all day arithmetic uses midnight UTC dates.
  static DateTime normalizeUtcDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Sums remaining units (`max(0, totalUnits - completedUnits)`) across
  /// active (non-postponed) [materials], filtered by [subjectId] when set.
  static int calculateRemainingUnits(
    Iterable<PrepMaterial> materials, {
    String? subjectId,
    Set<String> postponedMaterialIds = const <String>{},
  }) {
    var remaining = 0;
    for (final material in materials) {
      if (!_matchesPlanScope(
        material,
        subjectId: subjectId,
        postponedMaterialIds: postponedMaterialIds,
      )) {
        continue;
      }
      final total = math.max(0, material.totalUnits);
      final completed = math.max(0, material.completedUnits);
      if (total > completed) {
        remaining += total - completed;
      }
    }
    return remaining;
  }

  /// Calculates remaining study days between [today] and [targetDate] after
  /// subtracting [finishBufferDays], weekly [restDaysPerWeek], and adding back
  /// any converted [extraStudyDays].
  static StudyDaysBreakdown calculateStudyDaysLeft({
    required DateTime today,
    required DateTime targetDate,
    int finishBufferDays = 7,
    int restDaysPerWeek = 0,
    int extraStudyDays = 0,
  }) {
    final todayDay = normalizeUtcDate(today);
    final examDay = normalizeUtcDate(targetDate);
    final safeBuffer = math.max(0, finishBufferDays);
    final safeRestPerWeek = restDaysPerWeek.clamp(0, 6);
    final safeExtra = math.max(0, extraStudyDays);

    final calendarDaysUntilExam = math.max(
      0,
      examDay.difference(todayDay).inDays,
    );
    final effectiveFinishDay = examDay.subtract(Duration(days: safeBuffer));
    final calendarDaysLeft = math.max(
      0,
      effectiveFinishDay.difference(todayDay).inDays,
    );

    final scheduledRest = countRestDays(calendarDaysLeft, safeRestPerWeek);
    final restDaysLeft = math.max(0, scheduledRest - safeExtra);
    final studyDaysLeft = math.max(0, calendarDaysLeft - restDaysLeft);

    return (
      calendarDaysUntilExam: calendarDaysUntilExam,
      calendarDaysLeft: calendarDaysLeft,
      restDaysLeft: restDaysLeft,
      studyDaysLeft: studyDaysLeft,
      isInsideBufferOrPast: calendarDaysLeft <= 0,
    );
  }

  /// Counts whole scheduled rest days inside [calendarDays] given
  /// [restDaysPerWeek] (`0..6`). Guaranteed strictly `< calendarDays` whenever
  /// `calendarDays >= 1`.
  static int countRestDays(int calendarDays, int restDaysPerWeek) {
    if (calendarDays <= 0 || restDaysPerWeek <= 0) return 0;
    final clampedRest = restDaysPerWeek.clamp(0, 6);
    return math.min(calendarDays, (calendarDays * clampedRest) ~/ 7);
  }

  /// Calculates exact fractional and rounded-up whole daily target for
  /// [remainingUnits] over [studyDaysLeft].
  ///
  /// Guards cleanly against zero remaining units (returns `0`) and zero/past
  /// study days left (returns `remainingUnits` without dividing by zero).
  static DailyTargetResult calculateDailyTarget({
    required int remainingUnits,
    required int studyDaysLeft,
  }) {
    if (remainingUnits <= 0) {
      return (exact: 0.0, rounded: 0);
    }
    if (studyDaysLeft <= 0) {
      return (exact: remainingUnits.toDouble(), rounded: remainingUnits);
    }
    final exact = remainingUnits / studyDaysLeft;
    return (exact: exact, rounded: exact.ceil());
  }

  /// Compares cumulative study progress since `startDate` against the ideal
  /// progress line (`elapsedStudyDays * baselineDailyPace`).
  static StudyScheduleStatus determineScheduleStatus({
    required int totalSpanUnits,
    required int completedSinceStart,
    required int completedBeforeToday,
    required int remainingUnits,
    required int studyDaysLeft,
    required int elapsedStudyDays,
    required double baselineDailyPace,
  }) {
    if (remainingUnits <= 0) {
      return studyDaysLeft > 0
          ? StudyScheduleStatus.ahead
          : StudyScheduleStatus.onTrack;
    }
    if (studyDaysLeft <= 0) {
      return StudyScheduleStatus.behind;
    }

    final idealBeforeToday = math.min(
      totalSpanUnits.toDouble(),
      math.max(0, elapsedStudyDays) * baselineDailyPace,
    );
    final idealThroughToday = math.min(
      totalSpanUnits.toDouble(),
      (math.max(0, elapsedStudyDays) + 1) * baselineDailyPace,
    );

    if (completedSinceStart < idealBeforeToday - _comparisonEpsilon) {
      return StudyScheduleStatus.behind;
    }
    if (completedBeforeToday > idealBeforeToday + _comparisonEpsilon ||
        completedSinceStart > idealThroughToday + _comparisonEpsilon) {
      return StudyScheduleStatus.ahead;
    }
    return StudyScheduleStatus.onTrack;
  }

  /// Orders unfinished active materials so lower-priority and less-started
  /// items appear first when suggesting postponement.
  static List<PrepMaterial> prioritizePostponableMaterials(
    Iterable<PrepMaterial> materials, {
    String? subjectId,
    Set<String> postponedMaterialIds = const <String>{},
  }) {
    final candidates = <PrepMaterial>[
      for (final material in materials)
        if (_matchesPlanScope(
              material,
              subjectId: subjectId,
              postponedMaterialIds: postponedMaterialIds,
            ) &&
            material.totalUnits > math.max(0, material.completedUnits))
          material,
    ]..sort((a, b) {
        final rankDiff = _kindPriorityRank(a.kind) - _kindPriorityRank(b.kind);
        if (rankDiff != 0) return rankDiff;
        final aRatio = a.totalUnits > 0 ? a.completedUnits / a.totalUnits : 0.0;
        final bRatio = b.totalUnits > 0 ? b.completedUnits / b.totalUnits : 0.0;
        final ratioDiff = aRatio.compareTo(bRatio);
        if (ratioDiff != 0) return ratioDiff;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    return List<PrepMaterial>.unmodifiable(candidates);
  }

  /// Builds a complete live [StudyPlanSnapshot] for [plan] as of [today].
  static StudyPlanSnapshot buildSnapshot({
    required StudyPlan plan,
    required DateTime today,
    required Iterable<PrepMaterial> materials,
    required Iterable<ProgressLog> recentLogs,
    Subject? subject,
    Circular? circular,
    CircularExamDate? examDate,
  }) {
    return assembleStudyPlanSnapshot(
      plan: plan,
      today: today,
      materials: materials,
      recentLogs: recentLogs,
      subject: subject,
      circular: circular,
      examDate: examDate,
    );
  }

  static bool _matchesPlanScope(
    PrepMaterial material, {
    required String? subjectId,
    required Set<String> postponedMaterialIds,
  }) {
    if (postponedMaterialIds.contains(material.id)) return false;
    if (subjectId != null &&
        subjectId.isNotEmpty &&
        material.subjectId != subjectId) {
      return false;
    }
    return true;
  }

  static int _kindPriorityRank(MaterialKind kind) {
    return switch (kind) {
      MaterialKind.other => 0,
      MaterialKind.notes => 1,
      MaterialKind.lectureSheet => 2,
      MaterialKind.questionBank => 3,
      MaterialKind.mockTest => 4,
      MaterialKind.videoCourse => 5,
      MaterialKind.book => 6,
    };
  }
}
