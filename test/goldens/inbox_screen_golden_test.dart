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
import 'package:job_prep/features/circulars/presentation/screens/inbox_screen.dart';
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

  List<Circular> goldenInboxItems() {
    return [
      Circular(
        id: 'in-g1',
        userId: 'u-1',
        title: '47th BCS Notification Link',
        circularUrl: 'https://www.bpsc.gov.bd/notices/47th-bcs-cadre',
        deadline: DateTime.utc(2026, 11, 12, 17), // red
        workflowStatus: CircularWorkflowStatus.inbox,
        isQuickCapture: true,
        createdAt: DateTime.utc(2026, 11, 10, 9),
      ),
      Circular(
        id: 'in-g2',
        userId: 'u-1',
        title: 'erecruitment.bb.org.bd',
        circularUrl: 'https://erecruitment.bb.org.bd/career/ad-2026',
        deadline: DateTime.utc(2026, 11, 20, 17), // green
        workflowStatus: CircularWorkflowStatus.inbox,
        isQuickCapture: true,
        createdAt: DateTime.utc(2026, 11, 9, 14),
      ),
    ];
  }

  Future<void> pumpInboxGolden(
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
      initialItems: goldenInboxItems(),
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
          home: const Scaffold(body: InboxScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('InboxScreen Golden Tests', () {
    testWidgets('InboxScreen desktop golden - dark mode', (tester) async {
      await pumpInboxGolden(
        tester,
        themeMode: ThemeMode.dark,
        size: const Size(1100, 760),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/inbox_screen_dark.png'),
      );
    });

    testWidgets('InboxScreen desktop golden - light mode', (tester) async {
      await pumpInboxGolden(
        tester,
        themeMode: ThemeMode.light,
        size: const Size(1100, 760),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/inbox_screen_light.png'),
      );
    });
  });
}
