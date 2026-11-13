import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/core/widgets/app_bottom_nav_bar.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/today/presentation/screens/today_screen.dart';

import '../../integration_test/harness/e2e_test_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  group('Phase 8A Android Build - Native Project Configuration', () {
    test(
      'AndroidManifest.xml contains valid application, permissions, and '
      'deep links',
      () {
        final manifestFile = File('android/app/src/main/AndroidManifest.xml');
        expect(manifestFile.existsSync(), isTrue);

        final content = manifestFile.readAsStringSync();
        expect(content, contains('android:label="@string/app_name"'));
        expect(content, contains('android:icon="@mipmap/ic_launcher"'));
        expect(
          content,
          contains('android:roundIcon="@mipmap/ic_launcher_round"'),
        );
        expect(content, contains('android.permission.INTERNET'));
        expect(content, contains('android.permission.ACCESS_NETWORK_STATE'));

        // Deep link intent filter for Supabase OAuth & Password reset
        expect(content, contains('android:scheme="io.supabase.jobprep"'));
        expect(content, contains('android:host="login-callback"'));
        expect(content, contains('android:host="reset-password"'));
        expect(content, contains('android.intent.action.VIEW'));
        expect(content, contains('android.intent.category.BROWSABLE'));
      },
    );

    test(
      'build.gradle.kts enforces namespace, applicationId, Java 17, and '
      'signing configs',
      () {
        final buildGradle = File('android/app/build.gradle.kts');
        expect(buildGradle.existsSync(), isTrue);

        final content = buildGradle.readAsStringSync();
        expect(content, contains('namespace = "com.jobprep.app"'));
        expect(content, contains('applicationId = "com.jobprep.app"'));
        expect(content, contains('JavaVersion.VERSION_17'));
        expect(content, contains('signingConfigs'));
        expect(content, contains('create("release")'));
        expect(content, contains('key.properties'));
        expect(content, contains('ANDROID_KEYSTORE_PATH'));
      },
    );

    test(
      'MainActivity.kt resides in com.jobprep.app package and extends '
      'FlutterActivity',
      () {
        final mainActivity = File(
          'android/app/src/main/kotlin/com/jobprep/app/MainActivity.kt',
        );
        expect(mainActivity.existsSync(), isTrue);

        final content = mainActivity.readAsStringSync();
        expect(content, contains('package com.jobprep.app'));
        expect(content, contains('class MainActivity : FlutterActivity()'));
      },
    );

    test('Android launcher mipmap icons exist across all density buckets', () {
      final buckets = [
        'mipmap-mdpi',
        'mipmap-hdpi',
        'mipmap-xhdpi',
        'mipmap-xxhdpi',
        'mipmap-xxxhdpi',
      ];

      for (final bucket in buckets) {
        final launcher =
            File('android/app/src/main/res/$bucket/ic_launcher.png');
        final round =
            File('android/app/src/main/res/$bucket/ic_launcher_round.png');
        expect(
          launcher.existsSync(),
          isTrue,
          reason: '$bucket ic_launcher.png missing',
        );
        expect(
          round.existsSync(),
          isTrue,
          reason: '$bucket ic_launcher_round.png missing',
        );
        expect(launcher.lengthSync(), greaterThan(0));
        expect(round.lengthSync(), greaterThan(0));
      }
    });

    test(
      'Splash screen drawables and branded design token colors are '
      'configured',
      () {
        final colorsFile = File('android/app/src/main/res/values/colors.xml');
        expect(colorsFile.existsSync(), isTrue);
        final colors = colorsFile.readAsStringSync();
        expect(colors, contains('#F4F6FB')); // light splash background
        expect(colors, contains('#0A0E1A')); // dark splash background
        expect(colors, contains('#C59128')); // light gold accent
        expect(colors, contains('#E5A93C')); // dark gold accent

        final launchImage =
            File('android/app/src/main/res/drawable/launch_image.png');
        expect(launchImage.existsSync(), isTrue);
        expect(launchImage.lengthSync(), greaterThan(0));

        final lightSplash =
            File('android/app/src/main/res/drawable/launch_background.xml');
        final darkSplash = File(
          'android/app/src/main/res/drawable-night/launch_background.xml',
        );
        expect(lightSplash.existsSync(), isTrue);
        expect(darkSplash.existsSync(), isTrue);
        expect(
          lightSplash.readAsStringSync(),
          contains('@drawable/launch_image'),
        );
        expect(
          darkSplash.readAsStringSync(),
          contains('@drawable/launch_image'),
        );
      },
    );

    test('Bilingual localized app names are configured in string resources',
        () {
      final defaultStrings =
          File('android/app/src/main/res/values/strings.xml');
      final bengaliStrings =
          File('android/app/src/main/res/values-bn/strings.xml');
      expect(defaultStrings.existsSync(), isTrue);
      expect(bengaliStrings.existsSync(), isTrue);

      expect(
        defaultStrings.readAsStringSync(),
        contains('<string name="app_name">JobPrep</string>'),
      );
      expect(
        bengaliStrings.readAsStringSync(),
        contains('<string name="app_name">জবপ্রেপ</string>'),
      );
    });

    test('Signing key templates and git ignore rules protect secrets', () {
      final keyExample = File('key.properties.example');
      final androidKeyExample = File('android/key.properties.example');
      final gitignore = File('.gitignore');
      final script = File('scripts/generate_release_keystore.sh');

      expect(keyExample.existsSync(), isTrue);
      expect(androidKeyExample.existsSync(), isTrue);
      expect(script.existsSync(), isTrue);

      final gitignoreContent = gitignore.readAsStringSync();
      expect(gitignoreContent, contains('*.keystore'));
      expect(gitignoreContent, contains('*.jks'));
      expect(gitignoreContent, contains('key.properties'));
      expect(gitignoreContent, contains('android/key.properties'));
      expect(gitignoreContent, contains('*.apk'));
      expect(gitignoreContent, contains('*.aab'));

      // Ensure no live keystores or actual passwords are committed
      expect(File('android/app/upload-keystore.jks').existsSync(), isFalse);
      expect(File('key.properties').existsSync(), isFalse);
      expect(File('android/key.properties').existsSync(), isFalse);
    });

    test('GitHub Actions CI contains Android build and signing job', () {
      final ciFile = File('.github/workflows/ci.yml');
      expect(ciFile.existsSync(), isTrue);

      final content = ciFile.readAsStringSync();
      expect(content, contains('android:'));
      expect(content, contains('actions/setup-java@v4'));
      expect(content, contains("java-version: '17'"));
      expect(content, contains('flutter build appbundle --release'));
      expect(content, contains('flutter build apk --release'));
      expect(content, contains('ANDROID_KEYSTORE_BASE64'));
      expect(content, contains('upload-artifact@v4'));
      expect(content, contains('jobprep-release-appbundle'));
      expect(content, contains('jobprep-release-apk'));
    });
  });

  group('Phase 8A Phone Viewport & Responsive Mobile Verification', () {
    testWidgets('renders phone bottom navigation on compact mobile viewport',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });

    testWidgets(
        'supports seamless theme, language, and reduce effects on phone '
        'viewport', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(TodayScreen)));

      // 1. Switch to Bangla on phone
      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('bn'));
      await tester.pumpAndSettle();
      expect(container.read(localeProvider), equals(const Locale('bn')));

      // 2. Switch to Light theme on phone
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      // 3. Switch to Dark theme on phone
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      // 4. Toggle Reduce Effects on phone
      await container
          .read(reduceEffectsProvider.notifier)
          .setReduceEffects(enabled: true);
      await tester.pumpAndSettle();
      expect(container.read(reduceEffectsProvider), isTrue);

      // Verify that cards render with solid fill without error
      expect(find.byType(GlassCard), findsWidgets);
    });
  });
}
