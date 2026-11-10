import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPrep(
    WidgetTester tester, {
    required FakeSubjectRepository subjectRepo,
    required FakeMaterialRepository materialRepo,
    FakeMaterialCoverRepository? coverRepo,
    Size viewportSize = const Size(1280, 900),
    ThemeMode themeMode = ThemeMode.dark,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: true,
      kLocaleStorageKey: locale.languageCode,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          materialCoverRepositoryProvider.overrideWithValue(
            coverRepo ?? FakeMaterialCoverRepository(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PrepScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Subject Manager UI', () {
    testWidgets('creates and edits a user-defined subject', (tester) async {
      final subjectRepo = FakeSubjectRepository();
      final materialRepo = FakeMaterialRepository();

      await pumpPrep(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
      );

      expect(find.text('No subjects yet'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('add-subject-button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('subject-name-field')),
        'Anatomy & Physiology',
      );
      await tester.enterText(
        find.byKey(const ValueKey('subject-exam-type-field')),
        'Medical Residency',
      );
      await tester.tap(find.byKey(const ValueKey('subject-color-info')));
      await tester.tap(find.byKey(const ValueKey('subject-icon-science')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('subject-save-button')));
      await tester.pumpAndSettle();

      expect(subjectRepo.subjects, hasLength(1));
      final created = subjectRepo.subjects.first;
      expect(created.name, 'Anatomy & Physiology');
      expect(created.examType, 'Medical Residency');
      expect(created.color, 'info');
      expect(created.icon, 'science');
      expect(find.text('Anatomy & Physiology'), findsWidgets);

      await tester.tap(find.byKey(ValueKey('subject-edit-${created.id}')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('subject-name-field')),
        'Clinical Anatomy',
      );
      await tester.enterText(
        find.byKey(const ValueKey('subject-exam-type-field')),
        'FCPS Part 1',
      );
      await tester.tap(find.byKey(const ValueKey('subject-save-button')));
      await tester.pumpAndSettle();

      expect(subjectRepo.subjects.first.name, 'Clinical Anatomy');
      expect(subjectRepo.subjects.first.examType, 'FCPS Part 1');
      expect(find.text('Clinical Anatomy'), findsWidgets);
    });

    testWidgets('reorders subjects and persists updated sortOrder',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 'sub-1',
            userId: 'u-1',
            name: 'English Literature',
            examType: 'BCS',
          ),
          Subject(
            id: 'sub-2',
            userId: 'u-1',
            name: 'System Design',
            examType: 'Software Track',
            sortOrder: 1,
          ),
        ],
      );

      await pumpPrep(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: FakeMaterialRepository(),
      );

      await tester.tap(find.byKey(const ValueKey('subject-move-down-sub-1')));
      await tester.pumpAndSettle();

      final ordered = await subjectRepo.getSubjects();
      expect(ordered.map((s) => s.id).toList(), ['sub-2', 'sub-1']);
      expect(ordered.map((s) => s.sortOrder).toList(), [0, 1]);
    });

    testWidgets(
        'warns before deleting a subject that has logged material progress',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(id: 'sub-prog', userId: 'u-1', name: 'Mathematics'),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'mat-prog',
            userId: 'u-1',
            subjectId: 'sub-prog',
            title: 'Algebra Guide',
            totalUnits: 300,
            completedUnits: 120,
          ),
        ],
      );

      await pumpPrep(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        coverRepo: FakeMaterialCoverRepository(),
      );

      await tester.tap(find.byKey(const ValueKey('subject-delete-sub-prog')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('prep-delete-progress-warning')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('prep-delete-cancel')));
      await tester.pumpAndSettle();
      expect(subjectRepo.subjects, hasLength(1));

      await tester.tap(find.byKey(const ValueKey('subject-delete-sub-prog')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('prep-delete-confirm')));
      await tester.pumpAndSettle();
      expect(subjectRepo.subjects, isEmpty);
    });

    testWidgets(
        'renders Bangla mobile 360px layout in light mode and opens detail',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 'sub-bn',
            userId: 'u-1',
            name: 'বাংলা সাহিত্য ও ব্যাকরণ',
            color: 'success',
            icon: 'language',
            examType: 'বিসিএস',
          ),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'mat-bn',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'অগ্রদূত বাংলা',
            unitLabel: 'পৃষ্ঠা',
            totalUnits: 300,
            completedUnits: 300,
          ),
        ],
      );

      await pumpPrep(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        viewportSize: const Size(360, 800),
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('বাংলা সাহিত্য ও ব্যাকরণ'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('subject-card-sub-bn')));
      await tester.pumpAndSettle();

      expect(find.text('অগ্রদূত বাংলা'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('prep-detail-back-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('subject-card-sub-bn')), findsOneWidget);
    });
  });
}
