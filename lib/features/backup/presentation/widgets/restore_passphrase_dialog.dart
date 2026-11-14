import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/backup/domain/entities/backup_crypto_envelope.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';

/// Opens the passphrase dialog to unlock an encrypted backup.
Future<BackupManifest?> showRestorePassphraseDialog(
  BuildContext context, {
  required BackupCryptoEnvelope envelope,
}) {
  return showGlassDialog<BackupManifest>(
    context: context,
    builder: (_) => RestorePassphraseDialog(envelope: envelope),
  );
}

/// Dialog asking for backup passphrase to decrypt and preview envelope.
class RestorePassphraseDialog extends ConsumerStatefulWidget {
  /// Creates a [RestorePassphraseDialog].
  const RestorePassphraseDialog({
    required this.envelope,
    super.key,
  });

  /// Encrypted envelope to unlock.
  final BackupCryptoEnvelope envelope;

  @override
  ConsumerState<RestorePassphraseDialog> createState() =>
      _RestorePassphraseDialogState();
}

class _RestorePassphraseDialogState
    extends ConsumerState<RestorePassphraseDialog> {
  final _passphraseController = TextEditingController();
  bool _isUnlocking = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _handleUnlock() async {
    final passphrase = _passphraseController.text.trim();
    if (passphrase.isEmpty || _isUnlocking) return;

    final l10n = context.l10n;
    setState(() {
      _isUnlocking = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(backupControllerProvider);
      final result = await controller.unlockEncryptedBackup(
        envelope: widget.envelope,
        passphrase: passphrase,
      );

      if (!mounted) return;
      if (result.isValid && result.manifest != null) {
        Navigator.of(context).pop(result.manifest);
      } else {
        setState(() {
          _isUnlocking = false;
          _errorMessage = l10n.restoreErrorWrongPassphrase;
        });
      }
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _isUnlocking = false;
        _errorMessage = l10n.restoreErrorWrongPassphrase;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassDialog(
      key: const ValueKey('restore-passphrase-dialog'),
      title: Text(l10n.restoreDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.restorePassphrasePrompt,
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: spacing.md),
            TextFormField(
              key: const ValueKey('restore-passphrase-input'),
              controller: _passphraseController,
              obscureText: true,
              enabled: !_isUnlocking,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.restorePassphraseLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              onFieldSubmitted: (_) => _handleUnlock(),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                _errorMessage!,
                key: const ValueKey('restore-passphrase-error-text'),
                style: textStyles.bodySmall.copyWith(color: colors.danger),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('restore-passphrase-cancel-btn'),
          onPressed: _isUnlocking ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.backupDialogCancel),
        ),
        GlassButton(
          key: const ValueKey('restore-passphrase-submit-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: _isUnlocking ? null : _handleUnlock,
          leading: _isUnlocking
              ? SizedBox(
                  width: spacing.md,
                  height: spacing.md,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.textPrimary),
                  ),
                )
              : Icon(Icons.lock_open_rounded, size: spacing.lg),
          child: Text(l10n.restorePassphraseSubmit),
        ),
      ],
    );
  }
}
