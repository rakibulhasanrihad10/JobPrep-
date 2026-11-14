import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';

/// Local Drift SQLite implementation of [UserSettingsRepository].
class LocalUserSettingsRepository implements UserSettingsRepository {
  /// Creates a [LocalUserSettingsRepository].
  const LocalUserSettingsRepository(this._db);

  final AppDatabase _db;

  static const String _localSettingsId = 'local_user_settings';

  @override
  Future<UserAppSettings?> getSettings() async {
    final row = await (_db.select(_db.localUserSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapRow(row);
  }

  @override
  Future<UserAppSettings> upsertSettings(UserAppSettings settings) async {
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.localUserSettings)
          ..where((t) => t.id.equals(_localSettingsId)))
        .getSingleOrNull();

    final themeModeStr = switch (settings.themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    final companion = LocalUserSettingsCompanion(
      id: const Value(_localSettingsId),
      displayName: Value(settings.displayName?.trim()),
      themeMode: Value(themeModeStr),
      reduceEffects: Value(settings.reduceEffects),
      localeCode: Value(settings.localeCode),
      banglaDigits: Value(settings.banglaDigits),
      focusMinutes: Value(settings.focusMinutes),
      shortBreakMinutes: Value(settings.shortBreakMinutes),
      longBreakMinutes: Value(settings.longBreakMinutes),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _db.into(_db.localUserSettings).insertOnConflictUpdate(companion);
    return settings.copyWith(
      userId: _localSettingsId,
      updatedAt: now,
    );
  }

  UserAppSettings _mapRow(LocalUserSetting row) {
    final mode = switch (row.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return UserAppSettings(
      userId: row.id,
      displayName: row.displayName,
      themeMode: mode,
      reduceEffects: row.reduceEffects,
      localeCode: row.localeCode,
      banglaDigits: row.banglaDigits,
      focusMinutes: row.focusMinutes,
      shortBreakMinutes: row.shortBreakMinutes,
      longBreakMinutes: row.longBreakMinutes,
      updatedAt: row.updatedAt,
    );
  }
}
