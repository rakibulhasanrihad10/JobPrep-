import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';

/// Persistence interface syncing user preferences (`public.user_settings`)
/// alongside local storage.
abstract interface class UserSettingsRepository {
  /// Loads the current user's synced settings row, or `null` if no settings
  /// record has been written yet.
  Future<UserAppSettings?> getSettings();

  /// Inserts or updates the current user's [settings] row cleanly.
  Future<UserAppSettings> upsertSettings(UserAppSettings settings);
}
