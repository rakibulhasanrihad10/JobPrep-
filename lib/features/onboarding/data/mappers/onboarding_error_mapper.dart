import 'dart:async';

import 'package:job_prep/features/onboarding/domain/errors/onboarding_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase and transport exceptions into typed [OnboardingFailure]s.
abstract final class OnboardingErrorMapper {
  static const Set<String> _validationCodes = {
    '23514',
    '23502',
    '22P02',
  };

  /// Converts [error] into a typed [OnboardingFailure].
  static OnboardingFailure map(Object error) {
    if (error is OnboardingFailure) return error;

    if (error is TimeoutException) {
      return OnboardingNetworkFailure(
        message: error.message ?? 'Request timed out.',
        code: 'request_timeout',
      );
    }

    if (error is supabase.AuthRetryableFetchException) {
      return OnboardingNetworkFailure(
        message: error.message,
        code: error.code ?? 'auth_retry_error',
      );
    }

    if (error is supabase.AuthException) {
      return OnboardingPermissionFailure(
        message: error.message,
        code: error.code ?? 'auth_error',
      );
    }

    if (error is supabase.PostgrestException) {
      return _mapPostgrest(error);
    }

    final raw = error.toString().toLowerCase();
    final typeName = error.runtimeType.toString().toLowerCase();
    if (_looksLikeNetworkMessage(raw) || typeName.contains('socket')) {
      return const OnboardingNetworkFailure();
    }

    return const UnknownOnboardingFailure();
  }

  static OnboardingFailure _mapPostgrest(supabase.PostgrestException error) {
    final code = error.code;
    if (code == '42501') {
      return OnboardingPermissionFailure(
        message: error.message,
        code: '42501',
      );
    }
    if (code != null && _validationCodes.contains(code)) {
      return OnboardingValidationFailure(
        message: error.message,
        code: code,
      );
    }
    if (_looksLikeNetworkMessage(error.message.toLowerCase())) {
      return OnboardingNetworkFailure(
        message: error.message,
        code: code ?? 'network_error',
      );
    }
    return UnknownOnboardingFailure(
      message: error.message,
      code: code ?? 'postgrest_error',
    );
  }

  static bool _looksLikeNetworkMessage(String lower) {
    return lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection') ||
        lower.contains('timeout');
  }
}
