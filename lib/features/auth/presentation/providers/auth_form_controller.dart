import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_form_state.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';

/// Controller managing authentication form actions, loading indicators,
/// localized failure surfacing, and post-action confirmation states.
class AuthFormController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  /// Switches the login screen between sign-in, sign-up, and forgot-password
  /// modes, clearing stale errors and confirmation notices.
  void switchMode(AuthScreenMode nextMode) {
    if (state.isLoading) return;
    state = AuthFormState(mode: nextMode);
  }

  /// Clears any active failure banner without changing form mode.
  void clearError() {
    if (state.failure == null) return;
    state = state.copyWith(failure: null);
  }

  /// Resets the form controller back to its clean initial state.
  void reset() {
    state = const AuthFormState();
  }

  /// Signs in an existing user with [email] and [password].
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _runAction(
      AuthPendingAction.emailSignIn,
      () async {
        await ref.read(authRepositoryProvider).signInWithEmail(
              email: email,
              password: password,
            );
        if (!ref.mounted) return;
        state = state.copyWith(pendingAction: null);
      },
    );
  }

  /// Registers a new user and transitions to the check-your-email state.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _runAction(
      AuthPendingAction.emailSignUp,
      () async {
        final trimmedEmail = email.trim();
        await ref.read(authRepositoryProvider).signUpWithEmail(
              email: trimmedEmail,
              password: password,
            );
        if (!ref.mounted) return;
        state = state.copyWith(
          pendingAction: null,
          isSignUpSuccess: true,
          submittedEmail: trimmedEmail,
        );
      },
    );
  }

  /// Starts Google OAuth sign-in.
  Future<bool> signInWithGoogle() {
    return _runAction(
      AuthPendingAction.googleSignIn,
      () async {
        await ref.read(authRepositoryProvider).signInWithGoogle();
        if (!ref.mounted) return;
        state = state.copyWith(pendingAction: null);
      },
    );
  }

  /// Requests a password reset link for [email].
  Future<bool> sendPasswordReset({required String email}) {
    return _runAction(
      AuthPendingAction.sendPasswordReset,
      () async {
        final trimmedEmail = email.trim();
        await ref
            .read(authRepositoryProvider)
            .sendPasswordReset(email: trimmedEmail);
        if (!ref.mounted) return;
        state = state.copyWith(
          pendingAction: null,
          isResetEmailSent: true,
          submittedEmail: trimmedEmail,
        );
      },
    );
  }

  /// Updates the active user's password on `/reset-password`.
  Future<bool> updatePassword({required String newPassword}) {
    return _runAction(
      AuthPendingAction.updatePassword,
      () async {
        await ref
            .read(authRepositoryProvider)
            .updatePassword(newPassword: newPassword);
        if (!ref.mounted) return;
        state = state.copyWith(
          pendingAction: null,
          isPasswordUpdated: true,
        );
      },
    );
  }

  Future<bool> _runAction(
    AuthPendingAction action,
    Future<void> Function() task,
  ) async {
    if (state.isLoading) return false;
    state = state.copyWith(
      pendingAction: action,
      failure: null,
      isSignUpSuccess: false,
      isResetEmailSent: false,
      isPasswordUpdated: false,
    );

    try {
      await task();
      return true;
    } on AuthFailure catch (failure) {
      if (ref.mounted) {
        state = state.copyWith(
          pendingAction: null,
          failure: failure,
        );
      }
      return false;
    } on Object {
      if (ref.mounted) {
        state = state.copyWith(
          pendingAction: null,
          failure: const UnknownAuthFailure(),
        );
      }
      return false;
    }
  }
}

/// Auto-disposing Riverpod provider for authentication form UI state.
final NotifierProvider<AuthFormController, AuthFormState>
    authFormControllerProvider =
    NotifierProvider.autoDispose<AuthFormController, AuthFormState>(
  AuthFormController.new,
);
