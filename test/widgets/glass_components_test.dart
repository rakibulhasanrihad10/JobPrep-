import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.dark,
  bool reduceEffects = false,
  SharedPreferences? prefs,
}) {
  return ProviderScope(
    overrides: [
      if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
      reduceEffectsProvider.overrideWith(
        () => _MockReduceEffectsNotifier(initial: reduceEffects),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    ),
  );
}

class _MockReduceEffectsNotifier extends ReduceEffectsNotifier {
  _MockReduceEffectsNotifier({required this.initial});
  final bool initial;

  @override
  bool build() => initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reduce Effects Controller & Persistence', () {
    test('defaults to false when storage is uninitialized', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(reduceEffectsProvider), isFalse);
    });

    test('loads persisted preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        kReduceEffectsStorageKey: true,
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(reduceEffectsProvider), isTrue);
    });

    test('setReduceEffects and toggle persist to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(reduceEffectsProvider.notifier)
          .setReduceEffects(enabled: true);

      expect(container.read(reduceEffectsProvider), isTrue);
      expect(prefs.getBool(kReduceEffectsStorageKey), isTrue);

      await container.read(reduceEffectsProvider.notifier).toggle();

      expect(container.read(reduceEffectsProvider), isFalse);
      expect(prefs.getBool(kReduceEffectsStorageKey), isFalse);
    });
  });

  group('GlassCard Widget Tests', () {
    testWidgets('renders child content and handles tap callback',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: GlassCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);

      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('removes BackdropFilter when reduceEffects is enabled',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          reduceEffects: true,
          child: const GlassCard(
            child: Text('Solid Glass Card'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solid Glass Card'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('GlassButton Widget Tests', () {
    testWidgets('renders child, leading, trailing and handles tap',
        (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: GlassButton(
            leading: const Icon(Icons.star),
            trailing: const Icon(Icons.arrow_forward),
            onPressed: () => pressed = true,
            child: const Text('Action Button'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action Button'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);

      await tester.tap(find.text('Action Button'));
      expect(pressed, isTrue);
    });

    testWidgets('disabled state does not respond to taps', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const GlassButton(
            child: Text('Disabled Button'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Disabled Button'), findsOneWidget);
      await tester.tap(find.text('Disabled Button'));
      // No crashes, InkWell not active
    });

    testWidgets('primary variant renders successfully', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: GlassButton(
            variant: GlassButtonVariant.primary,
            onPressed: () {},
            child: const Text('Primary Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Primary Action'), findsOneWidget);
    });

    testWidgets('removes BackdropFilter when reduceEffects is true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          reduceEffects: true,
          child: GlassButton(
            onPressed: () {},
            child: const Text('Reduced Button'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reduced Button'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('GlassTextField Widget Tests', () {
    testWidgets('enters text, triggers onChanged, and handles hints/labels',
        (tester) async {
      String? entered;

      await tester.pumpWidget(
        _buildTestApp(
          child: SizedBox(
            width: 320,
            child: GlassTextField(
              labelText: 'Search Query',
              hintText: 'Enter keyword...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (val) => entered = val,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Query'), findsOneWidget);
      expect(find.text('Enter keyword...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Flutter');
      expect(entered, equals('Flutter'));
    });

    testWidgets('displays helper text and error text', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const SizedBox(
            width: 320,
            child: GlassTextField(
              helperText: 'Instructions here',
              errorText: 'Invalid value',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid value'), findsOneWidget);
      expect(find.text('Instructions here'), findsNothing);
    });

    testWidgets('swaps BackdropFilter for solid fill on reduceEffects',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          reduceEffects: true,
          child: const SizedBox(
            width: 320,
            child: GlassTextField(
              hintText: 'No blur field',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('GlassDialog Widget Tests', () {
    testWidgets('renders title, content, actions and responds to actions',
        (tester) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                unawaited(
                  showGlassDialog<void>(
                    context: ctx,
                    builder: (dialogCtx) => GlassDialog(
                      title: const Text('Confirm Action'),
                      content: const Text('Are you sure you want to proceed?'),
                      actions: [
                        GlassButton(
                          onPressed: () {
                            actionTriggered = true;
                            Navigator.of(dialogCtx).pop();
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure you want to proceed?'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsWidgets);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
      expect(find.text('Confirm Action'), findsNothing);
    });
  });

  group('GlassSidebar Widget Tests', () {
    testWidgets('renders header, children list items, and footer',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const SizedBox(
            height: 600,
            child: GlassSidebar(
              header: Text('Sidebar Header'),
              footer: Text('Sidebar Footer'),
              children: [
                Text('Nav Item 1'),
                Text('Nav Item 2'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sidebar Header'), findsOneWidget);
      expect(find.text('Nav Item 1'), findsOneWidget);
      expect(find.text('Nav Item 2'), findsOneWidget);
      expect(find.text('Sidebar Footer'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('supports isTrailing sidebar mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const SizedBox(
            height: 600,
            child: GlassSidebar(
              isTrailing: true,
              children: [
                Text('Trailing Content'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trailing Content'), findsOneWidget);
    });
  });

  group('GlassChip Widget Tests', () {
    testWidgets('renders label, leading icon, handles tap and delete',
        (tester) async {
      var tapped = false;
      var deleted = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: GlassChip(
            leading: const Icon(Icons.bookmark),
            label: const Text('Filter Chip'),
            onTap: () => tapped = true,
            onDeleted: () => deleted = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filter Chip'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.text('Filter Chip'));
      expect(tapped, isTrue);

      await tester.tap(find.byIcon(Icons.close));
      expect(deleted, isTrue);
    });

    testWidgets('renders selected state styling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const GlassChip(
            isSelected: true,
            label: Text('Selected Chip'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selected Chip'), findsOneWidget);
    });
  });
}
