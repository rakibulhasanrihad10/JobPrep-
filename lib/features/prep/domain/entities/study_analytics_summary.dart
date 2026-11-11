import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';

/// Complete computed view-model consumed by the Study Analytics UI.
@immutable
class StudyAnalyticsSummary {
  /// Creates a [StudyAnalyticsSummary].
  const StudyAnalyticsSummary({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.dailyTotals,
    required this.weeklyTotals,
    required this.heatmapDays,
    required this.subjectBreakdown,
    required this.totalUnitsInRange,
    required this.unitsThisWeek,
    required this.activeDaysInRange,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageLast7Days,
    required this.averageLast30Days,
    required this.consistencyScore,
    required this.todayUnits,
    required this.yesterdayUnits,
    required this.targetAlertStatus,
    required this.mockTestCountInRange,
    required this.hasAnyLogs,
    this.totalSessionSecondsInRange = 0,
    this.sessionSecondsThisWeek = 0,
    this.hasAnySessions = false,
    this.dailyTarget,
    this.bestDay,
    this.weakestDay,
    this.averageMockScoreInRange,
  });

  /// Selected lookback window.
  final StudyAnalyticsRange range;

  /// Inclusive local start date of [dailyTotals].
  final DateTime startDate;

  /// Inclusive local end date ("today").
  final DateTime endDate;

  /// Zero-filled per-day study units & hours across `[startDate, endDate]`.
  final List<DailyStudyTotal> dailyTotals;

  /// Weekly totals aggregated across `[startDate, endDate]`.
  final List<WeeklyStudyTotal> weeklyTotals;

  /// Rolling 91-day (13-week) local calendar heatmap series ending [endDate].
  final List<DailyStudyTotal> heatmapDays;

  /// Subject unit and time distribution for the selected date range.
  final List<SubjectStudyBreakdown> subjectBreakdown;

  /// Total units logged across `[startDate, endDate]`.
  final int totalUnitsInRange;

  /// Total units logged from Monday of the current local week through today.
  final int unitsThisWeek;

  /// Total study timer seconds across `[startDate, endDate]`.
  final int totalSessionSecondsInRange;

  /// Total study timer seconds accumulated from Monday through today.
  final int sessionSecondsThisWeek;

  /// Number of days inside `[startDate, endDate]` with `>= 1` unit or
  /// a qualifying `>= 10 min` study session.
  final int activeDaysInRange;

  /// Current active consecutive-day streak (`units >= 1` or `>= 10m session`).
  final int currentStreak;

  /// Longest consecutive-day streak observed across all logs/sessions in scope.
  final int longestStreak;

  /// Mean units per calendar day over the trailing 7 days ending today.
  final double averageLast7Days;

  /// Mean units per calendar day over the trailing 30 days ending today.
  final double averageLast30Days;

  /// Ratio `activeDaysInRange / range.days` clamped to `0.0..1.0`.
  final double consistencyScore;

  /// Optional daily target derived from active study plans for current scope.
  final int? dailyTarget;

  /// Units studied on local today.
  final int todayUnits;

  /// Units studied on local yesterday.
  final int yesterdayUnits;

  /// Alert status checking whether today or yesterday fell below target.
  final StudyDayTargetStatus targetAlertStatus;

  /// Highest-output day inside `[startDate, endDate]` (`null` if no activity).
  final DailyStudyTotal? bestDay;

  /// Lowest-output day inside `[startDate, endDate]` (`null` if no activity).
  final DailyStudyTotal? weakestDay;

  /// Number of mock tests recorded inside `[startDate, endDate]`.
  final int mockTestCountInRange;

  /// Mean mock test score inside `[startDate, endDate]` when tests exist.
  final double? averageMockScoreInRange;

  /// Whether at least one positive study log exists in current scope.
  final bool hasAnyLogs;

  /// Whether at least one completed positive study session exists in scope.
  final bool hasAnySessions;

  /// Total studied hours within `[startDate, endDate]`.
  double get totalHoursInRange => totalSessionSecondsInRange / 3600.0;

  /// Total studied hours accumulated from Monday through today.
  double get hoursThisWeek => sessionSecondsThisWeek / 3600.0;

  /// Whether any study log exists within the currently selected range.
  bool get hasLogsInRange => totalUnitsInRange > 0;

  /// Whether any study session duration exists within the selected range.
  bool get hasSessionsInRange => totalSessionSecondsInRange > 0;

  /// Whether either positive study logs or study sessions exist in scope.
  bool get hasAnyActivity => hasAnyLogs || hasAnySessions;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyAnalyticsSummary &&
        other.range == range &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        listEquals(other.dailyTotals, dailyTotals) &&
        listEquals(other.weeklyTotals, weeklyTotals) &&
        listEquals(other.heatmapDays, heatmapDays) &&
        listEquals(other.subjectBreakdown, subjectBreakdown) &&
        other.totalUnitsInRange == totalUnitsInRange &&
        other.unitsThisWeek == unitsThisWeek &&
        other.totalSessionSecondsInRange == totalSessionSecondsInRange &&
        other.sessionSecondsThisWeek == sessionSecondsThisWeek &&
        other.activeDaysInRange == activeDaysInRange &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.averageLast7Days == averageLast7Days &&
        other.averageLast30Days == averageLast30Days &&
        other.consistencyScore == consistencyScore &&
        other.dailyTarget == dailyTarget &&
        other.todayUnits == todayUnits &&
        other.yesterdayUnits == yesterdayUnits &&
        other.targetAlertStatus == targetAlertStatus &&
        other.bestDay == bestDay &&
        other.weakestDay == weakestDay &&
        other.mockTestCountInRange == mockTestCountInRange &&
        other.averageMockScoreInRange == averageMockScoreInRange &&
        other.hasAnyLogs == hasAnyLogs &&
        other.hasAnySessions == hasAnySessions;
  }

  @override
  int get hashCode => Object.hashAll([
        range,
        startDate,
        endDate,
        Object.hashAll(dailyTotals),
        Object.hashAll(weeklyTotals),
        Object.hashAll(heatmapDays),
        Object.hashAll(subjectBreakdown),
        totalUnitsInRange,
        unitsThisWeek,
        totalSessionSecondsInRange,
        sessionSecondsThisWeek,
        activeDaysInRange,
        currentStreak,
        longestStreak,
        averageLast7Days,
        averageLast30Days,
        consistencyScore,
        dailyTarget,
        todayUnits,
        yesterdayUnits,
        targetAlertStatus,
        bestDay,
        weakestDay,
        mockTestCountInRange,
        averageMockScoreInRange,
        hasAnyLogs,
        hasAnySessions,
      ]);
}
