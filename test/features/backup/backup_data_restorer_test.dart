import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/backup/data/repositories/backup_data_restorer.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

import '../migration/fake_cloud_repositories.dart';

class _FakeNotificationsRepository extends Fake
    implements NotificationsRepository {
  final List<AppNotification> items = [];

  @override
  Future<List<AppNotification>> getNotifications() async => items;

  @override
  Future<AppNotification> insertNotification(
    AppNotification notification,
  ) async {
    items.add(notification);
    return notification;
  }

  @override
  Future<AppNotification> markAsRead(String id) async {
    final idx = items.indexWhere((n) => n.id == id);
    if (idx == -1) throw Exception('Not found');
    final updated = items[idx].copyWith(readAt: DateTime.utc(2026, 1, 2));
    items[idx] = updated;
    return updated;
  }

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> deleteNotification(String id) async {
    items.removeWhere((n) => n.id == id);
  }
}

void main() {
  group('BackupDataRestorer Unit Tests', () {
    late FakeCloudRepositoriesBundle fakes;
    late _FakeNotificationsRepository fakeNotifications;

    setUp(() {
      fakes = FakeCloudRepositoriesBundle();
      fakeNotifications = _FakeNotificationsRepository();
    });

    test('restoreTables exercises all tables in merge and replace strategies',
        () async {
      final oldSubject = Subject(
        id: 's-1',
        name: 'Math Old',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      await fakes.subjectRepo.createSubject(oldSubject);

      final tables = BackupDataTables(
        subjects: [
          {
            'id': 's-1',
            'name': 'Math Newer',
            'created_at': DateTime.utc(2026).toIso8601String(),
            'updated_at': DateTime.utc(2026, 12).toIso8601String(),
          },
          {
            'id': 's-2',
            'name': 'Physics',
            'created_at': DateTime.utc(2026).toIso8601String(),
            'updated_at': DateTime.utc(2026).toIso8601String(),
          },
        ],
        topics: [
          {
            'id': 'top-1',
            'subject_id': 's-2',
            'name': 'Kinematics',
            'created_at': DateTime.utc(2026).toIso8601String(),
            'updated_at': DateTime.utc(2026).toIso8601String(),
          },
        ],
        materials: [
          {
            'id': 'm-1',
            'subject_id': 's-2',
            'title': 'Physics Mechanics',
            'total_units': 200,
            'completed_units': 50,
            'created_at': DateTime.utc(2026).toIso8601String(),
            'updated_at': DateTime.utc(2026).toIso8601String(),
          },
        ],
        progressLogs: [
          {
            'id': 'pl-1',
            'material_id': 'm-1',
            'units_completed': 50,
            'entry_type': 'study',
            'logged_at': DateTime.utc(2026, 1, 2).toIso8601String(),
          },
        ],
        circulars: [
          {
            'id': 'c-1',
            'title': 'Bangladesh Bank AD',
            'created_at': DateTime.utc(2026).toIso8601String(),
            'updated_at': DateTime.utc(2026).toIso8601String(),
          },
        ],
        circularExamDates: [
          {
            'id': 'ed-1',
            'circular_id': 'c-1',
            'stage': 'Preliminary',
            'exam_date': DateTime.utc(2026, 6).toIso8601String(),
          },
        ],
        studyPlans: [
          {
            'id': 'sp-1',
            'title': 'Sprint 2026',
            'daily_target_minutes': 90,
            'start_date': DateTime.utc(2026).toIso8601String(),
            'target_date': DateTime.utc(2026, 6).toIso8601String(),
            'created_at': DateTime.utc(2026).toIso8601String(),
            'updated_at': DateTime.utc(2026).toIso8601String(),
          },
        ],
        mockTests: [
          {
            'id': 'mt-1',
            'title': 'Full Mock 1',
            'score': 80.0,
            'total_marks': 100.0,
            'test_date': DateTime.utc(2026, 3).toIso8601String(),
          },
        ],
        revisionItems: [
          {
            'id': 'ri-1',
            'topic_id': 'top-1',
            'confidence_level': 2,
            'next_revision_at': DateTime.utc(2026, 3, 5).toIso8601String(),
            'created_at': DateTime.utc(2026).toIso8601String(),
            'updated_at': DateTime.utc(2026).toIso8601String(),
          },
        ],
        studySessions: [
          {
            'id': 'ss-1',
            'material_id': 'm-1',
            'duration_minutes': 60,
            'started_at': DateTime.utc(2026, 2, 1, 9).toIso8601String(),
            'ended_at': DateTime.utc(2026, 2, 1, 10).toIso8601String(),
          },
        ],
        notifications: [
          {
            'id': 'notif-1',
            'title': 'Test Reminder',
            'body': 'Time to study',
            'type': 'daily_reminder',
            'created_at': DateTime.utc(2026).toIso8601String(),
            'is_read': false,
          },
        ],
        portalAccounts: [
          {
            'id': 'pa-1',
            'portal_name': 'BPSC Direct',
            'username': 'candidate1',
            'encrypted_password': 'nonce:cipher:tag',
            'created_at': DateTime.utc(2026).toIso8601String(),
          },
        ],
        userSettings: const [
          {
            'id': 'user-settings-1',
            'theme_mode': 'dark',
            'locale': 'en',
            'reduce_effects': false,
          },
        ],
      );

      final mergeCount = await BackupDataRestorer.restoreTables(
        tables: tables,
        strategy: RestoreStrategy.merge,
        subjectRepo: fakes.subjectRepo,
        chapterRepo: fakes.chapterRepo,
        topicRepo: fakes.topicRepo,
        materialRepo: fakes.materialRepo,
        circularRepo: fakes.circularRepo,
        examDateRepo: fakes.examDateRepo,
        studyPlanRepo: fakes.studyPlanRepo,
        mockTestRepo: fakes.mockTestRepo,
        progressLogRepo: fakes.progressLogRepo,
        revisionItemRepo: fakes.revisionItemRepo,
        studySessionRepo: fakes.studySessionRepo,
        notificationsRepo: fakeNotifications,
        portalAccountRepo: fakes.portalAccountRepo,
        userSettingsRepo: fakes.userSettingsRepo,
      );

      expect(mergeCount, greaterThanOrEqualTo(10));
      final updated = await fakes.subjectRepo.getSubjectById('s-1');
      expect(updated!.name, equals('Math Newer'));

      // Now run with replace strategy
      final replaceCount = await BackupDataRestorer.restoreTables(
        tables: tables,
        strategy: RestoreStrategy.replace,
        subjectRepo: fakes.subjectRepo,
        chapterRepo: fakes.chapterRepo,
        topicRepo: fakes.topicRepo,
        materialRepo: fakes.materialRepo,
        circularRepo: fakes.circularRepo,
        examDateRepo: fakes.examDateRepo,
        studyPlanRepo: fakes.studyPlanRepo,
        mockTestRepo: fakes.mockTestRepo,
        progressLogRepo: fakes.progressLogRepo,
        revisionItemRepo: fakes.revisionItemRepo,
        studySessionRepo: fakes.studySessionRepo,
        notificationsRepo: fakeNotifications,
        portalAccountRepo: fakes.portalAccountRepo,
        userSettingsRepo: fakes.userSettingsRepo,
      );

      expect(replaceCount, greaterThanOrEqualTo(10));
    });
  });
}
