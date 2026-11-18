import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/presentation/utils/auth_failure_l10n.dart';
import 'package:job_prep/features/settings/presentation/providers/settings_account_controller.dart';

/// Opens a frosted glass dialog allowing the signed-in user to update their
/// password. Returns `true` if the password was updated.
Future<bool> showChangePasswordDialog(BuildContext context) async {
  final result = await showGlassDialog<bool>(
    context: context,
    builder: (_) => const ChangePasswordDialog(),
  );
  return result ?? false;
}

/// Frosted glass dialog validating and applying a new login password.
class ChangePasswordDialog extends ConsumerStatefulWidget {
  /// Creates a [ChangePasswordDialog].
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController
      ..clear()
      ..dispose();
    _confirmController
      ..clear()
      ..dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final error = await ref
        .read(settingsAccountControllerProvider.notifier)
        .updatePassword(_passwordController.text);

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    final l10n = context.l10n;
    final msg = error is AuthFailure
        ? localizeAuthFailure(error, l10n)
        : l10n.settingsPasswordError;
    setState(() {
      _submitting = false;
      _errorText = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassDialog(
      title: Text(l10n.settingsChangePasswordTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                key: const ValueKey('settings-new-password-field'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_submitting,
                labelText: l10n.settingsNewPasswordLabel,
                validator: (value) => validateNewPasswordField(value, l10n),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('settings-confirm-password-field'),
                controller: _confirmController,
                obscureText: _obscureConfirm,
                enabled: !_submitting,
                labelText: l10n.settingsConfirmPasswordLabel,
                validator: (value) => validateConfirmPasswordField(
                  value,
                  _passwordController.text,
                  l10n,
                ),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              if (_errorText != null) ...[
                SizedBox(height: spacing.sm),
                Text(
                  _errorText!,
                  key: const ValueKey('settings-change-password-error'),
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _submitting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('settings-confirm-password-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.settingsPasswordSaveButton),
        ),
      ],
    );
  }
}
