import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
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

  setUpAll(() async {
    await initializeDateFormatting('en');
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = _TolerantGoldenComparator(currentUrl);
  });

  List<Circular> goldenCalendarItems() {
    return [
      Circular(
        id: 'cal-g1',
        userId: 'u-1',
        title: '47th BCS General Cadre',
        organizationName: 'BPSC',
        sector: CircularSector.bcs,
        deadline: DateTime.utc(2026, 11, 10, 17),
        workflowStatus: CircularWorkflowStatus.preparing,
        examDates: [
          CircularExamDate(
            id: 'ed-g1',
            circularId: 'cal-g1',
            stage: 'preliminary',
            examDate: DateTime.utc(2026, 11, 10, 10),
            venue: 'Dhaka College',
          ),
          CircularExamDate(
            id: 'ed-g2',
            circularId: 'cal-g1',
            stage: 'written',
            examDate: DateTime.utc(2026, 11, 18, 10),
          ),
          CircularExamDate(
            id: 'ed-g3',
            circularId: 'cal-g1',
            stage: 'viva',
            examDate: DateTime.utc(2026, 11, 25, 11),
          ),
        ],
      ),
      Circular(
        id: 'cal-g2',
        userId: 'u-1',
        title: 'Bangladesh Bank AD',
        organizationName: 'Bangladesh Bank',
        sector: CircularSector.bank,
        deadline: DateTime.utc(2026, 11, 15, 17),
        workflowStatus: CircularWorkflowStatus.applied,
      ),
    ];
  }

  Future<void> pumpCalendarGolden(
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
    final repo = FakeCircularRepository(
      initialItems: goldenCalendarItems(),
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
          home: const Scaffold(
            body: CalendarScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CalendarScreen Golden Tests', () {
    testWidgets('CalendarScreen desktop golden - dark mode', (tester) async {
      await pumpCalendarGolden(tester, themeMode: ThemeMode.dark);
      await expectLater(
        find.byType(CalendarScreen),
        matchesGoldenFile('goldens/calendar_screen_dark.png'),
      );
    });

    testWidgets('CalendarScreen desktop golden - light mode', (tester) async {
      await pumpCalendarGolden(tester, themeMode: ThemeMode.light);
      await expectLater(
        find.byType(CalendarScreen),
        matchesGoldenFile('goldens/calendar_screen_light.png'),
      );
    });
  });
}
