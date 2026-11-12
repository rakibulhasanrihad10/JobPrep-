import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/security/vault_providers.dart';
import 'package:job_prep/core/security/vault_service.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/data/mappers/user_settings_error_mapper.dart';
import 'package:job_prep/features/settings/data/mappers/user_settings_mapper.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/settings/domain/errors/settings_failure.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_builder.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_csv.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_json.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../auth/fake_auth_repository.dart';
import '../vault/fake_portal_account_repository.dart';
import 'fake_user_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7A Data Export Unit Tests', () {
    DataExportSnapshot sampleSnapshot() {
      return DataExportSnapshot(
        exportedAt: DateTime.utc(2026, 11, 12, 6, 30),
        circulars: [
          Circular(
            id: 'c-1',
            userId: 'u-1',
            title: '48th BCS, "Special" Cadre',
            sector: CircularSector.bcs,
            organizationName: 'BPSC',
            circularUrl: 'https://bpsc.gov.bd/48',
            applicationUrl: 'https://bpsc.teletalk.com.bd',
            deadline: DateTime.utc(2026, 12),
            vacancies: 300,
            applicationFee: 700,
            applicationStatus: ApplicationStatus.inProgress,
            admitCardStatus: AdmitCardStatus.available,
            priority: CircularPriority.high,
            workflowStatus: CircularWorkflowStatus.preparing,
            checklist: const ApplicationChecklist(photo: true, feePaid: true),
            notes: 'Line 1\nLine 2',
          ),
        ],
        examDates: [
          CircularExamDate(
            id: 'ed-1',
            circularId: 'c-1',
            userId: 'u-1',
            stage: 'preliminary',
            examDate: DateTime.utc(2027, 1, 15),
            venue: 'Dhaka',
          ),
        ],
        subjects: const [
          Subject(
            id: 'sub-1',
            userId: 'u-1',
            name: 'Bangladesh Affairs',
            sortOrder: 1,
          ),
        ],
        materials: const [
          PrepMaterial(
            id: 'mat-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'MP3 Bangladesh',
            totalUnits: 400,
            completedUnits: 120,
          ),
        ],
        topics: const [
          Topic(
            id: 'top-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            name: 'Liberation War',
            status: TopicStatus.inProgress,
          ),
        ],
        progressLogs: [
          ProgressLog(
            id: 'log-1',
            userId: 'u-1',
            materialId: 'mat-1',
            unitsDone: 40,
            loggedOn: DateTime.utc(2026, 11, 11),
            note: 'Chapter 3, verified',
          ),
        ],
        studyPlans: [
          StudyPlan(
            id: 'sp-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            startDate: DateTime.utc(2026, 11),
            targetDate: DateTime.utc(2027, 1, 15),
            maxDailyPace: 30,
          ),
        ],
        mockTests: [
          MockTest(
            id: 'mt-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'BCS Model #4',
            source: 'Oracle',
            takenOn: DateTime.utc(2026, 11, 10),
            marksObtained: 145.5,
            totalMarks: 200,
          ),
        ],
        revisionItems: [
          RevisionItem(
            id: 'rev-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            materialId: 'mat-1',
            referenceLabel: 'p. 128',
            pageNumber: 128,
            dueOn: DateTime.utc(2026, 11, 13),
          ),
        ],
        studySessions: [
          StudySession(
            id: 'ss-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            materialId: 'mat-1',
            startedAt: DateTime.utc(2026, 11, 12, 4),
            endedAt: DateTime.utc(2026, 11, 12, 4, 25),
            durationSeconds: 1500,
            note: 'Deep work',
          ),
        ],
      );
    }

    test('DataExportCsv.escapeCell escapes commas, quotes, and newlines', () {
      expect(DataExportCsv.escapeCell('plain'), 'plain');
      expect(DataExportCsv.escapeCell('a,b'), '"a,b"');
      expect(DataExportCsv.escapeCell('say "hi"'), '"say ""hi"""');
      expect(DataExportCsv.escapeCell('l1\nl2'), '"l1\nl2"');
      expect(DataExportCsv.escapeCell('l1\r\nl2'), '"l1\r\nl2"');
    });

    test('JSON export includes all circulars and prep collections cleanly', () {
      final snapshot = sampleSnapshot();
      final jsonText = DataExportBuilder.toJsonString(snapshot);
      final decoded = jsonDecode(jsonText) as Map<String, dynamic>;

      expect(decoded['schemaVersion'], DataExportJson.schemaVersion);
      expect(decoded['exportedAt'], '2026-11-12T06:30:00.000Z');
      final counts = decoded['counts'] as Map<String, dynamic>;
      expect(counts['circulars'], 1);
      expect(counts['examDates'], 1);
      expect(counts['subjects'], 1);
      expect(counts['materials'], 1);
      expect(counts['topics'], 1);
      expect(counts['progressLogs'], 1);
      expect(counts['studyPlans'], 1);
      expect(counts['mockTests'], 1);
      expect(counts['revisionItems'], 1);
      expect(counts['studySessions'], 1);

      final firstCircular = (decoded['circulars'] as List<dynamic>).single
          as Map<String, dynamic>;
      expect(firstCircular['title'], '48th BCS, "Special" Cadre');
      expect(firstCircular['checklist'], {
        'photo': true,
        'feePaid': true,
        'certificates': false,
        'submitted': false,
        'admitCardDownloaded': false,
      });
      expect(jsonText, isNot(contains('encryptedPassword')));
    });

    test('CSV export encodes all 10 record types with escaping & filename', () {
      final snapshot = sampleSnapshot();
      final csv = DataExportBuilder.toCsvString(snapshot);
      final bytes =
          DataExportBuilder.buildBytes(snapshot, DataExportFormat.csv);

      expect(utf8.decode(bytes), csv);
      expect(csv.startsWith(DataExportCsv.columns.join(',')), isTrue);
      expect(csv, contains('circular,c-1'));
      expect(csv, contains('"48th BCS, ""Special"" Cadre"'));
      expect(csv, contains('circular_exam_date,ed-1,c-1,preliminary'));
      expect(csv, contains('subject,sub-1'));
      expect(csv, contains('material,mat-1,sub-1,MP3 Bangladesh'));
      expect(csv, contains('topic,top-1,sub-1,Liberation War'));
      expect(csv, contains('progress_log,log-1,mat-1'));
      expect(csv, contains('study_plan,sp-1,sub-1'));
      expect(csv, contains('mock_test,mt-1,sub-1,BCS Model #4'));
      expect(csv, contains('revision_item,rev-1,mat-1,p. 128'));
      expect(csv, contains('study_session,ss-1,mat-1,Deep work'));

      expect(
        DataExportBuilder.buildFileName(
          DateTime.utc(2026, 11, 12, 23, 59),
          DataExportFormat.csv,
        ),
        'jobprep-export-2026-11-12.csv',
      );
      expect(
        DataExportBuilder.buildFileName(
          DateTime.utc(2026, 1, 5),
          DataExportFormat.json,
        ),
        'jobprep-export-2026-01-05.json',
      );
    });
  });

  group('UserSettings Mappers, Sync & Vault Passphrase Change', () {
    test('UserSettingsMapper round-trips, clamps bounds, and maps errors', () {
      final parsed = UserSettingsMapper.fromJson({
        'user_id': 'u-1',
        'display_name': '  Rakib Hasan  ',
        'theme_mode': 'dark',
        'reduce_effects': true,
        'locale_code': 'bn',
        'bangla_digits': true,
        'focus_minutes': 250,
        'short_break_minutes': 0,
        'long_break_minutes': 2,
        'updated_at': '2026-11-12T04:00:00Z',
      });

      expect(parsed.displayName, 'Rakib Hasan');
      expect(parsed.themeMode, ThemeMode.dark);
      expect(parsed.reduceEffects, isTrue);
      expect(parsed.localeCode, 'bn');
      expect(parsed.banglaDigits, isTrue);
      expect(parsed.focusMinutes, UserAppSettings.maxFocusMinutes);
      expect(parsed.shortBreakMinutes, UserAppSettings.minShortBreakMinutes);
      expect(parsed.longBreakMinutes, UserAppSettings.minLongBreakMinutes);

      expect(
        UserSettingsMapper.toUpsertJson(userId: 'u-1', settings: parsed),
        {
          'user_id': 'u-1',
          'display_name': 'Rakib Hasan',
          'theme_mode': 'dark',
          'reduce_effects': true,
          'locale_code': 'bn',
          'bangla_digits': true,
          'focus_minutes': 180,
          'short_break_minutes': 1,
          'long_break_minutes': 5,
        },
      );

      expect(
        UserSettingsErrorMapper.map(TimeoutException('slow')),
        isA<SettingsNetworkFailure>(),
      );
      expect(
        UserSettingsErrorMapper.map(
          const supabase.PostgrestException(message: 'denied', code: '42501'),
        ),
        isA<SettingsPermissionFailure>(),
      );
      expect(
        UserSettingsErrorMapper.map(
          const supabase.PostgrestException(message: 'check', code: '23514'),
        ),
        isA<SettingsValidationFailure>(),
      );
    });

    test(
      'UserSettingsNotifier hydrates remote settings, persists locally & '
      'keeps local state if remote upsert fails',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final authRepo = FakeAuthRepository.authenticated();
        addTearDown(authRepo.dispose);

        final settingsRepo = FakeUserSettingsRepository(
          initialSettings: const UserAppSettings(
            userId: 'test-user-id',
            displayName: 'Remote Name',
            themeMode: ThemeMode.dark,
            reduceEffects: true,
            localeCode: 'bn',
            banglaDigits: true,
            focusMinutes: 45,
            shortBreakMinutes: 10,
            longBreakMinutes: 20,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(authRepo),
            userSettingsRepositoryProvider.overrideWithValue(settingsRepo),
          ],
        );
        addTearDown(container.dispose);

        final loaded = await container.read(userSettingsProvider.future);
        expect(loaded.displayName, 'Remote Name');
        expect(container.read(themeModeProvider), ThemeMode.dark);
        expect(container.read(reduceEffectsProvider), isTrue);
        expect(container.read(localeProvider).languageCode, 'bn');
        expect(container.read(useBanglaDigitsProvider), isTrue);
        expect(container.read(pomodoroConfigProvider).focusMinutes, 45);
        expect(container.read(pomodoroConfigProvider).shortBreakMinutes, 10);
        expect(container.read(pomodoroConfigProvider).longBreakMinutes, 20);

        // Offline failure: local state stays updated and sync returns false.
        settingsRepo.nextError = const SettingsNetworkFailure();
        final syncOk = await container
            .read(userSettingsProvider.notifier)
            .updateStudyTimerDefaults(
              focusMinutes: 50,
              shortBreakMinutes: 8,
              longBreakMinutes: 25,
            );
        expect(syncOk, isFalse);
        expect(container.read(pomodoroConfigProvider).focusMinutes, 50);
        expect(prefs.getInt(kPomodoroFocusMinutesKey), 50);
      },
    );

    test(
      'PortalVaultController.changePassphrase re-encrypts saved accounts '
      'and rejects incorrect current passphrase',
      () async {
        const oldPass = 'OldVaultSecret#1';
        const newPass = 'NewVaultSecret#2';
        const portalPass = 'MyTeletalkPassword!99';
        final vaultService = VaultService(
          iterations: VaultService.minIterations,
        );
        final portalRepo = FakePortalAccountRepository();
        final authRepo = FakeAuthRepository.authenticated();
        addTearDown(authRepo.dispose);

        final container = ProviderContainer(
          overrides: [
            vaultServiceProvider.overrideWithValue(vaultService),
            authRepositoryProvider.overrideWithValue(authRepo),
            portalAccountRepositoryProvider.overrideWithValue(portalRepo),
          ],
        );
        addTearDown(container.dispose);

        final controller =
            container.read(portalVaultControllerProvider.notifier);
        await controller.setupPassphrase(oldPass);
        final savedAccount = await controller.savePortalAccount(
          const PortalAccountDraft(
            circularId: 'c-1',
            username: 'USER-1',
            password: portalPass,
          ),
        );

        // Wrong current passphrase aborts without altering verifier/ciphertext.
        final wrongAttempt = await controller.changePassphrase(
          currentPassphrase: 'WrongPassword!',
          newPassphrase: newPass,
        );
        expect(wrongAttempt, isFalse);

        // Correct passphrase re-encrypts account & unlocks under new one.
        final changed = await controller.changePassphrase(
          currentPassphrase: oldPass,
          newPassphrase: newPass,
        );
        expect(changed, isTrue);

        final updatedAccount = (await portalRepo.getAllAccounts()).single;
        expect(
          updatedAccount.encryptedPassword,
          isNot(equals(savedAccount.encryptedPassword)),
        );
        expect(
          await vaultService.decrypt(updatedAccount.toVaultPayload()),
          portalPass,
        );

        // Old passphrase no longer verifies or unlocks.
        controller.lockVault();
        expect(await controller.unlockWithPassphrase(oldPass), isFalse);
        expect(await controller.unlockWithPassphrase(newPass), isTrue);
      },
    );
  });
}
