import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/account_feature_gate.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/backup/domain/utils/backup_time_formatter.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/backup/presentation/utils/backup_flow_helper.dart';
import 'package:job_prep/features/backup/presentation/widgets/backup_passphrase_dialog.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_builder.dart';
import 'package:job_prep/features/settings/presentation/providers/data_export_providers.dart';
import 'package:job_prep/features/settings/presentation/widgets/delete_account_dialog.dart';

/// Data section card allowing CSV/JSON full export of circulars and prep data
/// plus confirmed permanent account deletion.
class DataSettingsCard extends ConsumerWidget {
  /// Creates a [DataSettingsCard].
  const DataSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final exportState = ref.watch(dataExportControllerProvider);
    final lastBackup = ref.watch(lastBackupTimeProvider);

    return GlassCard(
      key: const ValueKey('settings-data-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.download_for_offline_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsDataTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsDataSubtitle,
            style: tokens.textStyles.bodySmall,
          ),
          SizedBox(height: spacing.xs),
          Text(
            BackupTimeFormatter.format(lastBackup, l10n),
            key: const ValueKey('settings-signed-in-last-backup-text'),
            style: tokens.textStyles.labelSmall.copyWith(
              color: colors.goldAccent,
            ),
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              GlassButton(
                key: const ValueKey('settings-backup-btn'),
                onPressed: exportState.isExporting
                    ? null
                    : () => unawaited(showBackupPassphraseDialog(context)),
                leading: Icon(Icons.backup_outlined, size: spacing.lg),
                child: Text(l10n.settingsBackupDataButton),
              ),
              GlassButton(
                key: const ValueKey('settings-restore-btn'),
                onPressed: exportState.isExporting
                    ? null
                    : () => unawaited(
                          BackupFlowHelper.triggerRestoreFlow(context, ref),
                        ),
                leading: Icon(Icons.restore_page_outlined, size: spacing.lg),
                child: Text(l10n.settingsRestoreButton),
              ),
              GlassButton(
                key: const ValueKey('settings-export-csv-btn'),
                onPressed: exportState.isExporting
                    ? null
                    : () => unawaited(
                          ref
                              .read(dataExportControllerProvider.notifier)
                              .exportAll(DataExportFormat.csv),
                        ),
                leading: Icon(Icons.table_view_rounded, size: spacing.lg),
                child: Text(l10n.settingsExportCsvButton),
              ),
              GlassButton(
                key: const ValueKey('settings-export-json-btn'),
                onPressed: exportState.isExporting
                    ? null
                    : () => unawaited(
                          ref
                              .read(dataExportControllerProvider.notifier)
                              .exportAll(DataExportFormat.json),
                        ),
                leading: Icon(Icons.data_object_rounded, size: spacing.lg),
                child: Text(l10n.settingsExportJsonButton),
              ),
              AccountFeatureGate(
                feature: AccountOnlyFeature.deleteAccount,
                compact: true,
                child: GlassButton(
                  key: const ValueKey('settings-delete-account-btn'),
                  onPressed: exportState.isExporting
                      ? null
                      : () => unawaited(showDeleteAccountDialog(context)),
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    size: spacing.lg,
                    color: colors.danger,
                  ),
                  child: Text(
                    l10n.settingsDeleteAccountButton,
                    style: tokens.textStyles.labelLarge.copyWith(
                      color: colors.danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (exportState.failed) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.settingsExportError,
              key: const ValueKey('settings-export-error'),
              style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ] else if (exportState.lastExportedFileName != null) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.settingsExportSuccess(exportState.lastExportedFileName!),
              key: const ValueKey('settings-export-success'),
              style: tokens.textStyles.bodySmall.copyWith(
                color: colors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
