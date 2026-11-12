import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/book_progress_3d_canvas.dart';
import 'package:job_prep/core/widgets/book_progress_view.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_subject_detail_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/book_progress_dialog.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_mock_test_repository.dart';
import 'fake_prep_template_repository.dart';
import 'fake_study_plan_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

class _EmptyCircularRepository implements CircularRepository {
  @override
  Future<Circular> createCircular(Circular circular) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCircular(String id) async {}

  @override
  Future<Circular?> getCircularById(String id) async => null;

  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async =>
      const <Circular>[];

  @override
  Future<Circular> updateCircular(Circular circular) =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 11, 11, 10);

  Future<void> pumpStandaloneBookView(
    WidgetTester tester, {
    required int completedUnits,
    required Future<bool> Function(int targetPage, {required bool isCorrection})
        onCommit,
    int totalUnits = 500,
    bool reduceEffects = false,
    String localeCode = 'en',
    ThemeMode themeMode = ThemeMode.dark,
    Size viewport = const Size(860, 720),
    Widget? cover,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: reduceEffects,
      kLocaleStorageKey: localeCode,
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
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: BookProgressView(
                    title: 'Bangla Master Guide',
                    completedUnits: completedUnits,
                    totalUnits: totalUnits,
                    unitLabel: localeCode == 'bn' ? 'পৃষ্ঠা' : 'pages',
                    accentColor: const Color(0xFFE5A93C),
                    cover: cover,
                    lastUpdatedAt: DateTime.utc(2026, 11, 10),
                    replayKey: 'book-test',
                    onCommitPosition: onCommit,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<ProviderContainer> pumpSubjectScreen(
    WidgetTester tester, {
    required Size viewport,
    required FakeSubjectRepository subjectRepo,
    required FakeMaterialRepository materialRepo,
    required FakeProgressLogRepository logRepo,
    FakeStudyPlanRepository? planRepo,
    String localeCode = 'en',
    ThemeMode themeMode = ThemeMode.dark,
    bool reduceEffects = false,
    String? subjectId,
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: reduceEffects,
      kLocaleStorageKey: localeCode,
    });
    final prefs = await SharedPreferences.getInstance();

    final overrides = [
      sharedPreferencesProvider.overrideWithValue(prefs),
      circularNowProvider.overrideWithValue(() => now),
      circularRepositoryProvider.overrideWithValue(_EmptyCircularRepository()),
      subjectRepositoryProvider.overrideWithValue(subjectRepo),
      materialRepositoryProvider.overrideWithValue(materialRepo),
      progressLogRepositoryProvider.overrideWithValue(logRepo),
      materialCoverRepositoryProvider.overrideWithValue(
        FakeMaterialCoverRepository(),
      ),
      prepTemplateRepositoryProvider.overrideWithValue(
        FakePrepTemplateRepository(),
      ),
      mockTestRepositoryProvider.overrideWithValue(FakeMockTestRepository()),
      studyPlanRepositoryProvider.overrideWithValue(
        planRepo ?? FakeStudyPlanRepository(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: viewport.width > 1024
                ? const PrepScreen()
                : PrepSubjectDetailScreen(
                    subjectId: subjectId ?? 'sub-1',
                  ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(Scaffold).first);
    return ProviderScope.containerOf(element);
  }

  group('BookProgressView widget & interaction tests', () {
    testWidgets(
        'renders 3D perspective Transform, glass initial placeholder, edge '
        'painter, percentage and updated date; respects reduceEffects',
        (tester) async {
      await pumpStandaloneBookView(
        tester,
        completedUnits: 200,
        reduceEffects: true,
        onCommit: (target, {required isCorrection}) async => true,
      );

      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(BookProgress3dCanvas),
          matching: find.byType(Transform),
        ),
      );
      expect(
        transforms.any((t) => t.transform.storage[11] != 0.0),
        isTrue,
      );
      expect(
        find.byKey(const ValueKey('book-cover-glass-placeholder')),
        findsOneWidget,
      );
      expect(find.text('B'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('book-page-stack-edge')),
        findsOneWidget,
      );
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('200 / 500 pages'), findsOneWidget);
      expect(find.textContaining('Updated'), findsOneWidget);
    });

    testWidgets(
        'validates whole numbers in range and supports forward study jump '
        'vs backward correction confirmation & cancellation', (tester) async {
      final calls = <(int, bool)>[];
      var completed = 200;

      await pumpStandaloneBookView(
        tester,
        completedUnits: completed,
        onCommit: (target, {required isCorrection}) async {
          calls.add((target, isCorrection));
          completed = target;
          return true;
        },
      );

      final inputFinder = find.descendant(
        of: find.byKey(const ValueKey('book-position-input')),
        matching: find.byType(TextField),
      );
      final saveFinder =
          find.byKey(const ValueKey('book-position-save-button'));

      // Invalid whole / out-of-range checks
      await tester.enterText(inputFinder, '');
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();
      expect(find.text('Enter a page number'), findsOneWidget);

      await tester.enterText(inputFinder, '12.5');
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();
      expect(find.text('Enter a whole page number'), findsOneWidget);

      await tester.enterText(inputFinder, '-10');
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();
      expect(find.text('Page number cannot be negative'), findsOneWidget);

      await tester.enterText(inputFinder, '501');
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();
      expect(find.text('Page cannot exceed 500'), findsOneWidget);
      expect(calls, isEmpty);

      // Valid forward jump: 200 -> 245 saves without dialog
      await tester.enterText(inputFinder, '245');
      await tester.tap(saveFinder);
      await tester.pumpAndSettle();
      expect(calls, [(245, false)]);
      expect(
        find.byKey(const ValueKey('book-correction-confirm-dialog')),
        findsNothing,
      );
      expect(find.text('Logged +45 pages'), findsOneWidget);

      // Pump updated value (245) then enter lower page (140) -> confirm dialog
      await pumpStandaloneBookView(
        tester,
        completedUnits: completed,
        onCommit: (target, {required isCorrection}) async {
          calls.add((target, isCorrection));
          completed = target;
          return true;
        },
      );

      final inputAfter = find.descendant(
        of: find.byKey(const ValueKey('book-position-input')),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputAfter, '140');
      await tester.tap(find.byKey(const ValueKey('book-position-save-button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('book-correction-confirm-dialog')),
        findsOneWidget,
      );
      // Cancel first -> nothing saved
      await tester.tap(
        find.byKey(const ValueKey('book-correction-cancel-button')),
      );
      await tester.pumpAndSettle();
      expect(calls, hasLength(1));

      // Try again and confirm -> saved as correction
      await tester.enterText(inputAfter, '140');
      await tester.tap(find.byKey(const ValueKey('book-position-save-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('book-correction-confirm-button')),
      );
      await tester.pumpAndSettle();

      expect(calls.last, (140, true));
      expect(find.text('Updated position to 140 (correction)'), findsOneWidget);
    });

    testWidgets('dragging ribbon bookmark commits position update',
        (tester) async {
      final calls = <(int, bool)>[];

      await pumpStandaloneBookView(
        tester,
        completedUnits: 100,
        onCommit: (target, {required isCorrection}) async {
          calls.add((target, isCorrection));
          return true;
        },
      );

      final handle = find.byKey(const ValueKey('book-bookmark-handle'));
      expect(handle, findsOneWidget);

      // Drag handle significantly rightward across track
      await tester.drag(handle, const Offset(80, 0));
      await tester.pumpAndSettle();

      expect(calls, isNotEmpty);
      expect(calls.single.$1, greaterThan(100));
      expect(calls.single.$2, isFalse);
    });

    testWidgets(
        'renders Bangla labels and inputs cleanly on narrow 360x800 mobile '
        'without overflow', (tester) async {
      final calls = <(int, bool)>[];

      await pumpStandaloneBookView(
        tester,
        completedUnits: 200,
        localeCode: 'bn',
        themeMode: ThemeMode.light,
        viewport: const Size(360, 800),
        onCommit: (target, {required isCorrection}) async {
          calls.add((target, isCorrection));
          return true;
        },
      );

      expect(tester.takeException(), isNull);
      expect(find.text('আমি আছি পৃষ্ঠা'), findsOneWidget);
      expect(find.text('/ মোট ৫০০'), findsOneWidget);

      final inputFinder = find.descendant(
        of: find.byKey(const ValueKey('book-position-input')),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputFinder, '২৬০');
      await tester.tap(find.byKey(const ValueKey('book-position-save-button')));
      await tester.pumpAndSettle();

      expect(calls, [(260, false)]);
      expect(tester.takeException(), isNull);
    });
  });

  group('BooksShelfView & live Prep / StudyPlan / Dashboard propagation', () {
    testWidgets(
        'arranges 3 books per row on desktop, 2 per row on mobile, excludes '
        'non-book materials, opens Book View on tap, and updates all screens '
        'immediately', (tester) async {
      const subject = Subject(
        id: 'sub-1',
        userId: 'u-1',
        name: 'Bangla & English',
        examType: 'BCS',
      );
      final booksAndVideo = <PrepMaterial>[
        PrepMaterial(
          id: 'b1',
          userId: 'u-1',
          subjectId: 'sub-1',
          title: 'Agrodoot Bangla',
          totalUnits: 500,
          completedUnits: 200,
          updatedAt: DateTime.utc(2026, 11, 10),
        ),
        PrepMaterial(
          id: 'b2',
          userId: 'u-1',
          subjectId: 'sub-1',
          title: 'Master English',
          totalUnits: 300,
          completedUnits: 150,
          updatedAt: DateTime.utc(2026, 11, 9),
        ),
        PrepMaterial(
          id: 'b3',
          userId: 'u-1',
          subjectId: 'sub-1',
          title: 'Digest GK',
          totalUnits: 200,
          updatedAt: DateTime.utc(2026, 11, 8),
        ),
        const PrepMaterial(
          id: 'v1',
          userId: 'u-1',
          subjectId: 'sub-1',
          title: 'Live Grammar Videos',
          kind: MaterialKind.videoCourse,
          unitLabel: 'videos',
          totalUnits: 20,
          completedUnits: 10,
        ),
      ];
      final subjectRepo = FakeSubjectRepository(initialSubjects: [subject]);
      final materialRepo = FakeMaterialRepository(
        initialMaterials: booksAndVideo,
        clock: () => now,
      );
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
        clock: () => now,
        initialLogs: [
          ProgressLog(
            id: 'l-b1',
            userId: 'u-1',
            materialId: 'b1',
            unitsDone: 200,
            loggedOn: DateTime.utc(2026, 11, 10),
          ),
          ProgressLog(
            id: 'l-b2',
            userId: 'u-1',
            materialId: 'b2',
            unitsDone: 150,
            loggedOn: DateTime.utc(2026, 11, 9),
          ),
          ProgressLog(
            id: 'l-v1',
            userId: 'u-1',
            materialId: 'v1',
            unitsDone: 10,
            loggedOn: DateTime.utc(2026, 11, 8),
          ),
        ],
      );
      final planRepo = FakeStudyPlanRepository(
        initialPlans: [
          StudyPlan(
            id: 'plan-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            startDate: DateTime.utc(2026, 11, 10),
            targetDate: DateTime.utc(2026, 11, 28),
          ),
        ],
      );

      // 1) Desktop 1280x900 -> switch to Books shelf -> 3 per row
      final container = await pumpSubjectScreen(
        tester,
        viewport: const Size(1280, 900),
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        planRepo: planRepo,
      );

      await tester.tap(find.byKey(const ValueKey('subject-tab-books-shelf')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('books-shelf-view')), findsOneWidget);
      expect(find.byKey(const ValueKey('books-shelf-book-v1')), findsNothing);

      final r1 =
          tester.getRect(find.byKey(const ValueKey('books-shelf-book-b1')));
      final r2 =
          tester.getRect(find.byKey(const ValueKey('books-shelf-book-b2')));
      final r3 =
          tester.getRect(find.byKey(const ValueKey('books-shelf-book-b3')));
      expect((r1.top - r2.top).abs(), lessThan(2.0));
      expect((r2.top - r3.top).abs(), lessThan(2.0));
      expect(r1.left, lessThan(r2.left));
      expect(r2.left, lessThan(r3.left));

      // Tap first book -> opens BookProgressDialog at 200 -> enter 245 -> updates book/subject/plan/dashboard
      await tester.tap(find.byKey(const ValueKey('books-shelf-book-b1')));
      await tester.pumpAndSettle();

      expect(find.byType(BookProgressDialog), findsOneWidget);
      final fieldFinder = find.descendant(
        of: find.byKey(const ValueKey('book-position-input')),
        matching: find.byType(TextField),
      );
      await tester.enterText(fieldFinder, '245');
      await tester.tap(find.byKey(const ValueKey('book-position-save-button')));
      await tester.pumpAndSettle();

      // Immediate updates across book, study plan, and dashboard
      expect(find.text('245 / 500 pages'), findsWidgets);
      expect(
        container
            .read(studyPlanSnapshotsProvider)
            .requireValue
            .single
            .todayCompletedUnits,
        45,
      );
      expect(
        container
            .read(dashboardSummaryProvider)
            .requireValue
            .overallPrepProgress,
        closeTo((245 + 150 + 10) / (500 + 300 + 200 + 20), 1e-6),
      );

      // Confirm downward correction -> log history displays Correction badge
      await tester.enterText(fieldFinder, '180');
      await tester.tap(find.byKey(const ValueKey('book-position-save-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('book-correction-confirm-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('180 / 500 pages'), findsWidgets);
      expect(
        container
            .read(studyPlanSnapshotsProvider)
            .requireValue
            .single
            .todayCompletedUnits,
        45,
      );

      // Verify Log History marks backward adjustment with Correction pill
      await tester.tap(find.byKey(const ValueKey('book-open-history-b1')));
      await tester.pumpAndSettle();
      expect(find.text('Correction'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('180 / 500 pages'), findsOneWidget);

      // 2) Mobile 360x800 -> Books shelf arranges 2 columns per row cleanly
      await pumpSubjectScreen(
        tester,
        viewport: const Size(360, 800),
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        planRepo: planRepo,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('subject-tab-books-shelf')),
      );
      await tester.tap(find.byKey(const ValueKey('subject-tab-books-shelf')));
      await tester.pumpAndSettle();

      final m1 =
          tester.getRect(find.byKey(const ValueKey('books-shelf-book-b1')));
      final m2 =
          tester.getRect(find.byKey(const ValueKey('books-shelf-book-b2')));
      final m3 =
          tester.getRect(find.byKey(const ValueKey('books-shelf-book-b3')));
      expect((m1.top - m2.top).abs(), lessThan(2.0));
      expect(m3.top, greaterThan(m1.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows helpful empty shelf card when subject has no books',
        (tester) async {
      const subject = Subject(id: 'sub-v', userId: 'u-1', name: 'Videos Only');
      const video = PrepMaterial(
        id: 'v-only',
        userId: 'u-1',
        subjectId: 'sub-v',
        title: 'Course Lectures',
        kind: MaterialKind.videoCourse,
        unitLabel: 'videos',
        totalUnits: 12,
      );
      final subjectRepo = FakeSubjectRepository(initialSubjects: [subject]);
      final materialRepo = FakeMaterialRepository(initialMaterials: [video]);
      final logRepo =
          FakeProgressLogRepository(materialRepository: materialRepo);

      await pumpSubjectScreen(
        tester,
        viewport: const Size(1280, 900),
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
      );

      await tester.tap(find.byKey(const ValueKey('subject-tab-books-shelf')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('books-shelf-empty-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('books-shelf-add-book-button')),
        findsOneWidget,
      );
    });
  });
}
