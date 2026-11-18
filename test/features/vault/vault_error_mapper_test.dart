import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/vault/data/mappers/vault_error_mapper.dart';
import 'package:job_prep/features/vault/domain/errors/vault_feature_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('VaultErrorMapper', () {
    test('maps TimeoutException to VaultNetworkFailure', () {
      final failure = VaultErrorMapper.map(TimeoutException('Timed out'));
      expect(failure, isA<VaultNetworkFailure>());
      expect(failure.message, equals('Timed out'));
    });

    test('maps AuthException to VaultPermissionFailure', () {
      final failure = VaultErrorMapper.map(
        const supabase.AuthException('Not allowed', statusCode: '403'),
      );
      expect(failure, isA<VaultPermissionFailure>());
    });

    test('maps PostgrestException 42501 to VaultPermissionFailure', () {
      final failure = VaultErrorMapper.map(
        const supabase.PostgrestException(message: 'denied', code: '42501'),
      );
      expect(failure, isA<VaultPermissionFailure>());
    });

    test('maps validation SQLSTATE codes to VaultValidationFailure', () {
      for (final code in ['23514', '23502', '23503', '22P02']) {
        final failure = VaultErrorMapper.map(
          supabase.PostgrestException(message: 'check error', code: code),
        );
        expect(failure, isA<VaultValidationFailure>());
      }
    });

    test('maps network string to VaultNetworkFailure', () {
      final failure =
          VaultErrorMapper.map('SocketException: Connection refused');
      expect(failure, isA<VaultNetworkFailure>());
    });

    test('maps unknown error to UnknownVaultFailure', () {
      final failure = VaultErrorMapper.map(const FormatException('bad json'));
      expect(failure, isA<UnknownVaultFailure>());
    });
  });
}
