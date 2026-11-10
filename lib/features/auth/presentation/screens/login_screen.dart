import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_form_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_form_state.dart';
import 'package:job_prep/features/auth/presentation/utils/auth_failure_l10n.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_confirmation_view.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_mode_toggle_footer.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_page_shell.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_status_banner.dart';

/// Authentication screen supporting Email Sign-In, Account Creation,
/// Forgot Password recovery requests, and Google OAuth sign-in.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(AuthFormState formState) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final controller = ref.read(authFormControllerProvider.notifier);
    final email = _emailController.text;
    final password = _passwordController.text;

    switch (formState.mode) {
      case AuthScreenMode.signIn:
        await controller.signInWithEmail(email: email, password: password);
      case AuthScreenMode.signUp:
        await controller.signUpWithEmail(email: email, password: password);
      case AuthScreenMode.forgotPassword:
        await controller.sendPasswordReset(email: email);
    }
  }

  void _switchMode(AuthScreenMode nextMode) {
    _formKey.currentState?.reset();
    ref.read(authFormControllerProvider.notifier).switchMode(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormControllerProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final (title, subtitle) = switch (formState.mode) {
      AuthScreenMode.signIn => (l10n.authSignInTitle, l10n.authSignInSubtitle),
      AuthScreenMode.signUp => (l10n.authSignUpTitle, l10n.authSignUpSubtitle),
      AuthScreenMode.forgotPassword => (
          l10n.authForgotPasswordTitle,
          l10n.authForgotPasswordSubtitle,
        ),
    };

    if (formState.isSignUpSuccess) {
      return AuthPageShell(
        title: title,
        subtitle: subtitle,
        child: AuthConfirmationView(
          buttonKey: const ValueKey('auth_confirmation_back_button'),
          bannerTitle: l10n.authCheckEmailTitle,
          bannerMessage: l10n.authCheckEmailMessage(
            formState.submittedEmail ?? _emailController.text.trim(),
          ),
          buttonLabel: l10n.authBackToSignIn,
          onContinue: () => _switchMode(AuthScreenMode.signIn),
        ),
      );
    }

    if (formState.isResetEmailSent) {
      return AuthPageShell(
        title: title,
        subtitle: subtitle,
        child: AuthConfirmationView(
          buttonKey: const ValueKey('auth_confirmation_back_button'),
          bannerTitle: l10n.authResetLinkSentTitle,
          bannerMessage: l10n.authResetLinkSentMessage(
            formState.submittedEmail ?? _emailController.text.trim(),
          ),
          buttonLabel: l10n.authBackToSignIn,
          onContinue: () => _switchMode(AuthScreenMode.signIn),
        ),
      );
    }

    final primaryAction = switch (formState.mode) {
      AuthScreenMode.signIn => AuthPendingAction.emailSignIn,
      AuthScreenMode.signUp => AuthPendingAction.emailSignUp,
      AuthScreenMode.forgotPassword => AuthPendingAction.sendPasswordReset,
    };

    final primaryLabel = switch (formState.mode) {
      AuthScreenMode.signIn => l10n.authSignInButton,
      AuthScreenMode.signUp => l10n.authCreateAccountButton,
      AuthScreenMode.forgotPassword => l10n.authSendResetLinkButton,
    };

    return AuthPageShell(
      title: title,
      subtitle: subtitle,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (formState.failure != null) ...[
              AuthStatusBanner(
                tone: AuthBannerTone.error,
                message: localizeAuthFailure(formState.failure!, l10n),
              ),
              SizedBox(height: spacing.lg),
            ],
            GlassTextField(
              key: const ValueKey('auth_email_field'),
              controller: _emailController,
              labelText: l10n.authEmailLabel,
              hintText: l10n.authEmailHint,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              keyboardType: TextInputType.emailAddress,
              textInputAction: formState.mode == AuthScreenMode.forgotPassword
                  ? TextInputAction.done
                  : TextInputAction.next,
              enabled: !formState.isLoading,
              onChanged: (_) =>
                  ref.read(authFormControllerProvider.notifier).clearError(),
              onSubmitted: formState.mode == AuthScreenMode.forgotPassword
                  ? (_) => _submitForm(formState)
                  : null,
              validator: (value) => validateEmailField(value, l10n),
            ),
            if (formState.mode != AuthScreenMode.forgotPassword) ...[
              SizedBox(height: spacing.lg),
              GlassTextField(
                key: const ValueKey('auth_password_field'),
                controller: _passwordController,
                labelText: l10n.authPasswordLabel,
                hintText: formState.mode == AuthScreenMode.signUp
                    ? l10n.authNewPasswordHint
                    : l10n.authPasswordHint,
                helperText: formState.mode == AuthScreenMode.signUp
                    ? l10n.authPasswordMinLengthHelper
                    : null,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                obscureText: _obscurePassword,
                enabled: !formState.isLoading,
                textInputAction: TextInputAction.done,
                onChanged: (_) =>
                    ref.read(authFormControllerProvider.notifier).clearError(),
                onSubmitted: (_) => _submitForm(formState),
                validator: (value) => formState.mode == AuthScreenMode.signUp
                    ? validateNewPasswordField(value, l10n)
                    : validateSignInPasswordField(value, l10n),
                suffixIcon: IconButton(
                  key: const ValueKey('auth_toggle_password_visibility'),
                  tooltip: _obscurePassword
                      ? l10n.authShowPasswordTooltip
                      : l10n.authHidePasswordTooltip,
                  onPressed: formState.isLoading
                      ? null
                      : () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ],
            if (formState.mode == AuthScreenMode.signIn) ...[
              SizedBox(height: spacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const ValueKey('auth_forgot_password_button'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.goldAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: radii.buttonRadius,
                    ),
                  ),
                  onPressed: formState.isLoading
                      ? null
                      : () => _switchMode(AuthScreenMode.forgotPassword),
                  child: Text(l10n.authForgotPasswordLink),
                ),
              ),
            ] else
              SizedBox(height: spacing.lg),
            AuthActionButton(
              key: const ValueKey('auth_primary_submit_button'),
              label: primaryLabel,
              isLoading: formState.isActionLoading(primaryAction),
              isDisabled: formState.isLoading,
              onPressed: () => _submitForm(formState),
            ),
            if (formState.mode != AuthScreenMode.forgotPassword) ...[
              SizedBox(height: spacing.lg),
              Row(
                children: [
                  Expanded(child: Divider(color: colors.glassBorder)),
                  Padding(
                    padding: spacing.insetsHorizontalMd,
                    child: Text(
                      l10n.authOrDivider,
                      style: textStyles.labelSmall,
                    ),
                  ),
                  Expanded(child: Divider(color: colors.glassBorder)),
                ],
              ),
              SizedBox(height: spacing.lg),
              AuthActionButton(
                key: const ValueKey('auth_google_button'),
                label: l10n.authContinueWithGoogle,
                variant: GlassButtonVariant.standard,
                leading: const AuthGoogleMark(),
                isLoading: formState.isActionLoading(
                  AuthPendingAction.googleSignIn,
                ),
                isDisabled: formState.isLoading,
                onPressed: () => ref
                    .read(authFormControllerProvider.notifier)
                    .signInWithGoogle(),
              ),
            ],
            SizedBox(height: spacing.lg),
            AuthModeToggleFooter(
              mode: formState.mode,
              isDisabled: formState.isLoading,
              onSwitchMode: _switchMode,
            ),
          ],
        ),
      ),
    );
  }
}
