import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:job_prep/core/storage/preferences_provider.dart';

/// Key used to persist theme mode in [SharedPreferences].
const String kThemeModeStorageKey = 'jobprep_theme_mode';

/// Riverpod notifier managing [ThemeMode] with persistent storage.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(kThemeModeStorageKey);
    if (saved == 'light') return ThemeMode.light;
    if (saved == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  /// Updates and persists the selected [ThemeMode].
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(kThemeModeStorageKey, 'light');
      case ThemeMode.dark:
        await prefs.setString(kThemeModeStorageKey, 'dark');
      case ThemeMode.system:
        await prefs.remove(kThemeModeStorageKey);
    }
  }
}

/// Provider for the active [ThemeMode].
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
