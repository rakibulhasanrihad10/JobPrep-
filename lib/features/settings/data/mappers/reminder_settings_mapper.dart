import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';

/// JSON serialization helpers for `public.user_reminder_settings`.
abstract final class ReminderSettingsMapper {
  /// Converts a Supabase JSON row into a [ReminderSettings] domain entity.
  static ReminderSettings fromJson(Map<String, dynamic> json) {
    final rawDay = json['weekly_review_day'];
    final weeklyReviewDay = rawDay is num ? rawDay.toInt().clamp(0, 6) : 0;
    return ReminderSettings(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      enabled: (json['reminders_enabled'] as bool?) ?? true,
      emailLanguage: ReminderEmailLanguage.fromValue(
        json['email_language'] as String?,
      ),
      deadlineSoonEnabled: (json['deadline_soon_enabled'] as bool?) ?? true,
      examSoonEnabled: (json['exam_soon_enabled'] as bool?) ?? true,
      revisionDueEnabled: (json['revision_due_enabled'] as bool?) ?? true,
      behindScheduleEnabled: (json['behind_schedule_enabled'] as bool?) ?? true,
      weeklyReviewEnabled: (json['weekly_review_enabled'] as bool?) ?? true,
      weeklyReviewDay: weeklyReviewDay,
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
    );
  }

  /// Builds an upsert payload targeting `public.user_reminder_settings`.
  static Map<String, dynamic> toUpsertJson({
    required String userId,
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
  }) {
    return <String, dynamic>{
      'user_id': userId,
      'reminders_enabled': enabled,
      'email_language': emailLanguage.value,
      if (deadlineSoonEnabled != null)
        'deadline_soon_enabled': deadlineSoonEnabled,
      if (examSoonEnabled != null) 'exam_soon_enabled': examSoonEnabled,
      if (revisionDueEnabled != null)
        'revision_due_enabled': revisionDueEnabled,
      if (behindScheduleEnabled != null)
        'behind_schedule_enabled': behindScheduleEnabled,
      if (weeklyReviewEnabled != null)
        'weekly_review_enabled': weeklyReviewEnabled,
      if (weeklyReviewDay != null)
        'weekly_review_day': weeklyReviewDay.clamp(0, 6),
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
