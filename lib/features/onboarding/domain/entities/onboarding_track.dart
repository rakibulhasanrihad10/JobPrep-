/// Preparation career track selected in Step 2 of the onboarding wizard.
enum OnboardingTrack {
  /// Public sector / BCS / government recruitment exams (`government_job`).
  government('government', templateSlug: 'government_job'),

  /// Private software engineering / CS interview preparation (`software_engineer`).
  software('software', templateSlug: 'software_engineer'),

  /// Blank / custom setup with user-defined subjects and materials.
  blank('blank');

  const OnboardingTrack(this.value, {this.templateSlug});

  /// Canonical storage value persisted in `onboarding_draft`.
  final String value;

  /// Matching system template slug from `public.prep_templates`, if any.
  final String? templateSlug;

  /// Parses [raw] into an [OnboardingTrack], returning `null` when unknown.
  static OnboardingTrack? tryParse(String? raw) {
    if (raw == null) return null;
    for (final value in OnboardingTrack.values) {
      if (value.value == raw.trim()) {
        return value;
      }
    }
    return null;
  }
}
