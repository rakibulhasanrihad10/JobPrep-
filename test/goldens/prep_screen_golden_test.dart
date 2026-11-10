import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/prep/fake_material_and_log_repositories.dart';
import '../features/prep/fake_material_cover_repository.dart';
import '../features/prep/fake_prep_template_repository.dart';
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

  setUpAll(() {
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  List<Subject> sampleSubjects() {
    return const [
      Subject(
        id: 'g-sub-1',
        userId: 'u-1',
        name: 'Bengali Literature & Grammar',
        color: 'info',
        icon: 'language',
        examType: 'BCS',
      ),
      Subject(
        id: 'g-sub-2',
        userId: 'u-1',
        name: 'Quantitative Math',
        icon: 'calculate',
        examType: 'Bank',
        sortOrder: 1,
      ),
      Subject(
        id: 'g-sub-3',
        userId: 'u-1',
        name: 'System Design',
        color: 'accent_secondary',
        icon: 'computer',
        examType: 'Engineering',
        sortOrder: 2,
      ),
    ];
  }

  List<PrepMaterial> sampleMaterials() {
    return const [
      PrepMaterial(
        id: 'g-mat-1',
        userId: 'u-1',
        subjectId: 'g-sub-1',
        title: 'অগ্রদূত বাংলা সাহিত্য',
        totalUnits: 300,
        completedUnits: 300,
      ),
      PrepMaterial(
        id: 'g-mat-2',
        userId: 'u-1',
        subjectId: 'g-sub-1',
        title: 'MP3 বাংলা ব্যাকরণ',
        totalUnits: 300,
        completedUnits: 150,
        coverImagePath: 'u-1/g-mat-2/mp3.png',
      ),
      PrepMaterial(
        id: 'g-mat-3',
        userId: 'u-1',
        subjectId: 'g-sub-1',
        title: 'প্রফেসরস বাংলা ডাইজেস্ট',
        totalUnits: 400,
        completedUnits: 50,
      ),
      PrepMaterial(
        id: 'g-mat-4',
        userId: 'u-1',
        subjectId: 'g-sub-2',
        title: 'Bank Math Practice',
        kind: MaterialKind.questionBank,
        totalUnits: 200,
        completedUnits: 100,
      ),
    ];
  }

  Future<void> pumpPrepGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: 'en',
    });
    final prefs = await SharedPreferences.getInstance();

    final subjectRepo = FakeSubjectRepository(
      initialSubjects: sampleSubjects(),
    );
    final materialRepo = FakeMaterialRepository(
      initialMaterials: sampleMaterials(),
    );
    final coverRepo = FakeMaterialCoverRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          materialCoverRepositoryProvider.overrideWithValue(coverRepo),
          prepTemplateRepositoryProvider.overrideWithValue(
            FakePrepTemplateRepository(),
          ),
          materialCoverPreviewImageBuilderProvider.overrideWithValue(
            (context, uri) {
              final tokens = context.tokens;
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.colors.goldAccentSubtle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: tokens.spacing.xxl,
                  color: tokens.colors.goldAccent,
                ),
              );
            },
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: PrepScreen(selectedSubjectId: 'g-sub-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('PrepScreen Golden Tests', () {
    testWidgets('PrepScreen desktop golden - dark mode', (tester) async {
      await pumpPrepGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(PrepScreen),
        matchesGoldenFile('goldens/prep_screen_dark.png'),
      );
    });

    testWidgets('PrepScreen desktop golden - light mode', (tester) async {
      await pumpPrepGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(PrepScreen),
        matchesGoldenFile('goldens/prep_screen_light.png'),
      );
    });
  });
}
