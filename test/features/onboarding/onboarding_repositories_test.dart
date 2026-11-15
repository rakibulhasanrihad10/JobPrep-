import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/onboarding/data/repositories/local_onboarding_repository.dart';
import 'package:job_prep/features/onboarding/data/repositories/supabase_onboarding_repository.dart';
import 'package:job_prep/features/onboarding/data/repositories/unconfigured_onboarding_repository.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../contracts/mock_supabase_http_client.dart';

void main() {
  group('LocalOnboardingRepository', () {
    late AppDatabase db;
    late LocalOnboardingRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = LocalOnboardingRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('initial status returns needsOnboarding true', () async {
      final status = await repo.getStatus();
      expect(status.needsOnboarding, isTrue);
      expect(status.onboardingStep, equals(1));
    });

    test('saveProgress and completeOnboarding updates status', () async {
      const draft = OnboardingDraft();

      final progressed = await repo.saveProgress(step: 3, draft: draft);
      expect(progressed.onboardingStep, equals(3));
      expect(progressed.draft.track, equals(OnboardingTrack.government));

      final completed = await repo.completeOnboarding(
        completedAt: DateTime.utc(2026, 11, 15),
        draft: draft,
      );
      expect(completed.isCompleted, isTrue);
      expect(completed.needsOnboarding, isFalse);
    });
  });

  group('SupabaseOnboardingRepository', () {
    late MockSupabaseHttpClient mockHttp;
    late SupabaseOnboardingRepository repo;

    setUp(() {
      mockHttp = MockSupabaseHttpClient();
      final client = MockSupabaseClient(mockHttpClient: mockHttp);
      repo = SupabaseOnboardingRepository(client);
    });

    test('getStatus returns needsOnboarding for fresh user', () async {
      final status = await repo.getStatus();
      expect(status.needsOnboarding, isTrue);
    });

    test('saveProgress and completeOnboarding update PostgREST rows', () async {
      const draft = OnboardingDraft(track: OnboardingTrack.software);
      final progressed = await repo.saveProgress(step: 4, draft: draft);
      expect(progressed.onboardingStep, equals(4));

      final completed = await repo.completeOnboarding(
        completedAt: DateTime.utc(2026, 11, 15),
        draft: draft,
      );
      expect(completed.isCompleted, isTrue);
    });
  });

  group('UnconfiguredOnboardingRepository', () {
    test('default status is completed for offline dev', () async {
      const repo = UnconfiguredOnboardingRepository();
      final initial = await repo.getStatus();
      expect(initial.isCompleted, isTrue);
      expect(initial.needsOnboarding, isFalse);
    });

    test(
        'supports SharedPreferences persistence for step, completion, and tips',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo =
          UnconfiguredOnboardingRepository(prefs: prefs, userId: 'test-user');

      const draft = OnboardingDraft(track: OnboardingTrack.software);
      final saved = await repo.saveProgress(step: 2, draft: draft);
      expect(saved.onboardingStep, equals(2));

      final completed = await repo.completeOnboarding(
        completedAt: DateTime.utc(2026),
        draft: draft,
      );
      expect(completed.isCompleted, isTrue);

      final tips = await repo.dismissTodayTips();
      expect(tips.todayTipsDismissed, isTrue);

      final reset = await repo.resetOnboarding();
      expect(reset.needsOnboarding, isTrue);
    });
  });
}
