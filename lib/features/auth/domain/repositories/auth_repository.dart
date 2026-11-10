import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';

/// Contract for authentication operations and session observation.
abstract interface class AuthRepository {
  /// Synchronously returns the latest known [AuthSessionState].
  AuthSessionState get currentSession;

  /// Emits authentication session transitions, including sign-in, sign-out,
  /// token updates, and password recovery events.
  Stream<AuthSessionState> get onSessionStateChange;

  /// Registers a new user with [email] and [password].
  ///
  /// Returns the created [AuthUser], or `null` if confirmation is required
  /// and no user payload was returned. Throws an `AuthFailure` subclass on
  /// failure.
  Future<AuthUser?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? emailRedirectTo,
  });

  /// Signs in an existing user using [email] and [password].
  ///
  /// Throws an `AuthFailure` subclass on failure.
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Starts Google OAuth sign-in, redirecting back to the application.
  ///
  /// On web, uses OAuth browser redirect back to the active app origin unless
  /// [redirectTo] is supplied. Throws an `AuthFailure` subclass on failure.
  Future<void> signInWithGoogle({String? redirectTo});

  /// Sends a password reset link to [email].
  ///
  /// Redirects users back to `/reset-password` unless [redirectTo] is supplied.
  /// Throws an `AuthFailure` subclass on failure.
  Future<void> sendPasswordReset({
    required String email,
    String? redirectTo,
  });

  /// Updates the current user's password to [newPassword].
  ///
  /// Used both during active password recovery and authenticated updates.
  /// Throws an `AuthFailure` subclass on failure.
  Future<AuthUser> updatePassword({required String newPassword});

  /// Signs the current user out and clears local session state.
  ///
  /// Throws an `AuthFailure` subclass on failure.
  Future<void> signOut();
}
