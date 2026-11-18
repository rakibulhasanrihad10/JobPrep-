import 'package:flutter/material.dart' show ThemeMode;
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';

/// Serialization mapper between `public.user_settings` rows and
/// [UserAppSettings].
abstract final class UserSettingsMapper {
  /// Parses a [UserAppSettings] row returned from PostgREST or local cache.
  static UserAppSettings fromJson(Map<String, dynamic> json) {
    final rawName = json['display_name'] as String?;
    final trimmedName = rawName?.trim();
    final updatedRaw = json['updated_at'] as String?;
    return UserAppSettings(
      userId: (json['user_id'] as String?) ?? '',
      displayName:
          (trimmedName == null || trimmedName.isEmpty) ? null : trimmedName,
      themeMode: parseThemeMode(json['theme_mode'] as String?),
      reduceEffects: (json['reduce_effects'] as bool?) ?? false,
      localeCode: (json['locale_code'] as String?) == 'bn' ? 'bn' : 'en',
      banglaDigits: (json['bangla_digits'] as bool?) ?? false,
      focusMinutes: (json['focus_minutes'] as num?)?.toInt() ?? 25,
      shortBreakMinutes: (json['short_break_minutes'] as num?)?.toInt() ?? 5,
      longBreakMinutes: (json['long_break_minutes'] as num?)?.toInt() ?? 15,
      updatedAt: updatedRaw == null ? null : DateTime.tryParse(updatedRaw),
    ).normalized();
  }

  /// Builds an upsert payload targeting `public.user_settings`.
  static Map<String, dynamic> toUpsertJson({
    required String userId,
    required UserAppSettings settings,
  }) {
    final normalized = settings.normalized();
    return <String, dynamic>{
      'user_id': userId,
      'display_name': normalized.displayName,
      'theme_mode': normalized.themeMode.name,
      'reduce_effects': normalized.reduceEffects,
      'locale_code': normalized.localeCode,
      'bangla_digits': normalized.banglaDigits,
      'focus_minutes': normalized.focusMinutes,
      'short_break_minutes': normalized.shortBreakMinutes,
      'long_break_minutes': normalized.longBreakMinutes,
    };
  }

  /// Parses persisted theme mode string cleanly, defaulting to system.
  static ThemeMode parseThemeMode(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
