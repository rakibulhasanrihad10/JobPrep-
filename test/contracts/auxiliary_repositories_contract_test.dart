import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/prep/data/repositories/local_mock_test_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_revision_item_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_study_plan_repository.dart';
import 'package:job_prep/features/prep/data/repositories/local_study_session_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_mock_test_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_revision_item_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_study_plan_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_study_session_repository.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';

import 'mock_supabase_http_client.dart';

void testAuxiliaryRepositoriesContract({
  required Future<
              ({
                StudyPlanRepository studyPlans,
                MockTestRepository mockTests,
                RevisionItemRepository revisionItems,
                StudySessionRepository studySessions,
              })>
          Function()
      createRepositories,
  Future<void> Function()? tearDownRepositories,
}) {
  group('StudyPlan, MockTest, RevisionItem, StudySession Contracts', () {
    late StudyPlanRepository studyPlansRepo;
    late MockTestRepository mockTestsRepo;
    late RevisionItemRepository revisionItemsRepo;
    late StudySessionRepository studySessionsRepo;

    setUp(() async {
      final repos = await createRepositories();
      studyPlansRepo = repos.studyPlans;
      mockTestsRepo = repos.mockTests;
      revisionItemsRepo = repos.revisionItems;
      studySessionsRepo = repos.studySessions;
    });

    tearDown(() async {
      if (tearDownRepositories != null) {
        await tearDownRepositories();
      }
    });

    test('StudyPlan save, scope uniqueness, and retrieval', () async {
      final plan = StudyPlan(
        startDate: DateTime.utc(2026, 11),
        targetDate: DateTime.utc(2026, 12),
        finishBufferDays: 5,
        restDaysPerWeek: 1,
        subjectId: 'sub-1',
      );

      final saved = await studyPlansRepo.savePlan(plan);
      expect(saved.id, isNotEmpty);
      expect(saved.finishBufferDays, equals(5));

      final plans = await studyPlansRepo.getPlans();
      expect(plans, hasLength(1));

      final updated = await studyPlansRepo.savePlan(
        saved.copyWith(finishBufferDays: 10),
      );
      expect(updated.finishBufferDays, equals(10));

      final plansAfter = await studyPlansRepo.getPlans();
      expect(plansAfter, hasLength(1));
      expect(plansAfter.first.finishBufferDays, equals(10));
    });

    test('MockTest create, query, and delete', () async {
      final test = MockTest(
        subjectId: 'sub-2',
        title: 'Math Model Test 1',
        takenOn: DateTime.utc(2026, 11, 14),
        marksObtained: 85,
        totalMarks: 100,
      );

      final created = await mockTestsRepo.createTest(test);
      expect(created.id, isNotEmpty);

      final list = await mockTestsRepo.getTestsForSubject('sub-2');
      expect(list, hasLength(1));
      expect(list.first.marksObtained, equals(85));

      await mockTestsRepo.deleteTest(created.id);
      expect(await mockTestsRepo.getTestsForSubject('sub-2'), isEmpty);
    });

    test('RevisionItem batch create and update', () async {
      final items = [
        RevisionItem(
          subjectId: 'sub-3',
          referenceLabel: 'Ch 1',
          dueOn: DateTime.utc(2026, 11, 14),
        ),
      ];

      final createdList = await revisionItemsRepo.createRevisionItems(items);
      expect(createdList, hasLength(1));

      final fetched = await revisionItemsRepo.getRevisionItems();
      expect(fetched, hasLength(1));

      final updated = await revisionItemsRepo.updateRevisionItem(
        fetched.first.copyWith(status: RevisionStatus.revised),
      );
      expect(updated.status, equals(RevisionStatus.revised));
    });

    test('StudySession lifecycle and active session', () async {
      final session = StudySession(
        id: '',
        userId: '',
        subjectId: 'sub-4',
        startedAt: DateTime.utc(2026, 11, 14, 9),
      );

      final created = await studySessionsRepo.createStudySession(session);
      expect(created.id, isNotEmpty);

      final active = await studySessionsRepo.getActiveStudySession();
      expect(active, isNotNull);
      expect(active!.id, equals(created.id));

      final ended = await studySessionsRepo.updateStudySession(
        created.copyWith(
          endedAt: DateTime.utc(2026, 11, 14, 9, 30),
          durationSeconds: 1800,
        ),
      );
      expect(ended.endedAt, isNotNull);

      final activeAfter = await studySessionsRepo.getActiveStudySession();
      expect(activeAfter, isNull);
    });
  });
}

void main() {
  group('Local Implementation Contract', () {
    late AppDatabase db;

    testAuxiliaryRepositoriesContract(
      createRepositories: () async {
        db = AppDatabase(NativeDatabase.memory());
        return (
          studyPlans: LocalStudyPlanRepository(db),
          mockTests: LocalMockTestRepository(db),
          revisionItems: LocalRevisionItemRepository(db),
          studySessions: LocalStudySessionRepository(db),
        );
      },
      tearDownRepositories: () async {
        await db.close();
      },
    );
  });

  group('Supabase Implementation Contract', () {
    late MockSupabaseHttpClient mockHttp;
    late MockSupabaseClient client;

    testAuxiliaryRepositoriesContract(
      createRepositories: () async {
        mockHttp = MockSupabaseHttpClient();
        client = MockSupabaseClient(mockHttpClient: mockHttp);
        return (
          studyPlans: SupabaseStudyPlanRepository(client),
          mockTests: SupabaseMockTestRepository(client),
          revisionItems: SupabaseRevisionItemRepository(client),
          studySessions: SupabaseStudySessionRepository(client),
        );
      },
      tearDownRepositories: () async {
        mockHttp.clear();
      },
    );
  });
}
