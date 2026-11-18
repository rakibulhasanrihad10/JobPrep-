import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/migration/presentation/providers/guest_migration_providers.dart';
import 'package:job_prep/features/migration/presentation/widgets/guest_migration_choice_dialog.dart';
import 'package:job_prep/features/migration/presentation/widgets/guest_migration_complete_dialog.dart';
import 'package:job_prep/features/migration/presentation/widgets/guest_migration_progress_dialog.dart';

/// Coordinator executing the visual dialog steps for guest data migration.
abstract final class GuestMigrationFlowHelper {
  /// Entry point after signing in to detect guest data and start migration.
  static Future<void> triggerMigrationFlow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final backupRepo = ref.read(backupRepositoryProvider);
    final tables = await backupRepo.collectBackupData();

    // If local database is empty, no migration needed
    if (tables.totalRecords == 0) {
      await ref
          .read(guestMigrationControllerProvider.notifier)
          .startFreshWithoutMigration();
      if (context.mounted) {
        context.go(AppRoutePaths.today);
      }
      return;
    }

    if (!context.mounted) return;

    // 1. Show Choice Dialog
    await showGlassDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (choiceCtx) => GuestMigrationChoiceDialog(
        tables: tables,
        onStartFresh: () async {
          Navigator.of(choiceCtx).pop();
          await ref
              .read(guestMigrationControllerProvider.notifier)
              .startFreshWithoutMigration();
          if (context.mounted) {
            context.go(AppRoutePaths.today);
          }
        },
        onMoveData: () async {
          Navigator.of(choiceCtx).pop();
          await _executeUploadWorkflow(context, ref);
        },
      ),
    );
  }

  static Future<void> _executeUploadWorkflow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;

    // 2. Show Progress Dialog
    var isDone = false;
    unawaited(
      showGlassDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (progressCtx) => GuestMigrationProgressDialog(
          onRetry: () {
            unawaited(
              ref
                  .read(guestMigrationControllerProvider.notifier)
                  .startMigration(),
            );
          },
          onCancel: () {
            Navigator.of(progressCtx).pop();
            ref.read(guestMigrationControllerProvider.notifier).reset();
          },
        ),
      ).then((_) {
        isDone = true;
      }),
    );

    final result = await ref
        .read(guestMigrationControllerProvider.notifier)
        .startMigration();

    if (!context.mounted) return;

    // Pop progress dialog if completed
    if (result != null && !isDone) {
      Navigator.of(context).pop();

      // 3. Show Completion Dialog
      await showGlassDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (completeCtx) => GuestMigrationCompleteDialog(
          onFinish: ({required eraseLocalCopy}) async {
            Navigator.of(completeCtx).pop();
            await ref
                .read(guestMigrationControllerProvider.notifier)
                .finalizeMigration(eraseLocalCopy: eraseLocalCopy);
            if (context.mounted) {
              context.go(AppRoutePaths.today);
            }
          },
        ),
      );
    }
  }
}
