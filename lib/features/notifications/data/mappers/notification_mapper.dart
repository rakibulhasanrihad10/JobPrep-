import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/notifications/domain/entities/notification_type.dart';

/// Maps Supabase JSON rows for `public.notifications` into [AppNotification].
abstract final class NotificationMapper {
  /// Explicit column list selected for notification reads and mutations.
  static const String selectColumns =
      'id, user_id, type, message_key, params, route, dedupe_key, '
      'created_at, read_at';

  /// Deserializes a row from `public.notifications` into [AppNotification].
  static AppNotification fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'];
    final parsedParams = rawParams is Map
        ? Map<String, Object?>.unmodifiable(
            rawParams.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          )
        : const <String, Object?>{};

    final createdRaw = json['created_at'] as String?;
    final parsedCreated =
        createdRaw != null ? DateTime.tryParse(createdRaw) : null;
    final createdAt =
        parsedCreated ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final readRaw = json['read_at'] as String?;

    return AppNotification(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      type: AppNotificationType.fromValue(json['type'] as String?),
      messageKey: (json['message_key'] as String?) ?? '',
      params: parsedParams,
      route: (json['route'] as String?) ?? '/today',
      dedupeKey: (json['dedupe_key'] as String?) ?? '',
      createdAt: createdAt.toUtc(),
      readAt: readRaw == null ? null : DateTime.tryParse(readRaw)?.toUtc(),
    );
  }
}
