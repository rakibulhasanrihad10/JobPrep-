import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist selected locale code in [SharedPreferences].
const String kLocaleStorageKey = 'jobprep_locale';

/// Key used to persist Bangla digits preference in [SharedPreferences].
const String kUseBanglaDigitsStorageKey = 'jobprep_use_bangla_digits';

/// Supported application locales.
const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('bn'),
];

/// Riverpod notifier managing active application [Locale].
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(kLocaleStorageKey);

    if (savedCode == 'bn') return const Locale('bn');
    if (savedCode == 'en') return const Locale('en');

    // Default to device language if it is Bangla, otherwise English.
    final deviceLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (deviceLanguage == 'bn') {
      return const Locale('bn');
    }
    return const Locale('en');
  }

  /// Sets and persists the selected [Locale].
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(kLocaleStorageKey, locale.languageCode);
  }
}

/// Provider for active [Locale].
final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Riverpod notifier managing preference to display numbers in Bangla digits.
class BanglaDigitsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(kUseBanglaDigitsStorageKey) ?? false;
  }

  /// Sets and persists preference for Bangla numerals.
  Future<void> setUseBanglaDigits({required bool enabled}) async {
    state = enabled;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(kUseBanglaDigitsStorageKey, enabled);
  }

  /// Toggles preference for Bangla numerals.
  Future<void> toggle() async {
    await setUseBanglaDigits(enabled: !state);
  }
}

/// Provider for Bangla digits preference.
final useBanglaDigitsProvider =
    NotifierProvider<BanglaDigitsNotifier, bool>(BanglaDigitsNotifier.new);
