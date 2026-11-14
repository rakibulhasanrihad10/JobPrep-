import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/backup/presentation/widgets/backup_passphrase_dialog.dart';

/// Gentle in-app reminder banner displayed when backup has not been
/// taken for 7+ days.
class BackupReminderBanner extends ConsumerWidget {
  /// Creates a [BackupReminderBanner].
  const BackupReminderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(backupReminderVisibleProvider);
    if (!visible) return const SizedBox.shrink();

    final lastBackup = ref.watch(lastBackupTimeProvider);
    final changesAsync = ref.watch(backupChangesCountProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final days =
        lastBackup != null ? DateTime.now().difference(lastBackup).inDays : 7;
    final changes = changesAsync.asData?.value ?? 1;

    return GlassCard(
      key: const ValueKey('backup-reminder-banner'),
      padding: spacing.insetsAllMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.backup_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsBackupReminderTitle,
                  style: textStyles.titleMedium,
                ),
              ),
              IconButton(
                key: const ValueKey('backup-reminder-dismiss-btn'),
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  ref.read(backupReminderDismissedProvider.notifier).dismiss();
                },
                tooltip: l10n.settingsBackupReminderDismiss,
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsBackupReminderMessage(days, changes),
            style: textStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('backup-reminder-action-btn'),
              icon: const Icon(Icons.download_for_offline_outlined),
              label: Text(l10n.settingsBackupReminderAction),
              onPressed: () => showBackupPassphraseDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}
