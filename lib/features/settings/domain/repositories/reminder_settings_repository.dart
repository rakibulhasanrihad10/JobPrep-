import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';

/// Repository interface for reading and persisting per-user email reminder
/// preferences.
abstract interface class ReminderSettingsRepository {
  /// Loads the active user's reminder preferences, returning defaults when
  /// no row has been persisted yet.
  Future<ReminderSettings> getSettings();

  /// Persists the active user's email and in-app notification preferences.
  Future<ReminderSettings> saveSettings({
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
  });
}
