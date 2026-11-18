import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_map_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final fixedDate = DateTime.utc(2026, 11, 15, 10);

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpSyllabusMapGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(960, 960);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({kReduceEffectsStorageKey: true});
    final prefs = await SharedPreferences.getInstance();

    const subject = Subject(
      id: 'sub-math-1',
      name: 'Mathematics',
    );

    final chapter1 = Chapter(
      id: 'chap-algebra-1',
      subjectId: subject.id,
      title: 'Algebra & Number Theory',
    );

    final chapter2 = Chapter(
      id: 'chap-calc-2',
      subjectId: subject.id,
      title: 'Calculus Fundamentals',
      sortOrder: 1,
    );

    final topic1 = Topic(
      id: 'top-1',
      subjectId: subject.id,
      chapterId: chapter1.id,
      title: 'Linear Equations & Inequalities',
      studyDoneAt: fixedDate,
      practiceDoneAt: fixedDate,
      modelTestDoneAt: fixedDate,
      revisionDoneAt: fixedDate, // 100% complete
    );

    final topic2 = Topic(
      id: 'top-2',
      subjectId: subject.id,
      chapterId: chapter1.id,
      title: 'Quadratic & Polynomial Functions',
      studyDoneAt: fixedDate,
      // Gap: missing practice and model test
      sortOrder: 1,
    );

    final topic3 = Topic(
      id: 'top-3',
      subjectId: subject.id,
      chapterId: chapter1.id,
      title: 'Number Properties & Divisibility',
      sortOrder: 2,
      // Unstarted
    );

    final topic4 = Topic(
      id: 'top-4',
      subjectId: subject.id,
      chapterId: chapter2.id,
      title: 'Limits & Continuity',
      studyDoneAt: fixedDate,
      practiceDoneAt: fixedDate,
      // Gap: missing model test
    );

    final topics = [topic1, topic2, topic3, topic4];
    final chapters = [chapter1, chapter2];
    final topicRepo = FakeTopicRepository(initialTopics: topics);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          topicRepositoryProvider.overrideWithValue(topicRepo),
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
                  child: SyllabusMapView(
                    subject: subject,
                    chapters: chapters,
                    topics: topics,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Phase 9G Syllabus Map Golden Tests', () {
    testWidgets('SyllabusMapView - dark theme', (tester) async {
      await pumpSyllabusMapGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/syllabus_map_dark.png'),
      );
    });

    testWidgets('SyllabusMapView - light theme', (tester) async {
      await pumpSyllabusMapGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/syllabus_map_light.png'),
      );
    });
  });
}
