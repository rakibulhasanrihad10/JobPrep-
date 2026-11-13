import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/reminder_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/features/auth/fake_auth_repository.dart';
import '../../test/features/circulars/fake_circular_repository.dart';
import '../../test/features/circulars/fake_exam_date_repository.dart';
import '../../test/features/notifications/fake_notifications_repository.dart';
import '../../test/features/onboarding/fake_onboarding_repository.dart';
import '../../test/features/prep/fake_material_and_log_repositories.dart';
import '../../test/features/prep/fake_material_cover_repository.dart';
import '../../test/features/prep/fake_mock_test_repository.dart';
import '../../test/features/prep/fake_prep_template_repository.dart';
import '../../test/features/prep/fake_revision_item_repository.dart';
import '../../test/features/prep/fake_study_plan_repository.dart';
import '../../test/features/prep/fake_study_session_repository.dart';
import '../../test/features/prep/fake_subject_and_topic_repositories.dart';
import '../../test/features/settings/fake_reminder_settings_repository.dart';
import '../../test/features/settings/fake_user_settings_repository.dart';
import '../../test/features/vault/fake_portal_account_repository.dart';

/// Test harness orchestrating end-to-end integration tests with
/// in-memory fakes.
class E2ETestHarness {
  E2ETestHarness({
    required this.prefs,
    required this.authRepo,
    required this.circularRepo,
    required this.examDateRepo,
    required this.subjectRepo,
    required this.materialRepo,
    required this.logRepo,
    required this.vaultRepo,
    required this.studyPlanRepo,
    required this.revisionRepo,
    required this.studySessionRepo,
    required this.notificationRepo,
    required this.userSettingsRepo,
    required this.onboardingRepo,
  });

  final SharedPreferences prefs;
  final FakeAuthRepository authRepo;
  final FakeCircularRepository circularRepo;
  final FakeExamDateRepository examDateRepo;
  final FakeSubjectRepository subjectRepo;
  final FakeMaterialRepository materialRepo;
  final FakeProgressLogRepository logRepo;
  final FakePortalAccountRepository vaultRepo;
  final FakeStudyPlanRepository studyPlanRepo;
  final FakeRevisionItemRepository revisionRepo;
  final FakeStudySessionRepository studySessionRepo;
  final FakeNotificationsRepository notificationRepo;
  final FakeUserSettingsRepository userSettingsRepo;
  final FakeOnboardingRepository onboardingRepo;

  /// Creates and initializes a complete [E2ETestHarness] with default fakes.
  static Future<E2ETestHarness> create({
    bool isAuthenticated = true,
    bool needsOnboarding = false,
  }) async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final authRepo = isAuthenticated
        ? FakeAuthRepository.authenticated()
        : FakeAuthRepository();

    final circularRepo = FakeCircularRepository();
    final examDateRepo = FakeExamDateRepository();
    final subjectRepo = FakeSubjectRepository();
    final materialRepo = FakeMaterialRepository();
    final logRepo = FakeProgressLogRepository(materialRepository: materialRepo);
    final vaultRepo = FakePortalAccountRepository();
    final studyPlanRepo = FakeStudyPlanRepository();
    final revisionRepo = FakeRevisionItemRepository();
    final studySessionRepo = FakeStudySessionRepository();
    final notificationRepo = FakeNotificationsRepository();
    final userSettingsRepo = FakeUserSettingsRepository();
    final onboardingRepo = FakeOnboardingRepository(
      initialStatus: OnboardingStatus(
        userId: 'user-1',
        onboardingCompletedAt: needsOnboarding ? null : DateTime.utc(2026),
        onboardingStep: needsOnboarding ? 1 : 6,
      ),
    );

    return E2ETestHarness(
      prefs: prefs,
      authRepo: authRepo,
      circularRepo: circularRepo,
      examDateRepo: examDateRepo,
      subjectRepo: subjectRepo,
      materialRepo: materialRepo,
      logRepo: logRepo,
      vaultRepo: vaultRepo,
      studyPlanRepo: studyPlanRepo,
      revisionRepo: revisionRepo,
      studySessionRepo: studySessionRepo,
      notificationRepo: notificationRepo,
      userSettingsRepo: userSettingsRepo,
      onboardingRepo: onboardingRepo,
    );
  }

  /// Builds a [ProviderScope] configured with all repository overrides.
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(authRepo),
        circularRepositoryProvider.overrideWithValue(circularRepo),
        examDateRepositoryProvider.overrideWithValue(examDateRepo),
        subjectRepositoryProvider.overrideWithValue(subjectRepo),
        materialRepositoryProvider.overrideWithValue(materialRepo),
        progressLogRepositoryProvider.overrideWithValue(logRepo),
        portalAccountRepositoryProvider.overrideWithValue(vaultRepo),
        studyPlanRepositoryProvider.overrideWithValue(studyPlanRepo),
        revisionItemRepositoryProvider.overrideWithValue(revisionRepo),
        studySessionRepositoryProvider.overrideWithValue(studySessionRepo),
        notificationsRepositoryProvider.overrideWithValue(notificationRepo),
        userSettingsRepositoryProvider.overrideWithValue(userSettingsRepo),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepo),
        prepTemplateRepositoryProvider.overrideWithValue(
          FakePrepTemplateRepository(),
        ),
        mockTestRepositoryProvider.overrideWithValue(
          FakeMockTestRepository(),
        ),
        materialCoverRepositoryProvider.overrideWithValue(
          FakeMaterialCoverRepository(),
        ),
        reminderSettingsRepositoryProvider.overrideWithValue(
          FakeReminderSettingsRepository(),
        ),
      ],
      child: const JobPrepApp(),
    );
  }

  /// Cleans up state and controllers after test completion.
  Future<void> dispose() async {
    await authRepo.dispose();
  }
}
