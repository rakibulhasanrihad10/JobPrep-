import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/book_progress_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_logs_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_tab_switcher.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_queue_tab_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_mock_test_repository.dart';
import 'fake_prep_template_repository.dart';
import 'fake_revision_item_repository.dart';
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

  Future<void> pumpPrepScreen(
    WidgetTester tester, {
    required FakeSubjectRepository subjectRepo,
    required FakeMaterialRepository materialRepo,
    required FakeProgressLogRepository logRepo,
    required FakeRevisionItemRepository revisionRepo,
    FakeMockTestRepository? mockRepo,
    PrepSectionTab initialTab = PrepSectionTab.subjects,
    Size viewport = const Size(1280, 900),
    ThemeMode themeMode = ThemeMode.dark,
    String localeCode = 'en',
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: localeCode,
      kUseBanglaDigitsStorageKey: false,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularNowProvider.overrideWithValue(() => now),
          circularRepositoryProvider
              .overrideWithValue(_EmptyCircularRepository()),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
          materialCoverRepositoryProvider.overrideWithValue(
            FakeMaterialCoverRepository(),
          ),
          prepTemplateRepositoryProvider.overrideWithValue(
            FakePrepTemplateRepository(),
          ),
          mockTestRepositoryProvider.overrideWithValue(
            mockRepo ?? FakeMockTestRepository(clock: () => now),
          ),
          studyPlanRepositoryProvider.overrideWithValue(
            FakeStudyPlanRepository(),
          ),
          revisionItemRepositoryProvider.overrideWithValue(revisionRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PrepScreen(initialTab: initialTab),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Phase 6G flagging flows across Log, Book View, Material, MockTest',
      () {
    testWidgets(
        'allows flagging 2 items after saving progress in MaterialLogsDialog '
        'without leaving dialog, without adding study units', (tester) async {
      const subject = Subject(id: 'sub-1', userId: 'u-1', name: 'Math');
      const book = PrepMaterial(
        id: 'm1',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Khairul Math',
        totalUnits: 400,
        completedUnits: 100,
      );
      final subjectRepo = FakeSubjectRepository(initialSubjects: [subject]);
      final materialRepo = FakeMaterialRepository(
        initialMaterials: [book],
        clock: () => now,
      );
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
        clock: () => now,
        initialLogs: [
          ProgressLog(
            id: 'log-seed',
            materialId: 'm1',
            unitsDone: 100,
            loggedOn: DateTime.utc(2026, 11, 10),
          ),
        ],
      );
      final revisionRepo = FakeRevisionItemRepository(clock: () => now);

      await pumpPrepScreen(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        revisionRepo: revisionRepo,
      );

      await tester.tap(find.byKey(const ValueKey('material-custom-log-m1')));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialLogsDialog), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('log-units-field')),
        '28',
      );
      await tester.tap(find.byKey(const ValueKey('log-save-button')));
      await tester.pumpAndSettle();

      // Post-save revision prompt appears inside the same dialog
      expect(
        find.byKey(const ValueKey('log-post-save-revision-banner')),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('log-mark-for-revision-button')),
      );
      await tester.tap(
        find.byKey(const ValueKey('log-mark-for-revision-button')),
      );
      await tester.pumpAndSettle();

      final refField = find.descendant(
        of: find.byKey(const ValueKey('revision-ref-field')),
        matching: find.byType(TextField),
      );
      final noteField = find.descendant(
        of: find.byKey(const ValueKey('revision-note-field')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(refField);
      await tester.enterText(refField, 'p. 128 Problem 14');
      await tester.ensureVisible(
        find.byKey(const ValueKey('revision-reason-tricky')),
      );
      await tester.tap(find.byKey(const ValueKey('revision-reason-tricky')));
      await tester.enterText(noteField, 'Factoring trap');
      final addFlagButton =
          find.byKey(const ValueKey('revision-add-flag-button'));
      await tester.ensureVisible(addFlagButton);
      await tester.tap(addFlagButton);
      await tester.pumpAndSettle();

      // Still in the same dialog -> add second flag directly!
      await tester.ensureVisible(refField);
      await tester.enterText(refField, 'Problem 19');
      await tester.ensureVisible(
        find.byKey(const ValueKey('revision-reason-mistake')),
      );
      await tester.tap(find.byKey(const ValueKey('revision-reason-mistake')));
      await tester.ensureVisible(addFlagButton);
      await tester.tap(addFlagButton);
      await tester.pumpAndSettle();

      expect(revisionRepo.items, hasLength(2));
      expect(revisionRepo.items[0].referenceLabel, 'p. 128 Problem 14');
      expect(revisionRepo.items[0].pageNumber, 128);
      expect(revisionRepo.items[0].reason, RevisionReason.tricky);
      expect(revisionRepo.items[0].source, RevisionSource.log);
      expect(revisionRepo.items[0].progressLogId, isNotNull);
      expect(revisionRepo.items[0].dueOn, DateTime.utc(2026, 11, 12));

      expect(revisionRepo.items[1].referenceLabel, 'Problem 19');
      expect(revisionRepo.items[1].reason, RevisionReason.mistake);

      // Completed units reflect only the 100 + 28 study pages cleanly
      expect(materialRepo.materials.single.completedUnits, 128);
    });

    testWidgets(
        'flags from Phase 6F Book View after I am at page entry and renders '
        'flag marker pins at flagged pages on the book', (tester) async {
      const subject = Subject(id: 'sub-1', userId: 'u-1', name: 'Bangla');
      const book = PrepMaterial(
        id: 'b1',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Agrodoot Bangla',
        totalUnits: 400,
        completedUnits: 100,
      );
      final subjectRepo = FakeSubjectRepository(initialSubjects: [subject]);
      final materialRepo = FakeMaterialRepository(
        initialMaterials: [book],
        clock: () => now,
      );
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
        clock: () => now,
        initialLogs: [
          ProgressLog(
            id: 'log-1',
            materialId: 'b1',
            unitsDone: 100,
            loggedOn: DateTime.utc(2026, 11, 10),
          ),
        ],
      );
      final revisionRepo = FakeRevisionItemRepository(
        clock: () => now,
        initialItems: [
          RevisionItem(
            id: 'rev-existing',
            userId: 'u-1',
            subjectId: 'sub-1',
            materialId: 'b1',
            referenceLabel: 'p. 80',
            pageNumber: 80,
            dueOn: DateTime.utc(2026, 11, 11),
          ),
        ],
      );

      await pumpPrepScreen(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        revisionRepo: revisionRepo,
      );

      await tester.tap(find.byKey(const ValueKey('material-book-view-b1')));
      await tester.pumpAndSettle();
      expect(find.byType(BookProgressDialog), findsOneWidget);

      // Seeded flag pin on p. 80 is visible immediately on the book track!
      expect(
        find.byKey(const ValueKey('book-flag-marker-80')),
        findsOneWidget,
      );

      // Save new page position 210 via "I am at page ___ of ___"
      final pageInput = find.descendant(
        of: find.byKey(const ValueKey('book-position-input')),
        matching: find.byType(TextField),
      );
      await tester.enterText(pageInput, '210');
      await tester.tap(find.byKey(const ValueKey('book-position-save-button')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('book-post-save-mark-revision-button')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('revision-reason-forgot')));
      await tester.tap(find.byKey(const ValueKey('revision-add-flag-button')));
      await tester.pumpAndSettle();

      expect(revisionRepo.items, hasLength(2));
      expect(revisionRepo.items.last.pageNumber, 210);
      expect(revisionRepo.items.last.source, RevisionSource.log);
      expect(
        find.byKey(const ValueKey('book-flag-marker-210')),
        findsOneWidget,
      );
    });

    testWidgets(
        'adds flag directly from MaterialCard and sends mock test weak topics '
        'via Add to revision', (tester) async {
      const subject = Subject(id: 'sub-1', userId: 'u-1', name: 'Aptitude');
      const book = PrepMaterial(
        id: 'm1',
        userId: 'u-1',
        subjectId: 'sub-1',
        title: 'Geometry Guide',
        totalUnits: 300,
        completedUnits: 90,
      );
      final mockRepo = FakeMockTestRepository(
        clock: () => now,
        initialTests: [
          MockTest(
            id: 'mt-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'BCS Set 5',
            takenOn: DateTime.utc(2026, 11, 10),
            marksObtained: 70,
            totalMarks: 100,
            weakTopics: 'Probability, Permutation',
          ),
        ],
      );
      final subjectRepo = FakeSubjectRepository(initialSubjects: [subject]);
      final materialRepo = FakeMaterialRepository(initialMaterials: [book]);
      final logRepo =
          FakeProgressLogRepository(materialRepository: materialRepo);
      final revisionRepo = FakeRevisionItemRepository(clock: () => now);

      await pumpPrepScreen(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        mockRepo: mockRepo,
        revisionRepo: revisionRepo,
      );

      // 1) Direct flag icon on MaterialCard
      await tester.tap(find.byKey(const ValueKey('material-flag-m1')));
      await tester.pumpAndSettle();
      expect(find.byType(RevisionFlagDialog), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('revision-add-flag-button')));
      await tester.pumpAndSettle();
      expect(revisionRepo.items, hasLength(1));
      expect(revisionRepo.items.single.source, RevisionSource.manual);

      await tester
          .tap(find.byKey(const ValueKey('revision-dialog-close-button')));
      await tester.pumpAndSettle();

      // 2) Mock Test weak topics -> Add to revision
      await tester.tap(find.byKey(const ValueKey('prep-tab-mock-tests')));
      await tester.pumpAndSettle();

      final addToRevBtn =
          find.byKey(const ValueKey('mock-add-to-revision-mt-1'));
      await tester.ensureVisible(addToRevBtn);
      await tester.tap(addToRevBtn);
      await tester.pumpAndSettle();

      expect(find.byType(RevisionFlagDialog), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('revision-add-all-weak-topics-button')),
      );
      await tester.pumpAndSettle();

      expect(revisionRepo.items, hasLength(3));
      expect(
        revisionRepo.items
            .where((i) => i.source == RevisionSource.mockTest)
            .map((i) => i.referenceLabel)
            .toList(),
        ['Probability', 'Permutation'],
      );
    });
  });

  group('RevisionQueueTabView tabs, filters, spaced actions & Undo', () {
    testWidgets(
        'renders Due today, Overdue, Upcoming, and Done tabs, filters by '
        'subject/material, executes Easy/Still hard/Snooze/Dismiss with Undo, '
        'and fits 360x800 Bangla layout', (tester) async {
      const subMath = Subject(id: 'sub-m', userId: 'u-1', name: 'Math');
      const subBn = Subject(id: 'sub-b', userId: 'u-1', name: 'Bangla');
      const matMath = PrepMaterial(
        id: 'm-math',
        userId: 'u-1',
        subjectId: 'sub-m',
        title: 'Math Book',
        totalUnits: 200,
      );
      const matBn = PrepMaterial(
        id: 'm-bn',
        userId: 'u-1',
        subjectId: 'sub-b',
        title: 'Bangla Book',
        totalUnits: 200,
      );

      final seededItems = <RevisionItem>[
        RevisionItem(
          id: 'r-due-1',
          userId: 'u-1',
          subjectId: 'sub-m',
          materialId: 'm-math',
          referenceLabel: 'p. 128 Problem 14',
          pageNumber: 128,
          note: 'Check sign change',
          dueOn: DateTime.utc(2026, 11, 11),
        ),
        RevisionItem(
          id: 'r-due-2',
          userId: 'u-1',
          subjectId: 'sub-b',
          materialId: 'm-bn',
          referenceLabel: 'Charyapada poets',
          reason: RevisionReason.forgot,
          dueOn: DateTime.utc(2026, 11, 11),
        ),
        RevisionItem(
          id: 'r-overdue',
          userId: 'u-1',
          subjectId: 'sub-m',
          materialId: 'm-math',
          referenceLabel: 'Bayes formula',
          reason: RevisionReason.mistake,
          status: RevisionStatus.revised,
          dueOn: DateTime.utc(2026, 11, 8),
          reviewCount: 2,
          lastReviewedOn: DateTime.utc(2026, 11),
        ),
        RevisionItem(
          id: 'r-upcoming',
          userId: 'u-1',
          subjectId: 'sub-b',
          materialId: 'm-bn',
          referenceLabel: 'Sandhi rules',
          dueOn: DateTime.utc(2026, 11, 15),
          reviewCount: 1,
        ),
        RevisionItem(
          id: 'r-done',
          userId: 'u-1',
          subjectId: 'sub-m',
          materialId: 'm-math',
          referenceLabel: 'Mastered theorem',
          status: RevisionStatus.mastered,
          dueOn: DateTime.utc(2026, 11, 5),
          reviewCount: 5,
          lastReviewedOn: DateTime.utc(2026, 11, 5),
        ),
      ];

      final subjectRepo =
          FakeSubjectRepository(initialSubjects: [subMath, subBn]);
      final materialRepo = FakeMaterialRepository(
        initialMaterials: [matMath, matBn],
      );
      final logRepo =
          FakeProgressLogRepository(materialRepository: materialRepo);
      final revisionRepo = FakeRevisionItemRepository(
        initialItems: seededItems,
        clock: () => now,
      );

      await pumpPrepScreen(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        revisionRepo: revisionRepo,
        initialTab: PrepSectionTab.revision,
      );

      expect(find.byType(RevisionQueueTabView), findsOneWidget);
      expect(find.text('Due today (2)'), findsOneWidget);
      expect(find.text('Overdue (1)'), findsOneWidget);
      expect(find.text('Upcoming (1)'), findsOneWidget);
      expect(find.text('Done (1)'), findsOneWidget);
      expect(find.text('p. 128 Problem 14'), findsOneWidget);
      expect(find.text('Charyapada poets'), findsOneWidget);

      // Easy on r-due-1 -> moves to Upcoming (+3 days) & shows Undo
      await tester
          .tap(find.byKey(const ValueKey('revision-action-easy-r-due-1')));
      await tester.pumpAndSettle();
      expect(find.text('p. 128 Problem 14'), findsNothing);
      expect(find.text('Due today (1)'), findsOneWidget);
      expect(find.text('Upcoming (2)'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('revision-undo-banner')),
        findsOneWidget,
      );

      // Undo restores r-due-1 back into Due today!
      await tester.tap(find.byKey(const ValueKey('revision-undo-button')));
      await tester.pumpAndSettle();
      expect(find.text('p. 128 Problem 14'), findsOneWidget);
      expect(find.text('Due today (2)'), findsOneWidget);

      // Snooze r-due-1 -> moves to Upcoming without changing reviewCount
      await tester.tap(
        find.byKey(const ValueKey('revision-action-snooze-r-due-1')),
      );
      await tester.pumpAndSettle();
      final snoozed = revisionRepo.items.firstWhere((e) => e.id == 'r-due-1');
      expect(snoozed.reviewCount, 0);
      expect(snoozed.dueOn, DateTime.utc(2026, 11, 12));
      expect(find.text('Upcoming (2)'), findsOneWidget);

      // Undo snooze -> back to Due today
      await tester.tap(find.byKey(const ValueKey('revision-undo-button')));
      await tester.pumpAndSettle();

      // Dismiss r-due-2 -> moves to Done (2)
      await tester.tap(
        find.byKey(const ValueKey('revision-action-dismiss-r-due-2')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Done (2)'), findsOneWidget);

      // Switch to Overdue -> Still hard resets reviewCount to 0 & dueOn + 1d
      await tester.tap(
        find.byKey(const ValueKey('revision-queue-tab-overdue')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bayes formula'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('revision-action-stillHard-r-overdue')),
      );
      await tester.pumpAndSettle();
      final resetItem =
          revisionRepo.items.firstWhere((e) => e.id == 'r-overdue');
      expect(resetItem.reviewCount, 0);
      expect(resetItem.dueOn, DateTime.utc(2026, 11, 12));

      // Verify Done tab shows mastered & dismissed items
      await tester.tap(find.byKey(const ValueKey('revision-queue-tab-done')));
      await tester.pumpAndSettle();
      expect(find.text('Mastered theorem'), findsOneWidget);
      expect(find.text('Charyapada poets'), findsOneWidget);

      // Verify Bangla locale at 360x800 narrow mobile fits without overflow
      await pumpPrepScreen(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
        revisionRepo: revisionRepo,
        initialTab: PrepSectionTab.revision,
        viewport: const Size(360, 800),
        themeMode: ThemeMode.light,
        localeCode: 'bn',
      );
      expect(
        find.byKey(const ValueKey('revision-undo-banner')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
