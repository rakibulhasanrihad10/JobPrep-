import 'dart:async';

import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase Auth SDK and transport exceptions into typed [AuthFailure]s.
abstract final class AuthErrorMapper {
  static const Set<String> _invalidCredentialCodes = {
    'invalid_credentials',
    'invalid_grant',
  };

  static const Set<String> _emailNotConfirmedCodes = {
    'email_not_confirmed',
    'provider_email_needs_verification',
  };

  static const Set<String> _accountExistsCodes = {
    'user_already_exists',
    'email_exists',
    'identity_already_exists',
    'phone_exists',
    'email_conflict_identity_not_deletable',
  };

  static const Set<String> _rateLimitCodes = {
    'over_request_rate_limit',
    'over_email_send_rate_limit',
    'over_sms_send_rate_limit',
    'too_many_requests',
  };

  /// Converts an arbitrary thrown [error] into a typed domain [AuthFailure].
  static AuthFailure map(Object error) {
    if (error is AuthFailure) return error;

    if (error is TimeoutException) {
      return NetworkFailure(
        message: error.message ?? 'Connection timed out.',
        code: 'request_timeout',
      );
    }

    if (error is supabase.AuthWeakPasswordException) {
      return WeakPasswordFailure(
        message: error.message,
        code: error.code,
        reasons: error.reasons,
      );
    }

    if (error is supabase.AuthRetryableFetchException) {
      if (error.statusCode?.trim() == '429') {
        return TooManyRequestsFailure(
          message: error.message,
          code: error.code,
        );
      }
      return NetworkFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is supabase.AuthException) {
      return _mapAuthException(error);
    }

    final raw = error.toString().toLowerCase();
    if (_looksLikeNetworkMessage(raw) ||
        error.runtimeType.toString().toLowerCase().contains('socket')) {
      return const NetworkFailure();
    }

    return const UnknownAuthFailure();
  }

  static AuthFailure _mapAuthException(supabase.AuthException error) {
    final normalizedCode = error.code?.trim().toLowerCase();
    final statusCode = error.statusCode?.trim();
    final msgLower = error.message.toLowerCase();

    if (statusCode == '429' ||
        (normalizedCode != null && _rateLimitCodes.contains(normalizedCode)) ||
        msgLower.contains('rate limit') ||
        msgLower.contains('too many requests') ||
        msgLower.contains('only request this after')) {
      return TooManyRequestsFailure(
        message: error.message,
        code: error.code,
      );
    }

    if ((normalizedCode != null &&
            _emailNotConfirmedCodes.contains(normalizedCode)) ||
        msgLower.contains('email not confirmed')) {
      return EmailNotConfirmedFailure(
        message: error.message,
        code: error.code,
      );
    }

    if ((normalizedCode != null &&
            _invalidCredentialCodes.contains(normalizedCode)) ||
        msgLower.contains('invalid login credentials') ||
        msgLower.contains('invalid credentials') ||
        msgLower.contains('invalid email or password')) {
      return InvalidCredentialsFailure(
        message: error.message,
        code: error.code,
      );
    }

    if ((normalizedCode != null &&
            _accountExistsCodes.contains(normalizedCode)) ||
        msgLower.contains('already registered') ||
        msgLower.contains('already exists') ||
        msgLower.contains('already been registered')) {
      return AccountAlreadyExistsFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (normalizedCode == 'request_timeout' ||
        statusCode == '408' ||
        _looksLikeNetworkMessage(msgLower)) {
      return NetworkFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (normalizedCode == 'weak_password') {
      return WeakPasswordFailure(
        message: error.message,
        code: error.code,
      );
    }

    return UnknownAuthFailure(
      message: error.message,
      code: error.code,
    );
  }

  static bool _looksLikeNetworkMessage(String lowerMessage) {
    return lowerMessage.contains('socketexception') ||
        lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('failed to fetch') ||
        lowerMessage.contains('clientexception') ||
        lowerMessage.contains('xmlhttprequest') ||
        lowerMessage.contains('networkerror') ||
        lowerMessage.contains('network error') ||
        lowerMessage.contains('network is unreachable') ||
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('connection reset') ||
        lowerMessage.contains('connection closed') ||
        lowerMessage.contains('timed out') ||
        lowerMessage.contains('timeout');
  }
}
