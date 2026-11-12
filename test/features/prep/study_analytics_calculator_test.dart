import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/study_analytics_calculator.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';

void main() {
  const subMath = Subject(
    id: 'sub-math',
    userId: 'u-1',
    name: 'Mathematics',
    icon: 'calculate',
  );
  const subEng = Subject(
    id: 'sub-eng',
    userId: 'u-1',
    name: 'English',
    color: 'info',
    icon: 'language',
  );
  const matMath = PrepMaterial(
    id: 'mat-math',
    userId: 'u-1',
    subjectId: 'sub-math',
    title: 'Algebra Guide',
    totalUnits: 300,
    completedUnits: 120,
  );
  const matEng = PrepMaterial(
    id: 'mat-eng',
    userId: 'u-1',
    subjectId: 'sub-eng',
    title: 'Grammar Digest',
    totalUnits: 200,
    completedUnits: 80,
  );

  group('StudyAnalyticsCalculator date normalization & midnight boundary', () {
    test('groups UTC timestamps near midnight into user local calendar days',
        () {
      // Asia/Dhaka is UTC+6:
      // 2026-11-10T17:59:59Z -> 2026-11-10 23:59:59 local (Nov 10)
      // 2026-11-10T18:00:00Z -> 2026-11-11 00:00:00 local (Nov 11)
      const dhakaOffset = Duration(hours: 6);
      final beforeMidnight = ProgressLog(
        id: 'before',
        materialId: 'mat-math',
        unitsDone: 12,
        loggedOn: DateTime.utc(2026, 11, 10, 17, 59, 59),
      );
      final afterMidnight = ProgressLog(
        id: 'after',
        materialId: 'mat-math',
        unitsDone: 18,
        loggedOn: DateTime.utc(2026, 11, 10, 18),
      );
      // Date-only DB column has isUtc == false -> preserves calendar day.
      final dateOnly = ProgressLog(
        id: 'db-date',
        materialId: 'mat-math',
        unitsDone: 5,
        loggedOn: DateTime(2026, 11, 10),
      );

      final grouped = StudyAnalyticsCalculator.groupUnitsByLocalDay(
        [beforeMidnight, afterMidnight, dateOnly],
        localOffset: dhakaOffset,
      );

      expect(grouped[DateTime(2026, 11, 10)], 17);
      expect(grouped[DateTime(2026, 11, 11)], 18);

      final summary = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        subjects: const [subMath],
        materials: const [matMath],
        logs: [beforeMidnight, afterMidnight],
        planSnapshots: const [],
        mockTests: const [],
        now: DateTime.utc(2026, 11, 10, 19), // Nov 11 01:00 Dhaka
        localOffset: dhakaOffset,
      );
      expect(summary.endDate, DateTime(2026, 11, 11));
      expect(summary.todayUnits, 18);
      expect(summary.yesterdayUnits, 12);
      expect(summary.currentStreak, 2);
    });

    test('handles negative UTC offset midnight boundary accurately', () {
      // America/New_York EST is UTC-5:
      // 2026-11-11T04:59:59Z -> 2026-11-10 23:59:59 local (Nov 10)
      // 2026-11-11T05:00:00Z -> 2026-11-11 00:00:00 local (Nov 11)
      const nyOffset = Duration(hours: -5);
      final lateNightLocal = ProgressLog(
        materialId: 'mat-math',
        unitsDone: 25,
        loggedOn: DateTime.utc(2026, 11, 11, 4, 59, 59),
      );
      final earlyMorningLocal = ProgressLog(
        materialId: 'mat-math',
        unitsDone: 10,
        loggedOn: DateTime.utc(2026, 11, 11, 5),
      );

      final grouped = StudyAnalyticsCalculator.groupUnitsByLocalDay(
        [lateNightLocal, earlyMorningLocal],
        localOffset: nyOffset,
      );
      expect(grouped[DateTime(2026, 11, 10)], 25);
      expect(grouped[DateTime(2026, 11, 11)], 10);
    });
  });

  group('StudyAnalyticsCalculator series, streaks, and metrics', () {
    test('zero-fills empty range cleanly without crashing', () {
      final start = DateTime(2026, 11, 4);
      final end = DateTime(2026, 11, 10);
      final daily = StudyAnalyticsCalculator.calculateDailyUnits(
        const [],
        startDate: start,
        endDate: end,
      );
      expect(daily.length, 7);
      expect(daily.every((d) => d.units == 0), isTrue);

      final streaks = StudyAnalyticsCalculator.calculateStreaks(
        const {},
        today: end,
      );
      expect(streaks, (current: 0, longest: 0));
      expect(StudyAnalyticsCalculator.calculateConsistencyScore(daily), 0);
      expect(
        StudyAnalyticsCalculator.findBestAndWeakestDay(daily),
        (best: null, weakest: null),
      );
      expect(
        StudyAnalyticsCalculator.calculateRollingAverage(
          const {},
          today: end,
          days: 7,
        ),
        0,
      );
      expect(
        StudyAnalyticsCalculator.calculateRollingAverage(
          const {},
          today: end,
          days: 30,
        ),
        0,
      );
    });

    test('calculates streaks across single day, gaps, and pending today', () {
      final today = DateTime(2026, 11, 10);

      // Single logged day = today
      expect(
        StudyAnalyticsCalculator.calculateStreaks(
          {DateTime(2026, 11, 10): 1},
          today: today,
        ),
        (current: 1, longest: 1),
      );

      // Single logged day in the past
      expect(
        StudyAnalyticsCalculator.calculateStreaks(
          {DateTime(2026, 11, 7): 15},
          today: today,
        ),
        (current: 0, longest: 1),
      );

      // Ongoing streak through yesterday (today not logged) with longer run
      final withGaps = <DateTime, int>{
        DateTime(2026, 10, 20): 10,
        DateTime(2026, 10, 21): 20,
        DateTime(2026, 10, 22): 15,
        DateTime(2026, 10, 23): 5,
        DateTime(2026, 10, 24): 0, // zero units ignored
        DateTime(2026, 11, 8): 12,
        DateTime(2026, 11, 9): 8,
      };
      expect(
        StudyAnalyticsCalculator.calculateStreaks(withGaps, today: today),
        (current: 2, longest: 4),
      );

      // Broken streak when both yesterday and today have 0
      final broken = <DateTime, int>{
        DateTime(2026, 11, 6): 10,
        DateTime(2026, 11, 7): 15,
        DateTime(2026, 11, 8): 20,
      };
      expect(
        StudyAnalyticsCalculator.calculateStreaks(broken, today: today),
        (current: 0, longest: 3),
      );
    });

    test('computes weekly totals, consistency, rolling avgs, best & weakest',
        () {
      // Nov 1 (Sun) through Nov 10 (Tue) = 10 days across 3 ISO Mon-Sun weeks:
      // W1: Nov 1 (Sun)
      // W2: Nov 2 (Mon) .. Nov 8 (Sun)
      // W3: Nov 9 (Mon) .. Nov 10 (Tue)
      final start = DateTime(2026, 11);
      final end = DateTime(2026, 11, 10);
      final logs = [
        ProgressLog(
          materialId: 'm1',
          unitsDone: 15,
          loggedOn: DateTime(2026, 11),
        ),
        ProgressLog(
          materialId: 'm1',
          unitsDone: 20,
          loggedOn: DateTime(2026, 11, 3),
        ),
        ProgressLog(
          materialId: 'm1',
          unitsDone: 10,
          loggedOn: DateTime(2026, 11, 3),
        ),
        ProgressLog(
          materialId: 'm1',
          unitsDone: 5,
          loggedOn: DateTime(2026, 11, 6),
        ),
        ProgressLog(
          materialId: 'm1',
          unitsDone: 40,
          loggedOn: DateTime(2026, 11, 9),
        ),
        ProgressLog(
          materialId: 'm1',
          unitsDone: 20,
          loggedOn: DateTime(2026, 11, 10),
        ),
      ];

      final daily = StudyAnalyticsCalculator.calculateDailyUnits(
        logs,
        startDate: start,
        endDate: end,
      );
      expect(daily.length, 10);
      expect(daily[2].units, 30); // Nov 3 summed (20 + 10)
      expect(daily[3].units, 0); // Nov 4 gap

      final weekly = StudyAnalyticsCalculator.calculateWeeklyTotals(daily);
      expect(weekly.length, 3);
      expect(weekly[0].units, 15);
      expect(weekly[0].activeDays, 1);
      expect(weekly[1].units, 35);
      expect(weekly[1].activeDays, 2);
      expect(weekly[2].units, 60);
      expect(weekly[2].activeDays, 2);

      // 5 active days out of 10
      expect(
        StudyAnalyticsCalculator.calculateConsistencyScore(daily),
        closeTo(0.5, 0.0001),
      );

      final grouped = StudyAnalyticsCalculator.groupUnitsByLocalDay(logs);
      // Last 7 days: Nov 4..Nov 10 -> 0 + 0 + 5 + 0 + 0 + 40 + 20 = 65 -> 65/7
      expect(
        StudyAnalyticsCalculator.calculateRollingAverage(
          grouped,
          today: end,
          days: 7,
        ),
        closeTo(65 / 7, 0.0001),
      );
      // Last 30 days: total 110 / 30
      expect(
        StudyAnalyticsCalculator.calculateRollingAverage(
          grouped,
          today: end,
          days: 30,
        ),
        closeTo(110 / 30, 0.0001),
      );

      final extrema = StudyAnalyticsCalculator.findBestAndWeakestDay(daily);
      expect(
        extrema.best,
        DailyStudyTotal(date: DateTime(2026, 11, 9), units: 40),
      );
      // Most recent minimum (0 on Nov 8)
      expect(
        extrema.weakest,
        DailyStudyTotal(date: DateTime(2026, 11, 8), units: 0),
      );
    });

    test(
        'integrates study plan target alert, subject filter, breakdown, and '
        'mock test averages', () {
      final today = DateTime(2026, 11, 10);
      final logs = [
        ProgressLog(
          materialId: matMath.id,
          unitsDone: 30,
          loggedOn: DateTime(2026, 11, 8),
        ),
        ProgressLog(
          materialId: matMath.id,
          unitsDone: 5,
          loggedOn: DateTime(2026, 11, 9), // yesterday < 20
        ),
        ProgressLog(
          materialId: matEng.id,
          unitsDone: 15,
          loggedOn: DateTime(2026, 11, 10), // today < 20 for Math only
        ),
      ];
      final mathSnapshot = StudyPlanCalculator.buildSnapshot(
        plan: StudyPlan(
          id: 'plan-math',
          userId: 'u-1',
          subjectId: subMath.id,
          startDate: DateTime.utc(2026, 11),
          targetDate: DateTime.utc(2026, 11, 26),
        ),
        today: today,
        subject: subMath,
        materials: const [matMath],
        recentLogs: logs,
      );
      final mocks = [
        MockTest(
          id: 'mt-1',
          subjectId: subMath.id,
          title: 'Math Test 1',
          takenOn: DateTime(2026, 11, 9),
          marksObtained: 40,
          totalMarks: 50, // 80%
        ),
        MockTest(
          id: 'mt-2',
          subjectId: subEng.id,
          title: 'Eng Test 1',
          takenOn: DateTime(2026, 11, 10),
          marksObtained: 90,
          totalMarks: 100, // 90%
        ),
      ];

      final allScope = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        subjects: const [subMath, subEng],
        materials: const [matMath, matEng],
        logs: logs,
        planSnapshots: [mathSnapshot],
        mockTests: mocks,
        now: today,
      );
      expect(allScope.dailyTarget, mathSnapshot.todayTarget);
      expect(allScope.totalUnitsInRange, 50);
      expect(allScope.mockTestCountInRange, 2);
      expect(allScope.averageMockScoreInRange, closeTo(85.0, 0.0001));
      expect(allScope.subjectBreakdown.length, 2);
      expect(allScope.subjectBreakdown.first.subjectId, subMath.id);
      expect(allScope.subjectBreakdown.first.share, closeTo(35 / 50, 0.0001));

      // Filtering to Math checks Math's units (yesterday=5, today=0).
      final mathOnly = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        subjects: const [subMath, subEng],
        materials: const [matMath, matEng],
        logs: logs,
        planSnapshots: [mathSnapshot],
        mockTests: mocks,
        now: today,
        subjectId: subMath.id,
      );
      expect(mathOnly.totalUnitsInRange, 35);
      expect(mathOnly.todayUnits, 0);
      expect(mathOnly.yesterdayUnits, 5);
      expect(mathOnly.targetAlertStatus, StudyDayTargetStatus.bothBelowTarget);
      expect(mathOnly.mockTestCountInRange, 1);
      expect(mathOnly.averageMockScoreInRange, closeTo(80.0, 0.0001));
      expect(
        mathOnly.heatmapDays.length,
        StudyAnalyticsCalculator.heatmapDaysCount,
      );
    });
  });

  group('Phase 6H study session hours, >=10m streak & consistency', () {
    test(
        'counts days with >= 10 min session as studied for streaks & '
        'consistency while ignoring sessions under 10 min', () {
      const dhaka = Duration(hours: 6);
      final now = DateTime.utc(2026, 11, 10, 12); // Nov 10 18:00 Dhaka
      final sessions = [
        // Nov 8: exactly 10 minutes (600s) -> qualifies even with 0 units!
        StudySession(
          id: 's-10m',
          userId: 'u-1',
          subjectId: subMath.id,
          startedAt: DateTime.utc(2026, 11, 8, 4),
          endedAt: DateTime.utc(2026, 11, 8, 4, 10),
          durationSeconds: 600,
        ),
        // Nov 9: 9m59s (599s) -> must NOT qualify for streak/consistency!
        StudySession(
          id: 's-short',
          userId: 'u-1',
          subjectId: subEng.id,
          startedAt: DateTime.utc(2026, 11, 9, 4),
          endedAt: DateTime.utc(2026, 11, 9, 4, 9, 59),
          durationSeconds: 599,
          mode: StudySessionMode.stopwatch,
        ),
        // Nov 10: 60 minutes (3600s) on English -> qualifies!
        StudySession(
          id: 's-60m',
          userId: 'u-1',
          subjectId: subEng.id,
          startedAt: DateTime.utc(2026, 11, 10, 4),
          endedAt: DateTime.utc(2026, 11, 10, 5),
          durationSeconds: 3600,
          mode: StudySessionMode.manual,
        ),
      ];

      final summary = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        subjects: const [subMath, subEng],
        materials: const [matMath, matEng],
        logs: const [],
        planSnapshots: const [],
        mockTests: const [],
        sessions: sessions,
        now: now,
        localOffset: dhaka,
      );

      expect(summary.hasAnyLogs, isFalse);
      expect(summary.hasAnySessions, isTrue);
      expect(summary.hasAnyActivity, isTrue);
      // Nov 8 & Nov 10 qualified (Nov 9 was <10m), so 2 active days out of 7.
      expect(summary.activeDaysInRange, 2);
      expect(summary.consistencyScore, closeTo(2 / 7, 0.0001));
      expect(summary.currentStreak, 1);
      expect(summary.longestStreak, 1);
      expect(summary.totalSessionSecondsInRange, 4799);
      expect(summary.totalHoursInRange, closeTo(4799 / 3600, 0.0001));

      final mathRow =
          summary.subjectBreakdown.firstWhere((e) => e.subjectId == subMath.id);
      final engRow =
          summary.subjectBreakdown.firstWhere((e) => e.subjectId == subEng.id);
      expect(mathRow.sessionSeconds, 600);
      expect(engRow.sessionSeconds, 4199);
      expect(engRow.timeShare, closeTo(4199 / 4799, 0.0001));

      // Adding a study log on Nov 9 connects Nov 8-9-10 into a 3-day streak!
      final bridged = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        subjects: const [subMath, subEng],
        materials: const [matMath, matEng],
        logs: [
          ProgressLog(
            materialId: matMath.id,
            unitsDone: 5,
            loggedOn: DateTime.utc(2026, 11, 9, 10),
          ),
        ],
        planSnapshots: const [],
        mockTests: const [],
        sessions: sessions,
        now: now,
        localOffset: dhaka,
      );
      expect(bridged.activeDaysInRange, 3);
      expect(bridged.currentStreak, 3);
      expect(bridged.longestStreak, 3);
    });

    test('splits midnight-crossing sessions into separate daily hours buckets',
        () {
      // Dhaka (UTC+6): 2026-11-09 23:30 .. 2026-11-10 00:30 local
      // -> 30m (1800s) on Nov 9 + 30m (1800s) on Nov 10 -> 2-day streak!
      const dhaka = Duration(hours: 6);
      final midnightSession = StudySession(
        id: 's-mid',
        userId: 'u-1',
        subjectId: subMath.id,
        startedAt: DateTime.utc(2026, 11, 9, 17, 30),
        endedAt: DateTime.utc(2026, 11, 9, 18, 30),
        durationSeconds: 3600,
      );

      final summary = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        subjects: const [subMath],
        materials: const [matMath],
        logs: const [],
        planSnapshots: const [],
        mockTests: const [],
        sessions: [midnightSession],
        now: DateTime.utc(2026, 11, 10, 10),
        localOffset: dhaka,
      );

      final nov9 = summary.dailyTotals.firstWhere(
        (d) => d.date == DateTime(2026, 11, 9),
      );
      final nov10 = summary.dailyTotals.firstWhere(
        (d) => d.date == DateTime(2026, 11, 10),
      );
      expect(nov9.sessionSeconds, 1800);
      expect(nov9.hours, closeTo(0.5, 0.0001));
      expect(nov9.hasQualifyingSession, isTrue);
      expect(nov10.sessionSeconds, 1800);
      expect(nov10.hasQualifyingSession, isTrue);
      expect(summary.currentStreak, 2);
      expect(summary.longestStreak, 2);
    });
  });
}
