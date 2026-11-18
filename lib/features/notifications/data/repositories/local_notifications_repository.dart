import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';
import 'package:job_prep/features/notifications/domain/errors/notification_failure.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [NotificationsRepository].
class LocalNotificationsRepository implements NotificationsRepository {
  /// Creates a [LocalNotificationsRepository].
  const LocalNotificationsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final query = _db.select(_db.localNotifications)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    final query = _db.select(_db.localNotifications)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => List.unmodifiable(rows.map(_mapRow)));
  }

  @override
  Future<AppNotification> markAsRead(String notificationId) async {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) {
      throw const NotificationValidationFailure(
        code: 'missing_id',
        message: 'Notification ID cannot be empty.',
      );
    }

    final existing = await (_db.select(_db.localNotifications)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const NotificationValidationFailure(
        code: 'not_found',
        message: 'Notification not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final updated = existing.toCompanion(true).copyWith(
          readAt: Value(now),
        );
    await _db.update(_db.localNotifications).replace(updated);

    return _mapRow(existing.copyWith(readAt: Value(now)));
  }

  @override
  Future<void> markAllAsRead() async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.localNotifications)..where((t) => t.readAt.isNull()))
        .write(LocalNotificationsCompanion(readAt: Value(now)));
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final trimmedId = notificationId.trim();
    if (trimmedId.isEmpty) {
      throw const NotificationValidationFailure(
        code: 'missing_id',
        message: 'Notification ID cannot be empty.',
      );
    }

    await (_db.delete(_db.localNotifications)
          ..where((t) => t.id.equals(trimmedId)))
        .go();
  }

  @override
  Future<AppNotification> insertNotification(
    AppNotification notification,
  ) async {
    final dedupeKey = notification.dedupeKey.trim();
    if (dedupeKey.isNotEmpty) {
      final existing = await (_db.select(_db.localNotifications)
            ..where((t) => t.dedupeKey.equals(dedupeKey)))
          .getSingleOrNull();
      if (existing != null) {
        return _mapRow(existing);
      }
    }

    final id = notification.id.trim().isEmpty
        ? const Uuid().v4()
        : notification.id.trim();
    final companion = LocalNotificationsCompanion(
      id: Value(id),
      type: Value(notification.type.value),
      messageKey: Value(notification.messageKey),
      params: Value(jsonEncode(notification.params)),
      route: Value(notification.route),
      dedupeKey: Value(dedupeKey),
      createdAt: Value(notification.createdAt),
      readAt: Value(notification.readAt),
    );

    await _db.into(_db.localNotifications).insertOnConflictUpdate(companion);
    return notification.copyWith(id: id, createdAt: notification.createdAt);
  }

  AppNotification _mapRow(LocalNotification row) {
    Map<String, Object?> params;
    try {
      final decoded = jsonDecode(row.params);
      if (decoded is Map) {
        params = Map<String, Object?>.from(decoded);
      } else {
        params = const <String, Object?>{};
      }
    } on Object catch (_) {
      params = const <String, Object?>{};
    }

    return AppNotification(
      id: row.id,
      userId: '',
      type: AppNotificationType.fromValue(row.type),
      messageKey: row.messageKey,
      params: params,
      route: row.route,
      dedupeKey: row.dedupeKey,
      createdAt: row.createdAt,
      readAt: row.readAt,
    );
  }
}
