import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Schema Versioning & Table Creation Tests', () {
    test('Database opens with schemaVersion 3', () {
      expect(db.schemaVersion, equals(3));
    });

    test('All 18 mirrored domain tables are queryable and empty on init',
        () async {
      expect(await db.select(db.localCirculars).get(), isEmpty);
      expect(await db.select(db.localCircularExamDates).get(), isEmpty);
      expect(await db.select(db.localSubjects).get(), isEmpty);
      expect(await db.select(db.localChapters).get(), isEmpty);
      expect(await db.select(db.localMaterials).get(), isEmpty);
      expect(await db.select(db.localProgressLogs).get(), isEmpty);
      expect(await db.select(db.localTopics).get(), isEmpty);
      expect(await db.select(db.localCircularSubjects).get(), isEmpty);
      expect(await db.select(db.localStudyPlans).get(), isEmpty);
      expect(await db.select(db.localMockTests).get(), isEmpty);
      expect(await db.select(db.localMockTestTopics).get(), isEmpty);
      expect(await db.select(db.localMaterialChapters).get(), isEmpty);
      expect(await db.select(db.localRevisionItems).get(), isEmpty);
      expect(await db.select(db.localStudySessions).get(), isEmpty);
      expect(await db.select(db.localNotifications).get(), isEmpty);
      expect(await db.select(db.localPortalAccounts).get(), isEmpty);
      expect(await db.select(db.localUserSettings).get(), isEmpty);
      expect(await db.select(db.localUserReminderSettings).get(), isEmpty);
    });

    test('LocalChapters insertion and primary key constraint', () async {
      final now = DateTime.utc(2026, 11, 14);
      final entry = LocalChapter(
        id: 'chap-1',
        subjectId: 'sub-1',
        title: 'Mechanics',
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

      await db.into(db.localChapters).insert(entry);
      final retrieved = await db.select(db.localChapters).get();
      expect(retrieved, hasLength(1));
      expect(retrieved.first.id, equals('chap-1'));
      expect(retrieved.first.title, equals('Mechanics'));
    });

    test('LocalTopics with checkpoints and chapterId insertion', () async {
      final now = DateTime.utc(2026, 11, 14);
      final entry = LocalTopic(
        id: 'top-1',
        subjectId: 'sub-1',
        chapterId: 'chap-1',
        title: 'Newtonian Physics',
        name: 'Newtonian Physics',
        sortOrder: 0,
        weight: 2,
        studyDoneAt: now,
        notes: 'Study chapter 3 derivation',
        createdAt: now,
        updatedAt: now,
      );

      await db.into(db.localTopics).insert(entry);
      final retrieved = await db.select(db.localTopics).get();
      expect(retrieved, hasLength(1));
      expect(retrieved.first.title, equals('Newtonian Physics'));
      expect(retrieved.first.weight, equals(2));
      expect(
        retrieved.first.studyDoneAt!.isAtSameMomentAs(now),
        isTrue,
      );
      expect(retrieved.first.chapterId, equals('chap-1'));
    });

    test('LocalMockTestTopics and LocalMaterialChapters insertion', () async {
      final now = DateTime.utc(2026, 11, 16);
      await db.into(db.localMockTestTopics).insert(
            LocalMockTestTopic(
              id: 'mtt-1',
              mockTestId: 'mt-1',
              topicId: 'top-1',
              createdAt: now,
            ),
          );
      await db.into(db.localMaterialChapters).insert(
            LocalMaterialChapter(
              id: 'mc-1',
              materialId: 'mat-1',
              chapterId: 'chap-1',
              createdAt: now,
            ),
          );

      final mtts = await db.select(db.localMockTestTopics).get();
      expect(mtts, hasLength(1));
      expect(mtts.first.mockTestId, equals('mt-1'));
      expect(mtts.first.topicId, equals('top-1'));

      final mcs = await db.select(db.localMaterialChapters).get();
      expect(mcs, hasLength(1));
      expect(mcs.first.materialId, equals('mat-1'));
      expect(mcs.first.chapterId, equals('chap-1'));
    });

    test('LocalStudyPlans supports planBasis column', () async {
      final now = DateTime.utc(2026, 11, 16);
      await db.into(db.localStudyPlans).insert(
            LocalStudyPlan(
              id: 'plan-1',
              startDate: now,
              targetDate: now.add(const Duration(days: 30)),
              finishBufferDays: 7,
              restDaysPerWeek: 0,
              extraStudyDays: 0,
              initialCompletedUnits: 0,
              postponedMaterialIds: '[]',
              planBasis: 'syllabus_topics',
            ),
          );

      final plans = await db.select(db.localStudyPlans).get();
      expect(plans, hasLength(1));
      expect(plans.first.planBasis, equals('syllabus_topics'));
    });
  });
}
