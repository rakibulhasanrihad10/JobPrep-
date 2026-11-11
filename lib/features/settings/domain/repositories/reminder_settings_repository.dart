import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';

/// Repository interface for reading and persisting per-user email reminder
/// preferences.
abstract interface class ReminderSettingsRepository {
  /// Loads the active user's reminder preferences, returning defaults when
  /// no row has been persisted yet.
  Future<ReminderSettings> getSettings();

  /// Persists the active user's reminder opt-in toggle and email language.
  Future<ReminderSettings> saveSettings({
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
  });
}
