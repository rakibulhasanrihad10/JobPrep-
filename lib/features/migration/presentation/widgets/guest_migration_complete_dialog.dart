import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/migration/presentation/providers/guest_migration_providers.dart';

/// Modal dialog confirming verified completion of guest migration.
class GuestMigrationCompleteDialog extends ConsumerStatefulWidget {
  /// Creates a [GuestMigrationCompleteDialog].
  const GuestMigrationCompleteDialog({
    required this.onFinish,
    super.key,
  });

  /// Callback to finalize migration with the chosen `eraseLocalCopy` value.
  final void Function({required bool eraseLocalCopy}) onFinish;

  @override
  ConsumerState<GuestMigrationCompleteDialog> createState() =>
      _GuestMigrationCompleteDialogState();
}

class _GuestMigrationCompleteDialogState
    extends ConsumerState<GuestMigrationCompleteDialog> {
  bool _eraseLocalCopy = true;
  bool _isDownloadingBackup = false;

  Future<void> _handleDownloadBackup() async {
    final state = ref.read(guestMigrationControllerProvider);
    final manifest = state.finalBackupManifest;
    if (manifest == null) return;

    setState(() => _isDownloadingBackup = true);
    final saver = ref.read(backupFileSaverProvider);
    final timestamp = manifest.exportedAt
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = 'jobprep_final_safety_backup_$timestamp.json';

    final bytes = Uint8List.fromList(utf8.encode(manifest.toJsonString()));
    await saver(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
    );

    if (mounted) {
      setState(() => _isDownloadingBackup = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.backupExportSuccess(fileName)),
        ),
      );
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
      key: const ValueKey('guest-migration-complete-dialog'),
      title: Row(
        children: [
          Icon(
            Icons.verified_outlined,
            color: colors.success,
            size: spacing.lg,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              l10n.migrationCompleteTitle,
              style: textStyles.titleLarge,
            ),
          ),
        ],
      ),
      content: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.migrationCompleteSubtitle,
              style: textStyles.bodyMedium,
            ),
            SizedBox(height: spacing.md),
            // Optional final safety backup button
            GlassButton(
              key: const ValueKey('migration-download-final-backup-btn'),
              onPressed: _isDownloadingBackup ? null : _handleDownloadBackup,
              leading: _isDownloadingBackup
                  ? SizedBox(
                      width: spacing.md,
                      height: spacing.md,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(colors.textPrimary),
                      ),
                    )
                  : Icon(Icons.file_download_outlined, size: spacing.md),
              child: Text(l10n.migrationDownloadFinalBackup),
            ),
            SizedBox(height: spacing.md),
            // Erase local copy switch
            Material(
              color: colors.surfaceElevated,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.glassBorder),
                borderRadius: radii.buttonRadius,
              ),
              child: SwitchListTile.adaptive(
                key: const ValueKey('migration-erase-local-switch'),
                value: _eraseLocalCopy,
                activeTrackColor: colors.goldAccent,
                title: Text(
                  l10n.migrationEraseLocalOption,
                  style: textStyles.labelMedium,
                ),
                subtitle: Text(
                  l10n.migrationEraseLocalSubtitle,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                onChanged: (val) => setState(() => _eraseLocalCopy = val),
              ),
            ),
          ],
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('migration-complete-finish-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: () => widget.onFinish(eraseLocalCopy: _eraseLocalCopy),
          leading: Icon(Icons.check_rounded, size: spacing.md),
          child: Text(l10n.migrationFinishButton),
        ),
      ],
    );
  }
}
