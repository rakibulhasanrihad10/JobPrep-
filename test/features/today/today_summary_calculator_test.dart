import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/today/domain/entities/today_summary.dart';
import 'package:job_prep/features/today/domain/utils/today_summary_calculator.dart';
import 'package:job_prep/features/today/domain/utils/today_window_selectors.dart';

void main() {
  final fixedNow = DateTime(2026, 11, 12, 10, 30);

  const subMath = Subject(id: 'sub-math', userId: 'u-1', name: 'Math');
  const subBangla = Subject(id: 'sub-bn', userId: 'u-1', name: 'Bangla');

  const matMath = PrepMaterial(
    id: 'mat-math',
    userId: 'u-1',
    subjectId: 'sub-math',
    title: 'Algebra Guide',
    totalUnits: 300,
    completedUnits: 100,
  );
  const matBangla = PrepMaterial(
    id: 'mat-bn',
    userId: 'u-1',
    subjectId: 'sub-bn',
    title: 'Bangla Grammar',
    totalUnits: 200,
    completedUnits: 140,
  );

  // Target Nov 29 with 7d buffer => finish Nov 22 => 10 study days left.
  final planMath = StudyPlan(
    id: 'plan-math',
    userId: 'u-1',
    subjectId: 'sub-math',
    startDate: DateTime.utc(2026, 11, 10),
    targetDate: DateTime.utc(2026, 11, 29),
  ); // 200 rem / 10 days => 20/day

  final planBangla = StudyPlan(
    id: 'plan-bn',
    userId: 'u-1',
    subjectId: 'sub-bn',
    startDate: DateTime.utc(2026, 11, 10),
    targetDate: DateTime.utc(2026, 11, 29),
  ); // 60 rem / 10 days => 6/day

  group('TodaySummaryCalculator - Do This Next fixed priority', () {
    test('priority 1 picks circular deadline <= 2d over revision & study', () {
      final summary = TodaySummaryCalculator.buildSummary(
        now: fixedNow,
        subjects: const [subMath, subBangla],
        materials: const [matMath, matBangla],
        recentLogs: const [],
        plans: [planMath, planBangla],
        circulars: [
          Circular(
            id: 'c-5d',
            userId: 'u-1',
            title: 'Bank 5d',
            sector: CircularSector.bank,
            deadline: DateTime(2026, 11, 17, 17),
          ),
          Circular(
            id: 'c-1d',
            userId: 'u-1',
            title: 'BCS Tomorrow',
            sector: CircularSector.bcs,
            deadline: DateTime(2026, 11, 13, 17),
          ),
          Circular(
            id: 'c-archived',
            userId: 'u-1',
            title: 'Archived Today',
            sector: CircularSector.bcs,
            workflowStatus: CircularWorkflowStatus.archived,
            deadline: DateTime(2026, 11, 12, 18),
          ),
        ],
        revisionItems: [
          RevisionItem(
            id: 'rev-old',
            subjectId: 'sub-bn',
            referenceLabel: 'p. 42',
            dueOn: DateTime.utc(2026, 11, 10),
          ),
        ],
        sessions: const [],
      );

      expect(
        summary.doThisNext?.kind,
        TodayDoThisNextKind.circularDeadline,
      );
      expect(summary.doThisNext?.circular?.id, 'c-1d');
      expect(summary.doThisNext?.daysUntilDeadline, 1);
    });

    test('priority 2 picks overdue revision over study target when no <= 2d',
        () {
      final summary = TodaySummaryCalculator.buildSummary(
        now: fixedNow,
        subjects: const [subMath, subBangla],
        materials: const [matMath, matBangla],
        recentLogs: const [],
        plans: [planMath, planBangla],
        circulars: [
          Circular(
            id: 'c-3d',
            userId: 'u-1',
            title: 'Three Days Out',
            sector: CircularSector.bank,
            deadline: DateTime(2026, 11, 15, 17),
          ),
        ],
        revisionItems: [
          RevisionItem(
            id: 'rev-today',
            subjectId: 'sub-math',
            referenceLabel: 'Today item',
            dueOn: DateTime.utc(2026, 11, 12),
          ),
          RevisionItem(
            id: 'rev-older',
            subjectId: 'sub-bn',
            referenceLabel: 'Ch. 3 Verb',
            dueOn: DateTime.utc(2026, 11, 9),
          ),
          RevisionItem(
            id: 'rev-yesterday',
            subjectId: 'sub-math',
            referenceLabel: 'Ratio p. 19',
            dueOn: DateTime.utc(2026, 11, 11),
          ),
        ],
        sessions: const [],
      );

      expect(
        summary.doThisNext?.kind,
        TodayDoThisNextKind.overdueRevision,
      );
      expect(summary.doThisNext?.overdueRevisionCount, 2);
      expect(summary.doThisNext?.topOverdueRevision?.id, 'rev-older');
      expect(summary.doThisNext?.overdueRevisionSubject?.id, 'sub-bn');
    });

    test(
        'priority 3 picks biggest remaining study target when no <=2d deadline '
        'or overdue revision exists, then null when caught up', () {
      // Log 20/20 on Math so only Bangla (0/6 => 6 rem) remains!
      final withMathDone = TodaySummaryCalculator.buildSummary(
        now: fixedNow,
        subjects: const [subMath, subBangla],
        materials: [
          matMath.copyWith(completedUnits: 120),
          matBangla,
        ],
        recentLogs: [
          ProgressLog(
            id: 'l-math-done',
            materialId: 'mat-math',
            unitsDone: 20,
            loggedOn: DateTime.utc(2026, 11, 12),
          ),
        ],
        plans: [planMath, planBangla],
        circulars: const [],
        revisionItems: [
          RevisionItem(
            id: 'rev-due-today',
            subjectId: 'sub-bn',
            referenceLabel: 'Due today only',
            dueOn: DateTime.utc(2026, 11, 12),
          ),
        ],
        sessions: const [],
      );

      expect(withMathDone.doThisNext?.kind, TodayDoThisNextKind.studyTarget);
      expect(withMathDone.doThisNext?.studyTargetRow?.subject?.id, 'sub-bn');
      expect(withMathDone.doThisNext?.studyTargetRow?.remainingTodayUnits, 6);

      // Without logs, Math (20 remaining) beats Bangla (6 remaining).
      final withBothPending = TodaySummaryCalculator.buildSummary(
        now: fixedNow,
        subjects: const [subMath, subBangla],
        materials: const [matMath, matBangla],
        recentLogs: const [],
        plans: [planMath, planBangla],
        circulars: const [],
        revisionItems: const [],
        sessions: const [],
      );
      expect(withBothPending.doThisNext?.kind, TodayDoThisNextKind.studyTarget);
      expect(
        withBothPending.doThisNext?.studyTargetRow?.subject?.id,
        'sub-math',
      );
      expect(
        withBothPending.doThisNext?.studyTargetRow?.remainingTodayUnits,
        20,
      );

      // Log 20 Math + 6 Bangla => all targets complete => null (All caught up).
      final allCaughtUp = TodaySummaryCalculator.buildSummary(
        now: fixedNow,
        subjects: const [subMath, subBangla],
        materials: [
          matMath.copyWith(completedUnits: 120),
          matBangla.copyWith(completedUnits: 146),
        ],
        recentLogs: [
          ProgressLog(
            id: 'l-1',
            materialId: 'mat-math',
            unitsDone: 20,
            loggedOn: DateTime.utc(2026, 11, 12),
          ),
          ProgressLog(
            id: 'l-2',
            materialId: 'mat-bn',
            unitsDone: 6,
            loggedOn: DateTime.utc(2026, 11, 12),
          ),
        ],
        plans: [planMath, planBangla],
        circulars: const [],
        revisionItems: const [],
        sessions: const [],
      );
      expect(allCaughtUp.doThisNext, isNull);
      expect(allCaughtUp.dailyProgress, closeTo(1.0, 1e-6));
    });
  });

  group('TodaySummaryCalculator - Ordering, Windows, Catch-Up & Sessions', () {
    test('orders 7-day deadlines, 14-day exams, study targets & revisions', () {
      final summary = TodaySummaryCalculator.buildSummary(
        now: fixedNow,
        localOffset: const Duration(hours: 6),
        subjects: const [subMath, subBangla],
        materials: [
          matMath,
          matBangla.copyWith(completedUnits: 143),
        ],
        recentLogs: [
          ProgressLog(
            id: 'l-bn',
            materialId: 'mat-bn',
            unitsDone: 3,
            loggedOn: DateTime.utc(2026, 11, 12),
          ),
        ],
        plans: [
          planBangla,
          planMath.copyWith(initialCompletedUnits: 100),
          StudyPlan(
            id: 'plan-all',
            userId: 'u-1',
            startDate: DateTime.utc(2026, 11, 10),
            targetDate: DateTime.utc(2026, 11, 29),
          ),
        ],
        circulars: [
          Circular(
            id: 'c-inbox',
            userId: 'u-1',
            title: 'Inbox Link',
            workflowStatus: CircularWorkflowStatus.inbox,
            deadline: DateTime(2026, 11, 19, 12),
          ),
          Circular(
            id: 'c-7d',
            userId: 'u-1',
            title: 'Seven Days',
            deadline: DateTime(2026, 11, 19, 17),
            examDates: [
              CircularExamDate(
                id: 'ex-14d',
                circularId: 'c-7d',
                stage: 'written',
                examDate: DateTime(2026, 11, 26, 9),
              ),
              CircularExamDate(
                id: 'ex-15d-excluded',
                circularId: 'c-7d',
                stage: 'viva',
                examDate: DateTime(2026, 11, 27, 9),
              ),
            ],
          ),
          Circular(
            id: 'c-today',
            userId: 'u-1',
            title: 'Due Today',
            deadline: DateTime(2026, 11, 12, 23),
            examDates: [
              CircularExamDate(
                id: 'ex-3d',
                circularId: 'c-today',
                stage: 'preliminary',
                examDate: DateTime(2026, 11, 15, 10),
              ),
            ],
          ),
          Circular(
            id: 'c-8d-excluded',
            userId: 'u-1',
            title: 'Eight Days',
            deadline: DateTime(2026, 11, 20, 17),
          ),
        ],
        revisionItems: [
          RevisionItem(
            id: 'rev-1',
            subjectId: 'sub-math',
            referenceLabel: 'p. 10',
            dueOn: DateTime.utc(2026, 11, 12),
          ),
          RevisionItem(
            id: 'rev-2',
            subjectId: 'sub-bn',
            referenceLabel: 'p. 55',
            dueOn: DateTime.utc(2026, 11, 10),
          ),
          RevisionItem(
            id: 'rev-done',
            subjectId: 'sub-math',
            referenceLabel: 'Mastered',
            status: RevisionStatus.mastered,
            dueOn: DateTime.utc(2026, 11, 9),
          ),
        ],
        sessions: [
          // Crosses UTC+6 midnight Nov 11 -> Nov 12: 30m falls on Nov 12.
          StudySession(
            id: 'sess-midnight',
            userId: 'u-1',
            subjectId: 'sub-math',
            startedAt: DateTime.utc(2026, 11, 11, 17, 30), // 23:30 +06
            endedAt: DateTime.utc(2026, 11, 11, 18, 30), // 00:30 +06 on Nov 12
            durationSeconds: 3600,
          ),
          StudySession(
            id: 'sess-today',
            userId: 'u-1',
            subjectId: 'sub-bn',
            startedAt: DateTime.utc(2026, 11, 12, 3), // 09:00 +06
            endedAt: DateTime.utc(2026, 11, 12, 3, 45), // 09:45 +06
            durationSeconds: 2700,
          ),
        ],
      );

      // Daily ring uses per-subject basis without double counting plan-all.
      expect(summary.dailyDoneUnits, 3);
      expect(summary.dailyTargetUnits, 26); // Math 20 + Bangla 6
      expect(summary.dailyProgress, closeTo(3 / 26, 1e-6));

      // Targets ordered largest remaining first (all: 23, math: 20, bn: 3).
      expect(
        summary.studyTargets.map((r) => r.slug).toList(),
        ['all', 'sub-math', 'sub-bn'],
      );

      // Behind plans emit catch-up notices cleanly (Nov 10..12 missed days).
      expect(summary.catchUpNotices, isNotEmpty);

      // Revision: overdue first (rev-2), then due today (rev-1).
      expect(summary.revision.overdueCount, 1);
      expect(summary.revision.dueTodayCount, 1);
      expect(summary.revision.totalDueCount, 2);
      expect(
        summary.revision.previewItems.map((e) => e.item.id).toList(),
        ['rev-2', 'rev-1'],
      );

      // 7-day deadlines sorted chronologically, 8d excluded.
      expect(
        summary.deadlinesNext7Days.map((e) => e.circular.id).toList(),
        ['c-today', 'c-inbox', 'c-7d'],
      );
      expect(summary.inboxCount, 1);

      // 14-day exams sorted chronologically, 15d excluded.
      expect(
        summary.examsNext14Days.map((e) => e.examDate.id).toList(),
        ['ex-3d', 'ex-14d'],
      );

      // Time studied combines Nov 12 midnight slice (1800s) + morning (2700s).
      expect(summary.studiedSecondsToday, 4500);
      expect(summary.sessionsTodayCount, 2);
      expect(summary.hasActiveSessionToday, isFalse);

      // Greeting periods at morning, afternoon, evening.
      expect(
        TodaySummaryCalculator.greetingPeriodFor(DateTime(2026, 11, 12, 9)),
        TodayGreetingPeriod.morning,
      );
      expect(
        TodaySummaryCalculator.greetingPeriodFor(DateTime(2026, 11, 12, 14)),
        TodayGreetingPeriod.afternoon,
      );
      expect(
        TodaySummaryCalculator.greetingPeriodFor(DateTime(2026, 11, 12, 19)),
        TodayGreetingPeriod.evening,
      );
    });

    test('computeTimeStudiedToday handles active session & empty state', () {
      final empty = TodayWindowSelectors.computeTimeStudiedToday(
        sessions: const [],
        now: fixedNow,
      );
      expect(empty.totalSeconds, 0);
      expect(empty.sessionCount, 0);
      expect(empty.hasOpenToday, isFalse);

      final live = TodayWindowSelectors.computeTimeStudiedToday(
        sessions: [
          StudySession(
            id: 'open-1',
            userId: 'u-1',
            subjectId: 'sub-math',
            startedAt: DateTime(2026, 11, 12, 9, 30).toUtc(),
          ),
        ],
        now: fixedNow.toUtc(),
        localOffset: Duration.zero,
      );
      expect(live.sessionCount, 1);
      expect(live.hasOpenToday, isTrue);
      expect(live.totalSeconds, greaterThan(0));
    });
  });
}
