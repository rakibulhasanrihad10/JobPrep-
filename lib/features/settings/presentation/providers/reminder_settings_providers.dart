import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/settings/data/repositories/supabase_reminder_settings_repository.dart';
import 'package:job_prep/features/settings/data/repositories/unconfigured_reminder_settings_repository.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/domain/repositories/reminder_settings_repository.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [ReminderSettingsRepository] provider.
final Provider<ReminderSettingsRepository> reminderSettingsRepositoryProvider =
    Provider<ReminderSettingsRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredReminderSettingsRepository();
  }
  return SupabaseReminderSettingsRepository(client);
});

/// Reactive async notifier managing the signed-in user's daily reminder
/// opt-in toggle and email language preference.
class ReminderSettingsNotifier extends AsyncNotifier<ReminderSettings> {
  @override
  Future<ReminderSettings> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(reminderSettingsRepositoryProvider).getSettings();
  }

  /// Refreshes reminder settings from the active repository.
  Future<ReminderSettings> refresh() {
    ref.invalidateSelf();
    return future;
  }

  /// Persists whether daily email reminders are [enabled].
  Future<bool> setEnabled({required bool enabled}) {
    return _update(enabled: enabled);
  }

  /// Persists the preferred [emailLanguage] (`en` or `bn`) for reminder emails.
  Future<bool> setEmailLanguage(ReminderEmailLanguage emailLanguage) {
    return _update(emailLanguage: emailLanguage);
  }

  /// Updates per-type in-app notification preferences and/or the preferred
  /// weekly review day (`0` = Sunday .. `6` = Saturday).
  Future<bool> setNotificationPreferences({
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
  }) {
    return _update(
      deadlineSoonEnabled: deadlineSoonEnabled,
      examSoonEnabled: examSoonEnabled,
      revisionDueEnabled: revisionDueEnabled,
      behindScheduleEnabled: behindScheduleEnabled,
      weeklyReviewEnabled: weeklyReviewEnabled,
      weeklyReviewDay: weeklyReviewDay,
    );
  }

  Future<bool> _update({
    bool? enabled,
    ReminderEmailLanguage? emailLanguage,
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
  }) async {
    final current = state.asData?.value ?? const ReminderSettings();
    final next = current.copyWith(
      enabled: enabled,
      emailLanguage: emailLanguage,
      deadlineSoonEnabled: deadlineSoonEnabled,
      examSoonEnabled: examSoonEnabled,
      revisionDueEnabled: revisionDueEnabled,
      behindScheduleEnabled: behindScheduleEnabled,
      weeklyReviewEnabled: weeklyReviewEnabled,
      weeklyReviewDay: weeklyReviewDay,
    );

    if (next == current && state.hasValue) {
      return true;
    }

    state = AsyncData<ReminderSettings>(next);

    try {
      final saved =
          await ref.read(reminderSettingsRepositoryProvider).saveSettings(
                enabled: next.enabled,
                emailLanguage: next.emailLanguage,
                deadlineSoonEnabled: next.deadlineSoonEnabled,
                examSoonEnabled: next.examSoonEnabled,
                revisionDueEnabled: next.revisionDueEnabled,
                behindScheduleEnabled: next.behindScheduleEnabled,
                weeklyReviewEnabled: next.weeklyReviewEnabled,
                weeklyReviewDay: next.weeklyReviewDay,
              );
      if (ref.mounted) {
        state = AsyncData<ReminderSettings>(saved);
      }
      return true;
    } on Object {
      if (ref.mounted) {
        state = AsyncData<ReminderSettings>(current);
      }
      return false;
    }
  }
}

/// Provides the signed-in user's [ReminderSettings].
final AsyncNotifierProvider<ReminderSettingsNotifier, ReminderSettings>
    reminderSettingsProvider =
    AsyncNotifierProvider<ReminderSettingsNotifier, ReminderSettings>(
  ReminderSettingsNotifier.new,
  retry: _noRetry,
);
