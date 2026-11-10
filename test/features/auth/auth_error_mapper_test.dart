import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('AuthErrorMapper - Typed Failure Mapping', () {
    test(
        'maps invalid_credentials and invalid_grant to '
        'InvalidCredentialsFailure', () {
      const apiError = supabase.AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      );
      expect(
        AuthErrorMapper.map(apiError),
        isA<InvalidCredentialsFailure>().having(
          (f) => f.code,
          'code',
          equals('invalid_credentials'),
        ),
      );

      const grantError = supabase.AuthApiException(
        'Invalid grant',
        statusCode: '400',
        code: 'invalid_grant',
      );
      expect(AuthErrorMapper.map(grantError), isA<InvalidCredentialsFailure>());

      const legacyMessageError = supabase.AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
      );
      expect(
        AuthErrorMapper.map(legacyMessageError),
        isA<InvalidCredentialsFailure>(),
      );
    });

    test('maps email_not_confirmed errors to EmailNotConfirmedFailure', () {
      const codeError = supabase.AuthApiException(
        'Email not confirmed',
        statusCode: '400',
        code: 'email_not_confirmed',
      );
      expect(AuthErrorMapper.map(codeError), isA<EmailNotConfirmedFailure>());

      const providerVerificationError = supabase.AuthApiException(
        'Needs verification',
        statusCode: '400',
        code: 'provider_email_needs_verification',
      );
      expect(
        AuthErrorMapper.map(providerVerificationError),
        isA<EmailNotConfirmedFailure>(),
      );

      const messageError = supabase.AuthApiException(
        'Email not confirmed for this user',
        statusCode: '400',
      );
      expect(
        AuthErrorMapper.map(messageError),
        isA<EmailNotConfirmedFailure>(),
      );
    });

    test(
        'maps user_already_exists and email_exists to '
        'AccountAlreadyExistsFailure', () {
      for (final code in [
        'user_already_exists',
        'email_exists',
        'identity_already_exists',
        'phone_exists',
      ]) {
        final error = supabase.AuthApiException(
          'Account exists',
          statusCode: '422',
          code: code,
        );
        expect(
          AuthErrorMapper.map(error),
          isA<AccountAlreadyExistsFailure>(),
          reason: 'Expected $code to map to AccountAlreadyExistsFailure',
        );
      }

      const legacyMessageError = supabase.AuthApiException(
        'User already registered',
        statusCode: '400',
      );
      expect(
        AuthErrorMapper.map(legacyMessageError),
        isA<AccountAlreadyExistsFailure>(),
      );
    });

    test('maps rate limit status and codes to TooManyRequestsFailure', () {
      const status429 = supabase.AuthApiException(
        'Request rate limit reached',
        statusCode: '429',
      );
      expect(AuthErrorMapper.map(status429), isA<TooManyRequestsFailure>());

      const emailLimit = supabase.AuthApiException(
        'For security purposes, you can only request this after 60 seconds.',
        statusCode: '429',
        code: 'over_email_send_rate_limit',
      );
      expect(AuthErrorMapper.map(emailLimit), isA<TooManyRequestsFailure>());

      const codeLimit = supabase.AuthApiException(
        'Limited',
        code: 'over_request_rate_limit',
      );
      expect(AuthErrorMapper.map(codeLimit), isA<TooManyRequestsFailure>());

      final retryable429 = supabase.AuthRetryableFetchException(
        message: 'Too many requests',
        statusCode: '429',
      );
      expect(
        AuthErrorMapper.map(retryable429),
        isA<TooManyRequestsFailure>(),
      );
    });

    test('maps transport, fetch, and timeout exceptions to NetworkFailure', () {
      final retryable = supabase.AuthRetryableFetchException(
        message: 'ClientException: Failed host lookup',
      );
      expect(AuthErrorMapper.map(retryable), isA<NetworkFailure>());

      final timeout = TimeoutException('Connection timed out');
      expect(AuthErrorMapper.map(timeout), isA<NetworkFailure>());

      const requestTimeoutCode = supabase.AuthApiException(
        'Timed out',
        statusCode: '408',
        code: 'request_timeout',
      );
      expect(AuthErrorMapper.map(requestTimeoutCode), isA<NetworkFailure>());

      final webFetchError = Exception('TypeError: Failed to fetch');
      expect(AuthErrorMapper.map(webFetchError), isA<NetworkFailure>());

      final socketMessageError =
          Exception('SocketException: Connection refused');
      expect(AuthErrorMapper.map(socketMessageError), isA<NetworkFailure>());
    });

    test('maps AuthWeakPasswordException to WeakPasswordFailure with reasons',
        () {
      final weakError = supabase.AuthWeakPasswordException(
        message: 'Password is too weak',
        statusCode: '422',
        reasons: ['length', 'characters'],
      );

      final mapped = AuthErrorMapper.map(weakError);
      expect(
        mapped,
        isA<WeakPasswordFailure>().having(
          (f) => f.reasons,
          'reasons',
          equals(['length', 'characters']),
        ),
      );
    });

    test('passes through existing AuthFailure and falls back on unknown errors',
        () {
      const existing = InvalidCredentialsFailure();
      expect(AuthErrorMapper.map(existing), same(existing));

      final missingSession = supabase.AuthSessionMissingException();
      expect(AuthErrorMapper.map(missingSession), isA<UnknownAuthFailure>());

      final unrecognized = StateError('Unexpected bug');
      expect(AuthErrorMapper.map(unrecognized), isA<UnknownAuthFailure>());
    });
  });
}
