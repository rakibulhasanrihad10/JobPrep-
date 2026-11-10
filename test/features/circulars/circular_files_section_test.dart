import 'dart:async';
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
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_file_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/url_launcher_provider.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_image_resizer.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_circular_file_repository.dart';
import 'fake_circular_repository.dart';
import 'fake_exam_date_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Circular sampleCircular() {
    return Circular(
      id: 'c-files',
      userId: 'user-1',
      title: 'Bangladesh Bank AD',
      sector: CircularSector.bank,
      organizationName: 'Bangladesh Bank',
      deadline: DateTime.utc(2026, 11, 20, 17),
      priority: CircularPriority.high,
      createdAt: DateTime.utc(2026, 11, 1, 9),
      updatedAt: DateTime.utc(2026, 11, 9, 10),
    );
  }

  Future<({List<Uri> launchedUris, List<Uri> previewedImageUris})>
      pumpFilesDetailView(
    WidgetTester tester, {
    required FakeCircularRepository circularRepo,
    required FakeCircularFileRepository fileRepo,
    required Future<PickedCircularFile?> Function() onPickFile,
    CircularImageResizerFn? imageResizer,
    ThemeMode themeMode = ThemeMode.dark,
    String languageCode = 'en',
    Size viewportSize = const Size(900, 1400),
  }) async {
    tester.view.physicalSize = viewportSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, true);
    await prefs.setString(kLocaleStorageKey, languageCode);

    final launchedUris = <Uri>[];
    final previewedImageUris = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          examDateRepositoryProvider.overrideWithValue(
            FakeExamDateRepository(clock: () => fixedNow),
          ),
          circularFileRepositoryProvider.overrideWithValue(fileRepo),
          circularFilePickerProvider.overrideWithValue(onPickFile),
          if (imageResizer != null)
            circularImageResizerProvider.overrideWithValue(imageResizer),
          circularNowProvider.overrideWithValue(() => fixedNow),
          circularUrlLauncherProvider.overrideWithValue((uri) async {
            launchedUris.add(uri);
            return true;
          }),
          circularPreviewImageBuilderProvider.overrideWithValue(
            (context, signedUri) {
              previewedImageUris.add(signedUri);
              return Container(
                key: const ValueKey('test-signed-image-preview'),
                padding: const EdgeInsets.all(16),
                child: Text(signedUri.toString()),
              );
            },
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: Locale(languageCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: CircularDetailView(circularId: 'c-files'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final filesCard = find.byKey(const ValueKey('circular-detail-files-card'));
    await tester.ensureVisible(filesCard);
    await tester.pumpAndSettle();

    return (
      launchedUris: launchedUris,
      previewedImageUris: previewedImageUris,
    );
  }

  group('CircularFilesSection', () {
    testWidgets(
        'uploads a valid PDF showing progress and renders attachment row',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleCircular()],
        clock: () => fixedNow,
      );
      final uploadGate = Completer<void>();
      final fileRepo = FakeCircularFileRepository(clock: () => fixedNow)
        ..pendingUploadGate = uploadGate;

      await pumpFilesDetailView(
        tester,
        circularRepo: circularRepo,
        fileRepo: fileRepo,
        onPickFile: () async => PickedCircularFile.fromBytes(
          name: 'circular_notice.pdf',
          bytes: Uint8List(2048),
        ),
      );

      expect(
        find.byKey(const ValueKey('circular-files-empty-text')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('detail-upload-file-btn')));
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const ValueKey('file-upload-progress-box')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('file-upload-progress-bar')),
        findsOneWidget,
      );
      expect(find.textContaining('45%'), findsOneWidget);

      uploadGate.complete();
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('file-upload-progress-box')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('circular-file-tile-file-1')),
        findsOneWidget,
      );
      expect(find.text('circular_notice.pdf'), findsOneWidget);
      expect(find.text('2 KB'), findsOneWidget);
      expect(find.text('1 file'), findsOneWidget);
    });

    testWidgets(
        'resizes large image before upload and opens signed-URL preview dialog',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleCircular()],
        clock: () => fixedNow,
      );
      final fileRepo = FakeCircularFileRepository(clock: () => fixedNow);
      final rawJpgBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6]);
      final resizedPngBytes = Uint8List.fromList([9, 8, 7, 6]);
      final capturedMaxDimensions = <int>[];

      final tracking = await pumpFilesDetailView(
        tester,
        circularRepo: circularRepo,
        fileRepo: fileRepo,
        onPickFile: () async => PickedCircularFile.fromBytes(
          name: 'admit_card.jpg',
          bytes: rawJpgBytes,
        ),
        imageResizer: ({
          required bytes,
          required fileName,
          required mimeType,
          maxDimension = CircularImageResizer.defaultMaxDimension,
        }) async {
          expect(bytes, rawJpgBytes);
          expect(fileName, 'admit_card.jpg');
          expect(mimeType, 'image/jpeg');
          capturedMaxDimensions.add(maxDimension);
          return PreparedImageResult(
            bytes: resizedPngBytes,
            fileName: 'admit_card.png',
            mimeType: 'image/png',
            wasResized: true,
            width: 1600,
            height: 800,
          );
        },
      );

      await tester.tap(find.byKey(const ValueKey('detail-upload-file-btn')));
      await tester.pumpAndSettle();

      expect(capturedMaxDimensions, [1600]);
      expect(find.text('admit_card.png'), findsOneWidget);
      expect(
        fileRepo.blobs[fileRepo.files.single.storagePath],
        resizedPngBytes,
      );

      await tester.tap(find.byKey(const ValueKey('file-preview-btn-file-1')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('circular-file-preview-dialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('test-signed-image-preview')),
        findsOneWidget,
      );
      final previewUri = tracking.previewedImageUris.single;
      expect(previewUri.path, contains('/object/sign/circular-files/'));
      expect(previewUri.path, isNot(contains('/object/public/')));

      await tester.tap(
        find.byKey(const ValueKey('preview-open-signed-link-btn')),
      );
      await tester.pumpAndSettle();
      expect(tracking.launchedUris, contains(previewUri));

      await tester.tap(find.byKey(const ValueKey('preview-close-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-file-preview-dialog')),
        findsNothing,
      );
    });

    testWidgets(
        'shows validation and upload failures cleanly and supports dismiss',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleCircular()],
        clock: () => fixedNow,
      );
      final fileRepo = FakeCircularFileRepository(clock: () => fixedNow);
      var pickCount = 0;

      await pumpFilesDetailView(
        tester,
        circularRepo: circularRepo,
        fileRepo: fileRepo,
        onPickFile: () async {
          pickCount += 1;
          if (pickCount == 1) {
            return PickedCircularFile.fromBytes(
              name: 'bad.svg',
              bytes: Uint8List.fromList([1, 2, 3]),
            );
          }
          if (pickCount == 2) {
            return PickedCircularFile(
              name: 'oversized.pdf',
              sizeBytes: CircularFileValidator.maxCircularFileSizeBytes + 100,
              readBytes: () async => Uint8List(0),
            );
          }
          fileRepo.nextError =
              const CircularPermissionFailure(message: 'Forbidden');
          return PickedCircularFile.fromBytes(
            name: 'valid.pdf',
            bytes: Uint8List.fromList([1, 2, 3, 4]),
          );
        },
      );

      await tester.tap(find.byKey(const ValueKey('detail-upload-file-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-files-error-banner')),
        findsOneWidget,
      );
      expect(
        find.text('Only PDF, PNG, JPG, JPEG, and WEBP files are supported.'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('circular-files-error-dismiss-btn')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-files-error-banner')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('detail-upload-file-btn')));
      await tester.pumpAndSettle();
      expect(find.text('File exceeds the 5 MB limit.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('detail-upload-file-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-files-error-banner')),
        findsOneWidget,
      );
      expect(fileRepo.files, isEmpty);
    });

    testWidgets(
        'downloads PDF via download signed URL and deletes after confirmation',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleCircular()],
        clock: () => fixedNow,
      );
      final existingPdf = CircularFile(
        id: 'file-pdf',
        circularId: 'c-files',
        userId: 'user-1',
        storagePath: 'user-1/c-files/1_notice.pdf',
        fileName: 'notice.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 2048,
        createdAt: DateTime.utc(2026, 11, 5, 10),
      );
      final fileRepo = FakeCircularFileRepository(
        initialFiles: [existingPdf],
        clock: () => fixedNow,
      );

      final tracking = await pumpFilesDetailView(
        tester,
        circularRepo: circularRepo,
        fileRepo: fileRepo,
        onPickFile: () async => null,
      );

      // PDF preview uses signed-link guidance instead of image widget.
      await tester.tap(find.byKey(const ValueKey('file-preview-btn-file-pdf')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-file-preview-dialog')),
        findsOneWidget,
      );
      expect(
        find.text(
          'PDF files open with a temporary signed link in your browser or '
          'PDF viewer.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('preview-close-btn')));
      await tester.pumpAndSettle();

      // Download launches signed URL with download query param.
      await tester.tap(
        find.byKey(const ValueKey('file-download-btn-file-pdf')),
      );
      await tester.pumpAndSettle();
      expect(fileRepo.signedUrlRequests.last.download, isTrue);
      expect(
        tracking.launchedUris.last.queryParameters['download'],
        'notice.pdf',
      );

      // Delete confirmation: cancel keeps file, confirm deletes it.
      await tester.tap(find.byKey(const ValueKey('file-delete-btn-file-pdf')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-file-delete-dialog')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('file-delete-cancel-btn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('circular-file-tile-file-pdf')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('file-delete-btn-file-pdf')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('file-delete-confirm-btn')));
      await tester.pumpAndSettle();
      expect(fileRepo.files, isEmpty);
      expect(
        find.byKey(const ValueKey('circular-files-empty-text')),
        findsOneWidget,
      );
    });

    testWidgets('renders localized Bangla attachments in light mode cleanly',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleCircular()],
        clock: () => fixedNow,
      );
      final fileRepo = FakeCircularFileRepository(
        initialFiles: [
          CircularFile(
            id: 'file-bn',
            circularId: 'c-files',
            userId: 'user-1',
            storagePath: 'user-1/c-files/1_admit.pdf',
            fileName: 'admit.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 2048,
            createdAt: DateTime.utc(2026, 11, 5, 10),
          ),
        ],
        clock: () => fixedNow,
      );

      await pumpFilesDetailView(
        tester,
        circularRepo: circularRepo,
        fileRepo: fileRepo,
        onPickFile: () async => null,
        themeMode: ThemeMode.light,
        languageCode: 'bn',
        viewportSize: const Size(360, 812),
      );

      expect(find.text('ফাইল ও সংযুক্তি'), findsOneWidget);
      expect(find.text('ফাইল আপলোড করুন'), findsOneWidget);
      expect(find.text('১টি ফাইল'), findsOneWidget);
      expect(find.text('২ কে.বি.'), findsOneWidget);
    });
  });
}
