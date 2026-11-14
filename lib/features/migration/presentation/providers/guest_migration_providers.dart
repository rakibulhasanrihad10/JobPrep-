import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/local/local_database_provider.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/services/backup_format_service.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_exam_date_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_exam_date_repository.dart';
import 'package:job_prep/features/migration/domain/entities/guest_migration_state.dart';
import 'package:job_prep/features/migration/domain/entities/migration_verification_result.dart';
import 'package:job_prep/features/migration/domain/repositories/cloud_repositories.dart';
import 'package:job_prep/features/migration/domain/services/guest_migration_service.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_mock_test_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_revision_item_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_study_plan_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_study_session_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_topic_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_mock_test_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_revision_item_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_study_plan_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_study_session_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_topic_repository.dart';
import 'package:job_prep/features/settings/data/repositories/supabase_user_settings_repository.dart';
import 'package:job_prep/features/settings/data/repositories/unconfigured_user_settings_repository.dart';
import 'package:job_prep/features/vault/data/repositories/supabase_portal_account_repository.dart';
import 'package:job_prep/features/vault/data/repositories/unconfigured_portal_account_repository.dart';

/// Provider exposing default cloud repositories instance.
final Provider<CloudRepositories> cloudRepositoriesProvider =
    Provider<CloudRepositories>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return CloudRepositories(
      subjectRepo: const UnconfiguredSubjectRepository(),
      topicRepo: const UnconfiguredTopicRepository(),
      materialRepo: const UnconfiguredMaterialRepository(),
      circularRepo: const UnconfiguredCircularRepository(),
      examDateRepo: const UnconfiguredExamDateRepository(),
      studyPlanRepo: const UnconfiguredStudyPlanRepository(),
      mockTestRepo: const UnconfiguredMockTestRepository(),
      progressLogRepo: const UnconfiguredProgressLogRepository(),
      revisionItemRepo: const UnconfiguredRevisionItemRepository(),
      studySessionRepo: const UnconfiguredStudySessionRepository(),
      portalAccountRepo: const UnconfiguredPortalAccountRepository(),
      userSettingsRepo: UnconfiguredUserSettingsRepository(
        ref.watch(sharedPreferencesProvider),
      ),
    );
  }

  return CloudRepositories(
    subjectRepo: SupabaseSubjectRepository(client),
    topicRepo: SupabaseTopicRepository(client),
    materialRepo: SupabaseMaterialRepository(client),
    circularRepo: SupabaseCircularRepository(client),
    examDateRepo: SupabaseExamDateRepository(client),
    studyPlanRepo: SupabaseStudyPlanRepository(client),
    mockTestRepo: SupabaseMockTestRepository(client),
    progressLogRepo: SupabaseProgressLogRepository(client),
    revisionItemRepo: SupabaseRevisionItemRepository(client),
    studySessionRepo: SupabaseStudySessionRepository(client),
    portalAccountRepo: SupabasePortalAccountRepository(client),
    userSettingsRepo: SupabaseUserSettingsRepository(client),
  );
});

/// Provider for [GuestMigrationService].
final Provider<GuestMigrationService> guestMigrationServiceProvider =
    Provider<GuestMigrationService>((ref) => const GuestMigrationService());

/// FutureProvider inspecting if any guest data exists on the device.
final FutureProvider<BackupDataTables> guestDataTablesProvider =
    FutureProvider<BackupDataTables>((ref) async {
  final backupRepo = ref.watch(backupRepositoryProvider);
  return await backupRepo.collectBackupData();
});

/// Notifier coordinating the guest migration state and execution.
class GuestMigrationNotifier extends Notifier<GuestMigrationState> {
  @override
  GuestMigrationState build() => GuestMigrationState.idle();

  /// Starts the upload and verification flow.
  Future<MigrationVerificationResult?> startMigration() async {
    final service = ref.read(guestMigrationServiceProvider);
    final cloud = ref.read(cloudRepositoriesProvider);
    final backupRepo = ref.read(backupRepositoryProvider);

    try {
      final tables = await backupRepo.collectBackupData();
      final totalRecords = tables.totalRecords - tables.notifications.length;

      state = state.copyWith(
        status: MigrationStatus.uploading,
        totalRecords: totalRecords,
        processedRecords: 0,
      );

      final result = await service.migrate(
        tables: tables,
        cloud: cloud,
        onProgress: (table, processed, total) {
          state = state.copyWith(
            currentTable: table,
            processedRecords: processed,
            totalRecords: total,
          );
        },
      );

      state = state.copyWith(
        status: MigrationStatus.verifying,
      );

      final finalManifest = BackupFormatService.createManifest(tables: tables);

      state = state.copyWith(
        status: MigrationStatus.completed,
        verificationResult: result,
        finalBackupManifest: finalManifest,
      );

      return result;
    } on Object catch (e) {
      state = state.copyWith(
        status: MigrationStatus.failed,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Concludes migration: optionally erases local copy, switches to signedIn
  /// mode.
  Future<void> finalizeMigration({required bool eraseLocalCopy}) async {
    if (eraseLocalCopy) {
      final db = ref.read(appDatabaseProvider);
      await db.eraseAllData();
    }
    await ref.read(appModeProvider.notifier).setSignedIn();
    state = GuestMigrationState.idle();
  }

  /// Cancels / skips migration and starts fresh with account, keeping device data.
  Future<void> startFreshWithoutMigration() async {
    await ref.read(appModeProvider.notifier).setSignedIn();
    state = GuestMigrationState.idle();
  }

  /// Resets state back to idle.
  void reset() {
    state = GuestMigrationState.idle();
  }
}

/// Provider managing [GuestMigrationState].
final NotifierProvider<GuestMigrationNotifier, GuestMigrationState>
    guestMigrationControllerProvider =
    NotifierProvider<GuestMigrationNotifier, GuestMigrationState>(
  GuestMigrationNotifier.new,
);
