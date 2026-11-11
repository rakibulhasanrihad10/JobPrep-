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
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/circulars/fake_circular_repository.dart';
import '../features/prep/fake_material_and_log_repositories.dart';
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
    await initializeDateFormatting('bn');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  List<Circular> goldenCirculars() {
    return [
      Circular(
        id: 'dg-c1',
        userId: 'u-1',
        title: '48th BCS Special Cadre',
        organizationName: 'BPSC',
        sector: CircularSector.bcs,
        deadline: DateTime.utc(2026, 11, 11, 18),
        applicationStatus: ApplicationStatus.applied,
        priority: CircularPriority.high,
        examDates: [
          CircularExamDate(
            id: 'dg-e1',
            circularId: 'dg-c1',
            stage: 'preliminary',
            examDate: DateTime.utc(2026, 11, 10, 14),
            venue: 'Dhaka College',
          ),
        ],
      ),
      Circular(
        id: 'dg-c2',
        userId: 'u-1',
        title: 'Combined Bank Senior Officer',
        organizationName: 'Bankers Selection Committee',
        sector: CircularSector.bank,
        deadline: DateTime.utc(2026, 11, 15, 18),
        workflowStatus: CircularWorkflowStatus.inbox,
        checklist: const ApplicationChecklist(submitted: true),
        examDates: [
          CircularExamDate(
            id: 'dg-e2',
            circularId: 'dg-c2',
            stage: 'written',
            examDate: DateTime.utc(2026, 11, 18, 10),
          ),
        ],
      ),
      Circular(
        id: 'dg-c3',
        userId: 'u-1',
        title: 'Assistant Software Engineer',
        organizationName: 'ICT Division',
        sector: CircularSector.private,
        deadline: DateTime.utc(2026, 11, 22, 18),
        workflowStatus: CircularWorkflowStatus.examUpcoming,
        examDates: [
          CircularExamDate(
            id: 'dg-e3',
            circularId: 'dg-c3',
            stage: 'viva',
            examDate: DateTime.utc(2026, 11, 28, 10),
          ),
        ],
      ),
    ];
  }

  List<Subject> goldenSubjects() {
    return const [
      Subject(
        id: 'dg-sub-1',
        userId: 'u-1',
        name: 'Bengali Literature',
        examType: 'BCS',
      ),
      Subject(
        id: 'dg-sub-2',
        userId: 'u-1',
        name: 'Quantitative Math',
        color: 'info',
        icon: 'calculate',
        examType: 'Bank',
        sortOrder: 1,
      ),
    ];
  }

  List<PrepMaterial> goldenMaterials() {
    return const [
      PrepMaterial(
        id: 'dg-mat-1',
        userId: 'u-1',
        subjectId: 'dg-sub-1',
        title: 'অগ্রদূত বাংলা সাহিত্য',
        totalUnits: 400,
        completedUnits: 160,
        coverImagePath: 'u-1/dg-mat-1/cover.png',
      ),
      PrepMaterial(
        id: 'dg-mat-2',
        userId: 'u-1',
        subjectId: 'dg-sub-2',
        title: 'Bank Math Digest',
        kind: MaterialKind.questionBank,
        totalUnits: 200,
        completedUnits: 140,
      ),
    ];
  }

  List<ProgressLog> goldenLogs() {
    return [
      ProgressLog(
        id: 'dg-log-1',
        userId: 'u-1',
        materialId: 'dg-mat-1',
        unitsDone: 40,
        loggedOn: DateTime.utc(2026, 11, 9),
      ),
    ];
  }

  Future<void> pumpDashboardGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
    required Locale locale,
  }) async {
    tester.view.physicalSize = const Size(1280, 920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: false,
      kLocaleStorageKey: locale.languageCode,
      kUseBanglaDigitsStorageKey: locale.languageCode == 'bn',
    });
    final prefs = await SharedPreferences.getInstance();

    final circularRepo = FakeCircularRepository(
      clock: () => fixedNow,
      initialItems: goldenCirculars(),
    );
    final subjectRepo = FakeSubjectRepository(
      initialSubjects: goldenSubjects(),
    );
    final materialRepo = FakeMaterialRepository(
      initialMaterials: goldenMaterials(),
    );
    final logRepo = FakeProgressLogRepository(
      materialRepository: materialRepo,
      initialLogs: goldenLogs(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularNowProvider.overrideWithValue(() => fixedNow),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
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
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: DashboardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('DashboardScreen Golden Tests', () {
    testWidgets('Dashboard desktop golden - English dark mode', (tester) async {
      await pumpDashboardGolden(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
      );
      await expectLater(
        find.byType(DashboardScreen),
        matchesGoldenFile('goldens/dashboard_en_dark.png'),
      );
    });

    testWidgets('Dashboard desktop golden - English light mode',
        (tester) async {
      await pumpDashboardGolden(
        tester,
        themeMode: ThemeMode.light,
        locale: const Locale('en'),
      );
      await expectLater(
        find.byType(DashboardScreen),
        matchesGoldenFile('goldens/dashboard_en_light.png'),
      );
    });

    testWidgets('Dashboard desktop golden - Bangla dark mode', (tester) async {
      await pumpDashboardGolden(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('bn'),
      );
      await expectLater(
        find.byType(DashboardScreen),
        matchesGoldenFile('goldens/dashboard_bn_dark.png'),
      );
    });

    testWidgets('Dashboard desktop golden - Bangla light mode', (tester) async {
      await pumpDashboardGolden(
        tester,
        themeMode: ThemeMode.light,
        locale: const Locale('bn'),
      );
      await expectLater(
        find.byType(DashboardScreen),
        matchesGoldenFile('goldens/dashboard_bn_light.png'),
      );
    });
  });
}
