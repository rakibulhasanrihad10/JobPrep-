import 'dart:convert';

import 'package:job_prep/features/settings/data/mappers/user_settings_mapper.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key storing synced user settings offline / without Supabase.
const String kUserAppSettingsCacheKey = 'jobprep_user_app_settings_v1';

/// Offline/unconfigured [UserSettingsRepository] persisting synced user settings
/// into [SharedPreferences] when Supabase is not configured.
class UnconfiguredUserSettingsRepository implements UserSettingsRepository {
  /// Creates an [UnconfiguredUserSettingsRepository].
  const UnconfiguredUserSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UserAppSettings?> getSettings() async {
    final raw = _prefs.getString(kUserAppSettingsCacheKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<Object?, Object?>) return null;
      return UserSettingsMapper.fromJson(Map<String, dynamic>.from(decoded));
    } on Object {
      return null;
    }
  }

  @override
  Future<UserAppSettings> upsertSettings(UserAppSettings settings) async {
    final normalized = settings.normalized();
    final json = <String, dynamic>{
      ...UserSettingsMapper.toUpsertJson(
        userId: normalized.userId,
        settings: normalized,
      ),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _prefs.setString(kUserAppSettingsCacheKey, jsonEncode(json));
    return UserSettingsMapper.fromJson(json);
  }
}
