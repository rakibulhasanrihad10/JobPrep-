import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:job_prep/features/auth/data/repositories/unconfigured_auth_repository.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('AuthUserMapper Unit Tests', () {
    test('maps Supabase User with full metadata to AuthUser', () {
      const user = supabase.User(
        id: 'u-123',
        appMetadata: {},
        userMetadata: {
          'full_name': 'John Doe',
          'avatar_url': 'https://example.com/avatar.png',
        },
        aud: 'authenticated',
        email: 'john@example.com',
        createdAt: '2026-01-01T00:00:00Z',
        emailConfirmedAt: '2026-01-01T00:05:00Z',
      );

      final mapped = AuthUserMapper.fromSupabase(user);
      expect(mapped.id, equals('u-123'));
      expect(mapped.email, equals('john@example.com'));
      expect(mapped.displayName, equals('John Doe'));
      expect(mapped.avatarUrl, equals('https://example.com/avatar.png'));
      expect(mapped.emailConfirmed, isTrue);
    });

    test('falls back cleanly when metadata is empty or null', () {
      const user = supabase.User(
        id: 'u-456',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00Z',
      );

      final mapped = AuthUserMapper.fromSupabase(user);
      expect(mapped.id, equals('u-456'));
      expect(mapped.displayName, isNull);
      expect(mapped.avatarUrl, isNull);
      expect(mapped.emailConfirmed, isFalse);
    });
  });

  group('UnconfiguredAuthRepository Unit Tests', () {
    test('session defaults to signedOut', () {
      const repo = UnconfiguredAuthRepository();
      expect(repo.currentSession.isSignedOut, isTrue);
    });

    test('operations reject cleanly with UnknownAuthFailure', () async {
      const repo = UnconfiguredAuthRepository();
      expect(
        () => repo.signInWithEmail(email: 'test@example.com', password: 'pass'),
        throwsA(isA<UnknownAuthFailure>()),
      );
      expect(
        () => repo.signInWithGoogle(),
        throwsA(isA<UnknownAuthFailure>()),
      );
      expect(
        () => repo.signUpWithEmail(email: 'test@example.com', password: 'pass'),
        throwsA(isA<UnknownAuthFailure>()),
      );
      expect(
        () => repo.sendPasswordReset(email: 'test@example.com'),
        throwsA(isA<UnknownAuthFailure>()),
      );
      expect(
        () => repo.deleteMyAccount(),
        throwsA(isA<UnknownAuthFailure>()),
      );
    });
  });
}
