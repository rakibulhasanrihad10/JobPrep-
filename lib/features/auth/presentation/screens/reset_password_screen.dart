import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_form_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_form_state.dart';
import 'package:job_prep/features/auth/presentation/utils/auth_failure_l10n.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_action_button.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_confirmation_view.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_page_shell.dart';
import 'package:job_prep/features/auth/presentation/widgets/auth_status_banner.dart';

/// Recovery screen displayed at `/reset-password` to set a new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  /// Creates a [ResetPasswordScreen].
  const ResetPasswordScreen({
    super.key,
    this.onContinueToDashboard,
  });

  /// Optional navigation override primarily used in standalone widget tests.
  final VoidCallback? onContinueToDashboard;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    await ref
        .read(authFormControllerProvider.notifier)
        .updatePassword(newPassword: _passwordController.text);
  }

  void _handleContinue() {
    if (widget.onContinueToDashboard != null) {
      widget.onContinueToDashboard!.call();
      return;
    }
    GoRouter.maybeOf(context)?.go(AppRoutePaths.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormControllerProvider);
    final spacing = context.spacing;
    final l10n = context.l10n;

    if (formState.isPasswordUpdated) {
      return AuthPageShell(
        title: l10n.authResetPasswordTitle,
        subtitle: l10n.authResetPasswordSubtitle,
        child: AuthConfirmationView(
          buttonKey: const ValueKey('reset_continue_dashboard_button'),
          bannerTitle: l10n.authPasswordUpdatedTitle,
          bannerMessage: l10n.authPasswordUpdatedMessage,
          buttonLabel: l10n.authContinueToDashboard,
          onContinue: _handleContinue,
        ),
      );
    }

    return AuthPageShell(
      title: l10n.authResetPasswordTitle,
      subtitle: l10n.authResetPasswordSubtitle,
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
              key: const ValueKey('reset_new_password_field'),
              controller: _passwordController,
              labelText: l10n.authNewPasswordLabel,
              hintText: l10n.authNewPasswordHint,
              helperText: l10n.authPasswordMinLengthHelper,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              obscureText: _obscurePassword,
              enabled: !formState.isLoading,
              textInputAction: TextInputAction.next,
              onChanged: (_) =>
                  ref.read(authFormControllerProvider.notifier).clearError(),
              validator: (value) => validateNewPasswordField(value, l10n),
              suffixIcon: IconButton(
                key: const ValueKey('reset_toggle_password_visibility'),
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
            SizedBox(height: spacing.lg),
            GlassTextField(
              key: const ValueKey('reset_confirm_password_field'),
              controller: _confirmController,
              labelText: l10n.authConfirmPasswordLabel,
              hintText: l10n.authConfirmPasswordHint,
              prefixIcon: const Icon(Icons.lock_reset_rounded),
              obscureText: _obscureConfirm,
              enabled: !formState.isLoading,
              textInputAction: TextInputAction.done,
              onChanged: (_) =>
                  ref.read(authFormControllerProvider.notifier).clearError(),
              onSubmitted: (_) => _submit(),
              validator: (value) => validateConfirmPasswordField(
                value,
                _passwordController.text,
                l10n,
              ),
              suffixIcon: IconButton(
                key: const ValueKey('reset_toggle_confirm_visibility'),
                tooltip: _obscureConfirm
                    ? l10n.authShowPasswordTooltip
                    : l10n.authHidePasswordTooltip,
                onPressed: formState.isLoading
                    ? null
                    : () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            SizedBox(height: spacing.xl),
            AuthActionButton(
              key: const ValueKey('reset_submit_button'),
              label: l10n.authUpdatePasswordButton,
              isLoading: formState.isActionLoading(
                AuthPendingAction.updatePassword,
              ),
              isDisabled: formState.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
