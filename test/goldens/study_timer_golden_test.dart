import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_timer_tab_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/prep/fake_material_and_log_repositories.dart';
import '../features/prep/fake_study_session_repository.dart';
import '../features/prep/fake_subject_and_topic_repositories.dart';

class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(super.testFile);

  static const double _tolerance = 0.04;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (!result.passed && result.diffPercent <= _tolerance) {
      return true;
    }
    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}

class _NoopPlatform implements StudyTimerPlatformAdapter {
  @override
  Future<void> playGentleChime() async {}

  @override
  void restoreTabTitle() {}

  @override
  void setTabTitle(String title) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixedNow = DateTime.utc(2026, 11, 11, 10, 14, 15);

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpTimerGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(980, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: true,
      kLocaleStorageKey: 'en',
      kUseBanglaDigitsStorageKey: false,
      kTimerSoundEnabledKey: true,
    });
    final prefs = await SharedPreferences.getInstance();

    const subMath = Subject(
      id: 'g-math',
      userId: 'u-1',
      name: 'Quantitative Math',
      icon: 'calculate',
    );
    const subBn = Subject(
      id: 'g-bn',
      userId: 'u-1',
      name: 'Bangla Literature',
      color: 'info',
      icon: 'language',
      sortOrder: 1,
    );
    const matMath = PrepMaterial(
      id: 'gm-1',
      userId: 'u-1',
      subjectId: 'g-math',
      title: 'Khairul Basic Math',
      totalUnits: 450,
      completedUnits: 180,
    );

    final sessionRepo = FakeStudySessionRepository(
      clock: () => fixedNow,
      initialSessions: [
        StudySession(
          id: 'gs-open',
          userId: 'u-1',
          subjectId: 'g-math',
          materialId: 'gm-1',
          startedAt: DateTime.utc(2026, 11, 11, 10),
          phaseStartedAt: DateTime.utc(2026, 11, 11, 10),
          targetDurationSeconds: 1500,
          pomodoroRound: 1,
          pomodoroPhase: PomodoroPhase.focus,
        ),
        StudySession(
          id: 'gs-done-1',
          userId: 'u-1',
          subjectId: 'g-bn',
          startedAt: DateTime.utc(2026, 11, 10, 16),
          endedAt: DateTime.utc(2026, 11, 10, 17, 15),
          durationSeconds: 4500,
          mode: StudySessionMode.stopwatch,
          note: 'Charyapada & Medieval period notes',
        ),
        StudySession(
          id: 'gs-done-2',
          userId: 'u-1',
          subjectId: 'g-math',
          materialId: 'gm-1',
          startedAt: DateTime.utc(2026, 11, 9, 14),
          endedAt: DateTime.utc(2026, 11, 9, 15, 30),
          durationSeconds: 5400,
          mode: StudySessionMode.manual,
          note: 'Offline practice set',
        ),
      ],
    );

    final matRepo = FakeMaterialRepository(initialMaterials: const [matMath]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularNowProvider.overrideWithValue(() => fixedNow),
          subjectRepositoryProvider.overrideWithValue(
            FakeSubjectRepository(initialSubjects: const [subMath, subBn]),
          ),
          materialRepositoryProvider.overrideWithValue(matRepo),
          progressLogRepositoryProvider.overrideWithValue(
            FakeProgressLogRepository(
              materialRepository: matRepo,
              clock: () => fixedNow,
            ),
          ),
          studySessionRepositoryProvider.overrideWithValue(sessionRepo),
          studyTimerPlatformProvider.overrideWithValue(_NoopPlatform()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final tokens = context.tokens;
              return Scaffold(
                backgroundColor: tokens.colors.background,
                body: SingleChildScrollView(
                  padding: tokens.spacing.insetsAllXl,
                  child: const StudyTimerTabView(visitId: 1),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Phase 6H Study Timer Golden Tests', () {
    testWidgets('StudyTimerTabView - dark theme', (tester) async {
      await pumpTimerGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/study_timer_dark.png'),
      );
    });

    testWidgets('StudyTimerTabView - light theme', (tester) async {
      await pumpTimerGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/study_timer_light.png'),
      );
    });
  });
}
