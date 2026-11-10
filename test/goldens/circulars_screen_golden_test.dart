import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/circulars/fake_circular_repository.dart';

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
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  setUpAll(() {
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  List<Circular> goldenCirculars() {
    return [
      Circular(
        id: 'g-1',
        userId: 'u-1',
        title: '47th BCS General Cadre',
        sector: CircularSector.bcs,
        organizationName: 'Bangladesh Public Service Commission',
        deadline: DateTime.utc(2026, 11, 12, 17), // 2 days -> red
        vacancies: 1250,
        priority: CircularPriority.urgent,
        applicationStatus: ApplicationStatus.inProgress,
        workflowStatus: CircularWorkflowStatus.preparing,
        createdAt: DateTime.utc(2026, 11, 1, 9),
      ),
      Circular(
        id: 'g-2',
        userId: 'u-1',
        title: 'Assistant Director General',
        sector: CircularSector.bank,
        organizationName: 'Bangladesh Bank',
        deadline: DateTime.utc(2026, 11, 15, 17), // 5 days -> amber
        vacancies: 150,
        priority: CircularPriority.high,
        applicationStatus: ApplicationStatus.feePaid,
        workflowStatus: CircularWorkflowStatus.examUpcoming,
        createdAt: DateTime.utc(2026, 11, 5, 9),
      ),
      Circular(
        id: 'g-3',
        userId: 'u-1',
        title: 'Senior Software Engineer',
        sector: CircularSector.private,
        organizationName: 'Brac IT',
        deadline: DateTime.utc(2026, 11, 25, 17), // 15 days -> green
        vacancies: 12,
        applicationStatus: ApplicationStatus.applied,
        workflowStatus: CircularWorkflowStatus.applied,
        createdAt: DateTime.utc(2026, 11, 7, 9),
      ),
      Circular(
        id: 'g-4',
        userId: 'u-1',
        title: 'Field Operations Officer',
        sector: CircularSector.ngo,
        organizationName: 'ASA Bangladesh',
        deadline: DateTime.utc(2026, 11, 9, 17), // 1 day overdue -> red
        applicationStatus: ApplicationStatus.missed,
        workflowStatus: CircularWorkflowStatus.archived,
        priority: CircularPriority.low,
        createdAt: DateTime.utc(2026, 10, 20, 9),
      ),
    ];
  }

  Future<void> pumpCircularsGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
    required Size size,
  }) async {
    tester.view.physicalSize = size;
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
    final repo = FakeCircularRepository(
      initialItems: goldenCirculars(),
      clock: () => fixedNow,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularRepositoryProvider.overrideWithValue(repo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CircularsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CircularsScreen Golden Tests', () {
    testWidgets('CircularsScreen desktop table golden - dark mode',
        (tester) async {
      await pumpCircularsGolden(
        tester,
        themeMode: ThemeMode.dark,
        size: const Size(1200, 820),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/circulars_list_desktop_dark.png'),
      );
    });

    testWidgets('CircularsScreen desktop table golden - light mode',
        (tester) async {
      await pumpCircularsGolden(
        tester,
        themeMode: ThemeMode.light,
        size: const Size(1200, 820),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/circulars_list_desktop_light.png'),
      );
    });

    testWidgets('CircularsScreen mobile card list golden - dark mode',
        (tester) async {
      await pumpCircularsGolden(
        tester,
        themeMode: ThemeMode.dark,
        size: const Size(390, 844),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/circulars_list_mobile_dark.png'),
      );
    });

    testWidgets('CircularsScreen mobile card list golden - light mode',
        (tester) async {
      await pumpCircularsGolden(
        tester,
        themeMode: ThemeMode.light,
        size: const Size(390, 844),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/circulars_list_mobile_light.png'),
      );
    });
  });
}
