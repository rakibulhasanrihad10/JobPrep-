/// Typed domain failure hierarchy for notification persistence and sync.
sealed class NotificationFailure implements Exception {
  /// Creates a [NotificationFailure].
  const NotificationFailure({
    required this.code,
    required this.message,
  });

  /// Stable error code for mapping localized UI feedback.
  final String code;

  /// Non-sensitive diagnostic description.
  final String message;

  @override
  String toString() => 'NotificationFailure($code): $message';
}

/// Connectivity or timeout error while talking to Supabase notifications.
final class NotificationNetworkFailure extends NotificationFailure {
  /// Creates a [NotificationNetworkFailure].
  const NotificationNetworkFailure({
    super.code = 'network_error',
    super.message = 'Network error while syncing notifications.',
  });
}

/// Authentication or Row Level Security permission failure.
final class NotificationPermissionFailure extends NotificationFailure {
  /// Creates a [NotificationPermissionFailure].
  const NotificationPermissionFailure({
    super.code = 'permission_denied',
    super.message = 'You do not have permission to access these notifications.',
  });
}

/// Invalid input or constraint violation when updating notifications.
final class NotificationValidationFailure extends NotificationFailure {
  /// Creates a [NotificationValidationFailure].
  const NotificationValidationFailure({
    super.code = 'validation_error',
    super.message = 'Notification update is invalid.',
  });
}

/// Unclassified failure when backend is unconfigured or returns unknown errors.
final class UnknownNotificationFailure extends NotificationFailure {
  /// Creates an [UnknownNotificationFailure].
  const UnknownNotificationFailure({
    super.code = 'unknown_error',
    super.message = 'Unexpected notifications error.',
  });
}
