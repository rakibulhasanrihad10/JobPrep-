import 'package:flutter/foundation.dart' show immutable;

/// Base sealed class for typed circular data-layer failures.
@immutable
sealed class CircularFailure implements Exception {
  /// Creates a [CircularFailure].
  const CircularFailure({
    required this.message,
    this.code,
  });

  /// Technical fallback message for diagnostics.
  final String message;

  /// Optional backend or PostgreSQL SQLSTATE error code.
  final String? code;

  @override
  String toString() {
    final kind = switch (this) {
      CircularValidationFailure() => 'CircularValidationFailure',
      CircularNotFoundFailure() => 'CircularNotFoundFailure',
      CircularPermissionFailure() => 'CircularPermissionFailure',
      CircularNetworkFailure() => 'CircularNetworkFailure',
      UnknownCircularFailure() => 'UnknownCircularFailure',
    };
    return '$kind(code: $code, message: $message)';
  }
}

/// Failure thrown when input or database check constraints reject a circular.
final class CircularValidationFailure extends CircularFailure {
  /// Creates a [CircularValidationFailure].
  const CircularValidationFailure({
    super.message = 'Circular data failed validation checks.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CircularValidationFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(CircularValidationFailure, message, code);
}

/// Failure thrown when the requested circular does not exist or is invisible.
final class CircularNotFoundFailure extends CircularFailure {
  /// Creates a [CircularNotFoundFailure].
  const CircularNotFoundFailure({
    super.message = 'Circular could not be found.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CircularNotFoundFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(CircularNotFoundFailure, message, code);
}

/// Failure thrown when RLS or session credentials deny the circular request.
final class CircularPermissionFailure extends CircularFailure {
  /// Creates a [CircularPermissionFailure].
  const CircularPermissionFailure({
    super.message = 'You do not have permission to access this circular.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CircularPermissionFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(CircularPermissionFailure, message, code);
}

/// Failure thrown when a circular request cannot reach the server.
final class CircularNetworkFailure extends CircularFailure {
  /// Creates a [CircularNetworkFailure].
  const CircularNetworkFailure({
    super.message = 'Network error while communicating with Supabase.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CircularNetworkFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(CircularNetworkFailure, message, code);
}

/// Fallback failure for unexpected circular repository errors.
final class UnknownCircularFailure extends CircularFailure {
  /// Creates an [UnknownCircularFailure].
  const UnknownCircularFailure({
    super.message = 'An unexpected error occurred while managing circulars.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnknownCircularFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(UnknownCircularFailure, message, code);
}
