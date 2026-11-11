import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';

/// Repository interface for reading, streaming live updates, marking read, and
/// removing per-user in-app notifications.
abstract interface class NotificationsRepository {
  /// Loads all notifications belonging to the signed-in user, newest first.
  Future<List<AppNotification>> getNotifications();

  /// Subscribes to live inserts, read-state updates, and deletions for the
  /// signed-in user's notifications.
  Stream<List<AppNotification>> watchNotifications();

  /// Marks a single notification [notificationId] as read if still unread.
  Future<AppNotification> markAsRead(String notificationId);

  /// Marks every currently unread notification as read.
  Future<void> markAllAsRead();

  /// Permanently removes [notificationId].
  Future<void> deleteNotification(String notificationId);
}
