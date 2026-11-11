import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan_snapshot.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/mock_test_analytics.dart';
import 'package:job_prep/features/prep/domain/utils/study_analytics_calculator.dart';

/// Builds [StudyAnalyticsSummary] and subject breakdown slices from progress
/// logs, study plans, subjects, materials, and mock test history.
abstract final class StudyAnalyticsSummaryBuilder {
  /// Resolves today's daily unit target for [subjectId] (or overall scope when
  /// `null`) from live [planSnapshots], returning `null` if no plan applies.
  static int? resolveDailyTarget({
    required List<StudyPlanSnapshot> planSnapshots,
    String? subjectId,
  }) {
    if (planSnapshots.isEmpty) return null;

    if (subjectId != null && subjectId.isNotEmpty) {
      for (final snapshot in planSnapshots) {
        if (snapshot.plan.subjectId == subjectId) {
          return snapshot.todayTarget;
        }
      }
      return null;
    }

    for (final snapshot in planSnapshots) {
      if (snapshot.plan.isAllSubjects) {
        return snapshot.todayTarget;
      }
    }

    var summed = 0;
    var matched = 0;
    for (final snapshot in planSnapshots) {
      if (!snapshot.plan.isAllSubjects) {
        summed += snapshot.todayTarget;
        matched += 1;
      }
    }
    return matched > 0 ? summed : null;
  }

  /// Evaluates whether today and/or yesterday fell below [dailyTarget].
  static StudyDayTargetStatus evaluateTargetAlert({
    required int todayUnits,
    required int yesterdayUnits,
    required int? dailyTarget,
  }) {
    if (dailyTarget == null || dailyTarget <= 0) {
      return StudyDayTargetStatus.onTrackOrNoTarget;
    }
    final todayBelow = todayUnits < dailyTarget;
    final yesterdayBelow = yesterdayUnits < dailyTarget;
    if (todayBelow && yesterdayBelow) {
      return StudyDayTargetStatus.bothBelowTarget;
    }
    if (todayBelow) {
      return StudyDayTargetStatus.todayBelowTarget;
    }
    if (yesterdayBelow) {
      return StudyDayTargetStatus.yesterdayBelowTarget;
    }
    return StudyDayTargetStatus.onTrackOrNoTarget;
  }

  /// Builds subject-level breakdown showing where study units went and linking
  /// mock test counts/averages recorded in the same date window.
  static List<SubjectStudyBreakdown> calculateSubjectBreakdown({
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    required List<ProgressLog> logsInRange,
    required List<MockTest> mockTestsInRange,
  }) {
    final subjectByMaterialId = <String, String>{
      for (final m in materials) m.id: m.subjectId,
    };
    final unitsBySubject = <String, int>{};
    var grandTotalUnits = 0;

    for (final log in logsInRange) {
      if (log.unitsDone <= 0) continue;
      final subjectId = subjectByMaterialId[log.materialId];
      if (subjectId == null || subjectId.isEmpty) continue;
      unitsBySubject[subjectId] =
          (unitsBySubject[subjectId] ?? 0) + log.unitsDone;
      grandTotalUnits += log.unitsDone;
    }

    final testsBySubject = <String, List<MockTest>>{};
    for (final test in mockTestsInRange) {
      testsBySubject.putIfAbsent(test.subjectId, () => []).add(test);
    }

    final items = <SubjectStudyBreakdown>[];
    for (final subject in subjects) {
      final units = unitsBySubject[subject.id] ?? 0;
      final subjectTests = testsBySubject[subject.id] ?? const <MockTest>[];
      final mockSummary = subjectTests.isEmpty
          ? null
          : MockTestAnalytics.summarizeTests(subjectTests);
      final mockCount = mockSummary?.testCount ?? 0;
      if (units <= 0 && mockCount <= 0) continue;

      items.add(
        SubjectStudyBreakdown(
          subjectId: subject.id,
          subjectName: subject.name,
          colorKey: subject.color,
          units: units,
          share: grandTotalUnits > 0 ? units / grandTotalUnits : 0,
          mockTestCount: mockCount,
          averageMockScore: mockCount > 0 ? mockSummary!.averageScore : null,
        ),
      );
    }

    items.sort((a, b) {
      final unitDiff = b.units.compareTo(a.units);
      if (unitDiff != 0) return unitDiff;
      return a.subjectName.compareTo(b.subjectName);
    });
    return List<SubjectStudyBreakdown>.unmodifiable(items);
  }

  /// Builds the full [StudyAnalyticsSummary] for the requested [range] and
  /// optional [subjectId] filter relative to [now].
  static StudyAnalyticsSummary build({
    required StudyAnalyticsRange range,
    required List<Subject> subjects,
    required List<PrepMaterial> materials,
    required List<ProgressLog> logs,
    required List<StudyPlanSnapshot> planSnapshots,
    required List<MockTest> mockTests,
    DateTime? now,
    Duration? localOffset,
    String? subjectId,
  }) {
    final endDate = StudyAnalyticsCalculator.toLocalCalendarDate(
      now ?? DateTime.now(),
      localOffset: localOffset,
    );
    final startDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day - (range.days - 1),
    );
    final heatmapStart = DateTime(
      endDate.year,
      endDate.month,
      endDate.day - (StudyAnalyticsCalculator.heatmapDaysCount - 1),
    );

    final activeSubjectId =
        (subjectId != null && subjectId.trim().isNotEmpty) ? subjectId : null;
    final materialSubjectById = <String, String>{
      for (final m in materials) m.id: m.subjectId,
    };

    final scopedLogs = activeSubjectId == null
        ? logs
        : logs
            .where((l) => materialSubjectById[l.materialId] == activeSubjectId)
            .toList(growable: false);

    final logsInRange = <ProgressLog>[
      for (final log in scopedLogs)
        if (log.unitsDone > 0)
          if (!_isOutsideRange(
            StudyAnalyticsCalculator.resolveLogLocalDate(
              log,
              localOffset: localOffset,
            ),
            start: startDate,
            end: endDate,
          ))
            log,
    ];

    final scopedMocks = activeSubjectId == null
        ? mockTests
        : mockTests
            .where((t) => t.subjectId == activeSubjectId)
            .toList(growable: false);
    final mocksInRange = <MockTest>[
      for (final test in scopedMocks)
        if (!_isOutsideRange(
          StudyAnalyticsCalculator.toLocalCalendarDate(
            test.takenOn,
            localOffset: localOffset,
          ),
          start: startDate,
          end: endDate,
        ))
          test,
    ];

    final unitsByDayAll = StudyAnalyticsCalculator.groupUnitsByLocalDay(
      scopedLogs,
      localOffset: localOffset,
    );
    final dailyTotals = StudyAnalyticsCalculator.calculateDailyUnits(
      scopedLogs,
      startDate: startDate,
      endDate: endDate,
      localOffset: localOffset,
    );
    final weeklyTotals =
        StudyAnalyticsCalculator.calculateWeeklyTotals(dailyTotals);
    final heatmapDays = StudyAnalyticsCalculator.calculateDailyUnits(
      scopedLogs,
      startDate: heatmapStart,
      endDate: endDate,
      localOffset: localOffset,
    );

    var totalUnitsInRange = 0;
    var activeDaysInRange = 0;
    for (final item in dailyTotals) {
      totalUnitsInRange += item.units;
      if (item.units >= 1) activeDaysInRange += 1;
    }

    final mondayThisWeek = DateTime(
      endDate.year,
      endDate.month,
      endDate.day - (endDate.weekday - DateTime.monday),
    );
    var unitsThisWeek = 0;
    var cursor = mondayThisWeek;
    while (!cursor.isAfter(endDate)) {
      unitsThisWeek += unitsByDayAll[cursor] ?? 0;
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    final streaks = StudyAnalyticsCalculator.calculateStreaks(
      unitsByDayAll,
      today: endDate,
    );
    final avg7 = StudyAnalyticsCalculator.calculateRollingAverage(
      unitsByDayAll,
      today: endDate,
      days: 7,
    );
    final avg30 = StudyAnalyticsCalculator.calculateRollingAverage(
      unitsByDayAll,
      today: endDate,
      days: 30,
    );
    final consistency =
        StudyAnalyticsCalculator.calculateConsistencyScore(dailyTotals);
    final extrema = StudyAnalyticsCalculator.findBestAndWeakestDay(dailyTotals);

    final yesterday = DateTime(endDate.year, endDate.month, endDate.day - 1);
    final todayUnits = unitsByDayAll[endDate] ?? 0;
    final yesterdayUnits = unitsByDayAll[yesterday] ?? 0;
    final dailyTarget = resolveDailyTarget(
      planSnapshots: planSnapshots,
      subjectId: activeSubjectId,
    );
    final alertStatus = evaluateTargetAlert(
      todayUnits: todayUnits,
      yesterdayUnits: yesterdayUnits,
      dailyTarget: dailyTarget,
    );

    final breakdownSubjects = activeSubjectId == null
        ? subjects
        : subjects
            .where((s) => s.id == activeSubjectId)
            .toList(growable: false);
    final breakdown = calculateSubjectBreakdown(
      subjects: breakdownSubjects,
      materials: materials,
      logsInRange: logsInRange,
      mockTestsInRange: mocksInRange,
    );

    final mockSummary = MockTestAnalytics.summarizeTests(mocksInRange);
    final hasAnyLogs = unitsByDayAll.values.any((u) => u > 0);

    return StudyAnalyticsSummary(
      range: range,
      startDate: startDate,
      endDate: endDate,
      dailyTotals: dailyTotals,
      weeklyTotals: weeklyTotals,
      heatmapDays: heatmapDays,
      subjectBreakdown: breakdown,
      totalUnitsInRange: totalUnitsInRange,
      unitsThisWeek: unitsThisWeek,
      activeDaysInRange: activeDaysInRange,
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
      averageLast7Days: avg7,
      averageLast30Days: avg30,
      consistencyScore: consistency,
      dailyTarget: dailyTarget,
      todayUnits: todayUnits,
      yesterdayUnits: yesterdayUnits,
      targetAlertStatus: alertStatus,
      bestDay: extrema.best,
      weakestDay: extrema.weakest,
      mockTestCountInRange: mockSummary.testCount,
      averageMockScoreInRange:
          mockSummary.hasTests ? mockSummary.averageScore : null,
      hasAnyLogs: hasAnyLogs,
    );
  }

  static bool _isOutsideRange(
    DateTime day, {
    required DateTime start,
    required DateTime end,
  }) {
    return day.isBefore(start) || day.isAfter(end);
  }
}
