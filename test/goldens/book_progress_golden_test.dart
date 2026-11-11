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
import 'package:job_prep/core/widgets/book_progress_view.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/books_shelf_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/prep/fake_material_cover_repository.dart';

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

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  Future<void> pumpBookViewGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(760, 420);
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
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
              final colors = tokens.colors;
              return Scaffold(
                backgroundColor: colors.background,
                body: Center(
                  child: Padding(
                    padding: tokens.spacing.insetsAllLg,
                    child: BookProgressView(
                      title: 'Agrodoot Bangla Literature',
                      completedUnits: 245,
                      totalUnits: 500,
                      unitLabel: 'pages',
                      accentColor: colors.goldAccent,
                      lastUpdatedAt: DateTime.utc(2026, 11, 10),
                      replayKey: 'golden-$themeMode',
                      onCommitPosition: (
                        targetPage, {
                        required isCorrection,
                      }) async =>
                          true,
                    ),
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

  Future<void> pumpBooksShelfGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(820, 420);
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
    final coverRepo = FakeMaterialCoverRepository();

    final books = <PrepMaterial>[
      PrepMaterial(
        id: 'gb-1',
        userId: 'u-1',
        subjectId: 'g-sub',
        title: 'MP3 Bangla Grammar',
        totalUnits: 400,
        completedUnits: 320,
        coverImagePath: 'u-1/gb-1/cover.png',
        updatedAt: DateTime.utc(2026, 11, 10),
      ),
      PrepMaterial(
        id: 'gb-2',
        userId: 'u-1',
        subjectId: 'g-sub',
        title: 'Agrodoot Literature',
        totalUnits: 500,
        completedUnits: 245,
        updatedAt: DateTime.utc(2026, 11, 9),
      ),
      PrepMaterial(
        id: 'gb-3',
        userId: 'u-1',
        subjectId: 'g-sub',
        title: 'BCS Digest',
        totalUnits: 300,
        completedUnits: 60,
        updatedAt: DateTime.utc(2026, 11, 8),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          materialCoverRepositoryProvider.overrideWithValue(coverRepo),
          materialCoverPreviewImageBuilderProvider.overrideWithValue(
            (context, uri) {
              final tokens = context.tokens;
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.colors.goldAccentSubtle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: tokens.spacing.xxxl,
                  color: tokens.colors.goldAccent,
                ),
              );
            },
          ),
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
              final colors = tokens.colors;
              return Scaffold(
                backgroundColor: colors.background,
                body: SingleChildScrollView(
                  padding: tokens.spacing.insetsAllLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SubjectViewModeBar(
                        activeMode: PrepSubjectViewMode.booksShelf,
                        bookCount: books.length,
                        onChanged: (_) {},
                      ),
                      SizedBox(height: tokens.spacing.lg),
                      BooksShelfView(
                        subjectName: 'Bangla Literature',
                        subjectColor: colors.info,
                        books: books,
                        replayKey: 'shelf-golden-$themeMode',
                        onAddBook: () {},
                        onOpenBook: (_) {},
                      ),
                    ],
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

  group('Phase 6F Book Progress View & Books Shelf Goldens', () {
    testWidgets('BookProgressView - dark theme', (tester) async {
      await pumpBookViewGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/book_progress_view_dark.png'),
      );
    });

    testWidgets('BookProgressView - light theme', (tester) async {
      await pumpBookViewGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/book_progress_view_light.png'),
      );
    });

    testWidgets('BooksShelfView - dark theme', (tester) async {
      await pumpBooksShelfGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/books_shelf_dark.png'),
      );
    });

    testWidgets('BooksShelfView - light theme', (tester) async {
      await pumpBooksShelfGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/books_shelf_light.png'),
      );
    });
  });
}
