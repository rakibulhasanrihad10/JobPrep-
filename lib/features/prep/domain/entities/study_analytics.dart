import 'package:flutter/foundation.dart' show immutable;

export 'package:job_prep/features/prep/domain/entities/study_analytics_summary.dart';

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

/// Total study units and timer duration logged on a single local calendar day.
@immutable
class DailyStudyTotal {
  /// Creates a [DailyStudyTotal].
  const DailyStudyTotal({
    required this.date,
    required this.units,
    this.sessionSeconds = 0,
    this.hasQualifyingSession = false,
  });

  /// Local calendar midnight (`DateTime(year, month, day)`).
  final DateTime date;

  /// Total non-negative units studied on [date].
  final int units;

  /// Total completed study timer seconds attributed to local [date].
  final int sessionSeconds;

  /// Whether at least one session contributed `>= 10 min` (`600` seconds)
  /// on [date], marking [date] as an active study day even with `0` unit logs.
  final bool hasQualifyingSession;

  /// Studied hours on [date].
  double get hours => sessionSeconds / 3600.0;

  /// Whether [date] counts as a studied day (`>= 1` unit or `>= 10m` session).
  bool get isStudiedDay => units >= 1 || hasQualifyingSession;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyStudyTotal &&
        other.date == date &&
        other.units == units &&
        other.sessionSeconds == sessionSeconds &&
        other.hasQualifyingSession == hasQualifyingSession;
  }

  @override
  int get hashCode =>
      Object.hash(date, units, sessionSeconds, hasQualifyingSession);
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
    this.sessionSeconds = 0,
  });

  /// Inclusive start date (local calendar date) of this weekly bucket.
  final DateTime weekStart;

  /// Inclusive end date (local calendar date) of this weekly bucket.
  final DateTime weekEnd;

  /// Sum of units studied within `[weekStart, weekEnd]`.
  final int units;

  /// Count of studied days inside `[weekStart, weekEnd]`.
  final int activeDays;

  /// Total completed study session seconds within `[weekStart, weekEnd]`.
  final int sessionSeconds;

  /// Total studied hours within this weekly bucket.
  double get hours => sessionSeconds / 3600.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyStudyTotal &&
        other.weekStart == weekStart &&
        other.weekEnd == weekEnd &&
        other.units == units &&
        other.activeDays == activeDays &&
        other.sessionSeconds == sessionSeconds;
  }

  @override
  int get hashCode =>
      Object.hash(weekStart, weekEnd, units, activeDays, sessionSeconds);
}

/// Subject-level share of study units, timer hours, and optional mock test
/// outcomes in the selected window.
@immutable
class SubjectStudyBreakdown {
  /// Creates a [SubjectStudyBreakdown].
  const SubjectStudyBreakdown({
    required this.subjectId,
    required this.subjectName,
    required this.colorKey,
    required this.units,
    required this.share,
    this.sessionSeconds = 0,
    this.timeShare = 0,
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

  /// Total study timer seconds for this subject in the selected range.
  final int sessionSeconds;

  /// Normalized share of total timer seconds (`0.0..1.0`).
  final double timeShare;

  /// Count of mock tests recorded for this subject in the selected range.
  final int mockTestCount;

  /// Average mock test net percentage in range, if [mockTestCount] > 0.
  final double? averageMockScore;

  /// Total studied hours for this subject in the selected range.
  double get hours => sessionSeconds / 3600.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubjectStudyBreakdown &&
        other.subjectId == subjectId &&
        other.subjectName == subjectName &&
        other.colorKey == colorKey &&
        other.units == units &&
        other.share == share &&
        other.sessionSeconds == sessionSeconds &&
        other.timeShare == timeShare &&
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
        sessionSeconds,
        timeShare,
        mockTestCount,
        averageMockScore,
      );
}
