import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_prep_template_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPrepScreen(
    WidgetTester tester, {
    required FakeSubjectRepository subjectRepo,
    required FakeMaterialRepository materialRepo,
    required FakePrepTemplateRepository templateRepo,
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
          progressLogRepositoryProvider.overrideWithValue(
            FakeProgressLogRepository(materialRepository: materialRepo),
          ),
          materialCoverRepositoryProvider.overrideWithValue(
            FakeMaterialCoverRepository(),
          ),
          prepTemplateRepositoryProvider.overrideWithValue(templateRepo),
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

  group('Phase 4E - Prep Templates Flows', () {
    testWidgets(
        'customizes units before applying Software Engineer pack, edits '
        'material afterward, and guards double-apply in Templates dialog',
        (tester) async {
      final subjectRepo = FakeSubjectRepository();
      final materialRepo = FakeMaterialRepository();
      final templateRepo = FakePrepTemplateRepository();

      await pumpPrepScreen(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        templateRepo: templateRepo,
      );

      expect(find.text('Government Job'), findsOneWidget);
      expect(find.text('Software Engineer'), findsOneWidget);

      // Customize units on Software Engineer before copying
      final customizeBtn = find.byKey(
        const ValueKey('customize-template-software_engineer'),
      );
      await tester.ensureVisible(customizeBtn);
      await tester.tap(customizeBtn);
      await tester.pumpAndSettle();

      final dsaField = find.byKey(
        const ValueKey(
          'template-unit-field-00000000-0000-4000-8102-000000000001',
        ),
      );
      await tester.ensureVisible(dsaField);
      await tester.enterText(dsaField, '250');
      await tester.tap(
        find.byKey(const ValueKey('confirm-apply-template-button')),
      );
      await tester.pumpAndSettle();

      expect(subjectRepo.subjects, hasLength(5));
      expect(materialRepo.materials, hasLength(8));
      expect(find.textContaining('0 / 250'), findsOneWidget);

      // Material copied from template stays editable afterward
      final dsaMaterial = materialRepo.materials
          .firstWhere((m) => m.title == 'Core DSA Problem Set');
      final editDsaBtn =
          find.byKey(ValueKey('material-edit-${dsaMaterial.id}'));
      await tester.ensureVisible(editDsaBtn);
      await tester.tap(editDsaBtn);
      await tester.pumpAndSettle();
      final editUnitsField = find.byKey(
        const ValueKey('material-total-units-field'),
      );
      await tester.ensureVisible(editUnitsField);
      await tester.enterText(editUnitsField, '320');
      await tester.tap(find.byKey(const ValueKey('material-save-button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('0 / 320'), findsOneWidget);

      // Open Templates dialog and double-apply Software Engineer.
      final openTemplatesBtn =
          find.byKey(const ValueKey('open-templates-button'));
      await tester.ensureVisible(openTemplatesBtn);
      await tester.tap(openTemplatesBtn);
      await tester.pumpAndSettle();
      final appliedBadge = find.byKey(
        const ValueKey('template-applied-badge-software_engineer'),
      );
      await tester.ensureVisible(appliedBadge);
      expect(appliedBadge, findsOneWidget);

      final reApplyButton = find.byKey(
        const ValueKey('apply-template-software_engineer'),
      );
      await tester.ensureVisible(reApplyButton);
      await tester.tap(reApplyButton);
      await tester.pumpAndSettle();

      expect(subjectRepo.subjects, hasLength(5));
      expect(materialRepo.materials, hasLength(8));
      expect(
        find.textContaining('already in your plan (no duplicates created)'),
        findsOneWidget,
      );
    });

    testWidgets(
        'saves personal template, applies without duplicates, and deletes it '
        'cleanly on 360px mobile Bangla light mode', (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 'sub-1',
            userId: 'user-1',
            name: 'বাংলা সাহিত্য',
            examType: 'বিসিএস',
          ),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'mat-1',
            userId: 'user-1',
            subjectId: 'sub-1',
            title: 'অগ্রদূত বাংলা',
            unitLabel: 'পৃষ্ঠা',
            totalUnits: 300,
          ),
        ],
      );
      final templateRepo = FakePrepTemplateRepository();

      await pumpPrepScreen(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        templateRepo: templateRepo,
        viewportSize: const Size(360, 800),
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
      );

      // Open Save as template from header
      await tester.tap(find.byKey(const ValueKey('save-as-template-button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('personal-template-title-field')),
        'আমার ৪৮তম বিসিএস',
      );
      await tester.tap(
        find.byKey(const ValueKey('save-personal-template-submit')),
      );
      await tester.pumpAndSettle();

      final saved =
          templateRepo.allStoredTemplates.firstWhere((t) => !t.isSystem);
      expect(saved.title, 'আমার ৪৮তম বিসিএস');

      // Open Templates manager dialog -> shows saved personal template
      await tester.tap(find.byKey(const ValueKey('open-templates-button')));
      await tester.pumpAndSettle();
      final savedTitleFinder = find.text('আমার ৪৮তম বিসিএস');
      await tester.ensureVisible(savedTitleFinder);
      expect(savedTitleFinder, findsOneWidget);

      // Re-apply own personal template -> 0 duplicates created
      final applyPersonalBtn =
          find.byKey(ValueKey('apply-template-${saved.id}'));
      await tester.ensureVisible(applyPersonalBtn);
      await tester.tap(applyPersonalBtn);
      await tester.pumpAndSettle();
      expect(subjectRepo.subjects, hasLength(1));
      expect(materialRepo.materials, hasLength(1));

      // Delete own personal template with confirmation dialog
      final deletePersonalBtn =
          find.byKey(ValueKey('delete-template-${saved.id}'));
      await tester.ensureVisible(deletePersonalBtn);
      await tester.tap(deletePersonalBtn);
      await tester.pumpAndSettle();
      expect(find.byType(GlassDialog), findsWidgets);
      await tester.tap(
        find.byKey(const ValueKey('confirm-delete-template-button')),
      );
      await tester.pumpAndSettle();

      expect(
        templateRepo.allStoredTemplates.where((t) => !t.isSystem),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
