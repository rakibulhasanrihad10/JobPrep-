import 'package:flutter/foundation.dart' show immutable;

/// Base sealed error type for portal account & vault verifier data operations.
@immutable
sealed class VaultFeatureFailure implements Exception {
  /// Creates a [VaultFeatureFailure].
  const VaultFeatureFailure({
    required this.message,
    this.code,
  });

  /// Diagnostic message without any user credentials.
  final String message;

  /// Optional PostgreSQL SQLSTATE or Supabase error code.
  final String? code;

  @override
  String toString() {
    final kind = switch (this) {
      VaultValidationFailure() => 'VaultValidationFailure',
      VaultPermissionFailure() => 'VaultPermissionFailure',
      VaultNotFoundFailure() => 'VaultNotFoundFailure',
      VaultNetworkFailure() => 'VaultNetworkFailure',
      UnknownVaultFailure() => 'UnknownVaultFailure',
    };
    return '$kind(code: $code, message: $message)';
  }
}

/// Thrown when input or database check constraints reject a portal account.
final class VaultValidationFailure extends VaultFeatureFailure {
  /// Creates a [VaultValidationFailure].
  const VaultValidationFailure({
    super.message = 'Portal account details failed validation.',
    super.code,
  });
}

/// Thrown when authentication or RLS blocks vault access.
final class VaultPermissionFailure extends VaultFeatureFailure {
  /// Creates a [VaultPermissionFailure].
  const VaultPermissionFailure({
    super.message = 'Sign in again to access portal accounts.',
    super.code,
  });
}

/// Thrown when the target portal account no longer exists.
final class VaultNotFoundFailure extends VaultFeatureFailure {
  /// Creates a [VaultNotFoundFailure].
  const VaultNotFoundFailure({
    super.message = 'Portal account could not be found.',
    super.code,
  });
}

/// Thrown when network connectivity prevents syncing encrypted portal data.
final class VaultNetworkFailure extends VaultFeatureFailure {
  /// Creates a [VaultNetworkFailure].
  const VaultNetworkFailure({
    super.message = 'Network error while communicating with Supabase.',
    super.code,
  });
}

/// Fallback exception for unexpected errors or unconfigured backends.
final class UnknownVaultFailure extends VaultFeatureFailure {
  /// Creates an [UnknownVaultFailure].
  const UnknownVaultFailure({
    super.message = 'Unexpected error while accessing portal vault.',
    super.code,
  });
}
