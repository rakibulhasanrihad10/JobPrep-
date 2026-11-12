import 'package:job_prep/features/today/domain/entities/today_summary.dart';

/// Deterministic single-focus coaching recommendation shown at the end of the
/// Weekly Review summary.
enum WeeklyReviewSuggestionKind {
  /// Prioritize the nearest circular closing within 3 days.
  prioritizeNearestDeadline,

  /// Focus on catching up a study plan currently behind schedule.
  catchUpBehindPlan,

  /// Restart consistency after a week with no recorded study days.
  startLoggingRoutine,

  /// Trim missed days by scheduling shorter daily minimums.
  reduceMissedDays,

  /// Add timed mock practice where exam pressure or score dip warrants it.
  boostMockPractice,

  /// Clear pending spaced-revision items before new material piles up.
  clearOverdueRevision,

  /// Reinforce a consistent study week and maintain current pace.
  maintainStrongStreak,
}

/// Pure 7-day metrics for the Weekly Review (`[today - 6d .. today]`)
/// compared against the prior 7-day window (`[today - 13d .. today - 7d]`).
class WeeklyReviewSummary {
  /// Creates a [WeeklyReviewSummary].
  const WeeklyReviewSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.unitsThisWeek,
    required this.unitsPreviousWeek,
    required this.secondsThisWeek,
    required this.secondsPreviousWeek,
    required this.daysStudied,
    required this.missedDaysCount,
    required this.missedDates,
    required this.mockTestsThisWeekCount,
    required this.mockTestAverageThisWeek,
    required this.mockTestAveragePreviousWeek,
    required this.mockAverageDelta,
    required this.revisionsClearedThisWeek,
    required this.upcomingDeadlines,
    required this.upcomingExams,
    required this.suggestionKind,
    this.suggestionParam,
  });

  /// Inclusive start date (midnight token representing local start date).
  final DateTime weekStart;

  /// Inclusive end calendar date (`today` local date).
  final DateTime weekEnd;

  /// Study units logged during `[weekStart .. weekEnd]` (no corrections).
  final int unitsThisWeek;

  /// Study units logged during `[weekStart - 7d .. weekStart - 1d]`.
  final int unitsPreviousWeek;

  /// Studied seconds split by local calendar date in `[weekStart .. weekEnd]`.
  final int secondsThisWeek;

  /// Total studied seconds split by local calendar date in the previous 7 days.
  final int secondsPreviousWeek;

  /// Count of days (`0..7`) with >= 1 studied unit or >= 10 minutes focus time.
  final int daysStudied;

  /// Count of days (`7 - daysStudied`) without qualifying study activity.
  final int missedDaysCount;

  /// Calendar dates in `[weekStart .. weekEnd]` without qualifying activity.
  final List<DateTime> missedDates;

  /// Number of mock tests recorded in `[weekStart .. weekEnd]`.
  final int mockTestsThisWeekCount;

  /// Mean percentage score across this week's mock tests, or `null` when none.
  final double? mockTestAverageThisWeek;

  /// Mean percentage score across last week's mock tests, or `null` when none.
  final double? mockTestAveragePreviousWeek;

  /// Score delta (`thisWeek - previousWeek`) when both weeks have mock tests.
  final double? mockAverageDelta;

  /// Count of revision items reviewed (`revised` or `mastered`) this week.
  final int revisionsClearedThisWeek;

  /// Circular application deadlines closing in the next 7 days.
  final List<TodayDeadlineEntry> upcomingDeadlines;

  /// Circular exam dates scheduled in the next 7 days.
  final List<TodayExamEntry> upcomingExams;

  /// Single highest-signal actionable recommendation for next week.
  final WeeklyReviewSuggestionKind suggestionKind;

  /// Optional title or subject parameter used when formatting the suggestion.
  final String? suggestionParam;

  /// Net change in studied units compared with the previous 7 days.
  int get unitsDelta => unitsThisWeek - unitsPreviousWeek;

  /// Hours studied this week (fractional hours for display).
  double get hoursThisWeek => secondsThisWeek / 3600.0;

  /// Hours studied during the previous week.
  double get hoursPreviousWeek => secondsPreviousWeek / 3600.0;

  /// Net hour delta compared with the previous week.
  double get hoursDelta => hoursThisWeek - hoursPreviousWeek;

  /// Whether the user has recorded any study activity or upcoming events.
  bool get hasAnyActivity =>
      unitsThisWeek > 0 ||
      secondsThisWeek > 0 ||
      mockTestsThisWeekCount > 0 ||
      revisionsClearedThisWeek > 0;
}
