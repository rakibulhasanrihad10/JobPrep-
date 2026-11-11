import 'package:job_prep/features/onboarding/data/mappers/onboarding_error_mapper.dart';
import 'package:job_prep/features/onboarding/data/mappers/onboarding_settings_mapper.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/domain/errors/onboarding_failure.dart';
import 'package:job_prep/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [OnboardingRepository] backed by
/// `public.user_settings`.
class SupabaseOnboardingRepository implements OnboardingRepository {
  /// Creates a [SupabaseOnboardingRepository].
  const SupabaseOnboardingRepository(this._client);

  final supabase.SupabaseClient _client;

  static const String _table = 'user_settings';

  @override
  Future<OnboardingStatus> getStatus() async {
    final userId = _requireUserId();
    try {
      final row = await _client
          .from(_table)
          .select(OnboardingSettingsMapper.selectColumns)
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        return OnboardingStatus(userId: userId);
      }
      return OnboardingSettingsMapper.fromJson(Map<String, dynamic>.from(row));
    } on Object catch (error) {
      throw OnboardingErrorMapper.map(error);
    }
  }

  @override
  Future<OnboardingStatus> saveProgress({
    required int step,
    required OnboardingDraft draft,
  }) async {
    final userId = _requireUserId();
    try {
      final payload = OnboardingSettingsMapper.toProgressUpsertJson(
        userId: userId,
        step: step,
        draft: draft,
      );
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'user_id')
          .select(OnboardingSettingsMapper.selectColumns)
          .single();

      return OnboardingSettingsMapper.fromJson(Map<String, dynamic>.from(row));
    } on Object catch (error) {
      throw OnboardingErrorMapper.map(error);
    }
  }

  @override
  Future<OnboardingStatus> completeOnboarding({
    required DateTime completedAt,
    required OnboardingDraft draft,
  }) async {
    final userId = _requireUserId();
    try {
      final payload = OnboardingSettingsMapper.toProgressUpsertJson(
        userId: userId,
        step: 6,
        draft: draft,
        todayTipsDismissed: false,
        onboardingCompletedAt: completedAt,
        includeCompletedAt: true,
      );
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'user_id')
          .select(OnboardingSettingsMapper.selectColumns)
          .single();

      return OnboardingSettingsMapper.fromJson(Map<String, dynamic>.from(row));
    } on Object catch (error) {
      throw OnboardingErrorMapper.map(error);
    }
  }

  @override
  Future<OnboardingStatus> resetOnboarding() async {
    final userId = _requireUserId();
    try {
      final existing = await getStatus();
      final payload = OnboardingSettingsMapper.toProgressUpsertJson(
        userId: userId,
        step: 1,
        draft: existing.draft,
        includeCompletedAt: true,
      );
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'user_id')
          .select(OnboardingSettingsMapper.selectColumns)
          .single();

      return OnboardingSettingsMapper.fromJson(Map<String, dynamic>.from(row));
    } on Object catch (error) {
      throw OnboardingErrorMapper.map(error);
    }
  }

  @override
  Future<OnboardingStatus> dismissTodayTips() async {
    final userId = _requireUserId();
    try {
      final existing = await getStatus();
      final payload = OnboardingSettingsMapper.toProgressUpsertJson(
        userId: userId,
        step: existing.onboardingStep,
        draft: existing.draft,
        todayTipsDismissed: true,
      );
      final row = await _client
          .from(_table)
          .upsert(payload, onConflict: 'user_id')
          .select(OnboardingSettingsMapper.selectColumns)
          .single();

      return OnboardingSettingsMapper.fromJson(Map<String, dynamic>.from(row));
    } on Object catch (error) {
      throw OnboardingErrorMapper.map(error);
    }
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      throw const OnboardingPermissionFailure(code: 'unauthenticated');
    }
    return userId;
  }
}
