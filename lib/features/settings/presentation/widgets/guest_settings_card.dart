import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/storage/persistent_storage_service.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/backup/domain/utils/backup_time_formatter.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/backup/presentation/utils/backup_flow_helper.dart';
import 'package:job_prep/features/backup/presentation/widgets/backup_passphrase_dialog.dart';

/// Settings card rendered in guest mode replacing the account profile section.
class GuestSettingsCard extends ConsumerWidget {
  /// Creates a [GuestSettingsCard].
  const GuestSettingsCard({super.key});

  Future<void> _handleEraseData(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    // First confirmation dialog
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const ValueKey('erase_data_dialog_step_1'),
        title: Text(l10n.eraseDataDialog1Title),
        content: Text(l10n.eraseDataDialog1Message),
        actions: [
          TextButton(
            key: const ValueKey('erase_data_dialog_1_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.eraseDataDialogCancel),
          ),
          FilledButton(
            key: const ValueKey('erase_data_dialog_1_confirm_button'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.eraseDataDialog1Confirm),
          ),
        ],
      ),
    );

    if (firstConfirmed != true || !context.mounted) return;

    // Second confirmation dialog
    final secondConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const ValueKey('erase_data_dialog_step_2'),
        title: Text(l10n.eraseDataDialog2Title),
        content: Text(l10n.eraseDataDialog2Message),
        actions: [
          TextButton(
            key: const ValueKey('erase_data_dialog_2_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.eraseDataDialogCancel),
          ),
          FilledButton(
            key: const ValueKey('erase_data_dialog_2_confirm_button'),
            style: FilledButton.styleFrom(
              backgroundColor: ctx.tokens.colors.danger,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.eraseDataDialog2Confirm),
          ),
        ],
      ),
    );

    if (secondConfirmed != true || !context.mounted) return;

    await ref.read(appModeProvider.notifier).eraseAllData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('erase_data_success_snackbar'),
          content: Text(l10n.eraseDataSuccessMessage),
        ),
      );
      context.go(AppRoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final storageStatusAsync = ref.watch(persistentStorageStatusProvider);

    final isPersistent = storageStatusAsync.asData?.value ?? false;
    final lastBackup = ref.watch(lastBackupTimeProvider);

    return GlassCard(
      key: const ValueKey('settings-guest-section-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.phonelink_setup_rounded,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsGuestSectionTitle,
                  style: textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsGuestSectionSubtitle,
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.md),
          // Storage Status
          Container(
            key: const ValueKey('settings-guest-storage-status'),
            padding: spacing.insetsAllMd,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: tokens.radii.buttonRadius,
              border: Border.all(color: colors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPersistent
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      size: spacing.md,
                      color: isPersistent ? colors.success : colors.warning,
                    ),
                    SizedBox(width: spacing.xs),
                    Text(
                      l10n.settingsStorageStatusTitle,
                      style: textStyles.labelMedium,
                    ),
                  ],
                ),
                SizedBox(height: spacing.xs),
                Text(
                  isPersistent
                      ? l10n.settingsStoragePersistent
                      : l10n.settingsStorageTransient,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (kIsWeb) ...[
                  SizedBox(height: spacing.xs),
                  Text(
                    l10n.settingsStorageSafariWarning,
                    key: const ValueKey('settings-safari-warning-text'),
                    style: textStyles.labelSmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: spacing.xs),
                Text(
                  BackupTimeFormatter.format(lastBackup, l10n),
                  key: const ValueKey('settings-last-backup-text'),
                  style: textStyles.labelSmall.copyWith(
                    color: colors.goldAccent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              GlassButton(
                key: const ValueKey('settings-guest-backup-btn'),
                onPressed: () => unawaited(showBackupPassphraseDialog(context)),
                leading: Icon(Icons.backup_outlined, size: spacing.lg),
                child: Text(l10n.settingsBackupDataButton),
              ),
              GlassButton(
                key: const ValueKey('settings-guest-restore-btn'),
                onPressed: () => unawaited(
                  BackupFlowHelper.triggerRestoreFlow(context, ref),
                ),
                leading: Icon(Icons.restore_page_outlined, size: spacing.lg),
                child: Text(l10n.settingsRestoreButton),
              ),
              GlassButton(
                key: const ValueKey('settings-guest-create-account-btn'),
                variant: GlassButtonVariant.primary,
                onPressed: () => context.go(AppRoutePaths.login),
                leading: Icon(
                  Icons.person_add_alt_1_outlined,
                  size: spacing.lg,
                ),
                child: Text(l10n.settingsCreateAccountButton),
              ),
              GlassButton(
                key: const ValueKey('settings-guest-erase-data-btn'),
                onPressed: () => unawaited(_handleEraseData(context, ref)),
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  size: spacing.lg,
                  color: colors.danger,
                ),
                child: Text(
                  l10n.settingsEraseDataButton,
                  style: textStyles.labelLarge.copyWith(
                    color: colors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
