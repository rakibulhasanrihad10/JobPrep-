import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';

/// Persisted per-user in-app notification carrying a localization message key,
/// structured parameters, and target route instead of hardcoded copy.
@immutable
class AppNotification {
  /// Creates an [AppNotification].
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.messageKey,
    required this.route,
    required this.dedupeKey,
    required this.createdAt,
    this.params = const <String, Object?>{},
    this.readAt,
  });

  /// Primary UUID from `public.notifications`.
  final String id;

  /// Owner user UUID matching `auth.uid()`.
  final String userId;

  /// Semantic category of this notification.
  final AppNotificationType type;

  /// ARB localization key resolved dynamically at display time.
  final String messageKey;

  /// Structured JSON parameters formatted in the active locale.
  final Map<String, Object?> params;

  /// Destination `GoRouter` path opened when tapping this notification.
  final String route;

  /// Unique per-user deduplication key enforcing at-most-once dispatch.
  final String dedupeKey;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Timestamp when marked as read, or `null` while unread.
  final DateTime? readAt;

  /// Whether this notification has not yet been acknowledged.
  bool get isUnread => readAt == null;

  /// Whether this notification has already been marked as read.
  bool get isRead => readAt != null;

  /// Returns a copy of this notification with updated fields.
  AppNotification copyWith({
    String? id,
    String? userId,
    AppNotificationType? type,
    String? messageKey,
    Map<String, Object?>? params,
    String? route,
    String? dedupeKey,
    DateTime? createdAt,
    DateTime? readAt,
    bool clearReadAt = false,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      messageKey: messageKey ?? this.messageKey,
      params: params ?? this.params,
      route: route ?? this.route,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      createdAt: createdAt ?? this.createdAt,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppNotification) return false;
    return id == other.id &&
        userId == other.userId &&
        type == other.type &&
        messageKey == other.messageKey &&
        _mapsEqual(params, other.params) &&
        route == other.route &&
        dedupeKey == other.dedupeKey &&
        createdAt == other.createdAt &&
        readAt == other.readAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        type,
        messageKey,
        Object.hashAllUnordered(
          params.entries.map((entry) => Object.hash(entry.key, entry.value)),
        ),
        route,
        dedupeKey,
        createdAt,
        readAt,
      );

  static bool _mapsEqual(
    Map<String, Object?> a,
    Map<String, Object?> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}
