import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/security/vault_clipboard_service.dart';
import 'package:job_prep/core/security/vault_providers.dart';
import 'package:job_prep/core/security/vault_service.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/url_launcher_provider.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_view.dart';
import 'package:job_prep/features/settings/presentation/providers/reminder_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';
import 'package:job_prep/features/vault/data/mappers/portal_account_mapper.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/fake_auth_repository.dart';
import '../circulars/fake_circular_repository.dart';
import '../circulars/fake_exam_date_repository.dart';
import '../settings/fake_reminder_settings_repository.dart';
import 'fake_portal_account_repository.dart';

void main() {
  const passphrase = 'VaultMasterPassword!2026';

  Circular sampleCircular() {
    return Circular(
      id: 'c-portal',
      userId: 'user-1',
      title: '48th BCS Portal Circular',
      applicationUrl: 'https://bpsc.teletalk.com.bd',
      deadline: DateTime.utc(2026, 11, 20, 17),
    );
  }

  group('Phase 6B - Encryption Boundary, Auto-Lock & Clipboard Timer Tests',
      () {
    test(
      'database layer receives ONLY ciphertext and entities never leak secrets',
      () async {
        const plainPassword = 'TopSecretPortalPassword#99!';
        final repo = FakePortalAccountRepository();
        final authRepo = FakeAuthRepository.authenticated();
        addTearDown(authRepo.dispose);

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            portalAccountRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        final controller =
            container.read(portalVaultControllerProvider.notifier);
        await controller.setupPassphrase(passphrase);

        const draft = PortalAccountDraft(
          circularId: 'c-portal',
          portalUrl: 'https://bpsc.teletalk.com.bd',
          username: 'APPLICANT-1001',
          password: plainPassword,
          notes: 'PIN in SMS',
        );
        expect(draft.toString(), isNot(contains(plainPassword)));

        final saved = await controller.savePortalAccount(draft);
        expect(saved.toString(), isNot(contains(plainPassword)));
        expect(saved.encryptedPassword, isNotEmpty);
        expect(saved.encryptedPassword, isNot(equals(plainPassword)));
        expect(
          base64Decode(saved.salt),
          hasLength(VaultService.saltLengthBytes),
        );
        expect(
          base64Decode(saved.nonce),
          hasLength(VaultService.nonceLengthBytes),
        );

        // Inspect raw wire-format JSON payloads handed to the DB repository.
        expect(repo.wirePayloads, hasLength(2)); // verifier + account insert
        final serializedWire = jsonEncode(repo.wirePayloads);
        expect(serializedWire, isNot(contains(plainPassword)));
        expect(serializedWire, isNot(contains(passphrase)));
        expect(
          repo.wirePayloads.last['encrypted_password'],
          equals(saved.encryptedPassword),
        );

        // Mapper round trip restores ciphertext metadata without plaintext.
        final mapped = PortalAccountMapper.fromJson({
          ...repo.wirePayloads.last,
          'id': saved.id,
          'user_id': 'user-1',
        });
        expect(mapped.encryptedPassword, saved.encryptedPassword);
        expect(mapped.salt, saved.salt);
        expect(mapped.nonce, saved.nonce);

        final decryptedList = await container.read(
          circularPortalAccountsProvider('c-portal').future,
        );
        expect(decryptedList, hasLength(1));
        expect(decryptedList.first.password, equals(plainPassword));
        expect(
          decryptedList.first.toString(),
          isNot(contains(plainPassword)),
        );
      },
    );

    test(
      'auto-locks after inactivity timeout (reset by activity) and wipes clip',
      () async {
        final clipboardHistory = <String>[];
        String? clipboardValue;

        final authRepo = FakeAuthRepository.authenticated(
          const AuthUser(
            id: 'user-1',
            email: 'aspirant@example.com',
            emailConfirmed: true,
          ),
        );
        addTearDown(authRepo.dispose);

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
            vaultInactivityTimeoutProvider.overrideWithValue(
              const Duration(milliseconds: 120),
            ),
            vaultClipboardClearDurationProvider.overrideWithValue(
              const Duration(milliseconds: 250),
            ),
            vaultClipboardWriterProvider.overrideWithValue((text) async {
              clipboardValue = text;
              clipboardHistory.add(text);
            }),
            vaultClipboardReaderProvider.overrideWithValue(
              () async => clipboardValue,
            ),
          ],
        );
        addTearDown(container.dispose);

        container.listen(vaultSessionProvider, (_, __) {});
        final session = container.read(vaultSessionProvider.notifier);
        final vault = container.read(vaultServiceProvider);

        await session.unlock(passphrase: passphrase);
        await container
            .read(vaultClipboardServiceProvider)
            .copySensitive('Secret123!');
        expect(clipboardValue, equals('Secret123!'));
        expect(container.read(vaultSessionProvider).isUnlocked, isTrue);

        // Activity ping extends timeout past 120ms from initial unlock.
        await Future<void>.delayed(const Duration(milliseconds: 70));
        session.recordActivity();
        await Future<void>.delayed(const Duration(milliseconds: 70));
        expect(container.read(vaultSessionProvider).isUnlocked, isTrue);

        // Remaining idle longer than timeout auto-locks and clears clipboard.
        await Future<void>.delayed(const Duration(milliseconds: 160));
        expect(container.read(vaultSessionProvider).isUnlocked, isFalse);
        expect(vault.isUnlocked, isFalse);
        expect(clipboardValue, equals(''));
        expect(clipboardHistory, equals(['Secret123!', '']));
      },
    );

    test(
      'VaultClipboardService clears sensitive text automatically after timer',
      () async {
        final writes = <String>[];
        String? current;
        final service = VaultClipboardService(
          clearDuration: const Duration(milliseconds: 60),
          writer: (text) async {
            current = text;
            writes.add(text);
          },
          reader: () async => current,
        );
        addTearDown(service.dispose);

        await service.copySensitive('CopiedPassword!');
        expect(current, equals('CopiedPassword!'));
        expect(service.hasPendingClear, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(current, equals(''));
        expect(writes, equals(['CopiedPassword!', '']));
        expect(service.hasPendingClear, isFalse);
      },
    );
  });

  group('Phase 6B - Circular Detail Vault & Portal Accounts Widget Tests', () {
    Future<List<String>> pumpCircularDetailWithVault(
      WidgetTester tester, {
      required FakePortalAccountRepository portalRepo,
      String locale = 'en',
      ThemeMode themeMode = ThemeMode.dark,
      Duration clipboardClearDuration = const Duration(seconds: 30),
      List<Uri>? launchedUris,
      Size size = const Size(960, 1600),
    }) async {
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

      final circularRepo = FakeCircularRepository(
        initialItems: [sampleCircular()],
      );
      final examRepo = FakeExamDateRepository();
      final copiedLog = <String>[];
      String? currentClipboard;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            circularRepositoryProvider.overrideWithValue(circularRepo),
            examDateRepositoryProvider.overrideWithValue(examRepo),
            portalAccountRepositoryProvider.overrideWithValue(portalRepo),
            vaultClipboardClearDurationProvider
                .overrideWithValue(clipboardClearDuration),
            vaultClipboardWriterProvider.overrideWithValue((text) async {
              currentClipboard = text;
              copiedLog.add(text);
            }),
            vaultClipboardReaderProvider.overrideWithValue(
              () async => currentClipboard,
            ),
            circularUrlLauncherProvider.overrideWithValue((uri) async {
              launchedUris?.add(uri);
              return true;
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: CircularDetailView(
                  circularId: 'c-portal',
                  isPane: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return copiedLog;
    }

    testWidgets(
      'Portal login hidden when locked; setup warning, unlock, CRUD, and copy',
      (tester) async {
        final portalRepo = FakePortalAccountRepository();
        final launchedUris = <Uri>[];
        final clipboardWrites = await pumpCircularDetailWithVault(
          tester,
          portalRepo: portalRepo,
          clipboardClearDuration: const Duration(milliseconds: 90),
          launchedUris: launchedUris,
        );

        // 1. Locked state hides Portal Login section & reveals setup gate.
        expect(
          find.byKey(const ValueKey('circular-portal-vault-gate')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('circular-portal-login-section')),
          findsNothing,
        );
        expect(find.text('Set up vault'), findsOneWidget);

        // 2. Open first-time setup dialog & verify non-recovery warning + ack.
        await tester.ensureVisible(
          find.byKey(const ValueKey('circular-portal-unlock-button')),
        );
        await tester.tap(
          find.byKey(const ValueKey('circular-portal-unlock-button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('vault-setup-dialog')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('vault-setup-warning-banner')),
          findsOneWidget,
        );
        expect(
          find.textContaining('cannot be recovered or reset'),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const ValueKey('vault-passphrase-field')),
          passphrase,
        );
        await tester.enterText(
          find.byKey(const ValueKey('vault-confirm-passphrase-field')),
          passphrase,
        );

        // Submitting without acknowledging warning shows validation error.
        await tester.tap(find.byKey(const ValueKey('vault-dialog-submit')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('vault-dialog-error-text')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('vault-setup-ack-checkbox')),
        );
        await tester.tap(find.byKey(const ValueKey('vault-dialog-submit')));
        await tester.pumpAndSettle();

        // 3. Vault is unlocked -> Portal Login section becomes visible.
        expect(portalRepo.verifier, isNotNull);
        expect(
          find.byKey(const ValueKey('circular-portal-login-section')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('portal-empty-state')),
          findsOneWidget,
        );

        // 4. Add portal account and verify repository stores ciphertext only.
        await tester.ensureVisible(
          find.byKey(const ValueKey('portal-add-button')),
        );
        await tester.tap(find.byKey(const ValueKey('portal-add-button')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('portal-form-username')),
          'BCS-CANDIDATE-77',
        );
        await tester.enterText(
          find.byKey(const ValueKey('portal-form-password')),
          'PlainPassword!88',
        );
        await tester.enterText(
          find.byKey(const ValueKey('portal-form-notes')),
          'Admit download PIN',
        );
        await tester.tap(find.byKey(const ValueKey('portal-form-save')));
        await tester.pumpAndSettle();

        expect(portalRepo.accounts, hasLength(1));
        final accountId = portalRepo.accounts.first.id;
        expect(
          portalRepo.accounts.first.encryptedPassword,
          isNot(equals('PlainPassword!88')),
        );
        expect(
          find.byKey(ValueKey('portal-account-tile-$accountId')),
          findsOneWidget,
        );
        expect(find.text('BCS-CANDIDATE-77'), findsOneWidget);
        // Password starts masked cleanly.
        expect(find.text('••••••••'), findsOneWidget);
        expect(find.text('PlainPassword!88'), findsNothing);

        Future<void> tapVisible(Finder finder) async {
          ScaffoldMessenger.of(tester.element(finder)).clearSnackBars();
          await tester.pumpAndSettle();
          await tester.ensureVisible(finder);
          await tester.pumpAndSettle();
          await tester.tap(finder);
          await tester.pumpAndSettle();
        }

        // Reveal eye displays decrypted password in memory cleanly.
        await tapVisible(
          find.byKey(ValueKey('portal-toggle-password-$accountId')),
        );
        expect(find.text('PlainPassword!88'), findsOneWidget);

        // Copy user ID and copy password trigger clear-clipboard timer.
        await tapVisible(find.byKey(ValueKey('portal-copy-user-$accountId')));
        expect(clipboardWrites, contains('BCS-CANDIDATE-77'));

        await tapVisible(
          find.byKey(ValueKey('portal-copy-password-$accountId')),
        );
        expect(clipboardWrites, contains('PlainPassword!88'));

        await tester.pump(const Duration(milliseconds: 130));
        expect(clipboardWrites.last, equals(''));

        // Open portal link uses circularUrlLauncherProvider.
        await tapVisible(find.byKey(ValueKey('portal-open-url-$accountId')));
        expect(
          launchedUris,
          equals([Uri.parse('https://bpsc.teletalk.com.bd')]),
        );

        // 5. Edit account cleanly.
        await tapVisible(find.byKey(ValueKey('portal-edit-$accountId')));
        await tester.enterText(
          find.byKey(const ValueKey('portal-form-password')),
          'UpdatedSecret!99',
        );
        await tester.tap(find.byKey(const ValueKey('portal-form-save')));
        await tester.pumpAndSettle();
        expect(
          portalRepo.accounts.first.encryptedPassword,
          isNot(equals('UpdatedSecret!99')),
        );

        // 6. Lock hides Portal Login section and removes credentials.
        await tapVisible(
          find.byKey(const ValueKey('portal-vault-lock-button')),
        );
        expect(
          find.byKey(const ValueKey('circular-portal-login-section')),
          findsNothing,
        );
        expect(find.text('BCS-CANDIDATE-77'), findsNothing);

        // Re-unlock with wrong passphrase fails; right passphrase succeeds.
        await tapVisible(
          find.byKey(const ValueKey('circular-portal-unlock-button')),
        );
        expect(
          find.byKey(const ValueKey('vault-unlock-dialog')),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const ValueKey('vault-passphrase-field')),
          'WrongPassphrase9',
        );
        await tester.tap(find.byKey(const ValueKey('vault-dialog-submit')));
        await tester.pumpAndSettle();
        expect(
          find.text('Incorrect vault passphrase. Please try again.'),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const ValueKey('vault-passphrase-field')),
          passphrase,
        );
        await tester.tap(find.byKey(const ValueKey('vault-dialog-submit')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('circular-portal-login-section')),
          findsOneWidget,
        );
        expect(find.text('BCS-CANDIDATE-77'), findsOneWidget);

        // 7. Delete account cleanly with confirmation dialog.
        await tapVisible(find.byKey(ValueKey('portal-delete-$accountId')));
        await tester.tap(
          find.byKey(ValueKey('portal-confirm-delete-$accountId')),
        );
        await tester.pumpAndSettle();
        expect(portalRepo.accounts, isEmpty);
        expect(
          find.byKey(const ValueKey('portal-empty-state')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SettingsScreen renders VaultSecurityCard cleanly on 360x800 Bangla',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        SharedPreferences.setMockInitialValues({
          kLocaleStorageKey: 'bn',
        });
        final prefs = await SharedPreferences.getInstance();
        final authRepo = FakeAuthRepository.authenticated();
        addTearDown(authRepo.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              authRepositoryProvider.overrideWithValue(authRepo),
              reminderSettingsRepositoryProvider.overrideWithValue(
                FakeReminderSettingsRepository(),
              ),
              portalAccountRepositoryProvider.overrideWithValue(
                FakePortalAccountRepository(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              locale: const Locale('bn'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: SettingsScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('settings-vault-security-card')),
          findsOneWidget,
        );
        expect(find.text('পোর্টাল ভল্ট'), findsOneWidget);
        expect(find.text('লক করা আছে'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
