import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/domain/repositories/auth_repository.dart';

/// Safe fallback [AuthRepository] used when Supabase environment credentials
/// (`SUPABASE_URL` / `SUPABASE_ANON_KEY`) have not been provided.
class UnconfiguredAuthRepository implements AuthRepository {
  /// Creates an [UnconfiguredAuthRepository].
  const UnconfiguredAuthRepository();

  static const _notConfiguredError = UnknownAuthFailure(
    code: 'supabase_not_configured',
    message: 'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
  );

  @override
  AuthSessionState get currentSession => const AuthSessionState.signedOut();

  @override
  Stream<AuthSessionState> get onSessionStateChange => const Stream.empty();

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) =>
      Future.error(_notConfiguredError);

  @override
  Future<void> signInWithGoogle({String? redirectTo}) =>
      Future.error(_notConfiguredError);

  @override
  Future<AuthUser?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? emailRedirectTo,
  }) =>
      Future.error(_notConfiguredError);

  @override
  Future<void> sendPasswordReset({
    required String email,
    String? redirectTo,
  }) =>
      Future.error(_notConfiguredError);

  @override
  Future<AuthUser> updatePassword({required String newPassword}) =>
      Future.error(_notConfiguredError);

  @override
  Future<void> signOut() async {}
}
