import 'package:flutter/foundation.dart' show immutable;

/// Base sealed class for typed authentication failures in the domain layer.
@immutable
sealed class AuthFailure implements Exception {
  /// Creates an [AuthFailure].
  const AuthFailure({
    required this.message,
    this.code,
  });

  /// Technical fallback error message for diagnostics.
  final String message;

  /// Optional provider error code.
  final String? code;

  @override
  String toString() {
    final kind = switch (this) {
      InvalidCredentialsFailure() => 'InvalidCredentialsFailure',
      EmailNotConfirmedFailure() => 'EmailNotConfirmedFailure',
      AccountAlreadyExistsFailure() => 'AccountAlreadyExistsFailure',
      TooManyRequestsFailure() => 'TooManyRequestsFailure',
      NetworkFailure() => 'NetworkFailure',
      WeakPasswordFailure() => 'WeakPasswordFailure',
      UnknownAuthFailure() => 'UnknownAuthFailure',
    };
    return '$kind(code: $code)';
  }
}

/// Failure thrown when email/password or session credentials are invalid.
final class InvalidCredentialsFailure extends AuthFailure {
  /// Creates an [InvalidCredentialsFailure].
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is InvalidCredentialsFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(InvalidCredentialsFailure, message, code);
}

/// Failure thrown when a user attempts to sign in before confirming email.
final class EmailNotConfirmedFailure extends AuthFailure {
  /// Creates an [EmailNotConfirmedFailure].
  const EmailNotConfirmedFailure({
    super.message = 'Please confirm your email address before signing in.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EmailNotConfirmedFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(EmailNotConfirmedFailure, message, code);
}

/// Failure thrown when registering with an email that is already in use.
final class AccountAlreadyExistsFailure extends AuthFailure {
  /// Creates an [AccountAlreadyExistsFailure].
  const AccountAlreadyExistsFailure({
    super.message = 'An account with this email already exists.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AccountAlreadyExistsFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(AccountAlreadyExistsFailure, message, code);
}

/// Failure thrown when authentication requests exceed rate limits.
final class TooManyRequestsFailure extends AuthFailure {
  /// Creates a [TooManyRequestsFailure].
  const TooManyRequestsFailure({
    super.message = 'Too many attempts. Please wait a moment and try again.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TooManyRequestsFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(TooManyRequestsFailure, message, code);
}

/// Failure thrown when a network or connectivity problem blocks authentication.
final class NetworkFailure extends AuthFailure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({
    super.message = 'Network error. Please check your internet connection.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NetworkFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(NetworkFailure, message, code);
}

/// Failure thrown when a chosen password does not meet strength requirements.
final class WeakPasswordFailure extends AuthFailure {
  /// Creates a [WeakPasswordFailure].
  const WeakPasswordFailure({
    super.message = 'The password does not meet security requirements.',
    super.code,
    this.reasons = const [],
  });

  /// Specific password policy reasons returned by the auth backend.
  final List<String> reasons;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WeakPasswordFailure ||
        other.message != message ||
        other.code != code ||
        other.reasons.length != reasons.length) {
      return false;
    }
    for (var i = 0; i < reasons.length; i++) {
      if (other.reasons[i] != reasons[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        WeakPasswordFailure,
        message,
        code,
        Object.hashAll(reasons),
      );
}

/// Fallback failure for unexpected or unmapped authentication errors.
final class UnknownAuthFailure extends AuthFailure {
  /// Creates an [UnknownAuthFailure].
  const UnknownAuthFailure({
    super.message = 'An unexpected authentication error occurred.',
    super.code,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UnknownAuthFailure &&
            other.message == message &&
            other.code == code);
  }

  @override
  int get hashCode => Object.hash(UnknownAuthFailure, message, code);
}
