/// Typed failure hierarchy for general `user_settings` sync operations.
sealed class SettingsFailure implements Exception {
  const SettingsFailure({required this.message, this.code});

  /// Safe, non-sensitive error description for diagnostics.
  final String message;

  /// Optional SQLSTATE or repository failure code.
  final String? code;

  @override
  String toString() => 'SettingsFailure($code): $message';
}

/// Network or timeout failure while loading or saving settings.
final class SettingsNetworkFailure extends SettingsFailure {
  /// Creates a [SettingsNetworkFailure].
  const SettingsNetworkFailure({
    super.message = 'Network error while syncing settings.',
    super.code,
  });
}

/// Authentication or RLS permission denial.
final class SettingsPermissionFailure extends SettingsFailure {
  /// Creates a [SettingsPermissionFailure].
  const SettingsPermissionFailure({
    super.message = 'Permission denied while accessing settings.',
    super.code,
  });
}

/// Invalid settings payload rejected by client or DB constraints.
final class SettingsValidationFailure extends SettingsFailure {
  /// Creates a [SettingsValidationFailure].
  const SettingsValidationFailure({
    super.message = 'Settings values are invalid.',
    super.code,
  });
}

/// Fallback for unexpected persistence errors.
final class UnknownSettingsFailure extends SettingsFailure {
  /// Creates an [UnknownSettingsFailure].
  const UnknownSettingsFailure({
    super.message = 'Unexpected error while saving settings.',
    super.code,
  });
}
