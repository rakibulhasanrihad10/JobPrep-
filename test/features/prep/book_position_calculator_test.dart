import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/dashboard/domain/utils/dashboard_metrics.dart';
import 'package:job_prep/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:job_prep/features/prep/data/mappers/progress_log_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_analytics.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/book_position_calculator.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/domain/utils/study_analytics_calculator.dart';
import 'package:job_prep/features/prep/domain/utils/study_plan_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_analytics_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_mock_test_repository.dart';
import 'fake_study_plan_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

class _EmptyCircularRepository implements CircularRepository {
  @override
  Future<Circular> createCircular(Circular circular) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCircular(String id) async {}

  @override
  Future<Circular?> getCircularById(String id) async => null;

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async =>
      const <Circular>[];

  @override
  Future<Circular> updateCircular(Circular circular) =>
      throw UnimplementedError();
}

void main() {
  group('BookPositionCalculator', () {
    test('parses whole English & Bangla pages and validates bounds', () {
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          '245',
          totalUnits: 500,
        ),
        (page: 245, error: null),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          ' ২৪৫ ',
          totalUnits: 500,
        ),
        (page: 245, error: null),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          '0',
          totalUnits: 500,
        ),
        (page: 0, error: null),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          '500',
          totalUnits: 500,
        ),
        (page: 500, error: null),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          '   ',
          totalUnits: 500,
        ),
        (page: null, error: BookPositionValidationError.empty),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          '12.5',
          totalUnits: 500,
        ),
        (page: null, error: BookPositionValidationError.notWholeNumber),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          'abc',
          totalUnits: 500,
        ),
        (page: null, error: BookPositionValidationError.notWholeNumber),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          '-5',
          totalUnits: 500,
        ),
        (page: null, error: BookPositionValidationError.belowZero),
      );
      expect(
        BookPositionCalculator.parseAndValidateTargetPage(
          '501',
          totalUnits: 500,
        ),
        (page: null, error: BookPositionValidationError.exceedsTotal),
      );
    });

    test('computes forward study delta, no-op, and backward correction delta',
        () {
      final forward = BookPositionCalculator.computeChange(
        currentUnits: 200,
        totalUnits: 500,
        targetPage: 245,
      );
      expect(forward.currentPosition, 200);
      expect(forward.targetPosition, 245);
      expect(forward.delta, 45);
      expect(forward.entryType, ProgressLogEntryType.study);
      expect(forward.requiresConfirmation, isFalse);
      expect(forward.isNoOp, isFalse);

      final same = BookPositionCalculator.computeChange(
        currentUnits: 200,
        totalUnits: 500,
        targetPage: 200,
      );
      expect(same.delta, 0);
      expect(same.isNoOp, isTrue);
      expect(same.requiresConfirmation, isFalse);

      final backward = BookPositionCalculator.computeChange(
        currentUnits: 200,
        totalUnits: 500,
        targetPage: 140,
      );
      expect(backward.currentPosition, 200);
      expect(backward.targetPosition, 140);
      expect(backward.delta, -60);
      expect(backward.entryType, ProgressLogEntryType.correction);
      expect(backward.requiresConfirmation, isTrue);
      expect(backward.isNoOp, isFalse);
    });

    test('converts bookmark drag fractions to valid rounded pages', () {
      expect(
        BookPositionCalculator.pageFromFraction(
          fraction: 0,
          totalUnits: 500,
        ),
        0,
      );
      expect(
        BookPositionCalculator.pageFromFraction(
          fraction: 0.49,
          totalUnits: 500,
        ),
        245,
      );
      expect(
        BookPositionCalculator.pageFromFraction(
          fraction: 1.4,
          totalUnits: 500,
        ),
        500,
      );
      expect(
        BookPositionCalculator.pageFromFraction(
          fraction: double.nan,
          totalUnits: 500,
        ),
        0,
      );
    });
  });

  group('ProgressLogMapper entry_type & pure correction exclusion', () {
    test('round-trips entry_type and defaults missing column to study', () {
      final correction = ProgressLogMapper.fromJson(<String, dynamic>{
        'id': 'log-c',
        'user_id': 'u-1',
        'material_id': 'mat-1',
        'units_done': -35,
        'entry_type': 'correction',
        'logged_on': '2026-11-11',
      });
      expect(correction.entryType, ProgressLogEntryType.correction);
      expect(correction.isCorrection, isTrue);
      expect(correction.isStudy, isFalse);
      expect(
        ProgressLogMapper.toInsertJson(correction)['entry_type'],
        'correction',
      );
      expect(
        ProgressLogMapper.toUpdateJson(correction)['entry_type'],
        'correction',
      );

      final legacy = ProgressLogMapper.fromJson(<String, dynamic>{
        'id': 'log-s',
        'user_id': 'u-1',
        'material_id': 'mat-1',
        'units_done': 40,
        'logged_on': '2026-11-11',
      });
      expect(legacy.entryType, ProgressLogEntryType.study);
      expect(legacy.isStudy, isTrue);
    });

    test(
        'excludes correction logs from study plan todayCompleted, analytics '
        'daily/weekly totals, rolling averages, consistency, and streaks', () {
      const subject = Subject(
        id: 'sub-1',
        userId: 'u-1',
        name: 'Bangla',
      );
      const b1 = PrepMaterial(
        id: 'b1',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Book One',
        totalUnits: 300,
        completedUnits: 300,
      );
      const b2 = PrepMaterial(
        id: 'b2',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Book Two',
        totalUnits: 300,
        completedUnits: 120,
      );
      const b3 = PrepMaterial(
        id: 'b3',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Book Three',
        totalUnits: 400,
      );
      expect(calculateMaterialProgress(b1), closeTo(1.0, 1e-6));
      expect(
        calculateSubjectProgress(const [
          b1,
          PrepMaterial(id: 'b2z', title: 'Book Two', totalUnits: 300),
          b3,
        ]),
        closeTo(0.30, 1e-6),
      );

      final logs = <ProgressLog>[
        ProgressLog(
          id: 'l1',
          materialId: 'b1',
          unitsDone: 50,
          loggedOn: DateTime.utc(2026, 11, 10),
        ),
        ProgressLog(
          id: 'l2',
          materialId: 'b2',
          unitsDone: 30,
          loggedOn: DateTime.utc(2026, 11, 11),
        ),
        ProgressLog(
          id: 'l3',
          materialId: 'b2',
          unitsDone: -20,
          entryType: ProgressLogEntryType.correction,
          loggedOn: DateTime.utc(2026, 11, 11),
        ),
        ProgressLog(
          id: 'l4',
          materialId: 'b2',
          unitsDone: 99,
          entryType: ProgressLogEntryType.correction,
          loggedOn: DateTime.utc(2026, 11, 9),
        ),
      ];

      final plan = StudyPlan(
        id: 'plan-1',
        userId: 'u-1',
        subjectId: 'sub-1',
        startDate: DateTime.utc(2026, 11, 10),
        targetDate: DateTime.utc(2026, 11, 25),
      );
      final planSnapshot = StudyPlanCalculator.buildSnapshot(
        plan: plan,
        today: DateTime.utc(2026, 11, 11),
        subject: subject,
        materials: const [b1, b2, b3],
        recentLogs: logs,
      );
      expect(planSnapshot.todayCompletedUnits, 30);
      expect(planSnapshot.completedUnits, 420);
      expect(planSnapshot.remainingUnits, 580);

      final grouped = StudyAnalyticsCalculator.groupUnitsByLocalDay(
        logs,
        localOffset: Duration.zero,
      );
      expect(grouped, {
        DateTime(2026, 11, 10): 50,
        DateTime(2026, 11, 11): 30,
      });

      final analytics = StudyAnalyticsCalculator.buildSummary(
        range: StudyAnalyticsRange.days7,
        now: DateTime.utc(2026, 11, 11, 12),
        localOffset: Duration.zero,
        subjects: const [subject],
        materials: const [b1, b2, b3],
        logs: logs,
        planSnapshots: [planSnapshot],
        mockTests: const [],
      );
      expect(analytics.totalUnitsInRange, 80);
      expect(analytics.activeDaysInRange, 2);
      expect(analytics.currentStreak, 2);
      expect(analytics.longestStreak, 2);
      expect(analytics.consistencyScore, closeTo(2 / 7, 1e-6));
      expect(analytics.averageLast7Days, closeTo(80 / 7, 1e-6));

      final continueStudying =
          DashboardMetricsCalculator.resolveContinueStudyingTarget(
        recentLogs: logs,
        materials: const [b1, b2, b3],
        subjects: const [subject],
      );
      expect(continueStudying?.latestLog.id, 'l2');
    });
  });

  group('PrepProgressLogNotifier.setBookPosition reactive integration', () {
    test(
        'forward move logs delta as study; backward move requires '
        'confirmation and updates book, subject, study plan, analytics & '
        'dashboard without distorting studied units', () async {
      final now = DateTime.utc(2026, 11, 11, 10);
      const subject = Subject(id: 'sub-1', userId: 'u-1', name: 'English');
      const initialBook = PrepMaterial(
        id: 'book-1',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Master English',
        totalUnits: 500,
        completedUnits: 200,
      );

      final subjectRepo = FakeSubjectRepository(initialSubjects: [subject]);
      final materialRepo = FakeMaterialRepository(
        initialMaterials: [initialBook],
        clock: () => now,
      );
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
        clock: () => now,
        initialLogs: [
          ProgressLog(
            id: 'seed-log',
            userId: 'u-1',
            materialId: 'book-1',
            unitsDone: 200,
            loggedOn: DateTime.utc(2026, 11, 10),
          ),
        ],
      );
      final planRepo = FakeStudyPlanRepository(
        initialPlans: [
          StudyPlan(
            id: 'plan-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            startDate: DateTime.utc(2026, 11, 10),
            targetDate: DateTime.utc(2026, 11, 28),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          circularNowProvider.overrideWithValue(() => now),
          circularRepositoryProvider
              .overrideWithValue(_EmptyCircularRepository()),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
          studyPlanRepositoryProvider.overrideWithValue(planRepo),
          mockTestRepositoryProvider
              .overrideWithValue(FakeMockTestRepository()),
          studyAnalyticsOffsetProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      await container.read(circularsListProvider.future);
      await container.read(subjectsProvider.future);
      await container.read(allMaterialsProvider.future);
      await container.read(materialsForSubjectProvider('sub-1').future);
      await container.read(recentProgressLogsProvider.future);
      await container.read(studyPlansProvider.future);
      await container.read(mockTestsProvider.future);
      await container.read(analyticsProgressLogsProvider.future);

      final controller =
          container.read(prepProgressLogControllerProvider.notifier);

      final forwardChange = await controller.setBookPosition(
        material: initialBook,
        targetPage: 245,
      );
      expect(forwardChange?.delta, 45);
      expect(forwardChange?.entryType, ProgressLogEntryType.study);

      final updatedBook =
          (await container.read(allMaterialsProvider.future)).single;
      expect(updatedBook.completedUnits, 245);

      await container.read(analyticsProgressLogsProvider.future);
      expect(
        container
            .read(studyPlanSnapshotsProvider)
            .requireValue
            .single
            .todayCompletedUnits,
        45,
      );
      expect(
        container
            .read(studyAnalyticsSummaryProvider)
            .requireValue
            .totalUnitsInRange,
        245,
      );
      expect(
        container
            .read(dashboardSummaryProvider)
            .requireValue
            .overallPrepProgress,
        closeTo(245 / 500, 1e-6),
      );

      final rejected = await controller.setBookPosition(
        material: updatedBook,
        targetPage: 160,
      );
      expect(rejected, isNull);
      expect(
        (await container.read(allMaterialsProvider.future))
            .single
            .completedUnits,
        245,
      );

      final correctionChange = await controller.setBookPosition(
        material: updatedBook,
        targetPage: 160,
        confirmCorrection: true,
      );
      expect(correctionChange?.delta, -85);
      expect(correctionChange?.entryType, ProgressLogEntryType.correction);

      final correctedBook =
          (await container.read(allMaterialsProvider.future)).single;
      expect(correctedBook.completedUnits, 160);

      await container.read(analyticsProgressLogsProvider.future);
      final logs = await logRepo.getLogsForMaterial('book-1');
      expect(logs.any((l) => l.isCorrection && l.unitsDone == -85), isTrue);

      expect(
        container
            .read(studyPlanSnapshotsProvider)
            .requireValue
            .single
            .todayCompletedUnits,
        45,
      );
      expect(
        container
            .read(studyAnalyticsSummaryProvider)
            .requireValue
            .totalUnitsInRange,
        245,
      );
      expect(
        container
            .read(dashboardSummaryProvider)
            .requireValue
            .overallPrepProgress,
        closeTo(160 / 500, 1e-6),
      );
    });
  });
}
