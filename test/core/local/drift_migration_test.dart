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
    test('Database opens with schemaVersion 2', () {
      expect(db.schemaVersion, equals(2));
    });

    test('All 16 mirrored domain tables are queryable and empty on init',
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
  });
}
