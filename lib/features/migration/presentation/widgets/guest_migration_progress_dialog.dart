import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/migration/presentation/providers/guest_migration_providers.dart';

/// Modal dialog rendering progress while guest records are uploaded to cloud.
class GuestMigrationProgressDialog extends ConsumerWidget {
  /// Creates a [GuestMigrationProgressDialog].
  const GuestMigrationProgressDialog({
    required this.onRetry,
    required this.onCancel,
    super.key,
  });

  /// Callback when user retries a failed migration.
  final VoidCallback onRetry;

  /// Callback when user cancels a failed migration.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final migrationState = ref.watch(guestMigrationControllerProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final isFailed = migrationState.isFailed;

    return GlassDialog(
      key: const ValueKey('guest-migration-progress-dialog'),
      title: Row(
        children: [
          Icon(
            isFailed ? Icons.error_outline_rounded : Icons.cloud_sync_outlined,
            color: isFailed ? colors.danger : colors.goldAccent,
            size: spacing.lg,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              isFailed ? l10n.migrationErrorTitle : l10n.migrationProgressTitle,
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
            if (isFailed) ...[
              Text(
                l10n.migrationErrorMessage(
                  migrationState.errorMessage ?? 'Unknown error',
                ),
                key: const ValueKey('migration-error-message-text'),
                style: textStyles.bodySmall.copyWith(color: colors.danger),
              ),
            ] else ...[
              Text(
                migrationState.currentTable.isNotEmpty
                    ? l10n.migrationProgressStep(
                        migrationState.currentTable,
                        migrationState.processedRecords,
                        migrationState.totalRecords,
                      )
                    : l10n.migrationProgressTitle,
                key: const ValueKey('migration-progress-step-text'),
                style: textStyles.bodyMedium,
              ),
              SizedBox(height: spacing.md),
              ClipRRect(
                borderRadius: radii.buttonRadius,
                child: LinearProgressIndicator(
                  key: const ValueKey('migration-progress-bar'),
                  value: migrationState.progressFraction,
                  minHeight: 8,
                  backgroundColor: colors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation(colors.goldAccent),
                ),
              ),
              SizedBox(height: spacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(migrationState.progressFraction * 100).round()}%',
                  style: textStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: isFailed
          ? [
              GlassButton(
                key: const ValueKey('migration-cancel-btn'),
                onPressed: onCancel,
                child: Text(l10n.migrationKeepGuestButton),
              ),
              GlassButton(
                key: const ValueKey('migration-retry-btn'),
                variant: GlassButtonVariant.primary,
                onPressed: onRetry,
                leading: Icon(Icons.refresh_rounded, size: spacing.md),
                child: Text(l10n.migrationRetryButton),
              ),
            ]
          : const [],
    );
  }
}
