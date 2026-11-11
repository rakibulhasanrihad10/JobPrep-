import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/app_bottom_nav_bar.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:job_prep/features/prep/domain/utils/prep_seeded_templates.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';
import 'package:job_prep/features/today/presentation/screens/today_screen.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import '../prep/fake_material_and_log_repositories.dart';
import '../prep/fake_material_cover_repository.dart';
import '../prep/fake_mock_test_repository.dart';
import '../prep/fake_prep_template_repository.dart';
import '../prep/fake_revision_item_repository.dart';
import '../prep/fake_study_plan_repository.dart';
import '../prep/fake_study_session_repository.dart';
import '../prep/fake_subject_and_topic_repositories.dart';
import 'fake_onboarding_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  Future<
      ({
        FakeOnboardingRepository onboardingRepo,
        FakeSubjectRepository subjectRepo,
        FakeMaterialRepository materialRepo,
        FakeStudyPlanRepository planRepo,
        FakeCircularRepository circularRepo,
      })> pumpOnboardingApp(
    WidgetTester tester, {
    required Size size,
    OnboardingStatus? initialStatus,
    String locale = 'en',
  }) async {
    final now = DateTime.utc(2026, 11, 12, 3);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: true,
      kLocaleStorageKey: locale,
    });
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository.authenticated();
    addTearDown(authRepo.dispose);

    final onboardingRepo = FakeOnboardingRepository(
      initialStatus: initialStatus ?? const OnboardingStatus(userId: 'user-1'),
      clock: () => now,
    );
    final subjectRepo = FakeSubjectRepository();
    final materialRepo = FakeMaterialRepository();
    final planRepo = FakeStudyPlanRepository(clock: () => now);
    final circularRepo = FakeCircularRepository(clock: () => now);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          onboardingRepositoryProvider.overrideWithValue(onboardingRepo),
          onboardingNowProvider.overrideWithValue(() => now),
          circularNowProvider.overrideWithValue(() => now),
          todayOffsetProvider.overrideWithValue(const Duration(hours: 6)),
          prepTemplateRepositoryProvider.overrideWithValue(
            FakePrepTemplateRepository(
              initialTemplates: PrepSeededTemplates.defaults(),
            ),
          ),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(
            FakeProgressLogRepository(materialRepository: materialRepo),
          ),
          topicRepositoryProvider.overrideWithValue(FakeTopicRepository()),
          materialCoverRepositoryProvider.overrideWithValue(
            FakeMaterialCoverRepository(),
          ),
          mockTestRepositoryProvider.overrideWithValue(
            FakeMockTestRepository(clock: () => now),
          ),
          studyPlanRepositoryProvider.overrideWithValue(planRepo),
          studyPlanNowProvider.overrideWithValue(() => now),
          revisionItemRepositoryProvider.overrideWithValue(
            FakeRevisionItemRepository(),
          ),
          studySessionRepositoryProvider.overrideWithValue(
            FakeStudySessionRepository(clock: () => now),
          ),
          circularRepositoryProvider.overrideWithValue(circularRepo),
        ],
        child: const JobPrepApp(),
      ),
    );
    await tester.pumpAndSettle();

    return (
      onboardingRepo: onboardingRepo,
      subjectRepo: subjectRepo,
      materialRepo: materialRepo,
      planRepo: planRepo,
      circularRepo: circularRepo,
    );
  }

  group('Phase 6K Onboarding Wizard Widget & Flow Tests', () {
    testWidgets(
      'walks through steps 1..6 cleanly, opens Today with 3 dismissible tips, '
      'and re-runs setup from Settings without duplicates',
      (tester) async {
        final ctx = await pumpOnboardingApp(
          tester,
          size: const Size(1280, 960),
        );

        // Full-screen wizard before shell chrome
        expect(find.byType(OnboardingWizardScreen), findsOneWidget);
        expect(find.byType(AppSidebarNav), findsNothing);
        expect(find.byType(AppBottomNavBar), findsNothing);
        expect(
          find.byKey(const ValueKey('onboarding-back-btn')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('onboarding-skip-btn')),
          findsOneWidget,
        );

        // Step 1 -> Step 2
        await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('onboarding-step-2')), findsOneWidget);

        // Pick Software Jobs track -> Step 3
        await tester.tap(
          find.byKey(const ValueKey('onboarding-track-software')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('onboarding-step-3')), findsOneWidget);

        // Add custom subject in Step 3
        await tester.tap(
          find.byKey(const ValueKey('onboarding-add-subject-btn')),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('onboarding-new-subject-name-input')),
          'Distributed Systems',
        );
        await tester.enterText(
          find.byKey(const ValueKey('onboarding-new-subject-mat-input')),
          'DDIA',
        );
        await tester.tap(
          find.byKey(const ValueKey('onboarding-confirm-add-subject-btn')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Distributed Systems'), findsOneWidget);

        // Step 3 -> Step 4
        await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('onboarding-step-4')), findsOneWidget);

        // Choose "I don't know yet", 5 days/week, max pace 40
        await tester.tap(
          find.byKey(const ValueKey('onboarding-exam-unknown-switch')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('onboarding-study-days-5')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('onboarding-max-pace-input')),
          '40',
        );
        await tester.pumpAndSettle();

        // Step 4 -> Step 5
        await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('onboarding-step-5')), findsOneWidget);

        // Enter invalid URL first -> inline validation blocks Step 6
        await tester.enterText(
          find.byKey(const ValueKey('onboarding-circular-link-input')),
          'not a link',
        );
        await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('onboarding-step-5')), findsOneWidget);

        // Enter valid URL -> Step 6
        await tester.enterText(
          find.byKey(const ValueKey('onboarding-circular-link-input')),
          'https://jobs.example.com/swe',
        );
        await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('onboarding-step-6')), findsOneWidget);

        // Finish setup -> opens Today with 3 dismissible tips
        await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
        await tester.pumpAndSettle();

        expect(find.byType(TodayScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('today-onboarding-tips-card')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('today-tip-row-0')), findsOneWidget);
        expect(find.byKey(const ValueKey('today-tip-row-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('today-tip-row-2')), findsOneWidget);

        // Dismiss first tip individually, then dismiss all
        await tester.tap(find.byKey(const ValueKey('today-tip-dismiss-0')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('today-tip-row-0')), findsNothing);
        await tester.tap(
          find.byKey(const ValueKey('today-tips-dismiss-all-btn')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('today-onboarding-tips-card')),
          findsNothing,
        );

        final countBefore = (await ctx.subjectRepo.getSubjects()).length;
        expect((await ctx.circularRepo.getCirculars()).length, 1);

        // Navigate to Settings -> click "Run setup again"
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        final rerunBtn =
            find.byKey(const ValueKey('settings-run-setup-again-btn'));
        await tester.ensureVisible(rerunBtn);
        await tester.tap(rerunBtn);
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingWizardScreen), findsOneWidget);
        // Step through Finish again -> no duplicates created
        for (var i = 0; i < 6; i++) {
          await tester.tap(find.byKey(const ValueKey('onboarding-next-btn')));
          await tester.pumpAndSettle();
        }
        expect(find.byType(TodayScreen), findsOneWidget);
        expect((await ctx.subjectRepo.getSubjects()).length, countBefore);
        expect((await ctx.circularRepo.getCirculars()).length, 1);
      },
    );

    testWidgets(
      'resumes from saved step on reopen and skips cleanly on 360x800 '
      'Bangla mobile',
      (tester) async {
        final ctx = await pumpOnboardingApp(
          tester,
          size: const Size(360, 800),
          locale: 'bn',
          initialStatus: const OnboardingStatus(
            userId: 'user-1',
            onboardingStep: 4,
            draft: OnboardingDraft(
              track: OnboardingTrack.blank,
              dontKnowExamDate: true,
            ),
          ),
        );

        // Resumes straight to Step 4 in Bangla without overflow
        expect(find.byType(OnboardingWizardScreen), findsOneWidget);
        expect(find.byKey(const ValueKey('onboarding-step-4')), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Back returns cleanly to Step 3
        await tester.tap(find.byKey(const ValueKey('onboarding-back-btn')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('onboarding-step-3')), findsOneWidget);

        // Skip exits directly to Today without creating circular/study plan
        await tester.tap(find.byKey(const ValueKey('onboarding-skip-btn')));
        await tester.pumpAndSettle();

        expect(find.byType(TodayScreen), findsOneWidget);
        expect(ctx.onboardingRepo.currentStatus.isCompleted, isTrue);
        expect(await ctx.planRepo.getPlans(), isEmpty);
      },
    );
  });
}
