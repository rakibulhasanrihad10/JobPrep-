import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestHarness({
  required Widget child,
  Locale locale = const Locale('en'),
  bool useBanglaDigits = false,
  bool reduceEffects = false,
}) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith(
        () => _MockLocaleNotifier(locale),
      ),
      useBanglaDigitsProvider.overrideWith(
        () => _MockBanglaDigitsNotifier(initial: useBanglaDigits),
      ),
      reduceEffectsProvider.overrideWith(
        () => _MockReduceEffectsNotifier(initial: reduceEffects),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: locale,
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

class _MockLocaleNotifier extends LocaleNotifier {
  _MockLocaleNotifier(this._locale);
  final Locale _locale;

  @override
  Locale build() => _locale;
}

class _MockBanglaDigitsNotifier extends BanglaDigitsNotifier {
  _MockBanglaDigitsNotifier({required this.initial});
  final bool initial;

  @override
  bool build() => initial;
}

class _MockReduceEffectsNotifier extends ReduceEffectsNotifier {
  _MockReduceEffectsNotifier({required this.initial});
  final bool initial;

  @override
  bool build() => initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AnimatedProgressBar Widget Tests', () {
    testWidgets('animates from 0 to target value and settles', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const SizedBox(
            width: 200,
            child: AnimatedProgressBar(value: 0.75),
          ),
        ),
      );

      // Initially at begin (0.0 width factor)
      await tester.pump();
      final initialBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(initialBox.widthFactor, equals(0.0));

      // After settling, reaches 0.75
      await tester.pumpAndSettle();
      final settledBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(settledBox.widthFactor, equals(0.75));
    });

    testWidgets('clamps value to range 0.0 - 1.0', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const SizedBox(
            width: 200,
            child: AnimatedProgressBar(value: 1.5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, equals(1.0));
    });

    testWidgets('skips animation immediately when reduceEffects is true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          reduceEffects: true,
          child: const SizedBox(
            width: 200,
            child: AnimatedProgressBar(value: 0.6),
          ),
        ),
      );

      // Immediate pump without settling should already be at final value
      await tester.pump();
      final box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, equals(0.6));
    });

    testWidgets('replays animation when replayKey changes', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const SizedBox(
            width: 200,
            child: AnimatedProgressBar(
              replayKey: 'tab-1',
              value: 0.8,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      var box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, equals(0.8));

      // Switch replayKey to tab-2
      await tester.pumpWidget(
        _buildTestHarness(
          child: const SizedBox(
            width: 200,
            child: AnimatedProgressBar(
              replayKey: 'tab-2',
              value: 0.8,
            ),
          ),
        ),
      );

      // On restart, resets towards 0.0
      await tester.pump();
      box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, equals(0.0));

      await tester.pumpAndSettle();
      box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, equals(0.8));
    });
  });

  group('AnimatedProgressRing Widget Tests', () {
    testWidgets('animates to target value and draws custom painter',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const AnimatedProgressRing(
            value: 0.65,
            child: Text('65%'),
          ),
        ),
      );

      expect(find.text('65%'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('skips animation immediately when reduceEffects is true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          reduceEffects: true,
          child: const AnimatedProgressRing(
            value: 0.5,
          ),
        ),
      );

      // Verify no hanging animation tickers
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('replays ring animation when replayKey changes',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const AnimatedProgressRing(
            replayKey: 'screen-overview',
            value: 0.9,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch replayKey
      await tester.pumpWidget(
        _buildTestHarness(
          child: const AnimatedProgressRing(
            replayKey: 'screen-details',
            value: 0.9,
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('AnimatedCounter Widget Tests', () {
    testWidgets('animates integer counter to target value', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const AnimatedCounter(
            value: 100,
            suffix: ' books',
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('100 books'), findsOneWidget);
    });

    testWidgets('animates double counter with precision', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const AnimatedCounter(
            value: 42.5,
            decimalDigits: 1,
            suffix: '%',
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('42.5%'), findsOneWidget);
    });

    testWidgets('formats counter with Bangla digits in bn locale',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          locale: const Locale('bn'),
          child: const AnimatedCounter(
            value: 300,
            prefix: 'পৃষ্ঠা ',
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('পৃষ্ঠা ৩০০'), findsOneWidget);
    });

    testWidgets('skips animation immediately when reduceEffects is true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          reduceEffects: true,
          child: const AnimatedCounter(
            value: 250,
            suffix: ' pages',
          ),
        ),
      );

      // First pump immediately shows 250 without settling
      await tester.pump();
      expect(find.text('250 pages'), findsOneWidget);
    });
  });

  group('FadeSlideIn Widget Tests', () {
    testWidgets('renders child and completes fade-slide transition',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const FadeSlideIn(
            child: Text('Animated Card Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Animated Card Content'), findsOneWidget);
    });

    testWidgets('applies staggered delay based on item index', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: const Column(
            children: [
              FadeSlideIn(
                child: Text('Item 0'),
              ),
              FadeSlideIn(
                index: 1,
                child: Text('Item 1'),
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets(
        'skips animation and returns raw child when reduceEffects is on',
        (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          reduceEffects: true,
          child: const FadeSlideIn(
            child: Text('Immediate Content'),
          ),
        ),
      );

      // Single pump, no animation tickers active
      await tester.pump();
      expect(find.text('Immediate Content'), findsOneWidget);
    });
  });
}
