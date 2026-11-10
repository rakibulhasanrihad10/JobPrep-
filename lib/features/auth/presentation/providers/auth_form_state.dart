import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';

/// Active interaction mode rendered by the login screen card.
enum AuthScreenMode {
  /// Standard email/password and Google sign-in mode.
  signIn,

  /// Account registration mode (8+ character password, check-email notice).
  signUp,

  /// Password reset request mode.
  forgotPassword,
}

/// Identifies which asynchronous authentication request is currently active.
enum AuthPendingAction {
  /// Email and password sign-in.
  emailSignIn,

  /// Email and password registration.
  emailSignUp,

  /// Google OAuth sign-in.
  googleSignIn,

  /// Sending password reset instructions.
  sendPasswordReset,

  /// Updating password on the recovery screen.
  updatePassword,
}

const Object _unset = Object();

/// Immutable UI state for authentication forms (login, signup, forgot/reset).
@immutable
class AuthFormState {
  /// Creates an [AuthFormState].
  const AuthFormState({
    this.mode = AuthScreenMode.signIn,
    this.pendingAction,
    this.failure,
    this.isSignUpSuccess = false,
    this.isResetEmailSent = false,
    this.isPasswordUpdated = false,
    this.submittedEmail,
  });

  /// Active mode shown on the login screen.
  final AuthScreenMode mode;

  /// Currently running async action, or `null` when idle.
  final AuthPendingAction? pendingAction;

  /// Latest failure to surface in the UI, or `null`.
  final AuthFailure? failure;

  /// Whether email registration succeeded and requires inbox confirmation.
  final bool isSignUpSuccess;

  /// Whether password reset instructions were sent.
  final bool isResetEmailSent;

  /// Whether updating password on `/reset-password` succeeded.
  final bool isPasswordUpdated;

  /// Email address entered for sign-up confirmation or password reset notices.
  final String? submittedEmail;

  /// Whether any auth action is currently loading.
  bool get isLoading => pendingAction != null;

  /// Whether the specified [action] is currently running.
  bool isActionLoading(AuthPendingAction action) => pendingAction == action;

  /// Returns a modified copy of this [AuthFormState].
  AuthFormState copyWith({
    AuthScreenMode? mode,
    Object? pendingAction = _unset,
    Object? failure = _unset,
    bool? isSignUpSuccess,
    bool? isResetEmailSent,
    bool? isPasswordUpdated,
    Object? submittedEmail = _unset,
  }) {
    return AuthFormState(
      mode: mode ?? this.mode,
      pendingAction: identical(pendingAction, _unset)
          ? this.pendingAction
          : pendingAction as AuthPendingAction?,
      failure:
          identical(failure, _unset) ? this.failure : failure as AuthFailure?,
      isSignUpSuccess: isSignUpSuccess ?? this.isSignUpSuccess,
      isResetEmailSent: isResetEmailSent ?? this.isResetEmailSent,
      isPasswordUpdated: isPasswordUpdated ?? this.isPasswordUpdated,
      submittedEmail: identical(submittedEmail, _unset)
          ? this.submittedEmail
          : submittedEmail as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthFormState &&
        other.mode == mode &&
        other.pendingAction == pendingAction &&
        other.failure == failure &&
        other.isSignUpSuccess == isSignUpSuccess &&
        other.isResetEmailSent == isResetEmailSent &&
        other.isPasswordUpdated == isPasswordUpdated &&
        other.submittedEmail == submittedEmail;
  }

  @override
  int get hashCode => Object.hash(
        mode,
        pendingAction,
        failure,
        isSignUpSuccess,
        isResetEmailSent,
        isPasswordUpdated,
        submittedEmail,
      );
}
