/// Typed domain failures for onboarding persistence and application actions.
sealed class OnboardingFailure implements Exception {
  /// Creates an [OnboardingFailure].
  const OnboardingFailure({
    required this.code,
    required this.message,
  });

  /// Stable error code for mapping localized UI error feedback.
  final String code;

  /// Non-sensitive diagnostic description.
  final String message;

  @override
  String toString() => 'OnboardingFailure($code): $message';
}

/// Network or timeout error while saving or applying onboarding settings.
final class OnboardingNetworkFailure extends OnboardingFailure {
  /// Creates an [OnboardingNetworkFailure].
  const OnboardingNetworkFailure({
    super.code = 'network_error',
    super.message = 'Network error while saving onboarding progress.',
  });
}

/// Authentication or Row Level Security permission failure.
final class OnboardingPermissionFailure extends OnboardingFailure {
  /// Creates an [OnboardingPermissionFailure].
  const OnboardingPermissionFailure({
    super.code = 'permission_denied',
    super.message = 'Sign in required to update setup preferences.',
  });
}

/// Validation or constraint violation error.
final class OnboardingValidationFailure extends OnboardingFailure {
  /// Creates an [OnboardingValidationFailure].
  const OnboardingValidationFailure({
    super.code = 'validation_error',
    super.message = 'Onboarding configuration is invalid.',
  });
}

/// Unclassified onboarding persistence failure.
final class UnknownOnboardingFailure extends OnboardingFailure {
  /// Creates an [UnknownOnboardingFailure].
  const UnknownOnboardingFailure({
    super.code = 'unknown_error',
    super.message = 'Unexpected error during onboarding setup.',
  });
}
