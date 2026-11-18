import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';

/// Displays the backup export configuration dialog (encrypted vs plaintext).
Future<String?> showBackupPassphraseDialog(BuildContext context) {
  return showGlassDialog<String>(
    context: context,
    builder: (_) => const BackupPassphraseDialog(),
  );
}

/// Dialog allowing user to configure passphrase encryption or export plain
/// backup.
class BackupPassphraseDialog extends ConsumerStatefulWidget {
  /// Creates a [BackupPassphraseDialog].
  const BackupPassphraseDialog({super.key});

  @override
  ConsumerState<BackupPassphraseDialog> createState() =>
      _BackupPassphraseDialogState();
}

class _BackupPassphraseDialogState
    extends ConsumerState<BackupPassphraseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isEncrypted = true;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final l10n = context.l10n;
    if (_isEncrypted) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }
    }

    setState(() {
      _isExporting = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(backupControllerProvider);
      final fileName = await controller.exportBackup(
        passphrase: _isEncrypted ? _passphraseController.text.trim() : null,
      );

      if (!mounted) return;

      if (fileName != null) {
        Navigator.of(context).pop(fileName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const ValueKey('backup-export-success-snack'),
            content: Text(l10n.backupExportSuccess(fileName)),
          ),
        );
      } else {
        setState(() => _isExporting = false);
      }
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassDialog(
      key: const ValueKey('backup-passphrase-dialog'),
      title: Text(l10n.backupDialogTitle),
      content: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.backupDialogDescription,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: spacing.md),
                // Encryption toggle
                Material(
                  color: colors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colors.glassBorder),
                    borderRadius: radii.buttonRadius,
                  ),
                  child: SwitchListTile.adaptive(
                    key: const ValueKey('backup-encryption-switch'),
                    value: _isEncrypted,
                    activeTrackColor: colors.goldAccent,
                    title: Text(
                      l10n.backupEncryptionRecommended,
                      style: textStyles.labelMedium,
                    ),
                    onChanged: _isExporting
                        ? null
                        : (val) {
                            setState(() {
                              _isEncrypted = val;
                              _errorMessage = null;
                            });
                          },
                  ),
                ),
                SizedBox(height: spacing.md),
                if (_isEncrypted) ...[
                  // Passphrase encryption explanation
                  Container(
                    padding: spacing.insetsAllMd,
                    decoration: BoxDecoration(
                      color: colors.goldAccent.withValues(alpha: 0.1),
                      borderRadius: radii.cardRadius,
                      border: Border.all(
                        color: colors.goldAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: spacing.lg,
                          color: colors.goldAccent,
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: Text(
                            l10n.backupEncryptionNote,
                            style: textStyles.bodySmall.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  TextFormField(
                    key: const ValueKey('backup-passphrase-input'),
                    controller: _passphraseController,
                    obscureText: true,
                    enabled: !_isExporting,
                    decoration: InputDecoration(
                      labelText: l10n.backupPassphraseLabel,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 8) {
                        return l10n.backupPassphraseTooShort;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing.sm),
                  TextFormField(
                    key: const ValueKey('backup-passphrase-confirm-input'),
                    controller: _confirmController,
                    obscureText: true,
                    enabled: !_isExporting,
                    decoration: InputDecoration(
                      labelText: l10n.backupPassphraseConfirmLabel,
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                    ),
                    validator: (val) {
                      if (val != _passphraseController.text) {
                        return l10n.backupPassphraseMismatch;
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  // Plaintext warning banner
                  Container(
                    key: const ValueKey('backup-plaintext-warning-banner'),
                    padding: spacing.insetsAllMd,
                    decoration: BoxDecoration(
                      color: colors.danger.withValues(alpha: 0.12),
                      borderRadius: radii.cardRadius,
                      border: Border.all(
                        color: colors.danger.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: spacing.lg,
                          color: colors.danger,
                        ),
                        SizedBox(width: spacing.sm),
                        Expanded(
                          child: Text(
                            l10n.backupExportPlainWarning,
                            style: textStyles.bodySmall.copyWith(
                              color: colors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  SizedBox(height: spacing.sm),
                  Text(
                    _errorMessage!,
                    key: const ValueKey('backup-export-error-text'),
                    style: textStyles.bodySmall.copyWith(color: colors.danger),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('backup-dialog-cancel-btn'),
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.backupDialogCancel),
        ),
        GlassButton(
          key: const ValueKey('backup-dialog-export-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: _isExporting ? null : _handleExport,
          leading: _isExporting
              ? SizedBox(
                  width: spacing.md,
                  height: spacing.md,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.textPrimary),
                  ),
                )
              : Icon(Icons.file_download_outlined, size: spacing.lg),
          child: Text(
            _isEncrypted
                ? l10n.backupExportEncryptedButton
                : l10n.backupExportPlainButton,
          ),
        ),
      ],
    );
  }
}
