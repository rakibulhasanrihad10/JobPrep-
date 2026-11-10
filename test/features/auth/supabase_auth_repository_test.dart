import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:job_prep/features/auth/data/repositories/unconfigured_auth_repository.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class _FakeGoTrueClient extends Fake implements supabase.GoTrueClient {
  final StreamController<supabase.AuthState> _controller =
      StreamController<supabase.AuthState>.broadcast();

  supabase.Session? fakeSession;
  Exception? errorToThrow;
  supabase.AuthResponse? nextAuthResponse;
  supabase.UserResponse? nextUserResponse;

  String? lastSignUpEmail;
  String? lastSignUpEmailRedirectTo;
  Map<String, dynamic>? lastSignUpData;

  String? lastSignInEmail;
  String? lastResetEmail;
  String? lastResetRedirectTo;
  supabase.UserAttributes? lastUpdatedAttributes;
  int signOutCount = 0;

  @override
  supabase.Session? get currentSession => fakeSession;

  @override
  Stream<supabase.AuthState> get onAuthStateChange => _controller.stream;

  void emitAuthState(supabase.AuthState state) {
    fakeSession = state.session;
    _controller.add(state);
  }

  @override
  void dispose() {
    unawaited(_controller.close());
  }

  @override
  Future<supabase.AuthResponse> signUp({
    required String password,
    String? email,
    String? phone,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
    supabase.OtpChannel channel = supabase.OtpChannel.sms,
  }) async {
    lastSignUpEmail = email;
    lastSignUpEmailRedirectTo = emailRedirectTo;
    lastSignUpData = data;
    if (errorToThrow != null) throw errorToThrow!;
    return nextAuthResponse ?? supabase.AuthResponse();
  }

  @override
  Future<supabase.AuthResponse> signInWithPassword({
    required String password,
    String? email,
    String? phone,
    String? captchaToken,
  }) async {
    lastSignInEmail = email;
    if (errorToThrow != null) throw errorToThrow!;
    return nextAuthResponse ?? supabase.AuthResponse();
  }

  @override
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
    String? captchaToken,
  }) async {
    lastResetEmail = email;
    lastResetRedirectTo = redirectTo;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<supabase.UserResponse> updateUser(
    supabase.UserAttributes attributes, {
    String? emailRedirectTo,
  }) async {
    lastUpdatedAttributes = attributes;
    if (errorToThrow != null) throw errorToThrow!;
    return nextUserResponse ?? supabase.UserResponse.fromJson(const {});
  }

  @override
  Future<void> signOut({
    supabase.SignOutScope scope = supabase.SignOutScope.local,
  }) async {
    signOutCount++;
    if (errorToThrow != null) throw errorToThrow!;
    fakeSession = null;
  }
}

class _FakeSupabaseClient extends Fake implements supabase.SupabaseClient {
  _FakeSupabaseClient(this._auth);

  final supabase.GoTrueClient _auth;

  @override
  supabase.GoTrueClient get auth => _auth;
}

supabase.User _makeSupabaseUser({
  String id = 'user-123',
  String email = 'user@example.com',
  String? fullName = 'Rakib Hasan',
  String? emailConfirmedAt = '2026-01-01T00:00:00Z',
  List<supabase.UserIdentity>? identities,
}) {
  return supabase.User(
    id: id,
    appMetadata: const {},
    userMetadata: fullName != null ? {'full_name': fullName} : null,
    aud: 'authenticated',
    email: email,
    createdAt: '2026-01-01T00:00:00Z',
    emailConfirmedAt: emailConfirmedAt,
    identities: identities,
  );
}

supabase.Session _makeSession(supabase.User user) {
  return supabase.Session(
    accessToken: 'access-token',
    tokenType: 'bearer',
    user: user,
  );
}

void main() {
  late _FakeGoTrueClient fakeAuth;
  late _FakeSupabaseClient fakeClient;
  late SupabaseAuthRepository repository;

  setUp(() {
    fakeAuth = _FakeGoTrueClient();
    fakeClient = _FakeSupabaseClient(fakeAuth);
    repository = SupabaseAuthRepository(
      fakeClient,
      isWeb: true,
      appOriginUri: Uri.parse('https://app.jobprep.test/login'),
    );
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  group('SupabaseAuthRepository - Operations & Redirect URLs', () {
    test('signUpWithEmail trims email, passes displayName, maps AuthUser',
        () async {
      final user = _makeSupabaseUser(emailConfirmedAt: null);
      fakeAuth.nextAuthResponse = supabase.AuthResponse(user: user);

      final result = await repository.signUpWithEmail(
        email: '  user@example.com ',
        password: 'Password123!',
        displayName: '  Rakib Hasan ',
      );

      expect(fakeAuth.lastSignUpEmail, equals('user@example.com'));
      expect(
        fakeAuth.lastSignUpEmailRedirectTo,
        equals('https://app.jobprep.test'),
      );
      expect(fakeAuth.lastSignUpData, equals({'full_name': 'Rakib Hasan'}));
      expect(result?.id, equals('user-123'));
      expect(result?.displayName, equals('Rakib Hasan'));
      expect(result?.emailConfirmed, isFalse);
    });

    test(
        'signUpWithEmail detects obfuscated duplicate email with empty '
        'identities', () async {
      final duplicateUser = _makeSupabaseUser(identities: const []);
      fakeAuth.nextAuthResponse = supabase.AuthResponse(user: duplicateUser);

      await expectLater(
        () => repository.signUpWithEmail(
          email: 'existing@example.com',
          password: 'Password123!',
        ),
        throwsA(isA<AccountAlreadyExistsFailure>()),
      );
    });

    test('signInWithEmail returns mapped user and propagates typed failures',
        () async {
      final user = _makeSupabaseUser();
      fakeAuth.nextAuthResponse = supabase.AuthResponse(
        user: user,
        session: _makeSession(user),
      );

      final signedInUser = await repository.signInWithEmail(
        email: ' user@example.com ',
        password: 'secret',
      );
      expect(fakeAuth.lastSignInEmail, equals('user@example.com'));
      expect(signedInUser.id, equals('user-123'));
      expect(signedInUser.emailConfirmed, isTrue);

      fakeAuth.errorToThrow = const supabase.AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      );
      await expectLater(
        () => repository.signInWithEmail(
          email: 'user@example.com',
          password: 'wrong',
        ),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('signInWithGoogle passes OAuthProvider.google and web app origin',
        () async {
      supabase.OAuthProvider? capturedProvider;
      String? capturedRedirect;

      final repo = SupabaseAuthRepository(
        fakeClient,
        isWeb: true,
        appOriginUri: Uri.parse('https://app.jobprep.test/login'),
        oauthLauncher: (provider, {redirectTo}) async {
          capturedProvider = provider;
          capturedRedirect = redirectTo;
          return true;
        },
      );

      await repo.signInWithGoogle();

      expect(capturedProvider, equals(supabase.OAuthProvider.google));
      expect(capturedRedirect, equals('https://app.jobprep.test'));
    });

    test('sendPasswordReset passes /reset-password web redirect URL', () async {
      await repository.sendPasswordReset(email: ' user@example.com ');

      expect(fakeAuth.lastResetEmail, equals('user@example.com'));
      expect(
        fakeAuth.lastResetRedirectTo,
        equals('https://app.jobprep.test/reset-password'),
      );
    });

    test(
        'sendPasswordReset maps rate-limit exception to TooManyRequestsFailure',
        () async {
      fakeAuth.errorToThrow = const supabase.AuthApiException(
        'Rate limit exceeded',
        statusCode: '429',
        code: 'over_email_send_rate_limit',
      );

      await expectLater(
        () => repository.sendPasswordReset(email: 'user@example.com'),
        throwsA(isA<TooManyRequestsFailure>()),
      );
    });

    test('updatePassword updates user password and maps user', () async {
      final user = _makeSupabaseUser();
      fakeAuth.nextUserResponse = supabase.UserResponse.fromJson({
        'id': user.id,
        'email': user.email,
        'aud': 'authenticated',
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{'full_name': 'Rakib Hasan'},
        'created_at': '2026-01-01T00:00:00Z',
        'email_confirmed_at': '2026-01-01T00:00:00Z',
      });

      final updated = await repository.updatePassword(
        newPassword: 'NewPassword123!',
      );
      expect(
        fakeAuth.lastUpdatedAttributes?.password,
        equals('NewPassword123!'),
      );
      expect(updated.id, equals('user-123'));
    });

    test('signOut calls Supabase signOut and maps network errors', () async {
      await repository.signOut();
      expect(fakeAuth.signOutCount, equals(1));

      fakeAuth.errorToThrow = supabase.AuthRetryableFetchException(
        message: 'Network error',
      );
      await expectLater(
        () => repository.signOut(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('SupabaseAuthRepository - Auth State & Recovery Stream', () {
    test('maps onAuthStateChange including passwordRecovery and userUpdated',
        () async {
      final user = _makeSupabaseUser();
      final session = _makeSession(user);

      final emitted = <AuthSessionState>[];
      final sub = repository.onSessionStateChange.listen(emitted.add);
      addTearDown(sub.cancel);

      fakeAuth
        ..emitAuthState(
          const supabase.AuthState(
            supabase.AuthChangeEvent.initialSession,
            null,
          ),
        )
        ..emitAuthState(
          supabase.AuthState(
            supabase.AuthChangeEvent.passwordRecovery,
            session,
          ),
        )
        // Token refresh during recovery should stay in recovery mode.
        ..emitAuthState(
          supabase.AuthState(
            supabase.AuthChangeEvent.tokenRefreshed,
            session,
          ),
        )
        // Completing updateUser triggers userUpdated, moving to signedIn.
        ..emitAuthState(
          supabase.AuthState(
            supabase.AuthChangeEvent.userUpdated,
            session,
          ),
        )
        ..emitAuthState(
          const supabase.AuthState(
            supabase.AuthChangeEvent.signedOut,
            null,
          ),
        );

      await pumpEventQueue();

      expect(emitted.length, equals(5));
      expect(emitted[0].status, equals(AuthStatus.signedOut));
      expect(emitted[1].status, equals(AuthStatus.passwordRecovery));
      expect(emitted[2].status, equals(AuthStatus.passwordRecovery));
      expect(emitted[3].status, equals(AuthStatus.signedIn));
      expect(emitted[4].status, equals(AuthStatus.signedOut));
    });
  });

  group('Riverpod AuthRepository Injection', () {
    test('falls back to UnconfiguredAuthRepository when Supabase is unset', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      expect(repo, isA<UnconfiguredAuthRepository>());
      expect(repo.currentSession.isSignedOut, isTrue);
    });

    test('injects SupabaseAuthRepository when supabaseClientProvider is set',
        () {
      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(fakeClient),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      expect(repo, isA<SupabaseAuthRepository>());
    });
  });
}
