import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_passphrase_field.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_setup_warning_banner.dart';

/// Opens the first-time vault passphrase setup dialog (if no verifier exists)
/// or the vault unlock prompt cleanly. Returns `true` when unlocked.
Future<bool> showVaultUnlockDialog(BuildContext context) async {
  final result = await showGlassDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const VaultUnlockDialog(),
  );
  return result ?? false;
}

/// Dialog guiding either first-time passphrase creation (with explicit
/// non-recovery warning) or unlocking an existing passphrase check verifier.
class VaultUnlockDialog extends ConsumerStatefulWidget {
  /// Creates a [VaultUnlockDialog].
  const VaultUnlockDialog({super.key});

  @override
  ConsumerState<VaultUnlockDialog> createState() => _VaultUnlockDialogState();
}

class _VaultUnlockDialogState extends ConsumerState<VaultUnlockDialog> {
  static const int _minPassphraseLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassphrase = true;
  bool _obscureConfirm = true;
  bool _acknowledgedWarning = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passphraseController
      ..clear()
      ..dispose();
    _confirmController
      ..clear()
      ..dispose();
    super.dispose();
  }

  Future<void> _submitAuthAction({
    required Future<bool> Function() action,
    required String failureMessage,
  }) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final ok = await action();
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = failureMessage;
        });
      }
    } on Object {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = failureMessage;
      });
    }
  }

  Future<void> _submitSetup() async {
    final l10n = context.l10n;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acknowledgedWarning) {
      setState(() => _errorMessage = l10n.vaultAcknowledgeRequiredError);
      return;
    }
    await _submitAuthAction(
      action: () => ref
          .read(portalVaultControllerProvider.notifier)
          .setupPassphrase(_passphraseController.text),
      failureMessage: l10n.portalSaveError,
    );
  }

  Future<void> _submitUnlock() async {
    final l10n = context.l10n;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _submitAuthAction(
      action: () => ref
          .read(portalVaultControllerProvider.notifier)
          .unlockWithPassphrase(_passphraseController.text),
      failureMessage: l10n.vaultWrongPassphraseError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final verifierAsync = ref.watch(vaultVerifierProvider);

    return verifierAsync.when(
      loading: () => GlassDialog(
        title: Text(l10n.vaultUnlockDialogTitle, style: textStyles.titleLarge),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.xl),
          child: const Center(child: CircularProgressIndicator()),
        ),
        actions: [
          GlassButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.circularFormCancelButton),
          ),
        ],
      ),
      error: (_, __) => GlassDialog(
        title: Text(l10n.vaultTitle, style: textStyles.titleLarge),
        content: Text(
          l10n.portalLoadError,
          style: textStyles.bodyMedium.copyWith(color: colors.danger),
        ),
        actions: [
          GlassButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.circularFormCancelButton),
          ),
          GlassButton(
            variant: GlassButtonVariant.primary,
            onPressed: () => ref.invalidate(vaultVerifierProvider),
            child: Text(l10n.circularsRetryButton),
          ),
        ],
      ),
      data: (verifier) {
        final isSetupMode = verifier == null;

        return GlassDialog(
          key: ValueKey(
            isSetupMode ? 'vault-setup-dialog' : 'vault-unlock-dialog',
          ),
          title: Text(
            isSetupMode
                ? l10n.vaultSetupDialogTitle
                : l10n.vaultUnlockDialogTitle,
            style: textStyles.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isSetupMode
                        ? l10n.vaultSetupDialogBody
                        : l10n.vaultUnlockDialogBody,
                    style: textStyles.bodyMedium,
                  ),
                  if (isSetupMode) ...[
                    SizedBox(height: spacing.md),
                    const VaultSetupWarningBanner(),
                  ],
                  SizedBox(height: spacing.lg),
                  VaultPassphraseField(
                    fieldKey: const ValueKey('vault-passphrase-field'),
                    controller: _passphraseController,
                    labelText: l10n.vaultPassphraseLabel,
                    obscureText: _obscurePassphrase,
                    autofocus: true,
                    enabled: !_isSubmitting,
                    onToggleObscure: () => setState(
                      () => _obscurePassphrase = !_obscurePassphrase,
                    ),
                    textInputAction: isSetupMode
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onSubmitted:
                        isSetupMode ? null : (_) => unawaited(_submitUnlock()),
                    validator: (value) {
                      final trimmed = value ?? '';
                      if (trimmed.length < _minPassphraseLength) {
                        return l10n.vaultPassphraseTooShortError;
                      }
                      return null;
                    },
                  ),
                  if (isSetupMode) ...[
                    SizedBox(height: spacing.md),
                    VaultPassphraseField(
                      fieldKey:
                          const ValueKey('vault-confirm-passphrase-field'),
                      controller: _confirmController,
                      labelText: l10n.vaultPassphraseConfirmLabel,
                      obscureText: _obscureConfirm,
                      enabled: !_isSubmitting,
                      onToggleObscure: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => unawaited(_submitSetup()),
                      validator: (value) {
                        if (value != _passphraseController.text) {
                          return l10n.vaultPassphraseMismatchError;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: spacing.sm),
                    VaultSetupAckCheckbox(
                      value: _acknowledgedWarning,
                      enabled: !_isSubmitting,
                      onChanged: (checked) => setState(() {
                        _acknowledgedWarning = checked;
                        if (_acknowledgedWarning) _errorMessage = null;
                      }),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    SizedBox(height: spacing.sm),
                    Text(
                      _errorMessage!,
                      key: const ValueKey('vault-dialog-error-text'),
                      style:
                          textStyles.bodySmall.copyWith(color: colors.danger),
                    ),
                  ],
                  SizedBox(height: spacing.sm),
                  Text(l10n.vaultAutoLockNote, style: textStyles.bodySmall),
                ],
              ),
            ),
          ),
          actions: [
            GlassButton(
              key: const ValueKey('vault-dialog-cancel'),
              onPressed:
                  _isSubmitting ? null : () => Navigator.of(context).pop(false),
              child: Text(l10n.circularFormCancelButton),
            ),
            GlassButton(
              key: const ValueKey('vault-dialog-submit'),
              variant: GlassButtonVariant.primary,
              onPressed: _isSubmitting
                  ? null
                  : () => unawaited(
                        isSetupMode ? _submitSetup() : _submitUnlock(),
                      ),
              child: _isSubmitting
                  ? SizedBox(
                      width: spacing.lg,
                      height: spacing.lg,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isSetupMode
                          ? l10n.vaultCreateAndUnlockAction
                          : l10n.vaultUnlockButton,
                    ),
            ),
          ],
        );
      },
    );
  }
}
