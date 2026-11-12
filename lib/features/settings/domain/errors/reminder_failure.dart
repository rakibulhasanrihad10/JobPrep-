import 'package:flutter/foundation.dart' show immutable;

/// Base sealed exception type for reminder preference repository failures.
@immutable
sealed class ReminderFailure implements Exception {
  /// Creates a [ReminderFailure].
  const ReminderFailure({
    required this.message,
    this.code,
  });

  /// Diagnostic fallback message for logging/testing.
  final String message;

  /// Optional PostgreSQL SQLSTATE or Supabase error code.
  final String? code;

  @override
  String toString() {
    final kind = switch (this) {
      ReminderValidationFailure() => 'ReminderValidationFailure',
      ReminderPermissionFailure() => 'ReminderPermissionFailure',
      ReminderNetworkFailure() => 'ReminderNetworkFailure',
      UnknownReminderFailure() => 'UnknownReminderFailure',
    };
    return '$kind(code: $code, message: $message)';
  }
}

/// Thrown when reminder setting inputs violate validation/check constraints.
final class ReminderValidationFailure extends ReminderFailure {
  /// Creates a [ReminderValidationFailure].
  const ReminderValidationFailure({
    super.message = 'Reminder preferences failed validation.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReminderValidationFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(ReminderValidationFailure, message, code);
}

/// Thrown when authentication or RLS rejects reading/saving reminder settings.
final class ReminderPermissionFailure extends ReminderFailure {
  /// Creates a [ReminderPermissionFailure].
  const ReminderPermissionFailure({
    super.message = 'Sign in again to manage reminder settings.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReminderPermissionFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(ReminderPermissionFailure, message, code);
}

/// Thrown when reminder settings cannot be synced due to network issues.
final class ReminderNetworkFailure extends ReminderFailure {
  /// Creates a [ReminderNetworkFailure].
  const ReminderNetworkFailure({
    super.message = 'Network error while updating reminder settings.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ReminderNetworkFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(ReminderNetworkFailure, message, code);
}

/// Fallback exception for unconfigured backends or unexpected errors.
final class UnknownReminderFailure extends ReminderFailure {
  /// Creates an [UnknownReminderFailure].
  const UnknownReminderFailure({
    super.message = 'Unexpected error while loading reminder settings.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnknownReminderFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(UnknownReminderFailure, message, code);
}
