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

  Future<bool> _update({
    bool? enabled,
    ReminderEmailLanguage? emailLanguage,
  }) async {
    final current = state.asData?.value ?? const ReminderSettings();
    final nextEnabled = enabled ?? current.enabled;
    final nextLanguage = emailLanguage ?? current.emailLanguage;

    if (current.enabled == nextEnabled &&
        current.emailLanguage == nextLanguage &&
        state.hasValue) {
      return true;
    }

    final optimistic = current.copyWith(
      enabled: nextEnabled,
      emailLanguage: nextLanguage,
    );
    state = AsyncData<ReminderSettings>(optimistic);

    try {
      final saved =
          await ref.read(reminderSettingsRepositoryProvider).saveSettings(
                enabled: nextEnabled,
                emailLanguage: nextLanguage,
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
