import 'package:job_prep/features/settings/data/mappers/reminder_error_mapper.dart';
import 'package:job_prep/features/settings/data/mappers/reminder_settings_mapper.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/domain/errors/reminder_failure.dart';
import 'package:job_prep/features/settings/domain/repositories/reminder_settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [ReminderSettingsRepository].
class SupabaseReminderSettingsRepository implements ReminderSettingsRepository {
  /// Creates a [SupabaseReminderSettingsRepository].
  const SupabaseReminderSettingsRepository(this._client);

  static const String _table = 'user_reminder_settings';

  final supabase.SupabaseClient _client;

  @override
  Future<ReminderSettings> getSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return const ReminderSettings();
    }

    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        return ReminderSettings(userId: userId);
      }
      return ReminderSettingsMapper.fromJson(row);
    } on Object catch (error) {
      throw ReminderErrorMapper.map(error);
    }
  }

  @override
  Future<ReminderSettings> saveSettings({
    required bool enabled,
    required ReminderEmailLanguage emailLanguage,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      throw const ReminderPermissionFailure(code: 'unauthenticated');
    }

    try {
      final payload = ReminderSettingsMapper.toUpsertJson(
        userId: userId,
        enabled: enabled,
        emailLanguage: emailLanguage,
      );

      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'user_id')
          .select()
          .single();

      return ReminderSettingsMapper.fromJson(row);
    } on Object catch (error) {
      throw ReminderErrorMapper.map(error);
    }
  }
}
