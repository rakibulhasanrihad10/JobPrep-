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
    test('Database opens with schemaVersion 1', () {
      expect(db.schemaVersion, equals(1));
    });

    test('All 15 mirrored domain tables are queryable and empty on init',
        () async {
      expect(await db.select(db.localCirculars).get(), isEmpty);
      expect(await db.select(db.localCircularExamDates).get(), isEmpty);
      expect(await db.select(db.localSubjects).get(), isEmpty);
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

    test('LocalCirculars insertion and primary key constraint', () async {
      final now = DateTime.utc(2026, 11, 14);
      final entry = LocalCircular(
        id: 'c-1',
        title: 'Assistant Director',
        sector: 'government',
        isQuickCapture: false,
        checklistPhoto: false,
        checklistCertificates: false,
        checklistFeePaid: false,
        checklistSubmitted: false,
        checklistAdmitCardDownloaded: false,
        createdAt: now,
        updatedAt: now,
        applicationStatus: 'not_applied',
        admitCardStatus: 'not_available',
        priority: 'medium',
        workflowStatus: 'saved',
      );

      await db.into(db.localCirculars).insert(entry);
      final retrieved = await db.select(db.localCirculars).get();
      expect(retrieved, hasLength(1));
      expect(retrieved.first.id, equals('c-1'));
      expect(retrieved.first.title, equals('Assistant Director'));
    });
  });
}
