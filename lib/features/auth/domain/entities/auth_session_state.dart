import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';

/// Lifecycle status of the application's authentication session.
enum AuthStatus {
  /// No authenticated user session is present.
  signedOut,

  /// A standard authenticated user session is active.
  signedIn,

  /// User arrived via a password recovery flow and must choose a new password.
  passwordRecovery,
}

/// Immutable snapshot of the current authentication state.
@immutable
class AuthSessionState {
  /// Creates an [AuthSessionState].
  const AuthSessionState({
    required this.status,
    this.user,
  });

  /// Creates a signed-out session snapshot.
  const AuthSessionState.signedOut()
      : status = AuthStatus.signedOut,
        user = null;

  /// Creates a signed-in session snapshot for [user].
  const AuthSessionState.signedIn(AuthUser this.user)
      : status = AuthStatus.signedIn;

  /// Creates a password-recovery session snapshot.
  const AuthSessionState.passwordRecovery({this.user})
      : status = AuthStatus.passwordRecovery;

  /// Current session lifecycle status.
  final AuthStatus status;

  /// Active user when signed in or recovering a password.
  final AuthUser? user;

  /// Returns `true` when the user has a standard authenticated session.
  bool get isSignedIn => status == AuthStatus.signedIn && user != null;

  /// Returns `true` when the session is in password recovery mode.
  bool get isPasswordRecovery => status == AuthStatus.passwordRecovery;

  /// Returns `true` when no session is active.
  bool get isSignedOut => status == AuthStatus.signedOut;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthSessionState &&
        other.status == status &&
        other.user == user;
  }

  @override
  int get hashCode => Object.hash(status, user);

  @override
  String toString() =>
      'AuthSessionState(status: ${status.name}, hasUser: ${user != null})';
}
