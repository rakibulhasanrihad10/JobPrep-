import 'dart:convert';

import 'package:job_prep/features/onboarding/data/mappers/onboarding_settings_mapper.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fallback [OnboardingRepository] active when Supabase credentials are absent.
///
/// Defaults cleanly to completed with tips already dismissed so offline widget
/// tests and unconfigured launches reach `/today` smoothly, while still
/// supporting explicit **Run setup again**, step persistence, and tips
/// dismissal in [SharedPreferences].
class UnconfiguredOnboardingRepository implements OnboardingRepository {
  /// Creates an [UnconfiguredOnboardingRepository].
  const UnconfiguredOnboardingRepository({
    this.prefs,
    this.userId = 'local',
  });

  /// Optional [SharedPreferences] persistence store for local dev runs.
  final SharedPreferences? prefs;

  /// Active user scope key.
  final String userId;

  String get _storageKey => 'jobprep_unconfigured_onboarding_$userId';

  static final OnboardingStatus _defaultCompleted = OnboardingStatus(
    id: 'local-user-settings',
    onboardingCompletedAt: DateTime.utc(2026),
    onboardingStep: 6,
    todayTipsDismissed: true,
  );

  @override
  Future<OnboardingStatus> getStatus() async {
    final raw = prefs?.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return _defaultCompleted.copyWith(userId: userId);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return OnboardingSettingsMapper.fromJson(decoded);
      }
      if (decoded is Map) {
        return OnboardingSettingsMapper.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } on FormatException {
      // Recover gracefully from corrupted local cache.
    }
    return _defaultCompleted.copyWith(userId: userId);
  }

  @override
  Future<OnboardingStatus> saveProgress({
    required int step,
    required OnboardingDraft draft,
  }) async {
    final current = await getStatus();
    final updated = current.copyWith(
      userId: userId,
      onboardingStep: step.clamp(1, 6),
      draft: draft,
      updatedAt: DateTime.now().toUtc(),
    );
    await _persist(updated);
    return updated;
  }

  @override
  Future<OnboardingStatus> completeOnboarding({
    required DateTime completedAt,
    required OnboardingDraft draft,
  }) async {
    final current = await getStatus();
    final updated = current.copyWith(
      userId: userId,
      onboardingCompletedAt: completedAt.toUtc(),
      onboardingStep: 6,
      draft: draft,
      todayTipsDismissed: false,
      updatedAt: DateTime.now().toUtc(),
    );
    await _persist(updated);
    return updated;
  }

  @override
  Future<OnboardingStatus> resetOnboarding() async {
    final current = await getStatus();
    final updated = current.copyWith(
      userId: userId,
      onboardingCompletedAt: null,
      onboardingStep: 1,
      updatedAt: DateTime.now().toUtc(),
    );
    await _persist(updated);
    return updated;
  }

  @override
  Future<OnboardingStatus> dismissTodayTips() async {
    final current = await getStatus();
    final updated = current.copyWith(
      userId: userId,
      todayTipsDismissed: true,
      updatedAt: DateTime.now().toUtc(),
    );
    await _persist(updated);
    return updated;
  }

  Future<void> _persist(OnboardingStatus status) async {
    await prefs?.setString(
      _storageKey,
      jsonEncode(<String, dynamic>{
        'id': status.id,
        'user_id': status.userId,
        'onboarding_completed_at':
            status.onboardingCompletedAt?.toUtc().toIso8601String(),
        'onboarding_step': status.onboardingStep,
        'onboarding_draft': status.draft.toJson(),
        'today_tips_dismissed': status.todayTipsDismissed,
      }),
    );
  }
}
