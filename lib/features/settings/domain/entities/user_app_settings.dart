import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show ThemeMode;

/// Persisted user preference model synchronized between `SharedPreferences`
/// and `public.user_settings`.
@immutable
class UserAppSettings {
  /// Creates a [UserAppSettings].
  const UserAppSettings({
    this.userId = '',
    this.displayName,
    this.themeMode = ThemeMode.system,
    this.reduceEffects = false,
    this.localeCode = 'en',
    this.banglaDigits = false,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Minimum and maximum bounds matching database check constraints.
  static const int minFocusMinutes = 5;
  static const int maxFocusMinutes = 180;
  static const int minShortBreakMinutes = 1;
  static const int maxShortBreakMinutes = 60;
  static const int minLongBreakMinutes = 5;
  static const int maxLongBreakMinutes = 90;

  /// Authenticated owner ID (`user_id`), or empty in offline defaults.
  final String userId;

  /// Editable profile display name synced across sessions.
  final String? displayName;

  /// Selected appearance mode (`system`, `light`, or `dark`).
  final ThemeMode themeMode;

  /// Whether blur effects and motion animations are reduced.
  final bool reduceEffects;

  /// Active language code (`en` or `bn`).
  final String localeCode;

  /// Whether numbers render in Bangla script (`০১২৩...`).
  final bool banglaDigits;

  /// Default Pomodoro focus round duration in minutes (`5..180`).
  final int focusMinutes;

  /// Default short break duration in minutes (`1..60`).
  final int shortBreakMinutes;

  /// Default long break duration in minutes (`5..90`).
  final int longBreakMinutes;

  /// Server `updated_at` timestamp when synced with Supabase.
  final DateTime? updatedAt;

  /// Normalized copy with values clamped into valid bounds.
  UserAppSettings normalized() {
    final trimmedName = displayName?.trim();
    return copyWith(
      displayName:
          (trimmedName == null || trimmedName.isEmpty) ? null : trimmedName,
      localeCode: localeCode == 'bn' ? 'bn' : 'en',
      focusMinutes: focusMinutes.clamp(minFocusMinutes, maxFocusMinutes),
      shortBreakMinutes: shortBreakMinutes.clamp(
        minShortBreakMinutes,
        maxShortBreakMinutes,
      ),
      longBreakMinutes: longBreakMinutes.clamp(
        minLongBreakMinutes,
        maxLongBreakMinutes,
      ),
    );
  }

  /// Returns a copy with overridden properties.
  UserAppSettings copyWith({
    String? userId,
    Object? displayName = _unset,
    ThemeMode? themeMode,
    bool? reduceEffects,
    String? localeCode,
    bool? banglaDigits,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    Object? updatedAt = _unset,
  }) {
    return UserAppSettings(
      userId: userId ?? this.userId,
      displayName: identical(displayName, _unset)
          ? this.displayName
          : displayName as String?,
      themeMode: themeMode ?? this.themeMode,
      reduceEffects: reduceEffects ?? this.reduceEffects,
      localeCode: localeCode ?? this.localeCode,
      banglaDigits: banglaDigits ?? this.banglaDigits,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAppSettings &&
        other.userId == userId &&
        other.displayName == displayName &&
        other.themeMode == themeMode &&
        other.reduceEffects == reduceEffects &&
        other.localeCode == localeCode &&
        other.banglaDigits == banglaDigits &&
        other.focusMinutes == focusMinutes &&
        other.shortBreakMinutes == shortBreakMinutes &&
        other.longBreakMinutes == longBreakMinutes &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        userId,
        displayName,
        themeMode,
        reduceEffects,
        localeCode,
        banglaDigits,
        focusMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        updatedAt,
      );
}
