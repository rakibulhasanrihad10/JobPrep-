import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  Future<void> pumpDashboard(
    WidgetTester tester, {
    required FakeSubjectRepository subjectRepo,
    required FakeMaterialRepository materialRepo,
    required FakeProgressLogRepository logRepo,
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
          progressLogRepositoryProvider.overrideWithValue(logRepo),
          materialCoverRepositoryProvider.overrideWithValue(
            FakeMaterialCoverRepository(),
          ),
          prepNowProvider.overrideWithValue(() => fixedNow),
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

  group('Phase 4D - Prep Progress Logging & Dashboard', () {
    testWidgets('empty state applies starter template cleanly', (tester) async {
      final subjectRepo = FakeSubjectRepository();
      final materialRepo = FakeMaterialRepository();
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
      );

      await pumpDashboard(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
      );

      expect(
        find.byKey(const ValueKey('prep-empty-state-card')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('apply-template-bcsCore')));
      await tester.pumpAndSettle();

      expect(subjectRepo.subjects, hasLength(3));
      expect(materialRepo.materials, hasLength(5));
      expect(find.byType(GlassCard), findsWidgets);
      expect(find.byType(AnimatedProgressRing), findsWidgets);
    });

    testWidgets(
        'shows 3 books side-by-side on desktop, logs +10/+20/+50 and '
        'custom logs, edits/deletes past logs, and updates % live',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 'sub-bn',
            userId: 'u-1',
            name: 'Bangla Literature & Grammar',
            icon: 'language',
            examType: 'BCS',
          ),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'm1',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'অগ্রদূত বাংলা সাহিত্য',
            totalUnits: 300,
          ),
          PrepMaterial(
            id: 'm2',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'MP3 বাংলা ব্যাকরণ',
            totalUnits: 300,
          ),
          PrepMaterial(
            id: 'm3',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'প্রফেসরস বাংলা ডাইজেস্ট',
            totalUnits: 400,
          ),
        ],
      );
      final logRepo = FakeProgressLogRepository(
        materialRepository: materialRepo,
      );

      await pumpDashboard(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: logRepo,
      );

      final r1 = tester.getRect(find.byKey(const ValueKey('material-card-m1')));
      final r2 = tester.getRect(find.byKey(const ValueKey('material-card-m2')));
      final r3 = tester.getRect(find.byKey(const ValueKey('material-card-m3')));
      expect((r1.top - r2.top).abs(), lessThan(2.0));
      expect((r2.top - r3.top).abs(), lessThan(2.0));
      expect(r1.left, lessThan(r2.left));
      expect(r2.left, lessThan(r3.left));
      expect(find.byType(AnimatedProgressBar), findsNWidgets(3));

      await tester.tap(find.byKey(const ValueKey('material-quick-log-50-m1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('material-quick-log-20-m1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('material-quick-log-10-m1')));
      await tester.pumpAndSettle();
      expect(find.textContaining('80 / 300'), findsOneWidget);
      expect(find.text('8%'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('material-custom-log-m1')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('log-units-field')),
        '220',
      );
      await tester.enterText(
        find.byKey(const ValueKey('log-note-field')),
        'Finished book one',
      );
      await tester.tap(find.byKey(const ValueKey('log-save-button')));
      await tester.pumpAndSettle();
      expect(find.text('Finished book one'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('30%'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('material-custom-log-m2')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('log-units-field')),
        '150',
      );
      await tester.tap(find.byKey(const ValueKey('log-save-button')));
      await tester.pumpAndSettle();

      // Verify 45% live behind/in dialog header
      expect(find.text('50% complete'), findsOneWidget);

      // Edit 150 -> 50 inside dialog
      await tester.tap(
        find
            .descendant(
              of: find.byType(GlassDialog),
              matching: find.byIcon(Icons.edit_outlined),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('log-units-field')),
        '50',
      );
      await tester.tap(find.byKey(const ValueKey('log-save-button')));
      await tester.pumpAndSettle();

      // Delete that log from m2 -> subject returns to 30% live
      await tester.tap(
        find
            .descendant(
              of: find.byType(GlassDialog),
              matching: find.byIcon(Icons.delete_outline),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('30%'), findsWidgets);
    });

    testWidgets('renders two-column grid on mobile Bangla 360px layout',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 'sub-bn',
            userId: 'u-1',
            name: 'বাংলা সাহিত্য',
            examType: 'বিসিএস',
          ),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'm1',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'বই ১',
            unitLabel: 'পৃষ্ঠা',
            totalUnits: 100,
            completedUnits: 60,
          ),
          PrepMaterial(
            id: 'm2',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'বই ২',
            unitLabel: 'পৃষ্ঠা',
            totalUnits: 100,
          ),
          PrepMaterial(
            id: 'm3',
            userId: 'u-1',
            subjectId: 'sub-bn',
            title: 'বই ৩',
            unitLabel: 'পৃষ্ঠা',
            totalUnits: 100,
          ),
        ],
      );

      await pumpDashboard(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        logRepo: FakeProgressLogRepository(materialRepository: materialRepo),
        viewportSize: const Size(360, 800),
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
      );
      await tester.tap(find.byKey(const ValueKey('subject-card-sub-bn')));
      await tester.pumpAndSettle();

      final r1 = tester.getRect(find.byKey(const ValueKey('material-card-m1')));
      final r2 = tester.getRect(find.byKey(const ValueKey('material-card-m2')));
      final r3 = tester.getRect(find.byKey(const ValueKey('material-card-m3')));
      expect((r1.top - r2.top).abs(), lessThan(2.0));
      expect(r3.top, greaterThan(r1.bottom - 1.0));
      expect(tester.takeException(), isNull);
    });
  });
}
