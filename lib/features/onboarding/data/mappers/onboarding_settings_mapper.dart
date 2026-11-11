import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';

/// Serializes `public.user_settings` rows to/from [OnboardingStatus].
abstract final class OnboardingSettingsMapper {
  /// Explicit column list selected from `public.user_settings`.
  static const String selectColumns =
      'id, user_id, onboarding_completed_at, onboarding_step, '
      'onboarding_draft, today_tips_dismissed, created_at, updated_at';

  /// Parses a Supabase JSON row into an immutable [OnboardingStatus].
  static OnboardingStatus fromJson(Map<String, dynamic> json) {
    final rawStep = json['onboarding_step'];
    final step = rawStep is num ? rawStep.toInt().clamp(1, 6) : 1;

    final rawDraft = json['onboarding_draft'];
    final draft = rawDraft is Map
        ? OnboardingDraft.fromJson(Map<String, dynamic>.from(rawDraft))
        : const OnboardingDraft();

    return OnboardingStatus(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      onboardingCompletedAt: _parseTimestamp(json['onboarding_completed_at']),
      onboardingStep: step,
      draft: draft,
      todayTipsDismissed: (json['today_tips_dismissed'] as bool?) ?? false,
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
    );
  }

  /// Builds an upsert JSON payload for saving in-progress step & draft.
  static Map<String, dynamic> toProgressUpsertJson({
    required String userId,
    required int step,
    required OnboardingDraft draft,
    bool? todayTipsDismissed,
    DateTime? onboardingCompletedAt,
    bool includeCompletedAt = false,
  }) {
    return <String, dynamic>{
      'user_id': userId,
      'onboarding_step': step.clamp(1, 6),
      'onboarding_draft': draft.toJson(),
      if (todayTipsDismissed != null)
        'today_tips_dismissed': todayTipsDismissed,
      if (includeCompletedAt)
        'onboarding_completed_at':
            onboardingCompletedAt?.toUtc().toIso8601String(),
    };
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.toUtc();
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim())?.toUtc();
    }
    return null;
  }
}
