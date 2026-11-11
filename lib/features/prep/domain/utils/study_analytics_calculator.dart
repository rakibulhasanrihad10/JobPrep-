import 'dart:math' as math;

import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/study_analytics_summary_builder.dart';

/// Pure study analytics, streak, local-date grouping, consistency, and chart
/// series calculations built from `progress_logs`, study plans & mock tests.
abstract final class StudyAnalyticsCalculator {
  /// Number of rolling days plotted on the calendar heatmap (13 full weeks).
  static const int heatmapDaysCount = 91;

  /// Converts [value] into a date-only local calendar date
  /// (`DateTime(year, month, day)`).
  ///
  /// When [value] is in UTC (`value.isUtc == true`), it is converted via
  /// [localOffset] if provided (for deterministic timezone-boundary tests) or
  /// [DateTime.toLocal] otherwise so timestamps near midnight are grouped
  /// into the user's local calendar day rather than UTC.
  static DateTime toLocalCalendarDate(
    DateTime value, {
    Duration? localOffset,
  }) {
    final DateTime shifted;
    if (!value.isUtc) {
      shifted = value;
    } else if (localOffset != null) {
      shifted = value.add(localOffset);
    } else {
      shifted = value.toLocal();
    }
    return DateTime(shifted.year, shifted.month, shifted.day);
  }

  /// Resolves the best local calendar date for a [ProgressLog].
  static DateTime resolveLogLocalDate(
    ProgressLog log, {
    Duration? localOffset,
  }) {
    final raw = log.loggedOn;
    final hasExplicitTime = raw.hour != 0 || raw.minute != 0 || raw.second != 0;
    if (hasExplicitTime || raw.isUtc) {
      return toLocalCalendarDate(raw, localOffset: localOffset);
    }
    return DateTime(raw.year, raw.month, raw.day);
  }

  /// Aggregates total positive units logged on each local calendar day.
  static Map<DateTime, int> groupUnitsByLocalDay(
    Iterable<ProgressLog> logs, {
    Duration? localOffset,
  }) {
    final totals = <DateTime, int>{};
    for (final log in logs) {
      if (log.unitsDone <= 0) continue;
      final day = resolveLogLocalDate(log, localOffset: localOffset);
      totals[day] = (totals[day] ?? 0) + log.unitsDone;
    }
    return Map<DateTime, int>.unmodifiable(totals);
  }

  /// Builds an ascending zero-filled list of [DailyStudyTotal] entries across
  /// the inclusive local calendar range `[startDate, endDate]`.
  static List<DailyStudyTotal> calculateDailyUnits(
    Iterable<ProgressLog> logs, {
    required DateTime startDate,
    required DateTime endDate,
    Duration? localOffset,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    if (end.isBefore(start)) {
      return const <DailyStudyTotal>[];
    }

    final grouped = groupUnitsByLocalDay(logs, localOffset: localOffset);
    final result = <DailyStudyTotal>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      result.add(
        DailyStudyTotal(
          date: cursor,
          units: grouped[cursor] ?? 0,
        ),
      );
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return List<DailyStudyTotal>.unmodifiable(result);
  }

  /// Aggregates [dailyTotals] into chronological Monday-to-Sunday weekly
  /// buckets clipped to the first and last dates present.
  static List<WeeklyStudyTotal> calculateWeeklyTotals(
    Iterable<DailyStudyTotal> dailyTotals,
  ) {
    final ordered = List<DailyStudyTotal>.of(dailyTotals)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (ordered.isEmpty) return const <WeeklyStudyTotal>[];

    final weeks = <WeeklyStudyTotal>[];
    DateTime? currentMonday;
    DateTime? bucketStart;
    DateTime? bucketEnd;
    var sum = 0;
    var active = 0;

    for (final item in ordered) {
      final monday = DateTime(
        item.date.year,
        item.date.month,
        item.date.day - (item.date.weekday - DateTime.monday),
      );
      if (currentMonday == null) {
        currentMonday = monday;
        bucketStart = item.date;
        bucketEnd = item.date;
      } else if (monday != currentMonday) {
        weeks.add(
          WeeklyStudyTotal(
            weekStart: bucketStart!,
            weekEnd: bucketEnd!,
            units: sum,
            activeDays: active,
          ),
        );
        currentMonday = monday;
        bucketStart = item.date;
        bucketEnd = item.date;
        sum = 0;
        active = 0;
      } else {
        bucketEnd = item.date;
      }
      sum += math.max(0, item.units);
      if (item.units > 0) active += 1;
    }

    if (bucketStart != null && bucketEnd != null) {
      weeks.add(
        WeeklyStudyTotal(
          weekStart: bucketStart,
          weekEnd: bucketEnd,
          units: sum,
          activeDays: active,
        ),
      );
    }
    return List<WeeklyStudyTotal>.unmodifiable(weeks);
  }

  /// Computes `current` and `longest` study streaks (`units >= 1`).
  static ({int current, int longest}) calculateStreaks(
    Map<DateTime, int> unitsByLocalDay, {
    required DateTime today,
  }) {
    final todayOnly = DateTime(today.year, today.month, today.day);
    final activeDays = <DateTime>[
      for (final entry in unitsByLocalDay.entries)
        if (entry.value >= 1 && !entry.key.isAfter(todayOnly))
          DateTime(entry.key.year, entry.key.month, entry.key.day),
    ]..sort((a, b) => a.compareTo(b));

    if (activeDays.isEmpty) {
      return (current: 0, longest: 0);
    }

    final uniqueDays = <DateTime>[];
    for (final day in activeDays) {
      if (uniqueDays.isEmpty || uniqueDays.last != day) {
        uniqueDays.add(day);
      }
    }

    var longest = 1;
    var run = 1;
    for (var i = 1; i < uniqueDays.length; i++) {
      final expectedNext = DateTime(
        uniqueDays[i - 1].year,
        uniqueDays[i - 1].month,
        uniqueDays[i - 1].day + 1,
      );
      if (uniqueDays[i] == expectedNext) {
        run += 1;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }

    final yesterday =
        DateTime(todayOnly.year, todayOnly.month, todayOnly.day - 1);
    final activeSet = uniqueDays.toSet();

    DateTime? cursor;
    if (activeSet.contains(todayOnly)) {
      cursor = todayOnly;
    } else if (activeSet.contains(yesterday)) {
      cursor = yesterday;
    }

    var current = 0;
    while (cursor != null && activeSet.contains(cursor)) {
      current += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    return (current: current, longest: longest);
  }

  /// Calculates daily mean units across `[today - (days - 1), today]`.
  static double calculateRollingAverage(
    Map<DateTime, int> unitsByLocalDay, {
    required DateTime today,
    required int days,
  }) {
    if (days <= 0) return 0;
    var total = 0;
    for (var offset = 0; offset < days; offset++) {
      final day = DateTime(today.year, today.month, today.day - offset);
      total += math.max(0, unitsByLocalDay[day] ?? 0);
    }
    return total / days;
  }

  /// Calculates ratio `daysStudied / daysInRange` (`0.0..1.0`).
  static double calculateConsistencyScore(
    Iterable<DailyStudyTotal> dailyTotals,
  ) {
    final list = dailyTotals.toList(growable: false);
    if (list.isEmpty) return 0;
    var active = 0;
    for (final item in list) {
      if (item.units >= 1) active += 1;
    }
    return (active / list.length).clamp(0.0, 1.0);
  }

  /// Returns best (maximum units) and weakest (minimum units) day across
  /// [dailyTotals], or `(best: null, weakest: null)` when no logs exist.
  static ({DailyStudyTotal? best, DailyStudyTotal? weakest})
      findBestAndWeakestDay(Iterable<DailyStudyTotal> dailyTotals) {
    final list = dailyTotals.toList(growable: false)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (list.isEmpty || list.every((d) => d.units <= 0)) {
      return (best: null, weakest: null);
    }

    var best = list.first;
    var weakest = list.first;
    for (final item in list.skip(1)) {
      if (item.units >= best.units) {
        best = item;
      }
      if (item.units <= weakest.units) {
        weakest = item;
      }
    }
    return (best: best, weakest: weakest);
  }

  /// Resolves today's daily unit target from [planSnapshots].
  static int? resolveDailyTarget({
    required List<StudyPlanSnapshot> planSnapshots,
    String? subjectId,
  }) =>
      StudyAnalyticsSummaryBuilder.resolveDailyTarget(
        planSnapshots: planSnapshots,
        subjectId: subjectId,
      );

  /// Evaluates whether today or yesterday fell below [dailyTarget].
  static StudyDayTargetStatus evaluateTargetAlert({
    required int todayUnits,
    required int yesterdayUnits,
    required int? dailyTarget,
  }) =>
      StudyAnalyticsSummaryBuilder.evaluateTargetAlert(
        todayUnits: todayUnits,
        yesterdayUnits: yesterdayUnits,
        dailyTarget: dailyTarget,
      );

  /// Computes per-subject breakdown showing where study time and mock tests
  /// went.
  static List<SubjectStudyBreakdown> calculateSubjectBreakdown({
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    required List<ProgressLog> logsInRange,
    required List<MockTest> mockTestsInRange,
  }) =>
      StudyAnalyticsSummaryBuilder.calculateSubjectBreakdown(
        subjects: subjects,
        materials: materials,
        logsInRange: logsInRange,
        mockTestsInRange: mockTestsInRange,
      );

  /// Builds the complete [StudyAnalyticsSummary] for the requested filters.
  static StudyAnalyticsSummary buildSummary({
    required StudyAnalyticsRange range,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    required List<ProgressLog> logs,
    required List<StudyPlanSnapshot> planSnapshots,
    required List<MockTest> mockTests,
    DateTime? now,
    Duration? localOffset,
    String? subjectId,
  }) =>
      StudyAnalyticsSummaryBuilder.build(
        range: range,
        subjects: subjects,
        materials: materials,
        logs: logs,
        planSnapshots: planSnapshots,
        mockTests: mockTests,
        now: now,
        localOffset: localOffset,
        subjectId: subjectId,
      );
}
