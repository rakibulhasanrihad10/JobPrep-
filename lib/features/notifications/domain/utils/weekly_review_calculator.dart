import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/notifications/domain/entities/weekly_review_summary.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/mock_test_analytics.dart';
import 'package:job_prep/features/prep/domain/utils/study_session_date_splitter.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/domain/utils/today_window_selectors.dart';

/// Pure calculator aggregating a 7-day rolling Weekly Review summary
/// (`[today - 6d .. today]`) against the previous 7-day baseline
/// (`[today - 13d .. today - 7d]`).
abstract final class WeeklyReviewCalculator {
  /// Window length in calendar days covered by the Weekly Review screen.
  static const int windowDays = 7;

  /// Builds a complete [WeeklyReviewSummary] as of [now] in local time.
  static WeeklyReviewSummary buildSummary({
    required Iterable<ProgressLog> logs,
    required Iterable<StudySession> sessions,
    required Iterable<MockTest> mockTests,
    required Iterable<RevisionItem> revisionItems,
    required List<Circular> circulars,
    required List<StudyPlanSnapshot> planSnapshots,
    required DateTime now,
    Duration? localOffset,
  }) {
    final weekEnd = StudySessionDateSplitter.toLocalDate(
      now,
      localOffset: localOffset,
    );
    final weekStart = _addDays(weekEnd, -(windowDays - 1));
    final prevStart = _addDays(weekStart, -windowDays);
    final prevEnd = _addDays(weekStart, -1);

    final dailyUnits = <DateTime, int>{};
    var unitsThisWeek = 0;
    var unitsPreviousWeek = 0;

    for (final log in logs) {
      if (!log.isStudy || log.unitsDone <= 0) continue;
      final day = _dateOnly(log.loggedOn);
      if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) {
        unitsThisWeek += log.unitsDone;
        dailyUnits[day] = (dailyUnits[day] ?? 0) + log.unitsDone;
      } else if (!day.isBefore(prevStart) && !day.isAfter(prevEnd)) {
        unitsPreviousWeek += log.unitsDone;
      }
    }

    final dailySeconds = <DateTime, int>{};
    var secondsThisWeek = 0;
    var secondsPreviousWeek = 0;

    for (final session in sessions) {
      final slices = StudySessionDateSplitter.splitByLocalDate(
        session,
        now: now,
        localOffset: localOffset,
      );
      for (final entry in slices.entries) {
        final day = entry.key;
        final secs = entry.value;
        if (secs <= 0) continue;
        if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) {
          secondsThisWeek += secs;
          dailySeconds[day] = (dailySeconds[day] ?? 0) + secs;
        } else if (!day.isBefore(prevStart) && !day.isAfter(prevEnd)) {
          secondsPreviousWeek += secs;
        }
      }
    }

    var daysStudied = 0;
    final missedDates = <DateTime>[];
    for (var i = 0; i < windowDays; i++) {
      final day = _addDays(weekStart, i);
      final units = dailyUnits[day] ?? 0;
      final secs = dailySeconds[day] ?? 0;
      final qualified = units >= 1 || secs >= kMinimumQualifyingSessionSeconds;
      if (qualified) {
        daysStudied += 1;
      } else {
        missedDates.add(day);
      }
    }

    final thisWeekTests = <MockTest>[];
    final prevWeekTests = <MockTest>[];
    for (final test in mockTests) {
      final day = _dateOnly(test.takenOn);
      if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) {
        thisWeekTests.add(test);
      } else if (!day.isBefore(prevStart) && !day.isAfter(prevEnd)) {
        prevWeekTests.add(test);
      }
    }

    final mockTestAverageThisWeek = thisWeekTests.isEmpty
        ? null
        : MockTestAnalytics.calculateAverageScore(thisWeekTests);
    final mockTestAveragePreviousWeek = prevWeekTests.isEmpty
        ? null
        : MockTestAnalytics.calculateAverageScore(prevWeekTests);
    final mockAverageDelta =
        (mockTestAverageThisWeek != null && mockTestAveragePreviousWeek != null)
            ? mockTestAverageThisWeek - mockTestAveragePreviousWeek
            : null;

    var revisionsClearedThisWeek = 0;
    var dueOrOverdueRevisionCount = 0;
    for (final item in revisionItems) {
      final isClearedStatus = item.status == RevisionStatus.revised ||
          item.status == RevisionStatus.mastered;
      final reviewedDay =
          item.lastReviewedOn == null ? null : _dateOnly(item.lastReviewedOn!);
      if (isClearedStatus &&
          reviewedDay != null &&
          !reviewedDay.isBefore(weekStart) &&
          !reviewedDay.isAfter(weekEnd)) {
        revisionsClearedThisWeek += 1;
      }
      if (!item.isDone) {
        final dueDay = _dateOnly(item.dueOn);
        if (!dueDay.isAfter(weekEnd)) {
          dueOrOverdueRevisionCount += 1;
        }
      }
    }

    final upcomingDeadlines = TodayWindowSelectors.selectDeadlinesWithinDays(
      circulars: circulars,
      now: now,
    );
    final localRefNow = DateTime(
      weekEnd.year,
      weekEnd.month,
      weekEnd.day,
      now.hour,
      now.minute,
    );
    final upcomingExams = TodayWindowSelectors.selectExamsWithinDays(
      circulars: circulars,
      now: localRefNow,
      maxDays: TodayWindowSelectors.upcomingDeadlinesWindowDays,
    );

    final suggestion = selectSuggestion(
      daysStudied: daysStudied,
      missedDaysCount: missedDates.length,
      mockTestsThisWeekCount: thisWeekTests.length,
      mockAverageDelta: mockAverageDelta,
      dueOrOverdueRevisionCount: dueOrOverdueRevisionCount,
      upcomingDeadlines: upcomingDeadlines,
      upcomingExams: upcomingExams,
      planSnapshots: planSnapshots,
    );

    return WeeklyReviewSummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      unitsThisWeek: unitsThisWeek,
      unitsPreviousWeek: unitsPreviousWeek,
      secondsThisWeek: secondsThisWeek,
      secondsPreviousWeek: secondsPreviousWeek,
      daysStudied: daysStudied,
      missedDaysCount: missedDates.length,
      missedDates: List<DateTime>.unmodifiable(missedDates),
      mockTestsThisWeekCount: thisWeekTests.length,
      mockTestAverageThisWeek: mockTestAverageThisWeek,
      mockTestAveragePreviousWeek: mockTestAveragePreviousWeek,
      mockAverageDelta: mockAverageDelta,
      revisionsClearedThisWeek: revisionsClearedThisWeek,
      upcomingDeadlines: upcomingDeadlines,
      upcomingExams: upcomingExams,
      suggestionKind: suggestion.kind,
      suggestionParam: suggestion.param,
    );
  }

  /// Picks one focused coaching suggestion based on urgency, schedule status,
  /// consistency, mock trend, and revision backlog.
  static ({WeeklyReviewSuggestionKind kind, String? param}) selectSuggestion({
    required int daysStudied,
    required int missedDaysCount,
    required int mockTestsThisWeekCount,
    required double? mockAverageDelta,
    required int dueOrOverdueRevisionCount,
    required List<TodayDeadlineEntry> upcomingDeadlines,
    required List<TodayExamEntry> upcomingExams,
    required List<StudyPlanSnapshot> planSnapshots,
  }) {
    for (final deadline in upcomingDeadlines) {
      if (deadline.daysRemaining <= 3) {
        return (
          kind: WeeklyReviewSuggestionKind.prioritizeNearestDeadline,
          param: deadline.circular.title,
        );
      }
    }

    final behindPlans = planSnapshots
        .where(
          (snap) =>
              snap.scheduleStatus == StudyScheduleStatus.behind &&
              snap.remainingUnits > 0,
        )
        .toList(growable: false)
      ..sort((a, b) => b.missedUnits.compareTo(a.missedUnits));
    if (behindPlans.isNotEmpty) {
      final topPlan = behindPlans.first;
      return (
        kind: WeeklyReviewSuggestionKind.catchUpBehindPlan,
        param: topPlan.subject?.name,
      );
    }

    if (daysStudied == 0) {
      return (
        kind: WeeklyReviewSuggestionKind.startLoggingRoutine,
        param: null,
      );
    }

    if (missedDaysCount >= 3) {
      return (
        kind: WeeklyReviewSuggestionKind.reduceMissedDays,
        param: '$missedDaysCount',
      );
    }

    final mockDropped = mockAverageDelta != null && mockAverageDelta < -2.0;
    final examWithoutMock =
        upcomingExams.isNotEmpty && mockTestsThisWeekCount == 0;
    if (mockDropped || examWithoutMock) {
      return (
        kind: WeeklyReviewSuggestionKind.boostMockPractice,
        param: upcomingExams.isNotEmpty
            ? upcomingExams.first.circular.title
            : null,
      );
    }

    if (dueOrOverdueRevisionCount > 0) {
      return (
        kind: WeeklyReviewSuggestionKind.clearOverdueRevision,
        param: '$dueOrOverdueRevisionCount',
      );
    }

    return (
      kind: WeeklyReviewSuggestionKind.maintainStrongStreak,
      param: null,
    );
  }

  static DateTime _dateOnly(DateTime source) =>
      DateTime(source.year, source.month, source.day);

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);
}
