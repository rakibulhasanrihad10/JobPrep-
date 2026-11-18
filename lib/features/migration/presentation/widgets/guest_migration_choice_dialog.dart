import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/presentation/widgets/restore_table_counts_grid.dart';

/// Choice dialog displayed when an authenticated user has existing guest data.
class GuestMigrationChoiceDialog extends ConsumerWidget {
  /// Creates a [GuestMigrationChoiceDialog].
  const GuestMigrationChoiceDialog({
    required this.tables,
    required this.onMoveData,
    required this.onStartFresh,
    super.key,
  });

  /// The local tables to display.
  final BackupDataTables tables;

  /// Callback when user chooses to move data to account.
  final VoidCallback onMoveData;

  /// Callback when user chooses to start fresh and keep device data.
  final VoidCallback onStartFresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return GlassDialog(
      key: const ValueKey('guest-migration-choice-dialog'),
      title: Row(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            color: colors.goldAccent,
            size: spacing.lg,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              l10n.migrationChoiceTitle,
              style: textStyles.titleLarge,
            ),
          ),
        ],
      ),
      content: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.migrationChoiceSubtitle,
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              RestoreTableCountsGrid(data: tables),
            ],
          ),
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('migration-choice-fresh-btn'),
          onPressed: onStartFresh,
          child: Text(l10n.migrationChoiceFreshButton),
        ),
        GlassButton(
          key: const ValueKey('migration-choice-move-btn'),
          variant: GlassButtonVariant.primary,
          onPressed: onMoveData,
          leading: Icon(Icons.arrow_upward_rounded, size: spacing.md),
          child: Text(l10n.migrationChoiceMoveButton),
        ),
      ],
    );
  }
}
