import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/utils/material_cover_resizer.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_material_cover_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tinyPng = Uint8List.fromList(<int>[
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, //
    0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, //
    13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
  ]);

  Future<void> pumpMaterialsManager(
    WidgetTester tester, {
    required FakeSubjectRepository subjectRepo,
    required FakeMaterialRepository materialRepo,
    required FakeMaterialCoverRepository coverRepo,
    MaterialCoverPickerFn? pickerOverride,
    MaterialCoverResizerFn? resizerOverride,
    List<Uri>? renderedImageUris,
  }) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      kReduceEffectsStorageKey: true,
      kLocaleStorageKey: 'en',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          materialCoverRepositoryProvider.overrideWithValue(coverRepo),
          if (pickerOverride != null)
            materialCoverPickerProvider.overrideWithValue(pickerOverride),
          if (resizerOverride != null)
            materialCoverResizerProvider.overrideWithValue(resizerOverride),
          materialCoverPreviewImageBuilderProvider.overrideWithValue(
            (context, uri) {
              renderedImageUris?.add(uri);
              return Container(key: ValueKey('cover-network-${uri.path}'));
            },
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PrepScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Material Manager & Cover UI', () {
    testWidgets(
        'creates material without cover -> shows initial glass placeholder',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 'sub-1',
            userId: 'u-1',
            name: 'Algorithms',
            color: 'info',
            examType: 'Engineering',
          ),
        ],
      );
      final materialRepo = FakeMaterialRepository();

      await pumpMaterialsManager(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        coverRepo: FakeMaterialCoverRepository(),
      );

      await tester.tap(find.byKey(const ValueKey('add-material-button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('material-title-field')),
        'clrs Introduction',
      );
      await tester.tap(find.byKey(const ValueKey('material-kind-book')));
      await tester.enterText(
        find.byKey(const ValueKey('material-unit-label-field')),
        'chapters',
      );
      await tester.enterText(
        find.byKey(const ValueKey('material-total-units-field')),
        '35',
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('material-cover-placeholder')),
          matching: find.text('C'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('material-save-button')));
      await tester.pumpAndSettle();

      expect(materialRepo.materials, hasLength(1));
      final saved = materialRepo.materials.first;
      expect(saved.title, 'clrs Introduction');
      expect(saved.unitLabel, 'chapters');
      expect(saved.totalUnits, 35);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets(
        'uploads resized 600px cover into private storage and edits cover URL',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(
            id: 'sub-1',
            userId: 'u-1',
            name: 'Biology',
            color: 'success',
          ),
        ],
      );
      final materialRepo = FakeMaterialRepository();
      final coverRepo = FakeMaterialCoverRepository(defaultUserId: 'uid-a');
      final capturedWidths = <int>[];
      final renderedUris = <Uri>[];

      await pumpMaterialsManager(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        coverRepo: coverRepo,
        renderedImageUris: renderedUris,
        pickerOverride: () async => PickedMaterialCover.fromBytes(
          name: 'textbook_cover.jpg',
          bytes: tinyPng,
        ),
        resizerOverride: ({
          required bytes,
          required fileName,
          required mimeType,
          maxWidth = 600,
        }) async {
          capturedWidths.add(maxWidth);
          return PreparedCoverImageResult(
            bytes: tinyPng,
            fileName: 'textbook_cover.png',
            mimeType: 'image/png',
            wasResized: true,
            width: 600,
            height: 840,
          );
        },
      );

      await tester.tap(find.byKey(const ValueKey('add-material-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('material-title-field')),
        'Molecular Biology',
      );
      await tester.enterText(
        find.byKey(const ValueKey('material-unit-label-field')),
        'pages',
      );
      await tester.enterText(
        find.byKey(const ValueKey('material-total-units-field')),
        '400',
      );
      await tester.tap(
        find.byKey(const ValueKey('material-cover-mode-upload')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('material-pick-cover-button')),
      );
      await tester.pumpAndSettle();

      expect(capturedWidths, [600]);
      expect(find.textContaining('600 px'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('material-save-button')));
      await tester.pumpAndSettle();

      final created = materialRepo.materials.first;
      expect(created.coverImagePath, startsWith('uid-a/'));
      expect(
        coverRepo.uploadedBlobs.containsKey(created.coverImagePath),
        isTrue,
      );
      expect(
        renderedUris.any((u) => u.toString().contains('token=signed-')),
        isTrue,
      );

      await tester.tap(find.byKey(ValueKey('material-edit-${created.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('material-cover-mode-url')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('material-cover-url-field')),
        'https://cdn.example.org/bio-cover.webp',
      );
      await tester.tap(find.byKey(const ValueKey('material-save-button')));
      await tester.pumpAndSettle();

      expect(materialRepo.materials.first.coverImagePath, isNull);
      expect(
        materialRepo.materials.first.coverImageUrl,
        'https://cdn.example.org/bio-cover.webp',
      );
      expect(coverRepo.deletedPaths, contains(created.coverImagePath));
    });

    testWidgets(
        'rejects unsupported cover type and confirms delete with progress',
        (tester) async {
      final subjectRepo = FakeSubjectRepository(
        initialSubjects: const [
          Subject(id: 'sub-1', userId: 'u-1', name: 'English'),
        ],
      );
      final materialRepo = FakeMaterialRepository(
        initialMaterials: const [
          PrepMaterial(
            id: 'mat-1',
            userId: 'u-1',
            subjectId: 'sub-1',
            title: 'Grammar Manual',
            totalUnits: 300,
            completedUnits: 150,
          ),
        ],
      );

      await pumpMaterialsManager(
        tester,
        subjectRepo: subjectRepo,
        materialRepo: materialRepo,
        coverRepo: FakeMaterialCoverRepository(),
        pickerOverride: () async => PickedMaterialCover.fromBytes(
          name: 'bad_cover.pdf',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('add-material-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('material-cover-mode-upload')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('material-pick-cover-button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('material-cover-error')),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('material-delete-mat-1')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('prep-delete-progress-warning')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('prep-delete-cancel')));
      await tester.pumpAndSettle();
      expect(materialRepo.materials, hasLength(1));

      await tester.tap(find.byKey(const ValueKey('material-delete-mat-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('prep-delete-confirm')));
      await tester.pumpAndSettle();
      expect(materialRepo.materials, isEmpty);
    });
  });
}
