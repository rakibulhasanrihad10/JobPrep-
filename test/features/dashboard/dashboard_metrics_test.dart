import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/dashboard/domain/utils/dashboard_metrics.dart';
import 'package:job_prep/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';

import '../circulars/fake_circular_repository.dart';
import '../prep/fake_material_and_log_repositories.dart';
import '../prep/fake_subject_and_topic_repositories.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 9);

  Circular makeCircular({
    required String id,
    required String title,
    DateTime? deadline,
    CircularWorkflowStatus workflowStatus = CircularWorkflowStatus.saved,
    ApplicationStatus applicationStatus = ApplicationStatus.notApplied,
    ApplicationChecklist checklist = const ApplicationChecklist(),
    CircularPriority priority = CircularPriority.medium,
    List<CircularExamDate> examDates = const [],
  }) {
    return Circular(
      id: id,
      userId: 'u-1',
      title: title,
      deadline: deadline,
      workflowStatus: workflowStatus,
      applicationStatus: applicationStatus,
      checklist: checklist,
      priority: priority,
      examDates: examDates,
    );
  }

  group('DashboardMetricsCalculator unit tests', () {
    test('returns brand-new-user summary when all sources are empty', () {
      final summary = DashboardMetricsCalculator.buildSummary(
        circulars: const [],
        subjects: const [],
        materials: const [],
        recentLogs: const [],
        now: fixedNow,
      );

      expect(summary.isBrandNewUser, isTrue);
      expect(summary.upcomingDeadlinesThisWeekCount, 0);
      expect(summary.inboxCount, 0);
      expect(summary.upcomingExamsNext14DaysCount, 0);
      expect(summary.applicationsSubmittedCount, 0);
      expect(summary.overallPrepProgress, 0.0);
      expect(summary.upcomingDeadlines, isEmpty);
      expect(summary.upcomingExams, isEmpty);
      expect(summary.continueStudying, isNull);
    });

    test(
      'counts deadlines within 0..7 days, inbox items, exams in 0..14 days, '
      'and submitted applications accurately',
      () {
        final circulars = [
          // Today (day 0): counts in deadlinesThisWeek & upcomingDeadlines
          makeCircular(
            id: 'c-due-today',
            title: '48th BCS Special',
            deadline: DateTime.utc(2026, 11, 10, 23, 59),
            priority: CircularPriority.high,
          ),
          // Day 5 + inbox + submitted via checklist + written exam in 14d
          makeCircular(
            id: 'c-inbox-5d',
            title: 'Senior Officer (Combined Bank)',
            deadline: DateTime.utc(2026, 11, 15, 17),
            workflowStatus: CircularWorkflowStatus.inbox,
            checklist: const ApplicationChecklist(submitted: true),
            examDates: [
              CircularExamDate(
                id: 'e-14d',
                circularId: 'c-inbox-5d',
                stage: 'written',
                examDate: DateTime.utc(2026, 11, 24, 10),
              ),
            ],
          ),
          // Day 7 boundary + exam today + applicationStatus applied
          makeCircular(
            id: 'c-7d',
            title: 'Assistant Programmer BPSC',
            deadline: DateTime.utc(2026, 11, 17, 17),
            applicationStatus: ApplicationStatus.applied,
            examDates: [
              CircularExamDate(
                id: 'e-today',
                circularId: 'c-7d',
                stage: 'preliminary',
                examDate: DateTime.utc(2026, 11, 10, 15),
              ),
            ],
          ),
          // Day 8: included in upcomingDeadlines list, excluded from 7d KPI
          makeCircular(
            id: 'c-8d',
            title: 'Bangladesh Bank Officer',
            deadline: DateTime.utc(2026, 11, 18, 17),
            workflowStatus: CircularWorkflowStatus.examUpcoming,
            examDates: [
              CircularExamDate(
                id: 'e-15d',
                circularId: 'c-8d',
                stage: 'viva',
                examDate: DateTime.utc(2026, 11, 25, 10),
              ),
              CircularExamDate(
                id: 'e-past',
                circularId: 'c-8d',
                stage: 'preliminary',
                examDate: DateTime.utc(2026, 11, 9, 10),
              ),
            ],
          ),
          // Overdue deadline (-1d): excluded from upcoming lists & week count
          makeCircular(
            id: 'c-overdue',
            title: 'Closed Recruitment',
            deadline: DateTime.utc(2026, 11, 9, 17),
            applicationStatus: ApplicationStatus.feePaid,
          ),
          // Archived circular: excluded from upcoming deadlines & exams,
          // even though deadline/exam fall inside the windows.
          makeCircular(
            id: 'c-archived',
            title: 'Archived Circular',
            deadline: DateTime.utc(2026, 11, 12, 17),
            workflowStatus: CircularWorkflowStatus.archived,
            examDates: [
              CircularExamDate(
                id: 'e-arch',
                circularId: 'c-archived',
                stage: 'written',
                examDate: DateTime.utc(2026, 11, 12, 10),
              ),
            ],
          ),
        ];

        final summary = DashboardMetricsCalculator.buildSummary(
          circulars: circulars,
          subjects: const [],
          materials: const [],
          recentLogs: const [],
          now: fixedNow,
        );

        expect(summary.isBrandNewUser, isFalse);
        expect(summary.upcomingDeadlinesThisWeekCount, 3);
        expect(summary.inboxCount, 1);
        // e-today (day 0) + e-14d (day 14). e-15d (day 15), e-past, e-arch out.
        expect(summary.upcomingExamsNext14DaysCount, 2);
        // c-inbox-5d (checklist), c-7d (applied), c-8d (examUpcoming),
        // c-overdue (feePaid)
        expect(summary.applicationsSubmittedCount, 4);

        expect(
          summary.upcomingDeadlines.map((c) => c.id),
          equals(['c-due-today', 'c-inbox-5d', 'c-7d', 'c-8d']),
        );

        expect(
          summary.upcomingExams.map((e) => e.examDate.id),
          equals(['e-today', 'e-14d', 'e-15d']),
        );
        expect(summary.upcomingExams.first.daysUntil, 0);
        expect(summary.upcomingExams.first.stage, ExamStage.preliminary);
        expect(summary.upcomingExams[1].daysUntil, 14);
        expect(summary.upcomingExams[1].stage, ExamStage.written);
        expect(summary.upcomingExams[2].daysUntil, 15);
      },
    );

    test(
      'computes AGENTS.md weighted 300/300/400 prep progress and '
      'respects maxDeadlines / maxExams caps',
      () {
        const subject = Subject(
          id: 'sub-bn',
          userId: 'u-1',
          name: 'Bengali',
        );
        const materials = [
          PrepMaterial(
            id: 'm1',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'Book 1',
            totalUnits: 300,
            completedUnits: 300,
          ),
          PrepMaterial(
            id: 'm2',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'Book 2',
            totalUnits: 300,
          ),
          PrepMaterial(
            id: 'm3',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'Book 3',
            totalUnits: 400,
          ),
        ];

        final manyCirculars = List<Circular>.generate(
          8,
          (i) => makeCircular(
            id: 'c-$i',
            title: 'Job $i',
            deadline: DateTime.utc(2026, 11, 10 + i, 18),
            examDates: [
              CircularExamDate(
                id: 'ex-$i',
                circularId: 'c-$i',
                stage: 'preliminary',
                examDate: DateTime.utc(2026, 11, 10 + i, 10),
              ),
            ],
          ),
        );

        final summary = DashboardMetricsCalculator.buildSummary(
          circulars: manyCirculars,
          subjects: const [subject],
          materials: materials,
          recentLogs: const [],
          now: fixedNow,
          maxDeadlines: 3,
          maxExams: 2,
        );

        expect(summary.overallPrepProgress, closeTo(0.30, 1e-9));
        expect(summary.upcomingDeadlines, hasLength(3));
        expect(summary.upcomingExams, hasLength(2));
        expect(summary.upcomingDeadlinesThisWeekCount, 8);
      },
    );

    test(
      'resolveContinueStudyingTarget picks most recent log with positive units '
      'and skips deleted materials or subjects',
      () {
        const subjects = [
          Subject(id: 's1', userId: 'u-1', name: 'Bengali'),
        ];
        const materials = [
          PrepMaterial(
            id: 'm1',
            userId: 'u-1',
            subjectId: 's1',
            title: 'MP3 বাংলা',
            totalUnits: 200,
            completedUnits: 100,
          ),
          PrepMaterial(
            id: 'm2',
            userId: 'u-1',
            subjectId: 's1',
            title: 'অগ্রদূত বাংলা',
            totalUnits: 400,
            completedUnits: 120,
          ),
        ];
        final logs = [
          ProgressLog(
            id: 'log-orphan',
            materialId: 'm-deleted',
            unitsDone: 50,
            loggedOn: DateTime.utc(2026, 11, 10),
          ),
          ProgressLog(
            id: 'log-older',
            materialId: 'm1',
            unitsDone: 25,
            loggedOn: DateTime.utc(2026, 11, 8),
          ),
          ProgressLog(
            id: 'log-same-day-earlier',
            materialId: 'm1',
            unitsDone: 20,
            loggedOn: DateTime.utc(2026, 11, 9),
            createdAt: DateTime.utc(2026, 11, 9, 10),
          ),
          ProgressLog(
            id: 'log-latest',
            materialId: 'm2',
            unitsDone: 40,
            loggedOn: DateTime.utc(2026, 11, 9),
            updatedAt: DateTime.utc(2026, 11, 9, 18),
          ),
        ];

        final target = DashboardMetricsCalculator.resolveContinueStudyingTarget(
          recentLogs: logs,
          materials: materials,
          subjects: subjects,
        );

        expect(target, isNotNull);
        expect(target!.material.id, 'm2');
        expect(target.subject.id, 's1');
        expect(target.latestLog.id, 'log-latest');
        expect(target.materialProgress, closeTo(0.30, 1e-9));
      },
    );

    test('isApplicationSubmitted handles every workflow and status enum', () {
      expect(
        DashboardMetricsCalculator.isApplicationSubmitted(
          makeCircular(id: '1', title: 'A'),
        ),
        isFalse,
      );
      expect(
        DashboardMetricsCalculator.isApplicationSubmitted(
          makeCircular(
            id: '2',
            title: 'B',
            applicationStatus: ApplicationStatus.inProgress,
          ),
        ),
        isFalse,
      );
      expect(
        DashboardMetricsCalculator.isApplicationSubmitted(
          makeCircular(
            id: '3',
            title: 'C',
            workflowStatus: CircularWorkflowStatus.resultAwaited,
          ),
        ),
        isTrue,
      );
      expect(
        DashboardMetricsCalculator.isApplicationSubmitted(
          makeCircular(
            id: '4',
            title: 'D',
            applicationStatus: ApplicationStatus.feePaid,
          ),
        ),
        isTrue,
      );
    });
  });

  group('dashboardSummaryProvider integration with Riverpod', () {
    test('reactively combines circulars, prep, and progress logs', () async {
      final circularRepo = FakeCircularRepository(
        clock: () => fixedNow,
        initialItems: [
          makeCircular(
            id: 'c1',
            title: 'BCS 48',
            deadline: DateTime.utc(2026, 11, 13, 18),
            workflowStatus: CircularWorkflowStatus.inbox,
            examDates: [
              CircularExamDate(
                id: 'ex-1',
                circularId: 'c1',
                stage: 'preliminary',
                examDate: DateTime.utc(2026, 11, 20, 10),
              ),
            ],
          ),
        ],
      );
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(id: 'sub-1', userId: 'user-1', name: 'English'),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'mat-1',
            userId: 'user-1',
            subjectId: 'sub-1',
            title: 'Cliffs TOEFL',
            totalUnits: 200,
            completedUnits: 100,
          ),
        ],
      );
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
        initialLogs: [
          ProgressLog(
            id: 'l-1',
            userId: 'user-1',
            materialId: 'mat-1',
            unitsDone: 30,
            loggedOn: DateTime.utc(2026, 11, 9),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          circularNowProvider.overrideWithValue(() => fixedNow),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
        ],
      );
      addTearDown(container.dispose);

      // Kick off all underlying Future/AsyncNotifier providers.
      container.listen(dashboardSummaryProvider, (_, __) {});
      await container.read(circularsListProvider.future);
      await container.read(subjectsProvider.future);
      await container.read(allMaterialsProvider.future);
      await container.read(recentProgressLogsProvider.future);

      final summaryAsync = container.read(dashboardSummaryProvider);
      expect(summaryAsync.hasValue, isTrue);
      final summary = summaryAsync.requireValue;
      expect(summary.upcomingDeadlinesThisWeekCount, 1);
      expect(summary.inboxCount, 1);
      expect(summary.upcomingExamsNext14DaysCount, 1);
      expect(summary.overallPrepProgress, closeTo(0.50, 1e-9));
      expect(summary.continueStudying?.material.id, 'mat-1');
    });

    test('propagates repository failure as AsyncError', () async {
      final circularRepo = FakeCircularRepository(clock: () => fixedNow)
        ..nextError = const CircularNetworkFailure(message: 'offline');

      final container = ProviderContainer(
        overrides: [
          circularNowProvider.overrideWithValue(() => fixedNow),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          subjectRepositoryProvider.overrideWithValue(FakeSubjectRepository()),
          materialRepositoryProvider
              .overrideWithValue(FakeMaterialRepository()),
          progressLogRepositoryProvider
              .overrideWithValue(FakeProgressLogRepository()),
        ],
      );
      addTearDown(container.dispose);

      container.listen(dashboardSummaryProvider, (_, __) {});
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final summaryAsync = container.read(dashboardSummaryProvider);
      expect(summaryAsync.hasError, isTrue);
    });
  });
}
