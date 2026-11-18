import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/inbox_screen.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';
import 'package:job_prep/features/prep/presentation/widgets/mock_test_list_tile.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_item_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/subject_card.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/circulars/fake_circular_repository.dart';

void main() {
  late SharedPreferences prefs;
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget wrapWithApp(
    Widget child, {
    required bool reduceEffects,
    List<Override> extraOverrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        circularNowProvider.overrideWithValue(() => fixedNow),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('PWA Assets, Manifest, Service Worker & Wasm Bootstrap', () {
    test('web/manifest.json defines installable metadata and maskable icons',
        () {
      final manifestFile = File('web/manifest.json');
      expect(manifestFile.existsSync(), isTrue);

      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
      expect(manifest['name'], isA<String>());
      expect((manifest['name'] as String).isNotEmpty, isTrue);
      expect(manifest['short_name'], equals('JobPrep'));
      expect(manifest['start_url'], equals('.'));
      expect(manifest['display'], equals('standalone'));
      expect(manifest['background_color'], equals('#0A0E17'));
      expect(manifest['theme_color'], equals('#0A0E17'));

      final icons =
          (manifest['icons'] as List<dynamic>).cast<Map<String, dynamic>>();
      final hasAny192 = icons.any(
        (icon) => icon['sizes'] == '192x192' && icon['purpose'] == 'any',
      );
      final hasAny512 = icons.any(
        (icon) => icon['sizes'] == '512x512' && icon['purpose'] == 'any',
      );
      final hasMaskable192 = icons.any(
        (icon) => icon['sizes'] == '192x192' && icon['purpose'] == 'maskable',
      );
      final hasMaskable512 = icons.any(
        (icon) => icon['sizes'] == '512x512' && icon['purpose'] == 'maskable',
      );

      expect(hasAny192, isTrue);
      expect(hasAny512, isTrue);
      expect(hasMaskable192, isTrue);
      expect(hasMaskable512, isTrue);

      for (final icon in icons) {
        final src = icon['src'] as String;
        expect(File('web/$src').existsSync(), isTrue, reason: 'Missing $src');
      }
      expect(File('web/icons/apple-touch-icon.png').existsSync(), isTrue);
      expect(File('web/favicon.png').existsSync(), isTrue);
    });

    test('index.html, flutter_bootstrap.js, and sw.js support PWA & Wasm', () {
      final indexHtml = File('web/index.html').readAsStringSync();
      expect(indexHtml, contains('rel="manifest" href="manifest.json"'));
      expect(indexHtml, contains('name="apple-mobile-web-app-capable"'));
      expect(indexHtml, contains('apple-touch-icon.png'));
      expect(indexHtml, contains('viewport-fit=cover'));
      expect(indexHtml, contains('id="jobprep-loader"'));

      final bootstrapJs = File('web/flutter_bootstrap.js').readAsStringSync();
      expect(bootstrapJs, contains('{{flutter_js}}'));
      expect(bootstrapJs, contains('{{flutter_build_config}}'));
      expect(bootstrapJs, contains("register('sw.js'"));
      expect(bootstrapJs, isNot(contains('serviceWorkerSettings')));

      final swJs = File('web/sw.js').readAsStringSync();
      expect(swJs, contains('jobprep-pwa-'));
      expect(swJs, contains('url.origin !== self.location.origin'));
      expect(swJs, contains("self.addEventListener('fetch'"));

      final buildScript = File('scripts/build_web.dart').readAsStringSync();
      expect(buildScript, contains('--wasm'));
      expect(buildScript, contains('--release'));
    });
  });

  group('Performance Pass - BackdropFilter Limits & Sliver Virtualization', () {
    testWidgets('CircularsScreen virtualizes 200 rows cleanly with zero blur',
        (tester) async {
      await prefs.setBool(kReduceEffectsStorageKey, false);
      tester.view.physicalSize = const Size(430, 840);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeCircularRepository(
        initialItems: List<Circular>.generate(
          200,
          (i) => Circular(
            id: 'circ-$i',
            userId: 'user-1',
            title: 'Recruitment Circular $i',
            organizationName: 'Org $i',
            deadline: fixedNow.add(Duration(days: (i % 20) + 1)),
            createdAt: fixedNow.subtract(Duration(hours: i)),
          ),
        ),
        clock: () => fixedNow,
      );

      await tester.pumpWidget(
        wrapWithApp(
          const CircularsScreen(),
          reduceEffects: false,
          extraOverrides: [
            circularRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circulars-mobile-list')),
        findsOneWidget,
      );
      // Sliver virtualization materializes only viewport + cacheExtent rows.
      expect(find.text('Recruitment Circular 0'), findsOneWidget);
      expect(find.text('Recruitment Circular 190'), findsNothing);

      // Zero BackdropFilter inside the virtualized card list rows.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('circulars-mobile-list')),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );

      // Scrolls smoothly toward later items.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1800));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Recruitment Circular 0'), findsNothing);
    });

    testWidgets(
        'InboxScreen virtualizes 100 items without per-row BackdropFilter',
        (tester) async {
      await prefs.setBool(kReduceEffectsStorageKey, false);
      tester.view.physicalSize = const Size(430, 840);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakeCircularRepository(
        initialItems: List<Circular>.generate(
          100,
          (i) => Circular(
            id: 'inbox-$i',
            userId: 'user-1',
            title: 'Captured Item $i',
            isQuickCapture: true,
            workflowStatus: CircularWorkflowStatus.inbox,
            createdAt: fixedNow.subtract(Duration(minutes: i)),
          ),
        ),
        clock: () => fixedNow,
      );

      await tester.pumpWidget(
        wrapWithApp(
          const InboxScreen(),
          reduceEffects: false,
          extraOverrides: [
            circularRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('inbox-list')), findsOneWidget);
      expect(find.text('Captured Item 0'), findsOneWidget);
      expect(find.text('Captured Item 95'), findsNothing);

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('inbox-list')),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
    });

    testWidgets(
        'list row cards omit BackdropFilter even when reduceEffects is false',
        (tester) async {
      await prefs.setBool(kReduceEffectsStorageKey, false);

      await tester.pumpWidget(
        wrapWithApp(
          SingleChildScrollView(
            child: Column(
              children: [
                SubjectCard(
                  subject: const Subject(id: 's1', name: 'General Knowledge'),
                  index: 0,
                  totalCount: 1,
                  materials: const [],
                  isSelected: false,
                  onTap: () {},
                  onEdit: () {},
                  onDelete: () {},
                  onMoveUp: null,
                  onMoveDown: null,
                ),
                RevisionItemCard(
                  item: RevisionItem(
                    id: 'r1',
                    subjectId: 's1',
                    referenceLabel: 'Page 42',
                    dueOn: fixedNow,
                  ),
                  subjectName: 'General Knowledge',
                  subjectColor: Colors.amber,
                  today: fixedNow,
                  locale: const Locale('en'),
                  useBanglaDigits: false,
                  isBusy: false,
                  onReviewAction: (_) {},
                  onDelete: () {},
                ),
                MockTestListTile(
                  test: MockTest(
                    id: 'm1',
                    subjectId: 's1',
                    title: 'Model Test 1',
                    takenOn: fixedNow,
                    marksObtained: 80,
                    totalMarks: 100,
                  ),
                  subjectName: 'General Knowledge',
                  accentColor: Colors.amber,
                  isBusy: false,
                  onEdit: () {},
                  onDelete: () {},
                ),
              ],
            ),
          ),
          reduceEffects: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('MaterialCoverThumbnail bounds decode dimensions cleanly',
        (tester) async {
      await prefs.setBool(kReduceEffectsStorageKey, true);
      Uri? capturedUri;

      await tester.pumpWidget(
        wrapWithApp(
          const MaterialCoverThumbnail(
            title: 'BCS Digest',
            subjectColor: Colors.amber,
            coverImageUrl: 'https://example.com/cover.png',
          ),
          reduceEffects: true,
          extraOverrides: [
            materialCoverPreviewImageBuilderProvider.overrideWithValue(
              (_, uri) {
                capturedUri = uri;
                return const SizedBox(key: ValueKey('lazy-cover-rendered'));
              },
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedUri?.toString(), equals('https://example.com/cover.png'));
      expect(find.byKey(const ValueKey('lazy-cover-rendered')), findsOneWidget);
    });
  });
}
