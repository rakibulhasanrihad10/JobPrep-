import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_mock_tests_section.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/circulars/fake_circular_repository.dart';
import '../features/prep/fake_material_and_log_repositories.dart';
import '../features/prep/fake_mock_test_repository.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixedNow = DateTime.utc(2026, 11, 10, 9);

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpMockTestGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(920, 960);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kLocaleStorageKey: 'en',
      kUseBanglaDigitsStorageKey: false,
    });
    final prefs = await SharedPreferences.getInstance();

    const subject = Subject(
      id: 'g-sub',
      userId: 'u-1',
      name: 'Quantitative Aptitude',
      icon: 'calculate',
    );
    const material = PrepMaterial(
      id: 'g-mat',
      userId: 'u-1',
      subjectId: 'g-sub',
      title: 'Khairul Basic Math',
      totalUnits: 420,
      completedUnits: 210,
    );
    const topic = Topic(
      id: 'g-top',
      userId: 'u-1',
      subjectId: 'g-sub',
      name: 'Permutation & Probability',
    );
    const circular = Circular(
      id: 'g-circ',
      userId: 'u-1',
      title: '48th BCS Circular',
      sector: CircularSector.bcs,
    );

    final mockRepo = FakeMockTestRepository(
      clock: () => fixedNow,
      initialTests: [
        MockTest(
          id: 'gm-1',
          userId: 'u-1',
          subjectId: 'g-sub',
          title: 'Foundation Speed Test 01',
          source: 'Khairul Practice',
          takenOn: DateTime.utc(2026, 10, 26),
          marksObtained: 62,
          totalMarks: 100,
          negativeMarks: 4,
        ),
        MockTest(
          id: 'gm-2',
          userId: 'u-1',
          subjectId: 'g-sub',
          title: 'Combined Bank Mock 04',
          source: 'Live MCQ',
          takenOn: DateTime.utc(2026, 11, 2),
          marksObtained: 77,
          totalMarks: 100,
          negativeMarks: 3,
        ),
        MockTest(
          id: 'gm-3',
          userId: 'u-1',
          subjectId: 'g-sub',
          circularId: 'g-circ',
          materialId: 'g-mat',
          topicId: 'g-top',
          title: '48th BCS Math Full Set 08',
          source: 'Oracle Model',
          takenOn: DateTime.utc(2026, 11, 9),
          marksObtained: 89,
          totalMarks: 100,
          negativeMarks: 2.5,
          timeTakenMinutes: 52,
          timeLimitMinutes: 60,
          weakTopics: 'Conditional Probability',
          notes: 'Review Bayes theorem shortcuts.',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subjectRepositoryProvider.overrideWithValue(
            FakeSubjectRepository(initialSubjects: const [subject]),
          ),
          materialRepositoryProvider.overrideWithValue(
            FakeMaterialRepository(initialMaterials: const [material]),
          ),
          topicRepositoryProvider.overrideWithValue(
            FakeTopicRepository(initialTopics: const [topic]),
          ),
          circularRepositoryProvider.overrideWithValue(
            FakeCircularRepository(initialItems: const [circular]),
          ),
          mockTestRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final tokens = context.tokens;
                final subjectColor = PrepStyleTokens.resolveSubjectColor(
                  subject.color,
                  tokens.colors,
                );
                return Container(
                  color: tokens.colors.background,
                  padding: tokens.spacing.insetsAllLg,
                  child: SingleChildScrollView(
                    child: SubjectMockTestsSection(
                      subject: subject,
                      subjectColor: subjectColor,
                      replayKey: 'golden-$themeMode',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('Mock test stats, trend chart & list golden - dark theme',
      (tester) async {
    await pumpMockTestGolden(tester, themeMode: ThemeMode.dark);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/mock_test_dark.png'),
    );
  });

  testWidgets('Mock test stats, trend chart & list golden - light theme',
      (tester) async {
    await pumpMockTestGolden(tester, themeMode: ThemeMode.light);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/mock_test_light.png'),
    );
  });
}
