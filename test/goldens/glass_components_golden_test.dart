import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/widgets/widgets.dart';

class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {this.tolerance = 0.04});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= tolerance) {
      return true;
    }

    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}

class _MockReduceEffectsNotifier extends ReduceEffectsNotifier {
  _MockReduceEffectsNotifier({required this.initial});
  final bool initial;

  @override
  bool build() => initial;
}

Widget _buildGoldenHarness({
  required Widget child,
  required ThemeMode themeMode,
  bool reduceEffects = false,
  Size size = const Size(800, 600),
}) {
  return ProviderScope(
    overrides: [
      reduceEffectsProvider.overrideWith(
        () => _MockReduceEffectsNotifier(initial: reduceEffects),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                // Background visual elements so blur shows clearly
                Positioned.fill(
                  child: Builder(
                    builder: (ctx) {
                      final colors = ctx.colors;
                      return ColoredBox(
                        color: colors.background,
                        child: CustomPaint(
                          painter: _GridBackgroundPainter(
                            accentColor: colors.goldAccent.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Center(child: child),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _GridBackgroundPainter extends CustomPainter {
  _GridBackgroundPainter({required this.accentColor});
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Draw background decorative accent circles
    canvas
      ..drawCircle(Offset(size.width * 0.25, size.height * 0.3), 80, paint)
      ..drawCircle(
        Offset(size.width * 0.75, size.height * 0.7),
        100,
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final currentUrl = Uri.base.resolve('test/goldens/test.dart');
    goldenFileComparator = TolerantGoldenComparator(currentUrl);
  });

  group('Glass Components Golden Tests', () {
    testWidgets('GlassCard golden - dark mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.dark,
          child: const GlassCard(
            width: 380,
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BCS Cadre Circular 2026',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Application deadline: 30 November 2026',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_card_dark.png'),
      );
    });

    testWidgets('GlassCard golden - light mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.light,
          child: const GlassCard(
            width: 380,
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bank Officer Circular 2026',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Application deadline: 15 December 2026',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_card_light.png'),
      );
    });

    testWidgets('GlassButton golden - dark mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.dark,
          child: GlassCard(
            width: 440,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassButton(
                  width: double.infinity,
                  variant: GlassButtonVariant.primary,
                  onPressed: () {},
                  leading: const Icon(Icons.check),
                  child: const Text('Primary Action'),
                ),
                const SizedBox(height: 16),
                GlassButton(
                  width: double.infinity,
                  onPressed: () {},
                  leading: const Icon(Icons.bookmark_outline),
                  child: const Text('Standard Action'),
                ),
                const SizedBox(height: 16),
                const GlassButton(
                  width: double.infinity,
                  leading: Icon(Icons.block),
                  child: Text('Disabled Action'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_button_dark.png'),
      );
    });

    testWidgets('GlassButton golden - light mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.light,
          child: GlassCard(
            width: 440,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassButton(
                  width: double.infinity,
                  variant: GlassButtonVariant.primary,
                  onPressed: () {},
                  leading: const Icon(Icons.check),
                  child: const Text('Primary Action'),
                ),
                const SizedBox(height: 16),
                GlassButton(
                  width: double.infinity,
                  onPressed: () {},
                  leading: const Icon(Icons.bookmark_outline),
                  child: const Text('Standard Action'),
                ),
                const SizedBox(height: 16),
                const GlassButton(
                  width: double.infinity,
                  leading: Icon(Icons.block),
                  child: Text('Disabled Action'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_button_light.png'),
      );
    });

    testWidgets('GlassTextField golden - dark mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.dark,
          child: const GlassCard(
            width: 440,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassTextField(
                  labelText: 'Portal Username',
                  hintText: 'Enter registration number',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                SizedBox(height: 20),
                GlassTextField(
                  labelText: 'Secret Passphrase',
                  hintText: 'Enter vault key',
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_outline),
                  errorText: 'Passphrase must be at least 12 characters',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_text_field_dark.png'),
      );
    });

    testWidgets('GlassTextField golden - light mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.light,
          child: const GlassCard(
            width: 440,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassTextField(
                  labelText: 'Portal Username',
                  hintText: 'Enter registration number',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                SizedBox(height: 20),
                GlassTextField(
                  labelText: 'Secret Passphrase',
                  hintText: 'Enter vault key',
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock_outline),
                  errorText: 'Passphrase must be at least 12 characters',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_text_field_light.png'),
      );
    });

    testWidgets('GlassDialog golden - dark mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.dark,
          child: GlassDialog(
            maxWidth: 420,
            title: const Text('Export Application Data'),
            content: const Text(
              'Your encrypted portal credentials and tracked circulars '
              'will be exported as an encrypted JSON archive.',
            ),
            actions: [
              GlassButton(
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              GlassButton(
                variant: GlassButtonVariant.primary,
                onPressed: () {},
                child: const Text('Export'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_dialog_dark.png'),
      );
    });

    testWidgets('GlassDialog golden - light mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.light,
          child: GlassDialog(
            maxWidth: 420,
            title: const Text('Export Application Data'),
            content: const Text(
              'Your encrypted portal credentials and tracked circulars '
              'will be exported as an encrypted JSON archive.',
            ),
            actions: [
              GlassButton(
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              GlassButton(
                variant: GlassButtonVariant.primary,
                onPressed: () {},
                child: const Text('Export'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_dialog_light.png'),
      );
    });

    testWidgets('GlassSidebar golden - dark mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.dark,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 260,
              height: 600,
              child: GlassSidebar(
                header: const Text(
                  'JobPrep Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                footer: const Text('Version 1.0.0'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: const Text('Dashboard'),
                    selected: true,
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: const Text('Circulars'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('Exam Prep'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_sidebar_dark.png'),
      );
    });

    testWidgets('GlassSidebar golden - light mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.light,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 260,
              height: 600,
              child: GlassSidebar(
                header: const Text(
                  'JobPrep Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                footer: const Text('Version 1.0.0'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: const Text('Dashboard'),
                    selected: true,
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: const Text('Circulars'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: const Text('Exam Prep'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_sidebar_light.png'),
      );
    });

    testWidgets('GlassChip golden - dark mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.dark,
          child: GlassCard(
            width: 440,
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                GlassChip(
                  leading: const Icon(Icons.category_outlined),
                  label: const Text('All Jobs'),
                  isSelected: true,
                  onTap: () {},
                ),
                GlassChip(
                  leading: const Icon(Icons.account_balance_outlined),
                  label: const Text('Govt Banks'),
                  onTap: () {},
                ),
                GlassChip(
                  label: const Text('Custom Tag'),
                  onDeleted: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_chip_dark.png'),
      );
    });

    testWidgets('GlassChip golden - light mode', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.light,
          child: GlassCard(
            width: 440,
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                GlassChip(
                  leading: const Icon(Icons.category_outlined),
                  label: const Text('All Jobs'),
                  isSelected: true,
                  onTap: () {},
                ),
                GlassChip(
                  leading: const Icon(Icons.account_balance_outlined),
                  label: const Text('Govt Banks'),
                  onTap: () {},
                ),
                GlassChip(
                  label: const Text('Custom Tag'),
                  onDeleted: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_chip_light.png'),
      );
    });

    testWidgets('ReduceEffects golden - solid translucent fill',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildGoldenHarness(
          themeMode: ThemeMode.dark,
          reduceEffects: true,
          child: GlassCard(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reduce Effects Mode Active',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Blur filter replaced with solid translucent fill for '
                  'reduced GPU load and accessibility.',
                ),
                const SizedBox(height: 16),
                GlassButton(
                  variant: GlassButtonVariant.primary,
                  onPressed: () {},
                  child: const Text('Solid Glass Button'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/glass_reduce_effects_dark.png'),
      );
    });
  });
}
