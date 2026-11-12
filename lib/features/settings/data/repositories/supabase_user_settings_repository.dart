import 'package:job_prep/features/settings/data/mappers/user_settings_error_mapper.dart';
import 'package:job_prep/features/settings/data/mappers/user_settings_mapper.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/domain/errors/settings_failure.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [UserSettingsRepository].
class SupabaseUserSettingsRepository implements UserSettingsRepository {
  /// Creates a [SupabaseUserSettingsRepository].
  const SupabaseUserSettingsRepository(this._client);

  static const String _table = 'user_settings';
  static const String _selectColumns =
      'user_id, display_name, theme_mode, reduce_effects, locale_code, '
      'bangla_digits, focus_minutes, short_break_minutes, long_break_minutes, '
      'updated_at';

  final supabase.SupabaseClient _client;

  @override
  Future<UserAppSettings?> getSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) return null;

    try {
      final row = await _client
          .from(_table)
          .select(_selectColumns)
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) return null;
      return UserSettingsMapper.fromJson(row);
    } on Object catch (error) {
      throw UserSettingsErrorMapper.map(error);
    }
  }

  @override
  Future<UserAppSettings> upsertSettings(UserAppSettings settings) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      throw const SettingsPermissionFailure(code: 'unauthenticated');
    }

    try {
      final payload = UserSettingsMapper.toUpsertJson(
        userId: userId,
        settings: settings,
      );
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'user_id')
          .select(_selectColumns)
          .single();

      return UserSettingsMapper.fromJson(row);
    } on Object catch (error) {
      throw UserSettingsErrorMapper.map(error);
    }
  }
}
