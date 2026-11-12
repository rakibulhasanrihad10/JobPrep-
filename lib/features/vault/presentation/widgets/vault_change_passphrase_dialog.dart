import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_passphrase_field.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_setup_warning_banner.dart';

/// Opens a frosted glass dialog letting the user verify their current vault
/// passphrase and re-encrypt all portal credentials under a new passphrase.
Future<bool> showVaultChangePassphraseDialog(BuildContext context) async {
  final result = await showGlassDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const VaultChangePassphraseDialog(),
  );
  return result ?? false;
}

/// Dialog validating current/new passphrases and re-keying saved portal
/// credentials client-side without ever logging or persisting passphrases.
class VaultChangePassphraseDialog extends ConsumerStatefulWidget {
  /// Creates a [VaultChangePassphraseDialog].
  const VaultChangePassphraseDialog({super.key});

  @override
  ConsumerState<VaultChangePassphraseDialog> createState() =>
      _VaultChangePassphraseDialogState();
}

class _VaultChangePassphraseDialogState
    extends ConsumerState<VaultChangePassphraseDialog> {
  static const int _minPassphraseLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _acknowledgedWarning = false;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController
      ..clear()
      ..dispose();
    _newController
      ..clear()
      ..dispose();
    _confirmController
      ..clear()
      ..dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acknowledgedWarning) {
      setState(() => _errorMessage = l10n.vaultAcknowledgeRequiredError);
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final ok = await ref
          .read(portalVaultControllerProvider.notifier)
          .changePassphrase(
            currentPassphrase: _currentController.text,
            newPassphrase: _newController.text,
          );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.vaultCurrentPassphraseWrongError;
        });
      }
    } on Object {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = l10n.portalSaveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return GlassDialog(
      key: const ValueKey('vault-change-passphrase-dialog'),
      title: Text(l10n.vaultChangePassphraseTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.vaultChangePassphraseBody,
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              const VaultSetupWarningBanner(),
              SizedBox(height: spacing.md),
              VaultPassphraseField(
                fieldKey: const ValueKey('vault-current-passphrase-field'),
                controller: _currentController,
                labelText: l10n.vaultCurrentPassphraseLabel,
                obscureText: _obscureCurrent,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                onToggleObscure: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (val) => (val == null || val.isEmpty)
                    ? l10n.vaultPassphraseTooShortError
                    : null,
              ),
              SizedBox(height: spacing.md),
              VaultPassphraseField(
                fieldKey: const ValueKey('vault-new-passphrase-field'),
                controller: _newController,
                labelText: l10n.vaultNewPassphraseLabel,
                obscureText: _obscureNew,
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                onToggleObscure: () =>
                    setState(() => _obscureNew = !_obscureNew),
                validator: (val) {
                  if (val == null || val.length < _minPassphraseLength) {
                    return l10n.vaultPassphraseTooShortError;
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),
              VaultPassphraseField(
                fieldKey: const ValueKey('vault-confirm-new-passphrase-field'),
                controller: _confirmController,
                labelText: l10n.vaultConfirmNewPassphraseLabel,
                obscureText: _obscureConfirm,
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (val) => val != _newController.text
                    ? l10n.vaultPassphraseMismatchError
                    : null,
              ),
              SizedBox(height: spacing.sm),
              VaultSetupAckCheckbox(
                value: _acknowledgedWarning,
                enabled: !_submitting,
                onChanged: (checked) {
                  setState(() {
                    _acknowledgedWarning = checked;
                    if (checked) _errorMessage = null;
                  });
                },
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: spacing.xs),
                Text(
                  _errorMessage!,
                  key: const ValueKey('vault-change-error-text'),
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
          key: const ValueKey('vault-change-passphrase-submit'),
          variant: GlassButtonVariant.primary,
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.vaultChangePassphraseSubmit),
        ),
      ],
    );
  }
}
