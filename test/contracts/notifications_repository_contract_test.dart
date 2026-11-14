import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/notifications/data/repositories/local_notifications_repository.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';

void testNotificationsRepositoryContract({
  required Future<NotificationsRepository> Function() createRepository,
  required Future<void> Function(AppNotification notification)
      insertNotification,
  Future<void> Function()? tearDownRepository,
}) {
  group('NotificationsRepository Contract Tests', () {
    late NotificationsRepository repo;

    setUp(() async {
      repo = await createRepository();
    });

    tearDown(() async {
      if (tearDownRepository != null) {
        await tearDownRepository();
      }
    });

    test('retrieves inserted notifications newest first', () async {
      final n1 = AppNotification(
        id: 'n-1',
        userId: 'user-1',
        type: AppNotificationType.deadlineSoon,
        messageKey: 'deadline_warning',
        route: '/circulars/1',
        dedupeKey: 'd-1',
        createdAt: DateTime.utc(2026, 11, 14, 10),
      );
      final n2 = AppNotification(
        id: 'n-2',
        userId: 'user-1',
        type: AppNotificationType.examSoon,
        messageKey: 'exam_warning',
        route: '/circulars/2',
        dedupeKey: 'd-2',
        createdAt: DateTime.utc(2026, 11, 14, 11),
      );

      await insertNotification(n1);
      await insertNotification(n2);

      final list = await repo.getNotifications();
      expect(list, hasLength(2));
      expect(list.first.id, equals('n-2'));
      expect(list.last.id, equals('n-1'));
    });

    test('marks single notification as read', () async {
      final n = AppNotification(
        id: 'n-3',
        userId: 'user-1',
        type: AppNotificationType.weeklyReview,
        messageKey: 'review_prompt',
        route: '/today',
        dedupeKey: 'd-3',
        createdAt: DateTime.utc(2026, 11, 14),
      );
      await insertNotification(n);

      final readResult = await repo.markAsRead('n-3');
      expect(readResult.readAt, isNotNull);

      final list = await repo.getNotifications();
      expect(list.first.readAt, isNotNull);
    });

    test('marks all notifications as read', () async {
      await insertNotification(
        AppNotification(
          id: 'n-4',
          userId: 'user-1',
          type: AppNotificationType.behindSchedule,
          messageKey: 'behind',
          route: '/prep',
          dedupeKey: 'd-4',
          createdAt: DateTime.utc(2026, 11, 14, 8),
        ),
      );
      await insertNotification(
        AppNotification(
          id: 'n-5',
          userId: 'user-1',
          type: AppNotificationType.revisionDue,
          messageKey: 'revision',
          route: '/prep',
          dedupeKey: 'd-5',
          createdAt: DateTime.utc(2026, 11, 14, 9),
        ),
      );

      await repo.markAllAsRead();

      final list = await repo.getNotifications();
      for (final item in list) {
        expect(item.readAt, isNotNull);
      }
    });

    test('deletes notification', () async {
      await insertNotification(
        AppNotification(
          id: 'n-6',
          userId: 'user-1',
          type: AppNotificationType.deadlineSoon,
          messageKey: 'test',
          route: '/today',
          dedupeKey: 'd-6',
          createdAt: DateTime.utc(2026, 11, 14),
        ),
      );

      await repo.deleteNotification('n-6');
      final list = await repo.getNotifications();
      expect(list.where((n) => n.id == 'n-6'), isEmpty);
    });
  });
}

void main() {
  late AppDatabase db;
  late LocalNotificationsRepository localRepo;

  testNotificationsRepositoryContract(
    createRepository: () async {
      db = AppDatabase(NativeDatabase.memory());
      return localRepo = LocalNotificationsRepository(db);
    },
    insertNotification: (notification) async {
      await localRepo.insertNotification(notification);
    },
    tearDownRepository: () async {
      await db.close();
    },
  );
}
