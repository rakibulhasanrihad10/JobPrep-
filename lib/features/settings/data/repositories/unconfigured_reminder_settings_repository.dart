import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/domain/errors/reminder_failure.dart';
import 'package:job_prep/features/settings/domain/repositories/reminder_settings_repository.dart';

/// Safe fallback [ReminderSettingsRepository] used when Supabase credentials
/// are not passed via `--dart-define`.
class UnconfiguredReminderSettingsRepository
    implements ReminderSettingsRepository {
  /// Creates an [UnconfiguredReminderSettingsRepository].
  const UnconfiguredReminderSettingsRepository();

  static const _notConfiguredError = UnknownReminderFailure(
    code: 'supabase_not_configured',
    message: 'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
  );

  @override
  Future<ReminderSettings> getSettings() async => const ReminderSettings();

  @override
  Future<ReminderSettings> saveSettings({
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
  }) =>
      Future.error(_notConfiguredError);
}
