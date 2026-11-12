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
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_queue_tab_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/prep/fake_material_and_log_repositories.dart';
import '../features/prep/fake_revision_item_repository.dart';
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
  final fixedNow = DateTime.utc(2026, 11, 11, 10);

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpRevisionGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(960, 880);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: 'en',
      kUseBanglaDigitsStorageKey: false,
    });
    final prefs = await SharedPreferences.getInstance();

    const subMath = Subject(
      id: 'g-math',
      userId: 'u-1',
      name: 'Quantitative Math',
      icon: 'calculate',
    );
    const subBangla = Subject(
      id: 'g-bn',
      userId: 'u-1',
      name: 'Bangla Literature',
      color: 'info',
      icon: 'language',
      sortOrder: 1,
    );
    const matMath = PrepMaterial(
      id: 'g-mat-m',
      userId: 'u-1',
      subjectId: 'g-math',
      title: 'Khairul Basic Math',
      totalUnits: 450,
      completedUnits: 128,
    );
    const matBn = PrepMaterial(
      id: 'g-mat-b',
      userId: 'u-1',
      subjectId: 'g-bn',
      title: 'Agrodoot Bangla',
      totalUnits: 320,
      completedUnits: 200,
    );

    final revisionRepo = FakeRevisionItemRepository(
      clock: () => fixedNow,
      initialItems: [
        RevisionItem(
          id: 'gr-1',
          userId: 'u-1',
          subjectId: 'g-math',
          materialId: 'g-mat-m',
          referenceLabel: 'p. 128 Problem 14',
          pageNumber: 128,
          note: 'Sign flip in quadratic substitution shortcut',
          source: RevisionSource.log,
          dueOn: DateTime.utc(2026, 11, 11),
          reviewCount: 1,
          lastReviewedOn: DateTime.utc(2026, 11, 8),
        ),
        RevisionItem(
          id: 'gr-2',
          userId: 'u-1',
          subjectId: 'g-bn',
          materialId: 'g-mat-b',
          referenceLabel: 'Charyapada Verse Authors',
          reason: RevisionReason.forgot,
          dueOn: DateTime.utc(2026, 11, 11),
        ),
        RevisionItem(
          id: 'gr-3',
          userId: 'u-1',
          subjectId: 'g-math',
          referenceLabel: 'Conditional Probability',
          reason: RevisionReason.mistake,
          source: RevisionSource.mockTest,
          dueOn: DateTime.utc(2026, 11, 9),
          reviewCount: 2,
          lastReviewedOn: DateTime.utc(2026, 11, 2),
        ),
        RevisionItem(
          id: 'gr-4',
          userId: 'u-1',
          subjectId: 'g-math',
          referenceLabel: 'Binomial Expansion',
          status: RevisionStatus.mastered,
          dueOn: DateTime.utc(2026, 11),
          reviewCount: 5,
          lastReviewedOn: DateTime.utc(2026, 11),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          revisionNowProvider.overrideWithValue(() => fixedNow),
          subjectRepositoryProvider.overrideWithValue(
            FakeSubjectRepository(initialSubjects: const [subMath, subBangla]),
          ),
          materialRepositoryProvider.overrideWithValue(
            FakeMaterialRepository(initialMaterials: const [matMath, matBn]),
          ),
          revisionItemRepositoryProvider.overrideWithValue(revisionRepo),
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
                  child: const RevisionQueueTabView(visitId: 1),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Phase 6G Revision Queue Golden Tests', () {
    testWidgets('RevisionQueueTabView - dark theme', (tester) async {
      await pumpRevisionGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/revision_queue_dark.png'),
      );
    });

    testWidgets('RevisionQueueTabView - light theme', (tester) async {
      await pumpRevisionGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/revision_queue_light.png'),
      );
    });
  });
}
