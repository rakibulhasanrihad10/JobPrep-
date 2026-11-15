import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/dashboard/domain/utils/dashboard_metrics.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

void main() {
  group('DashboardMetricsCalculator Unit Tests', () {
    final now = DateTime.utc(2026, 11, 15, 12);

    test('builds empty summary cleanly', () {
      final summary = DashboardMetricsCalculator.buildSummary(
        circulars: [],
        subjects: [],
        materials: [],
        recentLogs: [],
        now: now,
      );

      expect(summary.upcomingDeadlinesThisWeekCount, equals(0));
      expect(summary.inboxCount, equals(0));
      expect(summary.overallPrepProgress, equals(0.0));
      expect(summary.upcomingDeadlines, isEmpty);
      expect(summary.upcomingExams, isEmpty);
    });

    test('calculates counts, active materials, and progress math accurately',
        () {
      final circulars = [
        Circular(
          id: 'c-1',
          title: '38th BCS',
          deadline: now.add(const Duration(days: 4)),
        ),
        const Circular(
          id: 'c-2',
          title: 'Inbox Circular',
          workflowStatus: CircularWorkflowStatus.inbox,
        ),
        const Circular(
          id: 'c-3',
          title: 'Archived Circular',
          workflowStatus: CircularWorkflowStatus.archived,
        ),
      ];

      final subjects = [
        const Subject(id: 's-1', name: 'General Science'),
      ];

      final materials = [
        const PrepMaterial(
          id: 'm-1',
          subjectId: 's-1',
          title: 'Physics',
          totalUnits: 300,
          completedUnits: 300,
        ),
        const PrepMaterial(
          id: 'm-2',
          subjectId: 's-1',
          title: 'Chemistry',
          totalUnits: 300,
        ),
        const PrepMaterial(
          id: 'm-3',
          subjectId: 's-1',
          title: 'Biology',
          totalUnits: 400,
        ),
      ];

      final recentLogs = [
        ProgressLog(
          id: 'l-1',
          materialId: 'm-1',
          unitsDone: 50,
          loggedOn: now,
        ),
      ];

      final summary = DashboardMetricsCalculator.buildSummary(
        circulars: circulars,
        subjects: subjects,
        materials: materials,
        recentLogs: recentLogs,
        now: now,
      );

      expect(summary.inboxCount, equals(1));
      expect(summary.upcomingDeadlinesThisWeekCount, equals(1));
      // 300 out of 1000 = 30%
      expect(summary.overallPrepProgress, closeTo(0.30, 0.001));
      expect(summary.upcomingDeadlines, hasLength(1));
    });

    test('StudyAnalyticsSummary properties and equality check', () {
      final start = DateTime.utc(2026);
      final end = DateTime.utc(2026, 1, 31);
      final analytics = StudyAnalyticsSummary(
        range: StudyAnalyticsRange.days30,
        startDate: start,
        endDate: end,
        dailyTotals: const [],
        weeklyTotals: const [],
        heatmapDays: const [],
        subjectBreakdown: const [],
        totalUnitsInRange: 150,
        unitsThisWeek: 50,
        activeDaysInRange: 10,
        currentStreak: 3,
        longestStreak: 5,
        averageLast7Days: 7.1,
        averageLast30Days: 5,
        consistencyScore: 80,
        todayUnits: 15,
        yesterdayUnits: 10,
        targetAlertStatus: StudyDayTargetStatus.onTrackOrNoTarget,
        mockTestCountInRange: 2,
        hasAnyLogs: true,
      );

      expect(analytics.range, equals(StudyAnalyticsRange.days30));
      expect(analytics.totalUnitsInRange, equals(150));
      expect(analytics.consistencyScore, equals(80));
    });
  });
}
