import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/errors/notification_failure.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';

/// Safe fallback [NotificationsRepository] active when Supabase credentials
/// are not provided via `--dart-define`.
class UnconfiguredNotificationsRepository implements NotificationsRepository {
  /// Creates an [UnconfiguredNotificationsRepository].
  const UnconfiguredNotificationsRepository();

  static const _notConfiguredError = UnknownNotificationFailure(
    code: 'supabase_not_configured',
    message: 'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
  );

  @override
  Future<List<AppNotification>> getNotifications() async =>
      const <AppNotification>[];

  @override
  Stream<List<AppNotification>> watchNotifications() =>
      Stream<List<AppNotification>>.value(const <AppNotification>[]);

  @override
  Future<AppNotification> markAsRead(String notificationId) =>
      Future<AppNotification>.error(_notConfiguredError);

  @override
  Future<void> markAllAsRead() => Future<void>.error(_notConfiguredError);

  @override
  Future<void> deleteNotification(String notificationId) =>
      Future<void>.error(_notConfiguredError);
}
