import 'package:flutter/foundation.dart' show immutable;

/// Base sealed class for typed preparation data-layer failures.
@immutable
sealed class PrepFailure implements Exception {
  /// Creates a [PrepFailure].
  const PrepFailure({
    required this.message,
    this.code,
  });

  /// Technical diagnostic message (safe, never contains secrets).
  final String message;

  /// Optional backend or PostgreSQL SQLSTATE error code.
  final String? code;

  @override
  String toString() {
    final kind = switch (this) {
      PrepValidationFailure() => 'PrepValidationFailure',
      PrepNotFoundFailure() => 'PrepNotFoundFailure',
      PrepPermissionFailure() => 'PrepPermissionFailure',
      PrepNetworkFailure() => 'PrepNetworkFailure',
      UnknownPrepFailure() => 'UnknownPrepFailure',
    };
    return '$kind(code: $code, message: $message)';
  }
}

/// Failure thrown when validation or PostgreSQL constraints reject input.
final class PrepValidationFailure extends PrepFailure {
  /// Creates a [PrepValidationFailure].
  const PrepValidationFailure({
    super.message = 'Preparation data failed validation checks.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PrepValidationFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(PrepValidationFailure, message, code);
}

/// Failure thrown when the requested record does not exist or is invisible.
final class PrepNotFoundFailure extends PrepFailure {
  /// Creates a [PrepNotFoundFailure].
  const PrepNotFoundFailure({
    super.message = 'Requested preparation record could not be found.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PrepNotFoundFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(PrepNotFoundFailure, message, code);
}

/// Failure thrown when RLS or authentication credentials reject access.
final class PrepPermissionFailure extends PrepFailure {
  /// Creates a [PrepPermissionFailure].
  const PrepPermissionFailure({
    super.message = 'You do not have permission to access this prep data.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PrepPermissionFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(PrepPermissionFailure, message, code);
}

/// Failure thrown when a request fails due to connectivity or timeout.
final class PrepNetworkFailure extends PrepFailure {
  /// Creates a [PrepNetworkFailure].
  const PrepNetworkFailure({
    super.message = 'Network error while communicating with Supabase.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PrepNetworkFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(PrepNetworkFailure, message, code);
}

/// Fallback failure for unexpected repository exceptions.
final class UnknownPrepFailure extends PrepFailure {
  /// Creates an [UnknownPrepFailure].
  const UnknownPrepFailure({
    super.message = 'An unexpected error occurred while accessing prep data.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnknownPrepFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(UnknownPrepFailure, message, code);
}
