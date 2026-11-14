import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/data/data_source_mode.dart';
import 'package:job_prep/core/local/local_database_provider.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/data/repositories/local_user_settings_repository.dart';
import 'package:job_prep/features/settings/data/repositories/supabase_user_settings_repository.dart';
import 'package:job_prep/features/settings/data/repositories/unconfigured_user_settings_repository.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [UserSettingsRepository] provider syncing settings with
/// `public.user_settings` when configured, or `SharedPreferences` offline.
final Provider<UserSettingsRepository> userSettingsRepositoryProvider =
    Provider<UserSettingsRepository>((ref) {
  final mode = ref.watch(dataSourceModeProvider);
  if (mode == DataSourceMode.local) {
    return LocalUserSettingsRepository(ref.watch(appDatabaseProvider));
  }
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return UnconfiguredUserSettingsRepository(
      ref.watch(sharedPreferencesProvider),
    );
  }
  return SupabaseUserSettingsRepository(client);
});

/// Coordinates user profile display name, appearance, language, and study
/// timer defaults across local `SharedPreferences` and `public.user_settings`.
class UserSettingsNotifier extends AsyncNotifier<UserAppSettings> {
  @override
  Future<UserAppSettings> build() async {
    final user = ref.watch(currentUserProvider);
    final repo = ref.watch(userSettingsRepositoryProvider);
    final local = _readLocalSnapshot(userId: user?.id ?? '');

    if (user == null) return local;

    final remote = await repo.getSettings();
    if (!ref.mounted || remote == null) {
      return local.copyWith(displayName: user.displayName);
    }

    final mergedName = remote.displayName ?? user.displayName;
    final hasCustomRemote = remote.displayName != null ||
        remote.themeMode != ThemeMode.system ||
        remote.reduceEffects ||
        remote.localeCode != 'en' ||
        remote.banglaDigits ||
        remote.focusMinutes != 25 ||
        remote.shortBreakMinutes != 5 ||
        remote.longBreakMinutes != 15;

    if (hasCustomRemote) {
      await _applyRemoteToLocalNotifiers(remote);
      return remote.copyWith(displayName: mergedName).normalized();
    }

    return local.copyWith(displayName: mergedName).normalized();
  }

  /// Updates and syncs profile display name (`auth` metadata and
  /// `user_settings`).
  Future<bool> saveDisplayName(String? rawName) async {
    final trimmed = rawName?.trim();
    final nextName = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    try {
      await ref
          .read(authRepositoryProvider)
          .updateDisplayName(displayName: nextName);
      if (!ref.mounted) return true;
      final current = _currentOrLocal();
      return await _persistAndSync(current.copyWith(displayName: nextName));
    } on Object {
      return false;
    }
  }

  /// Updates theme mode locally and syncs to `public.user_settings`.
  Future<bool> updateThemeMode(ThemeMode mode) async {
    await ref.read(themeModeProvider.notifier).setThemeMode(mode);
    if (!ref.mounted) return true;
    return await _persistAndSync(_currentOrLocal().copyWith(themeMode: mode));
  }

  /// Updates reduce effects locally and syncs to `public.user_settings`.
  Future<bool> updateReduceEffects({required bool enabled}) async {
    await ref
        .read(reduceEffectsProvider.notifier)
        .setReduceEffects(enabled: enabled);
    if (!ref.mounted) return true;
    return await _persistAndSync(
      _currentOrLocal().copyWith(reduceEffects: enabled),
    );
  }

  /// Updates locale locally and syncs to `public.user_settings`.
  Future<bool> updateLocale(Locale locale) async {
    await ref.read(localeProvider.notifier).setLocale(locale);
    if (!ref.mounted) return true;
    final code = locale.languageCode == 'bn' ? 'bn' : 'en';
    return await _persistAndSync(_currentOrLocal().copyWith(localeCode: code));
  }

  /// Updates Bangla digits toggle locally and syncs to `public.user_settings`.
  Future<bool> updateBanglaDigits({required bool enabled}) async {
    await ref
        .read(useBanglaDigitsProvider.notifier)
        .setUseBanglaDigits(enabled: enabled);
    if (!ref.mounted) return true;
    return await _persistAndSync(
      _currentOrLocal().copyWith(banglaDigits: enabled),
    );
  }

  /// Updates default study timer focus & break lengths and syncs to
  /// `public.user_settings`.
  Future<bool> updateStudyTimerDefaults({
    required int focusMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
  }) async {
    final nextSettings = _currentOrLocal()
        .copyWith(
          focusMinutes: focusMinutes,
          shortBreakMinutes: shortBreakMinutes,
          longBreakMinutes: longBreakMinutes,
        )
        .normalized();

    await ref.read(pomodoroConfigProvider.notifier).updateConfig(
          PomodoroConfig(
            focusMinutes: nextSettings.focusMinutes,
            shortBreakMinutes: nextSettings.shortBreakMinutes,
            longBreakMinutes: nextSettings.longBreakMinutes,
          ),
        );
    if (!ref.mounted) return true;
    return await _persistAndSync(nextSettings);
  }

  UserAppSettings _readLocalSnapshot({String? userId}) {
    final user = ref.read(currentUserProvider);
    final pomodoro = ref.read(pomodoroConfigProvider);
    final locale = ref.read(localeProvider);
    return UserAppSettings(
      userId: userId ?? user?.id ?? '',
      displayName: user?.displayName,
      themeMode: ref.read(themeModeProvider),
      reduceEffects: ref.read(reduceEffectsProvider),
      localeCode: locale.languageCode == 'bn' ? 'bn' : 'en',
      banglaDigits: ref.read(useBanglaDigitsProvider),
      focusMinutes: pomodoro.focusMinutes,
      shortBreakMinutes: pomodoro.shortBreakMinutes,
      longBreakMinutes: pomodoro.longBreakMinutes,
    ).normalized();
  }

  UserAppSettings _currentOrLocal() {
    final cached = state.asData?.value;
    final local = _readLocalSnapshot();
    if (cached == null) return local;
    return local.copyWith(
      displayName: cached.displayName ?? local.displayName,
      updatedAt: cached.updatedAt,
    );
  }

  Future<void> _applyRemoteToLocalNotifiers(UserAppSettings remote) async {
    if (ref.read(themeModeProvider) != remote.themeMode) {
      await ref.read(themeModeProvider.notifier).setThemeMode(remote.themeMode);
    }
    if (!ref.mounted) return;
    if (ref.read(reduceEffectsProvider) != remote.reduceEffects) {
      await ref
          .read(reduceEffectsProvider.notifier)
          .setReduceEffects(enabled: remote.reduceEffects);
    }
    if (!ref.mounted) return;
    if (ref.read(localeProvider).languageCode != remote.localeCode) {
      await ref
          .read(localeProvider.notifier)
          .setLocale(Locale(remote.localeCode));
    }
    if (!ref.mounted) return;
    if (ref.read(useBanglaDigitsProvider) != remote.banglaDigits) {
      await ref
          .read(useBanglaDigitsProvider.notifier)
          .setUseBanglaDigits(enabled: remote.banglaDigits);
    }
    if (!ref.mounted) return;
    final currentTimer = ref.read(pomodoroConfigProvider);
    if (currentTimer.focusMinutes != remote.focusMinutes ||
        currentTimer.shortBreakMinutes != remote.shortBreakMinutes ||
        currentTimer.longBreakMinutes != remote.longBreakMinutes) {
      await ref.read(pomodoroConfigProvider.notifier).updateConfig(
            PomodoroConfig(
              focusMinutes: remote.focusMinutes,
              shortBreakMinutes: remote.shortBreakMinutes,
              longBreakMinutes: remote.longBreakMinutes,
            ),
          );
    }
  }

  Future<bool> _persistAndSync(UserAppSettings next) async {
    final normalized = next.normalized();
    state = AsyncData<UserAppSettings>(normalized);
    if (ref.read(currentUserProvider) == null) return true;
    try {
      final saved =
          await ref.read(userSettingsRepositoryProvider).upsertSettings(
                normalized,
              );
      if (ref.mounted) {
        state = AsyncData<UserAppSettings>(saved);
      }
      return true;
    } on Object {
      return false;
    }
  }
}

/// Provides synced [UserAppSettings] for Profile, Appearance, Language & Study.
final AsyncNotifierProvider<UserSettingsNotifier, UserAppSettings>
    userSettingsProvider =
    AsyncNotifierProvider<UserSettingsNotifier, UserAppSettings>(
  UserSettingsNotifier.new,
  retry: _noRetry,
);
