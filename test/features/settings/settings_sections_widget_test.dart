import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/router/app_router.dart';
import 'package:job_prep/core/security/vault_providers.dart';
import 'package:job_prep/core/security/vault_service.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:job_prep/features/onboarding/presentation/providers/onboarding_status_provider.dart';
import 'package:job_prep/features/onboarding/presentation/screens/onboarding_wizard_screen.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/data_export_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/reminder_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import '../circulars/fake_exam_date_repository.dart';
import '../onboarding/fake_onboarding_repository.dart';
import '../prep/fake_material_and_log_repositories.dart';
import '../prep/fake_material_cover_repository.dart';
import '../prep/fake_mock_test_repository.dart';
import '../prep/fake_prep_template_repository.dart';
import '../prep/fake_revision_item_repository.dart';
import '../prep/fake_study_plan_repository.dart';
import '../prep/fake_study_session_repository.dart';
import '../prep/fake_subject_and_topic_repositories.dart';
import '../vault/fake_portal_account_repository.dart';
import 'fake_reminder_settings_repository.dart';
import 'fake_user_settings_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  Future<
      ({
        FakeAuthRepository authRepo,
        FakeUserSettingsRepository settingsRepo,
        FakePortalAccountRepository portalRepo,
        VaultService vaultService,
        List<({String fileName, Uint8List bytes, String mimeType})> exports,
        SharedPreferences prefs,
      })> pumpSettingsApp(
    WidgetTester tester, {
    Size size = const Size(1280, 960),
    String locale = 'en',
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kLocaleStorageKey: locale,
      kReduceEffectsStorageKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final authRepo = FakeAuthRepository.authenticated();
    addTearDown(authRepo.dispose);

    final settingsRepo = FakeUserSettingsRepository();
    final portalRepo = FakePortalAccountRepository();
    final vaultService = VaultService(iterations: VaultService.minIterations);
    final exports = <({String fileName, Uint8List bytes, String mimeType})>[];

    final materialRepo = FakeMaterialRepository(
      initialMaterials: const [
        PrepMaterial(
          id: 'm-1',
          userId: 'user-1',
          subjectId: 'sub-1',
          title: 'BCS Digest',
          totalUnits: 300,
          completedUnits: 120,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
          userSettingsRepositoryProvider.overrideWithValue(settingsRepo),
          reminderSettingsRepositoryProvider.overrideWithValue(
            FakeReminderSettingsRepository(),
          ),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(
              initialStatus: OnboardingStatus(
                userId: 'user-1',
                onboardingCompletedAt: DateTime.utc(2026, 11),
                todayTipsDismissed: true,
              ),
            ),
          ),
          portalAccountRepositoryProvider.overrideWithValue(portalRepo),
          vaultServiceProvider.overrideWithValue(vaultService),
          circularRepositoryProvider.overrideWithValue(
            FakeCircularRepository(
              initialItems: const [
                Circular(
                  id: 'c-export-1',
                  userId: 'user-1',
                  title: '48th BCS Export Check',
                ),
              ],
            ),
          ),
          examDateRepositoryProvider.overrideWithValue(
            FakeExamDateRepository(),
          ),
          subjectRepositoryProvider.overrideWithValue(
            FakeSubjectRepository(
              initialSubjects: const [
                Subject(
                  id: 'sub-1',
                  userId: 'user-1',
                  name: 'Bangla Literature',
                ),
              ],
            ),
          ),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(
            FakeProgressLogRepository(materialRepository: materialRepo),
          ),
          topicRepositoryProvider.overrideWithValue(FakeTopicRepository()),
          materialCoverRepositoryProvider.overrideWithValue(
            FakeMaterialCoverRepository(),
          ),
          mockTestRepositoryProvider.overrideWithValue(
            FakeMockTestRepository(),
          ),
          studyPlanRepositoryProvider.overrideWithValue(
            FakeStudyPlanRepository(),
          ),
          revisionItemRepositoryProvider.overrideWithValue(
            FakeRevisionItemRepository(),
          ),
          studySessionRepositoryProvider.overrideWithValue(
            FakeStudySessionRepository(),
          ),
          prepTemplateRepositoryProvider.overrideWithValue(
            FakePrepTemplateRepository(),
          ),
          dataExportFileSaverProvider.overrideWithValue(({
            required fileName,
            required bytes,
            required mimeType,
          }) async {
            exports.add((fileName: fileName, bytes: bytes, mimeType: mimeType));
            return Uri.file(fileName);
          }),
          initialRouteLocationProvider.overrideWithValue('/settings'),
        ],
        child: const JobPrepApp(),
      ),
    );
    await tester.pumpAndSettle();

    return (
      authRepo: authRepo,
      settingsRepo: settingsRepo,
      portalRepo: portalRepo,
      vaultService: vaultService,
      exports: exports,
      prefs: prefs,
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('Phase 7A Settings Screen All-Sections Widget Tests', () {
    testWidgets(
      'Profile: displays email, updates name, changes password & signs out',
      (tester) async {
        final ctx = await pumpSettingsApp(tester);

        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.text('aspirant@example.com'), findsOneWidget);

        await tester.enterText(
          find.byKey(const ValueKey('settings-display-name-input')),
          'Nadia Karim',
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-save-display-name-btn')),
        );
        expect(ctx.authRepo.lastUpdatedDisplayName, 'Nadia Karim');
        expect(ctx.settingsRepo.currentSettings?.displayName, 'Nadia Karim');
        expect(find.text('Display name updated'), findsOneWidget);

        // Change password dialog validates mismatch & saves new password
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-change-password-btn')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('settings-new-password-field')),
          'StrongPass!2026',
        );
        await tester.enterText(
          find.byKey(const ValueKey('settings-confirm-password-field')),
          'MismatchPass!',
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-confirm-password-btn')),
        );
        expect(find.text('Passwords do not match.'), findsAtLeastNWidgets(1));

        await tester.enterText(
          find.byKey(const ValueKey('settings-confirm-password-field')),
          'StrongPass!2026',
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-confirm-password-btn')),
        );
        expect(ctx.authRepo.lastUpdatedPassword, 'StrongPass!2026');
        expect(find.text('Password updated successfully'), findsOneWidget);

        // Sign out locks vault and redirects to LoginScreen
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-sign-out-btn')),
        );
        expect(ctx.authRepo.signOutCallCount, 1);
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Appearance, Language & Study: toggles reduce effects, Bangla digits, '
      'timer defaults, and Run setup again',
      (tester) async {
        final ctx = await pumpSettingsApp(tester);

        // Appearance: Light theme + Reduce effects off -> on
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-theme-light')),
        );
        expect(ctx.prefs.getString(kThemeModeStorageKey), 'light');
        expect(ctx.settingsRepo.currentSettings?.themeMode, ThemeMode.light);

        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-reduce-effects-switch')),
        );
        expect(ctx.prefs.getBool(kReduceEffectsStorageKey), isFalse);
        expect(ctx.settingsRepo.currentSettings?.reduceEffects, isFalse);

        // Language: Bangla digits switch
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-bangla-digits-switch')),
        );
        expect(ctx.prefs.getBool(kUseBanglaDigitsStorageKey), isTrue);
        expect(ctx.settingsRepo.currentSettings?.banglaDigits, isTrue);

        // Study: invalid timer rejects, valid timer saves & syncs
        await tester.enterText(
          find.byKey(const ValueKey('settings-timer-focus-input')),
          '2',
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-save-timer-btn')),
        );
        expect(
          find.textContaining('Enter valid minutes'),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const ValueKey('settings-timer-focus-input')),
          '40',
        );
        await tester.enterText(
          find.byKey(const ValueKey('settings-timer-short-break-input')),
          '8',
        );
        await tester.enterText(
          find.byKey(const ValueKey('settings-timer-long-break-input')),
          '20',
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-save-timer-btn')),
        );
        expect(ctx.prefs.getInt(kPomodoroFocusMinutesKey), 40);
        expect(ctx.settingsRepo.currentSettings?.focusMinutes, 40);
        expect(ctx.settingsRepo.currentSettings?.shortBreakMinutes, 8);
        expect(ctx.settingsRepo.currentSettings?.longBreakMinutes, 20);

        // Run setup again opens full-screen onboarding wizard
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-run-setup-again-btn')),
        );
        expect(find.byType(OnboardingWizardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Security & Data: vault warning, setup/change/lock, CSV & JSON export, '
      'and Delete account confirmation',
      (tester) async {
        final ctx = await pumpSettingsApp(tester);

        // Security section displays unrecoverable warning directly
        expect(
          find.byKey(const ValueKey('vault-setup-warning-banner')),
          findsOneWidget,
        );

        // Set up vault via Security card
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-vault-unlock-button')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('vault-passphrase-field')),
          'VaultPass#111',
        );
        await tester.enterText(
          find.byKey(const ValueKey('vault-confirm-passphrase-field')),
          'VaultPass#111',
        );
        await tester
            .tap(find.byKey(const ValueKey('vault-setup-ack-checkbox')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('vault-dialog-submit')));
        await tester.pumpAndSettle();
        expect(find.text('Unlocked'), findsOneWidget);

        // Save an account under old passphrase, then change passphrase
        final encryptedPayload = await tester.runAsync(
          () => ctx.vaultService.encrypt('SecretPIN#42'),
        );
        await ctx.portalRepo.createAccount(
          PortalAccount(
            id: 'pa-1',
            userId: 'user-1',
            circularId: 'c-export-1',
            username: 'CAND-10',
            encryptedPassword: encryptedPayload!.ciphertext,
            salt: encryptedPayload.salt,
            nonce: encryptedPayload.nonce,
            iterations: encryptedPayload.iterations,
          ),
        );

        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-vault-change-passphrase-button')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('vault-current-passphrase-field')),
          'VaultPass#111',
        );
        await tester.enterText(
          find.byKey(const ValueKey('vault-new-passphrase-field')),
          'VaultPass#222',
        );
        await tester.enterText(
          find.byKey(const ValueKey('vault-confirm-new-passphrase-field')),
          'VaultPass#222',
        );
        await tester.tap(
          find.descendant(
            of: find.byKey(const ValueKey('vault-change-passphrase-dialog')),
            matching: find.byKey(const ValueKey('vault-setup-ack-checkbox')),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('vault-change-passphrase-submit')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Vault passphrase updated'), findsOneWidget);

        // Re-encrypted account decrypts under new passphrase cleanly
        final updatedAcct = (await ctx.portalRepo.getAllAccounts()).single;
        final decryptedSecret = await tester.runAsync(
          () => ctx.vaultService.decrypt(updatedAcct.toVaultPayload()),
        );
        expect(decryptedSecret, 'SecretPIN#42');

        // Lock vault from Security card
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-vault-lock-button')),
        );
        expect(find.text('Locked'), findsOneWidget);

        // Data section: export CSV & JSON (without vault secrets)
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-export-csv-btn')),
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-export-json-btn')),
        );
        expect(ctx.exports, hasLength(2));
        expect(ctx.exports[0].fileName, endsWith('.csv'));
        expect(
          utf8.decode(ctx.exports[0].bytes),
          contains('48th BCS Export Check'),
        );
        expect(ctx.exports[1].fileName, endsWith('.json'));
        final jsonText = utf8.decode(ctx.exports[1].bytes);
        expect(jsonText, contains('Bangla Literature'));
        expect(jsonText, isNot(contains('SecretPIN#42')));

        // Delete account confirmation requires acknowledgement checkbox
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-delete-account-btn')),
        );
        expect(
          find.byKey(const ValueKey('settings-delete-account-dialog')),
          findsOneWidget,
        );
        await tester
            .tap(find.byKey(const ValueKey('settings-delete-account-ack')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('settings-delete-account-confirm-btn')),
        );
        await tester.pumpAndSettle();

        expect(ctx.authRepo.deleteAccountCallCount, 1);
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets(
      'renders all 7 Settings sections cleanly in Bangla on 360x800 mobile '
      'with no overflow',
      (tester) async {
        await pumpSettingsApp(
          tester,
          size: const Size(360, 800),
          locale: 'bn',
        );
        expect(find.text('প্রোফাইল'), findsOneWidget);
        expect(find.text('চেহারা ও থিম'), findsOneWidget);
        await tapVisible(
          tester,
          find.byKey(const ValueKey('settings-data-card')),
        );
        expect(find.text('ডেটা ও অ্যাকাউন্ট'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
