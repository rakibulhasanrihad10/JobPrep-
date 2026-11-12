import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/onboarding/data/mappers/onboarding_error_mapper.dart';
import 'package:job_prep/features/onboarding/data/mappers/onboarding_settings_mapper.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:job_prep/features/onboarding/domain/errors/onboarding_failure.dart';
import 'package:job_prep/features/onboarding/domain/utils/onboarding_planner.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_wizard_controller.dart';
import 'package:job_prep/features/prep/domain/entities/prep_template.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/utils/prep_seeded_templates.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import '../prep/fake_material_and_log_repositories.dart';
import '../prep/fake_study_plan_repository.dart';
import '../prep/fake_subject_and_topic_repositories.dart';
import 'fake_onboarding_repository.dart';

void main() {
  group('Onboarding Redirect, Mappers & Pure Planners', () {
    const signedIn = AuthSessionState.signedIn(
      FakeAuthRepository.defaultTestUser,
    );

    test('resolveAuthRedirect enforces /onboarding only while incomplete', () {
      expect(
        resolveAuthRedirect(
          authState: signedIn,
          location: '/today',
          needsOnboarding: true,
        ),
        '/onboarding',
      );
      expect(
        resolveAuthRedirect(
          authState: signedIn,
          location: '/onboarding',
          needsOnboarding: true,
        ),
        isNull,
      );
      expect(
        resolveAuthRedirect(
          authState: signedIn,
          location: '/onboarding',
        ),
        '/today',
      );
    });

    test(
        'OnboardingSettingsMapper and ErrorMapper serialize & classify cleanly',
        () {
      const draft = OnboardingDraft(
        track: OnboardingTrack.software,
        dontKnowExamDate: true,
        restWeekdays: {5, 6},
        maxDailyPace: 40,
        circularLink: 'https://example.com/jobs/1',
      );
      final parsed = OnboardingSettingsMapper.fromJson({
        'id': 'us-1',
        'user_id': 'u-1',
        'onboarding_step': 4,
        'onboarding_draft': draft.toJson(),
        'today_tips_dismissed': false,
        'created_at': '2026-11-12T00:00:00Z',
      });

      expect(parsed.onboardingStep, 4);
      expect(parsed.draft, draft);
      expect(parsed.needsOnboarding, isTrue);

      expect(
        OnboardingErrorMapper.map(TimeoutException('timeout')),
        isA<OnboardingNetworkFailure>(),
      );
      expect(
        OnboardingErrorMapper.map(
          const supabase.PostgrestException(message: 'denied', code: '42501'),
        ),
        isA<OnboardingPermissionFailure>(),
      );
      expect(
        OnboardingErrorMapper.map(
          const supabase.PostgrestException(message: 'bad', code: '23514'),
        ),
        isA<OnboardingValidationFailure>(),
      );
    });

    test('OnboardingPlanner validates steps 3 & 4 and syncs rest weekdays', () {
      expect(
        OnboardingPlanner.syncRestWeekdaysForStudyCount(
          studyDaysPerWeek: 5,
          currentRestDays: {5},
        ),
        equals({5, 6}),
      );

      expect(
        OnboardingPlanner.validateSubjectsAndMaterials(const [
          OnboardingSubjectDraft(localId: 's1', name: '  '),
        ]),
        OnboardingSubjectsValidationError.emptySubjectName,
      );
      expect(
        OnboardingPlanner.validateSubjectsAndMaterials(const [
          OnboardingSubjectDraft(localId: 's1', name: 'English'),
          OnboardingSubjectDraft(localId: 's2', name: ' english '),
        ]),
        OnboardingSubjectsValidationError.duplicateSubjectName,
      );
      expect(
        OnboardingPlanner.validateSubjectsAndMaterials(const [
          OnboardingSubjectDraft(
            localId: 's1',
            name: 'Math',
            materials: [
              OnboardingMaterialDraft(
                localId: 'm1',
                title: 'Digest',
                totalUnits: 0,
              ),
            ],
          ),
        ]),
        OnboardingSubjectsValidationError.invalidMaterialUnits,
      );

      final today = DateTime.utc(2026, 11, 12);
      expect(
        OnboardingPlanner.validateSchedule(
          dontKnowExamDate: false,
          examDate: null,
          today: today,
          restWeekdays: const {5},
          maxDailyPaceText: '',
        ),
        OnboardingScheduleValidationError.missingExamDate,
      );
      expect(
        OnboardingPlanner.validateSchedule(
          dontKnowExamDate: false,
          examDate: DateTime.utc(2026, 11, 10),
          today: today,
          restWeekdays: const {5},
          maxDailyPaceText: '',
        ),
        OnboardingScheduleValidationError.pastExamDate,
      );
      expect(
        OnboardingPlanner.validateSchedule(
          dontKnowExamDate: true,
          examDate: null,
          today: today,
          restWeekdays: const {5},
          maxDailyPaceText: '০',
          parsedMaxDailyPace: 0,
        ),
        OnboardingScheduleValidationError.invalidMaxDailyPace,
      );
    });
  });

  group('OnboardingWizardController State, Persistence & Idempotency', () {
    ProviderContainer buildContainer({
      required FakeOnboardingRepository onboardingRepo,
      FakeSubjectRepository? subjectRepo,
      FakeMaterialRepository? materialRepo,
      FakeStudyPlanRepository? planRepo,
      FakeCircularRepository? circularRepo,
    }) {
      final now = DateTime.utc(2026, 11, 12, 3);
      final authRepo = FakeAuthRepository.authenticated();
      addTearDown(authRepo.dispose);

      final subs = subjectRepo ?? FakeSubjectRepository();
      final mats = materialRepo ?? FakeMaterialRepository();
      final plans = planRepo ?? FakeStudyPlanRepository(clock: () => now);
      final circulars =
          circularRepo ?? FakeCircularRepository(clock: () => now);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          onboardingRepositoryProvider.overrideWithValue(onboardingRepo),
          onboardingNowProvider.overrideWithValue(() => now),
          prepTemplatesProvider.overrideWith(
            () => _StubTemplatesNotifier(PrepSeededTemplates.defaults()),
          ),
          subjectRepositoryProvider.overrideWithValue(subs),
          materialRepositoryProvider.overrideWithValue(mats),
          studyPlanRepositoryProvider.overrideWithValue(plans),
          studyPlanNowProvider.overrideWithValue(() => now),
          circularRepositoryProvider.overrideWithValue(circulars),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test(
      'applies track subjects, edited materials, study plan, and circular '
      'once without duplicates on repeat run',
      () async {
        final onboardingRepo = FakeOnboardingRepository();
        final subjectRepo = FakeSubjectRepository();
        final materialRepo = FakeMaterialRepository();
        final planRepo = FakeStudyPlanRepository();
        final circularRepo = FakeCircularRepository();

        final container = buildContainer(
          onboardingRepo: onboardingRepo,
          subjectRepo: subjectRepo,
          materialRepo: materialRepo,
          planRepo: planRepo,
          circularRepo: circularRepo,
        );

        await container.read(onboardingStatusProvider.future);
        await container.read(prepTemplatesProvider.future);
        final ctrl =
            container.read(onboardingWizardControllerProvider.notifier);

        // Step 1 -> Step 2 (select Software track)
        expect(await ctrl.goNext(), isTrue);
        ctrl.selectTrack(OnboardingTrack.software);
        expect(await ctrl.goNext(), isTrue);

        // Step 3: edit first subject name & add a custom subject
        final step3Subjects =
            container.read(onboardingWizardControllerProvider).draft.subjects;
        expect(step3Subjects, isNotEmpty);
        ctrl
          ..renameSubject(step3Subjects.first.localId, 'DSA & Problem Solving')
          ..updateMaterialUnits(
            step3Subjects.first.localId,
            step3Subjects.first.materials.first.localId,
            '350',
          )
          ..addCustomSubject(
            name: 'Behavioral Stories',
            firstMaterialTitle: 'STAR Prep Notes',
            firstMaterialUnits: 60,
          );
        expect(await ctrl.goNext(), isTrue);

        // Step 4: exam date, 5 study days/week, max pace 45
        ctrl
          ..setExamDate(DateTime.utc(2027, 1, 15))
          ..setStudyDaysPerWeek(5)
          ..setMaxDailyPaceInput('45');
        expect(await ctrl.goNext(), isTrue);

        // Step 5: first circular quick capture
        ctrl
          ..setCircularLink('https://careers.techcorp.example/swe')
          ..setCircularTitle('TechCorp Junior SWE');
        expect(await ctrl.goNext(), isTrue);
        expect(
          container.read(onboardingWizardControllerProvider).step,
          6,
        );

        // Step 6 Finish
        expect(await ctrl.finishOnboarding(), isTrue);
        final createdSubjects = await subjectRepo.getSubjects();
        final createdMaterials = await materialRepo.getAllMaterials();
        final createdPlans = await planRepo.getPlans();
        final createdCirculars = await circularRepo.getCirculars();

        expect(
          createdSubjects.any((s) => s.name == 'DSA & Problem Solving'),
          isTrue,
        );
        expect(
          createdSubjects.any((s) => s.name == 'Behavioral Stories'),
          isTrue,
        );
        expect(createdMaterials.any((m) => m.totalUnits == 350), isTrue);
        expect(
          createdMaterials.any((m) => m.title == 'STAR Prep Notes'),
          isTrue,
        );
        expect(createdPlans.length, 1);
        expect(createdPlans.first, isA<StudyPlan>());
        expect(createdPlans.first.restDaysPerWeek, 2);
        expect(createdPlans.first.maxDailyPace, 45);
        expect(createdCirculars.length, 1);
        expect(onboardingRepo.currentStatus.showTodayTips, isTrue);

        // Re-running Finish on repeat setup must create ZERO duplicates!
        expect(await ctrl.finishOnboarding(), isTrue);
        expect(
          (await subjectRepo.getSubjects()).length,
          createdSubjects.length,
        );
        expect(
          (await materialRepo.getAllMaterials()).length,
          createdMaterials.length,
        );
        expect((await planRepo.getPlans()).length, 1);
        expect((await circularRepo.getCirculars()).length, 1);
      },
    );

    test('resumes mid-flow from saved step & draft and supports skip',
        () async {
      final resumedRepo = FakeOnboardingRepository(
        initialStatus: const OnboardingStatus(
          userId: 'user-1',
          onboardingStep: 4,
          draft: OnboardingDraft(
            track: OnboardingTrack.blank,
            hasCustomizedSubjects: true,
            subjects: [
              OnboardingSubjectDraft(
                localId: 'sub_r1',
                name: 'Bank Math',
                materials: [
                  OnboardingMaterialDraft(
                    localId: 'mat_r1',
                    title: 'Arithmetic',
                    totalUnits: 250,
                  ),
                ],
              ),
            ],
            restWeekdays: {5, 6},
            maxDailyPace: 30,
          ),
        ),
      );

      final container = buildContainer(onboardingRepo: resumedRepo);
      await container.read(onboardingStatusProvider.future);
      await container.read(prepTemplatesProvider.future);

      final resumedState = container.read(onboardingWizardControllerProvider);
      expect(resumedState.step, 4);
      expect(resumedState.draft.track, OnboardingTrack.blank);
      expect(resumedState.draft.subjects.single.name, 'Bank Math');
      expect(resumedState.maxDailyPaceInput, '30');

      final skipped = await container
          .read(onboardingWizardControllerProvider.notifier)
          .skipOnboarding();
      expect(skipped, isTrue);
      expect(resumedRepo.currentStatus.isCompleted, isTrue);
    });
  });
}

class _StubTemplatesNotifier extends PrepTemplatesNotifier {
  _StubTemplatesNotifier(this._items);

  final List<PrepTemplate> _items;

  @override
  Future<List<PrepTemplate>> build() async => _items;
}
