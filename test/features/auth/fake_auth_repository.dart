import 'dart:async';

import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/domain/repositories/auth_repository.dart';

/// In-memory fake implementation of [AuthRepository] for unit and widget tests.
class FakeAuthRepository implements AuthRepository {
  /// Creates a [FakeAuthRepository] starting with [initialSession].
  FakeAuthRepository({
    AuthSessionState? initialSession,
    this.autoConfirmOnSignUp = false,
  }) : _currentSession = initialSession ?? const AuthSessionState.signedOut();

  /// Convenience factory for a repository with a signed-in test user.
  factory FakeAuthRepository.authenticated([AuthUser? user]) {
    return FakeAuthRepository(
      initialSession: AuthSessionState.signedIn(user ?? defaultTestUser),
    );
  }

  /// Default authenticated user used in tests.
  static const AuthUser defaultTestUser = AuthUser(
    id: 'test-user-id',
    email: 'aspirant@example.com',
    displayName: 'Test Aspirant',
    emailConfirmed: true,
  );

  /// Whether [signUpWithEmail] immediately promotes the session to signed-in.
  final bool autoConfirmOnSignUp;

  AuthSessionState _currentSession;
  final StreamController<AuthSessionState> _controller =
      StreamController<AuthSessionState>.broadcast();

  /// Optional failure to throw on the next repository call.
  AuthFailure? nextFailure;

  /// Optional blocker allowing tests to pause async requests in loading state.
  Completer<void>? pendingGate;

  /// Last `redirectTo` passed to [sendPasswordReset].
  String? lastPasswordResetRedirectTo;

  /// Last `redirectTo` passed to [signInWithGoogle].
  String? lastOAuthRedirectTo;

  /// Last email passed to [signInWithEmail] or [signUpWithEmail].
  String? lastEmail;

  /// Last password passed to [updatePassword].
  String? lastUpdatedPassword;

  /// Number of times [signOut] was called.
  int signOutCallCount = 0;

  /// Emits a new [AuthSessionState] to all session listeners.
  void emitSession(AuthSessionState state) {
    _currentSession = state;
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  /// Emits a stream error to verify listener error handling.
  void emitStreamError(Object error) {
    if (!_controller.isClosed) {
      _controller.addError(error);
    }
  }

  /// Closes the internal stream controller.
  Future<void> dispose() => _controller.close();

  @override
  AuthSessionState get currentSession => _currentSession;

  @override
  Stream<AuthSessionState> get onSessionStateChange => _controller.stream;

  @override
  Future<AuthUser?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? emailRedirectTo,
  }) async {
    lastEmail = email;
    await _awaitGateAndThrowIfConfigured();
    final user = AuthUser(
      id: 'new-user-id',
      email: email,
      displayName: displayName,
      emailConfirmed: autoConfirmOnSignUp,
    );
    if (autoConfirmOnSignUp) {
      emitSession(AuthSessionState.signedIn(user));
    }
    return user;
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    await _awaitGateAndThrowIfConfigured();
    final user = AuthUser(
      id: 'signed-in-id',
      email: email,
      emailConfirmed: true,
    );
    emitSession(AuthSessionState.signedIn(user));
    return user;
  }

  @override
  Future<void> signInWithGoogle({String? redirectTo}) async {
    lastOAuthRedirectTo = redirectTo;
    await _awaitGateAndThrowIfConfigured();
    emitSession(const AuthSessionState.signedIn(defaultTestUser));
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    lastEmail = email;
    lastPasswordResetRedirectTo = redirectTo;
    await _awaitGateAndThrowIfConfigured();
  }

  @override
  Future<AuthUser> updatePassword({required String newPassword}) async {
    lastUpdatedPassword = newPassword;
    await _awaitGateAndThrowIfConfigured();
    final updatedUser = _currentSession.user ?? defaultTestUser;
    emitSession(AuthSessionState.signedIn(updatedUser));
    return updatedUser;
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    await _awaitGateAndThrowIfConfigured();
    emitSession(const AuthSessionState.signedOut());
  }

  Future<void> _awaitGateAndThrowIfConfigured() async {
    final gate = pendingGate;
    if (gate != null) {
      await gate.future;
    }
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      throw failure;
    }
  }
}
