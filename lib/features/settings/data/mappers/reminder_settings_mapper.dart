import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';

/// JSON serialization helpers for `public.user_reminder_settings`.
abstract final class ReminderSettingsMapper {
  /// Converts a Supabase JSON row into a [ReminderSettings] domain entity.
  static ReminderSettings fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      enabled: (json['reminders_enabled'] as bool?) ?? true,
      emailLanguage: ReminderEmailLanguage.fromValue(
        json['email_language'] as String?,
      ),
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
    );
  }

  /// Builds an upsert payload targeting `public.user_reminder_settings`.
  static Map<String, dynamic> toUpsertJson({
    required String userId,
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
  }) {
    return <String, dynamic>{
      'user_id': userId,
      'reminders_enabled': enabled,
      'email_language': emailLanguage.value,
    };
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim());
    }
    return null;
  }
}
