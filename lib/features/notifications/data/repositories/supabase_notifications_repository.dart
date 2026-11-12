import 'dart:async';

import 'package:job_prep/features/notifications/data/mappers/notification_error_mapper.dart';
import 'package:job_prep/features/notifications/data/mappers/notification_mapper.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/errors/notification_failure.dart';
import 'package:job_prep/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST + Realtime implementation of [NotificationsRepository].
class SupabaseNotificationsRepository implements NotificationsRepository {
  /// Creates a [SupabaseNotificationsRepository].
  const SupabaseNotificationsRepository(this._client);

  final supabase.SupabaseClient _client;

  static const String _table = 'notifications';

  @override
  Future<List<AppNotification>> getNotifications() async {
    final userId = _requireUserId();
    try {
      final rows = await _client
          .from(_table)
          .select(NotificationMapper.selectColumns)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map(
            (row) => NotificationMapper.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false);
    } catch (error) {
      throw NotificationErrorMapper.map(error);
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return Stream<List<AppNotification>>.value(const <AppNotification>[]);
    }

    late final StreamController<List<AppNotification>> controller;
    supabase.RealtimeChannel? channel;
    var closed = false;

    Future<void> emitLatest() async {
      if (closed || controller.isClosed) return;
      try {
        final latest = await getNotifications();
        if (!closed && !controller.isClosed) {
          controller.add(latest);
        }
      } on Object catch (error, stackTrace) {
        if (!closed && !controller.isClosed) {
          controller.addError(NotificationErrorMapper.map(error), stackTrace);
        }
      }
    }

    controller = StreamController<List<AppNotification>>(
      onListen: () {
        unawaited(emitLatest());
        channel = _client
            .channel('public:notifications:$userId')
            .onPostgresChanges(
              event: supabase.PostgresChangeEvent.all,
              schema: 'public',
              table: _table,
              filter: supabase.PostgresChangeFilter(
                type: supabase.PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (_) => unawaited(emitLatest()),
            )
            .subscribe();
      },
      onCancel: () {
        closed = true;
        final activeChannel = channel;
        if (activeChannel != null) {
          unawaited(_client.removeChannel(activeChannel));
        }
        return controller.close();
      },
    );

    return controller.stream;
  }

  @override
  Future<AppNotification> markAsRead(String notificationId) async {
    final userId = _requireUserId();
    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final row = await _client
          .from(_table)
          .update({'read_at': nowIso})
          .eq('id', notificationId)
          .eq('user_id', userId)
          .select(NotificationMapper.selectColumns)
          .single();

      return NotificationMapper.fromJson(Map<String, dynamic>.from(row));
    } catch (error) {
      throw NotificationErrorMapper.map(error);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _requireUserId();
    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await _client
          .from(_table)
          .update({'read_at': nowIso})
          .eq('user_id', userId)
          .isFilter('read_at', null);
    } catch (error) {
      throw NotificationErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final userId = _requireUserId();
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (error) {
      throw NotificationErrorMapper.map(error);
    }
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const NotificationPermissionFailure(
        code: 'unauthenticated',
        message: 'Sign in required to access notifications.',
      );
    }
    return userId;
  }
}
