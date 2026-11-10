import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Minimum required password length for sign up and password recovery.
const int kMinPasswordLength = 8;

final RegExp _emailPattern = RegExp(
  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
);

/// Maps any domain [AuthFailure] to a localized, user-facing message.
String localizeAuthFailure(AuthFailure failure, AppLocalizations l10n) {
  return switch (failure) {
    InvalidCredentialsFailure() => l10n.authErrorInvalidCredentials,
    EmailNotConfirmedFailure() => l10n.authErrorEmailNotConfirmed,
    AccountAlreadyExistsFailure() => l10n.authErrorAccountAlreadyExists,
    TooManyRequestsFailure() => l10n.authErrorTooManyRequests,
    NetworkFailure() => l10n.authErrorNetwork,
    WeakPasswordFailure() => l10n.authErrorWeakPassword,
    UnknownAuthFailure() => l10n.authErrorUnknown,
  };
}

/// Validates email format for sign-in, sign-up, and forgot-password forms.
String? validateEmailField(String? value, AppLocalizations l10n) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return l10n.authValidationEmailRequired;
  }
  if (!_emailPattern.hasMatch(trimmed)) {
    return l10n.authValidationEmailInvalid;
  }
  return null;
}

/// Validates that an existing password is provided on sign-in.
String? validateSignInPasswordField(String? value, AppLocalizations l10n) {
  if (value == null || value.isEmpty) {
    return l10n.authValidationPasswordRequired;
  }
  return null;
}

/// Validates a new password for account creation or password reset
/// (minimum 8 characters).
String? validateNewPasswordField(String? value, AppLocalizations l10n) {
  if (value == null || value.isEmpty) {
    return l10n.authValidationPasswordRequired;
  }
  if (value.length < kMinPasswordLength) {
    return l10n.authValidationPasswordTooShort;
  }
  return null;
}

/// Validates confirmation matches [password] on password reset.
String? validateConfirmPasswordField(
  String? value,
  String password,
  AppLocalizations l10n,
) {
  if (value == null || value.isEmpty) {
    return l10n.authValidationConfirmPasswordRequired;
  }
  if (value != password) {
    return l10n.authValidationPasswordsDoNotMatch;
  }
  return null;
}
