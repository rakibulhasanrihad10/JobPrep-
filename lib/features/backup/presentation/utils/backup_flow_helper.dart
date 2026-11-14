import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/backup/presentation/widgets/restore_passphrase_dialog.dart';
import 'package:job_prep/features/backup/presentation/widgets/restore_preview_dialog.dart';

/// Helper executing the unified file-pick, decrypt, and restore preview flow.
abstract final class BackupFlowHelper {
  /// Picks a backup file, unlocks if encrypted, and opens the preview dialog.
  static Future<void> triggerRestoreFlow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final controller = ref.read(backupControllerProvider);

    final validation = await controller.pickAndValidateBackup();
    if (validation == null || !context.mounted) return;

    if (!validation.isValid && !validation.isEncrypted) {
      final msg = switch (validation.errorMessage) {
        'file_too_large' => l10n.restoreErrorFileTooLarge,
        'checksum_mismatch' => l10n.restoreErrorChecksumMismatch,
        'app_version_newer' => l10n.restoreErrorNewerVersion('newer'),
        _ => l10n.restoreErrorInvalidFormat,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('restore-error-snackbar'),
          content: Text(msg),
        ),
      );
      return;
    }

    var manifest = validation.manifest;

    if (validation.isEncrypted && validation.envelope != null) {
      manifest = await showRestorePassphraseDialog(
        context,
        envelope: validation.envelope!,
      );
    }

    if (manifest != null && context.mounted) {
      await showRestorePreviewDialog(context, manifest: manifest);
    }
  }
}
