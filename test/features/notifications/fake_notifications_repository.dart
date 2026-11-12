import 'dart:async';

import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/errors/notification_failure.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';

/// In-memory fake [NotificationsRepository] supporting simulated Realtime
/// pushes and polling reads for unit and widget tests.
class FakeNotificationsRepository implements NotificationsRepository {
  /// Creates a [FakeNotificationsRepository].
  FakeNotificationsRepository({
    List<AppNotification> initialItems = const <AppNotification>[],
    DateTime Function()? clock,
  })  : _items = List<AppNotification>.of(initialItems),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 15, 8));

  final List<AppNotification> _items;
  final DateTime Function() _clock;
  final StreamController<List<AppNotification>> _controller =
      StreamController<List<AppNotification>>.broadcast();

  /// Optional failure thrown on the next repository call when non-null.
  NotificationFailure? nextError;

  /// Number of `getNotifications()` reads executed.
  int getCalls = 0;

  /// Number of `markAllAsRead()` invocations succeeded.
  int markAllReadCalls = 0;

  /// Current stored notifications ordered newest first.
  List<AppNotification> get currentItems {
    final copy = List<AppNotification>.of(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<AppNotification>.unmodifiable(copy);
  }

  /// Pushes a new notification as if inserted remotely via Edge Function
  /// Realtime sync.
  void emitRemoteInsert(AppNotification notification) {
    _items.removeWhere((item) => item.id == notification.id);
    _items.insert(0, notification);
    if (!_controller.isClosed) {
      _controller.add(currentItems);
    }
  }

  /// Stages an incoming notification without broadcasting over Realtime (to
  /// verify polling fallback recovery).
  void stageRemoteWithoutRealtime(AppNotification notification) {
    _items.removeWhere((item) => item.id == notification.id);
    _items.insert(0, notification);
  }

  /// Disposes the underlying broadcast stream controller.
  Future<void> dispose() => _controller.close();

  @override
  Future<List<AppNotification>> getNotifications() async {
    _consumeError();
    getCalls += 1;
    return currentItems;
  }

  @override
  Stream<List<AppNotification>> watchNotifications() => _controller.stream;

  @override
  Future<AppNotification> markAsRead(String notificationId) async {
    _consumeError();
    final idx = _items.indexWhere((item) => item.id == notificationId);
    if (idx < 0) {
      throw const UnknownNotificationFailure(
        code: 'not_found',
        message: 'Notification not found.',
      );
    }
    final updated = _items[idx].copyWith(readAt: _clock().toUtc());
    _items[idx] = updated;
    if (!_controller.isClosed) {
      _controller.add(currentItems);
    }
    return updated;
  }

  @override
  Future<void> markAllAsRead() async {
    _consumeError();
    markAllReadCalls += 1;
    final now = _clock().toUtc();
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isUnread) {
        _items[i] = _items[i].copyWith(readAt: now);
      }
    }
    if (!_controller.isClosed) {
      _controller.add(currentItems);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _consumeError();
    _items.removeWhere((item) => item.id == notificationId);
    if (!_controller.isClosed) {
      _controller.add(currentItems);
    }
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
