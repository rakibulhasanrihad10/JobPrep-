import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Selectable lookback windows supported on the Study Analytics screen.
enum StudyAnalyticsRange {
  /// Last 7 local calendar days including today.
  days7(7),

  /// Last 30 local calendar days including today.
  days30(30),

  /// Last 90 local calendar days including today.
  days90(90);

  const StudyAnalyticsRange(this.days);

  /// Inclusive calendar day count represented by this window.
  final int days;
}

/// Alert status indicating whether today or yesterday fell short of target.
enum StudyDayTargetStatus {
  /// Neither today nor yesterday is below an active study plan target, or
  /// no study plan target applies.
  onTrackOrNoTarget,

  /// Today has fewer logged units than the active daily target.
  todayBelowTarget,

  /// Yesterday had fewer logged units than the active daily target.
  yesterdayBelowTarget,

  /// Both today and yesterday fell below the active daily target.
  bothBelowTarget,
}

/// Total study units logged on a single local calendar day.
@immutable
class DailyStudyTotal {
  /// Creates a [DailyStudyTotal].
  const DailyStudyTotal({
    required this.date,
    required this.units,
  });

  /// Local calendar midnight (`DateTime(year, month, day)`).
  final DateTime date;

  /// Total non-negative units studied on [date].
  final int units;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyStudyTotal &&
        other.date == date &&
        other.units == units;
  }

  @override
  int get hashCode => Object.hash(date, units);
}

/// Aggregated study volume across a single week bucket within the selected
/// analytics window.
@immutable
class WeeklyStudyTotal {
  /// Creates a [WeeklyStudyTotal].
  const WeeklyStudyTotal({
    required this.weekStart,
    required this.weekEnd,
    required this.units,
    required this.activeDays,
  });

  /// Inclusive start date (local calendar date) of this weekly bucket.
  final DateTime weekStart;

  /// Inclusive end date (local calendar date) of this weekly bucket.
  final DateTime weekEnd;

  /// Sum of units studied within `[weekStart, weekEnd]`.
  final int units;

  /// Count of days inside this bucket with at least 1 unit studied.
  final int activeDays;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyStudyTotal &&
        other.weekStart == weekStart &&
        other.weekEnd == weekEnd &&
        other.units == units &&
        other.activeDays == activeDays;
  }

  @override
  int get hashCode => Object.hash(weekStart, weekEnd, units, activeDays);
}

/// Subject-level share of study units (and optional mock test outcomes) in
/// the selected window.
@immutable
class SubjectStudyBreakdown {
  /// Creates a [SubjectStudyBreakdown].
  const SubjectStudyBreakdown({
    required this.subjectId,
    required this.subjectName,
    required this.colorKey,
    required this.units,
    required this.share,
    this.mockTestCount = 0,
    this.averageMockScore,
  });

  /// Subject identifier.
  final String subjectId;

  /// Human-readable subject title.
  final String subjectName;

  /// Semantic token key (`gold`, `info`, etc.) resolved via `PrepStyleTokens`.
  final String colorKey;

  /// Total units logged for this subject in the selected range.
  final int units;

  /// Normalized share of total logged units (`0.0..1.0`).
  final double share;

  /// Count of mock tests recorded for this subject in the selected range.
  final int mockTestCount;

  /// Average mock test net percentage in range, if [mockTestCount] > 0.
  final double? averageMockScore;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubjectStudyBreakdown &&
        other.subjectId == subjectId &&
        other.subjectName == subjectName &&
        other.colorKey == colorKey &&
        other.units == units &&
        other.share == share &&
        other.mockTestCount == mockTestCount &&
        other.averageMockScore == averageMockScore;
  }

  @override
  int get hashCode => Object.hash(
        subjectId,
        subjectName,
        colorKey,
        units,
        share,
        mockTestCount,
        averageMockScore,
      );
}

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

  /// Zero-filled per-day study units across `[startDate, endDate]`.
  final List<DailyStudyTotal> dailyTotals;

  /// Weekly totals aggregated across `[startDate, endDate]`.
  final List<WeeklyStudyTotal> weeklyTotals;

  /// Rolling 91-day (13-week) local calendar heatmap series ending [endDate].
  final List<DailyStudyTotal> heatmapDays;

  /// Subject unit distribution for the selected date range.
  final List<SubjectStudyBreakdown> subjectBreakdown;

  /// Total units logged across `[startDate, endDate]`.
  final int totalUnitsInRange;

  /// Total units logged from Monday of the current local week through today.
  final int unitsThisWeek;

  /// Number of days inside `[startDate, endDate]` with `>= 1` unit logged.
  final int activeDaysInRange;

  /// Current active consecutive-day streak (`units >= 1`).
  final int currentStreak;

  /// Longest consecutive-day streak observed across all logs in scope.
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

  /// Highest-output day inside `[startDate, endDate]` (`null` if no logs).
  final DailyStudyTotal? bestDay;

  /// Lowest-output day inside `[startDate, endDate]` (`null` if no logs).
  final DailyStudyTotal? weakestDay;

  /// Number of mock tests recorded inside `[startDate, endDate]`.
  final int mockTestCountInRange;

  /// Mean mock test score inside `[startDate, endDate]` when tests exist.
  final double? averageMockScoreInRange;

  /// Whether at least one positive study log exists in current scope.
  final bool hasAnyLogs;

  /// Whether any study log exists within the currently selected range.
  bool get hasLogsInRange => totalUnitsInRange > 0;

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
        other.hasAnyLogs == hasAnyLogs;
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
      ]);
}
