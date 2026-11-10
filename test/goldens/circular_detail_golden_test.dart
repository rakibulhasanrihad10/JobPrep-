import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/circulars/fake_circular_repository.dart';
import '../features/circulars/fake_exam_date_repository.dart';

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

  Future<void> pumpDetailGolden(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    tester.view.physicalSize = const Size(860, 1180);
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

    final circularRepo = FakeCircularRepository(
      initialItems: [
        Circular(
          id: 'g-detail',
          userId: 'u-1',
          title: '47th BCS General Cadre',
          sector: CircularSector.bcs,
          organizationName: 'Bangladesh Public Service Commission',
          organizationWebsite: 'https://bpsc.gov.bd',
          circularUrl: 'https://bpsc.gov.bd/notices/47',
          applicationUrl: 'https://bpsc.teletalk.com.bd',
          deadline: DateTime.utc(2026, 11, 15, 17), // amber
          vacancies: 1250,
          salaryMin: 22000,
          salaryMax: 53060,
          applicationFee: 700,
          applicationStatus: ApplicationStatus.feePaid,
          workflowStatus: CircularWorkflowStatus.preparing,
          priority: CircularPriority.urgent,
          checklist: const ApplicationChecklist(
            photo: true,
            certificates: true,
            feePaid: true,
          ),
          createdAt: DateTime.utc(2026, 11, 1, 9),
          updatedAt: DateTime.utc(2026, 11, 9, 14),
        ),
      ],
      clock: () => fixedNow,
    );

    final examRepo = FakeExamDateRepository(
      initialItems: [
        CircularExamDate(
          id: 'ed-g1',
          circularId: 'g-detail',
          userId: 'u-1',
          stage: 'preliminary',
          examDate: DateTime.utc(2026, 12, 12, 10),
          venue: 'Dhaka College',
        ),
      ],
      clock: () => fixedNow,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          examDateRepositoryProvider.overrideWithValue(examRepo),
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
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: CircularDetailView(
                circularId: 'g-detail',
                isPane: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CircularDetailView Golden Tests', () {
    testWidgets('CircularDetailView golden - dark mode', (tester) async {
      await pumpDetailGolden(tester, themeMode: ThemeMode.dark);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/circular_detail_dark.png'),
      );
    });

    testWidgets('CircularDetailView golden - light mode', (tester) async {
      await pumpDetailGolden(tester, themeMode: ThemeMode.light);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/circular_detail_light.png'),
      );
    });
  });
}
