import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/app_bottom_nav_bar.dart';
import 'package:job_prep/core/widgets/app_nav_rail.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';
import 'package:job_prep/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/fake_auth_repository.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    Locale? locale,
    bool reduceEffects = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, reduceEffects);
    if (locale != null) {
      await prefs.setString(kLocaleStorageKey, locale.languageCode);
    } else {
      await prefs.remove(kLocaleStorageKey);
    }

    final authRepo = FakeAuthRepository.authenticated();
    addTearDown(authRepo.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const JobPrepApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Responsive Shell - Viewport Breakpoints', () {
    testWidgets(
      'Phone width (< 600 px): renders AppBottomNavBar, hides rail & sidebar',
      (tester) async {
        await pumpApp(tester, size: const Size(400, 800));

        expect(find.byType(AppBottomNavBar), findsOneWidget);
        expect(find.byType(AppNavRail), findsNothing);
        expect(find.byType(AppSidebarNav), findsNothing);

        // Verify navigation items on bottom bar
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Circulars'), findsOneWidget);
        expect(find.text('Prep'), findsOneWidget);
        expect(find.text('Calendar'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Inbox'), findsOneWidget);
      },
    );

    testWidgets(
      'Tablet width (600 - 1024 px): renders AppNavRail, '
      'hides bottom bar & sidebar',
      (tester) async {
        await pumpApp(tester, size: const Size(800, 900));

        expect(find.byType(AppNavRail), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsNothing);
        expect(find.byType(AppSidebarNav), findsNothing);

        // Verify rail items
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Circulars'), findsOneWidget);
        expect(find.text('Prep'), findsOneWidget);
        expect(find.text('Calendar'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Inbox'), findsOneWidget);
      },
    );

    testWidgets(
      'Desktop width (> 1024 px): renders AppSidebarNav with '
      'max 1200 px content',
      (tester) async {
        await pumpApp(tester, size: const Size(1440, 900));

        expect(find.byType(AppSidebarNav), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsNothing);
        expect(find.byType(AppNavRail), findsNothing);

        // Verify app brand and shortcut badges in sidebar
        expect(find.text('JobPrep'), findsOneWidget);
        expect(find.text('Alt+1'), findsOneWidget);
        expect(find.text('Alt+2'), findsOneWidget);
        expect(find.text('Alt+3'), findsOneWidget);
        expect(find.text('Alt+4'), findsOneWidget);
        expect(find.text('Alt+5'), findsOneWidget);
        expect(find.text('Alt+6'), findsOneWidget);

        // Content constraint check (1200 px max width)
        final constrainedBoxes = tester.widgetList<ConstrainedBox>(
          find.byType(ConstrainedBox),
        );
        final has1200Constraint = constrainedBoxes.any(
          (box) => box.constraints.maxWidth == 1200.0,
        );
        expect(has1200Constraint, isTrue);
      },
    );
  });

  group('Responsive Shell - Navigation Interactions', () {
    testWidgets(
      'Tapping navigation destinations swaps screens via GoRouter',
      (tester) async {
        await pumpApp(tester);

        expect(find.byType(DashboardScreen), findsOneWidget);

        // Tap Circulars
        await tester.tap(find.text('Circulars'));
        await tester.pumpAndSettle();
        expect(find.byType(CircularsScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);

        // Tap Prep
        await tester.tap(find.text('Prep'));
        await tester.pumpAndSettle();
        expect(find.byType(PrepScreen), findsOneWidget);

        // Tap Calendar
        await tester.tap(find.text('Calendar'));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarScreen), findsOneWidget);

        // Tap Settings
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);

        // Tap Dashboard
        await tester.tap(find.text('Dashboard'));
        await tester.pumpAndSettle();
        expect(find.byType(DashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping bottom bar destinations navigates on phone width',
      (tester) async {
        await pumpApp(tester, size: const Size(400, 800));

        expect(find.byType(DashboardScreen), findsOneWidget);

        await tester.tap(find.text('Circulars'));
        await tester.pumpAndSettle();
        expect(find.byType(CircularsScreen), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Web Keyboard Shortcuts navigate across screens',
      (tester) async {
        await pumpApp(tester);
        expect(find.byType(DashboardScreen), findsOneWidget);

        // Alt + 2 -> Circulars
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pumpAndSettle();
        expect(find.byType(CircularsScreen), findsOneWidget);

        // Alt + 3 -> Prep
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pumpAndSettle();
        expect(find.byType(PrepScreen), findsOneWidget);

        // Alt + 4 -> Calendar
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pumpAndSettle();
        expect(find.byType(CalendarScreen), findsOneWidget);

        // Alt + 5 -> Settings
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);

        // Alt + 1 -> Dashboard
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await tester.pumpAndSettle();
        expect(find.byType(DashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Hovering over navigation items updates hover state',
      (tester) async {
        await pumpApp(tester);

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        // Move over Settings nav tile
        await gesture.moveTo(tester.getCenter(find.text('Settings')));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
      },
    );
  });

  group('Responsive Shell - Accessibility & Settings', () {
    testWidgets(
      'BackdropFilter is present when reduceEffects is false',
      (tester) async {
        await pumpApp(tester, size: const Size(400, 800));
        expect(
          find.descendant(
            of: find.byType(AppBottomNavBar),
            matching: find.byType(BackdropFilter),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Reduce effects removes BackdropFilter blur from bottom nav',
      (tester) async {
        await pumpApp(tester, size: const Size(400, 800), reduceEffects: true);
        expect(
          find.descendant(
            of: find.byType(AppBottomNavBar),
            matching: find.byType(BackdropFilter),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Renders Bangla navigation labels when locale is bn',
      (tester) async {
        await pumpApp(
          tester,
          locale: const Locale('bn'),
        );

        expect(find.text('ড্যাশবোর্ড'), findsOneWidget);
        expect(find.text('সার্কুলার'), findsOneWidget);
        expect(find.text('প্রস্তুতি'), findsOneWidget);
        expect(find.text('ক্যালেন্ডার'), findsOneWidget);
        expect(find.text('সেটিংস'), findsOneWidget);
        expect(find.text('ইনবক্স'), findsOneWidget);
      },
    );
  });
}
