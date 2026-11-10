import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_error_mapper.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_circular_file_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_file_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_files_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/url_launcher_provider.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_image_resizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'fake_circular_file_repository.dart';
import 'fake_circular_repository.dart';

Future<Uint8List> _createSolidPngBytes(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const Color(0xFFD4AF37),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  picture.dispose();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  group('CircularFileValidator', () {
    test('resolves supported MIME types case-insensitively and rejects others',
        () {
      expect(
        CircularFileValidator.resolveMimeType('Circular.PDF'),
        'application/pdf',
      );
      expect(
        CircularFileValidator.resolveMimeType('admit_card.png'),
        'image/png',
      );
      expect(
        CircularFileValidator.resolveMimeType('scan.JPG'),
        'image/jpeg',
      );
      expect(
        CircularFileValidator.resolveMimeType('photo.jpeg'),
        'image/jpeg',
      );
      expect(
        CircularFileValidator.resolveMimeType('notice.webp'),
        'image/webp',
      );

      for (final bad in ['', 'noext', '.hidden', 'malware.exe', 'vector.svg']) {
        expect(CircularFileValidator.resolveMimeType(bad), isNull);
        expect(
          CircularFileValidator.validateFileType(bad),
          CircularFileValidationError.unsupportedType,
        );
      }
    });

    test('validates file type, empty files, and 5 MiB size cap', () {
      expect(
        CircularFileValidator.validateFile(
          fileName: 'bad.txt',
          sizeBytes: 100,
        ),
        CircularFileValidationError.unsupportedType,
      );
      expect(
        CircularFileValidator.validateFile(
          fileName: 'empty.pdf',
          sizeBytes: 0,
        ),
        CircularFileValidationError.emptyFile,
      );
      expect(
        CircularFileValidator.validateFile(
          fileName: 'exact.pdf',
          sizeBytes: CircularFileValidator.maxCircularFileSizeBytes,
        ),
        isNull,
      );
      expect(
        CircularFileValidator.validateFile(
          fileName: 'too_big.pdf',
          sizeBytes: CircularFileValidator.maxCircularFileSizeBytes + 1,
        ),
        CircularFileValidationError.fileTooLarge,
      );
    });

    test('sanitizes filenames, replaces extensions, and scopes paths by user',
        () {
      expect(
        CircularFileValidator.sanitizeFileName(r'..\..\..secret file (1).pdf'),
        'secret_file_1_.pdf',
      );
      expect(
        CircularFileValidator.replaceExtension('scan.JPEG', 'png'),
        'scan.png',
      );
      final path = CircularFileValidator.buildStoragePath(
        userId: 'user-abc',
        circularId: 'circ-9',
        fileName: 'my notice?.pdf',
        timestampMs: 123456,
      );
      expect(path, 'user-abc/circ-9/123456_my_notice_.pdf');
      expect(path.startsWith('user-abc/'), isTrue);
    });
  });

  group('CircularImageResizer', () {
    test('leaves PDFs and small images unchanged', () async {
      final pdfBytes = Uint8List.fromList([1, 2, 3, 4]);
      final pdfResult = await CircularImageResizer.resizeIfNeeded(
        bytes: pdfBytes,
        fileName: 'notice.pdf',
        mimeType: 'application/pdf',
      );
      expect(pdfResult.wasResized, isFalse);
      expect(pdfResult.bytes, pdfBytes);
      expect(pdfResult.mimeType, 'application/pdf');

      final smallPng = await _createSolidPngBytes(400, 300);
      final smallResult = await CircularImageResizer.resizeIfNeeded(
        bytes: smallPng,
        fileName: 'small.png',
        mimeType: 'image/png',
      );
      expect(smallResult.wasResized, isFalse);
      expect(smallResult.width, 400);
      expect(smallResult.height, 300);
      expect(smallResult.bytes, smallPng);
    });

    test('downscales oversized landscape and portrait images to max 1600 px',
        () async {
      final wideBytes = await _createSolidPngBytes(2000, 1000);
      final wideResized = await CircularImageResizer.resizeIfNeeded(
        bytes: wideBytes,
        fileName: 'wide_scan.JPG',
        mimeType: 'image/jpeg',
      );
      expect(wideResized.wasResized, isTrue);
      expect(wideResized.width, 1600);
      expect(wideResized.height, 800);
      expect(wideResized.fileName, 'wide_scan.png');
      expect(wideResized.mimeType, 'image/png');

      final codec = await ui.instantiateImageCodec(wideResized.bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1600);
      expect(frame.image.height, 800);
      frame.image.dispose();
      codec.dispose();

      final tallBytes = await _createSolidPngBytes(1200, 2400);
      final tallResized = await CircularImageResizer.resizeIfNeeded(
        bytes: tallBytes,
        fileName: 'tall.webp',
        mimeType: 'image/webp',
      );
      expect(tallResized.wasResized, isTrue);
      expect(tallResized.width, 800);
      expect(tallResized.height, 1600);
    });
  });

  group('CircularErrorMapper & UnconfiguredCircularFileRepository', () {
    test('maps StorageException codes accurately', () {
      expect(
        CircularErrorMapper.map(
          const supabase.StorageException(
            'Unauthorized',
            statusCode: '403',
          ),
        ),
        isA<CircularPermissionFailure>(),
      );
      expect(
        CircularErrorMapper.map(
          const supabase.StorageException(
            'Not found',
            statusCode: '404',
          ),
        ),
        isA<CircularNotFoundFailure>(),
      );
      expect(
        CircularErrorMapper.map(
          const supabase.StorageException(
            'Payload too large',
            statusCode: '413',
          ),
        ),
        isA<CircularValidationFailure>(),
      );
      expect(
        CircularErrorMapper.map(
          const supabase.StorageException('SocketException: offline'),
        ),
        isA<CircularNetworkFailure>(),
      );
    });

    test('unconfigured repository returns empty list and blocks writes',
        () async {
      const repo = UnconfiguredCircularFileRepository();
      expect(await repo.getFilesForCircular('c-1'), isEmpty);

      await expectLater(
        () => repo.uploadFile(
          circularId: 'c-1',
          fileName: 'a.pdf',
          mimeType: 'application/pdf',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<UnknownCircularFailure>()),
      );
      await expectLater(
        () => repo.createSignedUrl(
          const CircularFile(
            id: 'f-1',
            circularId: 'c-1',
            storagePath: 'u/c-1/a.pdf',
            fileName: 'a.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 3,
          ),
        ),
        throwsA(isA<UnknownCircularFailure>()),
      );
      await expectLater(
        () => repo.deleteFile(
          const CircularFile(
            id: 'f-1',
            circularId: 'c-1',
            storagePath: 'u/c-1/a.pdf',
            fileName: 'a.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 3,
          ),
        ),
        throwsA(isA<UnknownCircularFailure>()),
      );
    });
  });

  group('CircularFilesController', () {
    late FakeCircularRepository circularRepo;
    late FakeCircularFileRepository fileRepo;
    late List<Uri> launchedUris;
    var launchResult = true;
    PickedCircularFile? pickedResult;

    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [
          circularRepositoryProvider.overrideWithValue(circularRepo),
          circularFileRepositoryProvider.overrideWithValue(fileRepo),
          circularFilePickerProvider
              .overrideWithValue(() async => pickedResult),
          circularUrlLauncherProvider.overrideWithValue((uri) async {
            launchedUris.add(uri);
            return launchResult;
          }),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    setUp(() {
      circularRepo = FakeCircularRepository();
      fileRepo = FakeCircularFileRepository(
        defaultUserId: 'user-42',
        progressDelay: Duration.zero,
      );
      launchedUris = <Uri>[];
      launchResult = true;
      pickedResult = null;
    });

    test('canceling picker produces no upload or error', () async {
      final container = createContainer();
      pickedResult = null;

      final result = await container
          .read(circularFilesControllerProvider.notifier)
          .pickAndUploadFile('c-1');

      expect(result, isNull);
      expect(fileRepo.uploadedFiles, isEmpty);
      expect(
        container.read(circularFilesActionStateProvider('c-1')).error,
        isNull,
      );
    });

    test('rejects invalid extensions, empty payloads, and oversized files',
        () async {
      final container = createContainer();
      final controller =
          container.read(circularFilesControllerProvider.notifier);

      await controller.uploadPickedFile(
        'c-1',
        PickedCircularFile.fromBytes(
          name: 'script.svg',
          bytes: Uint8List.fromList([1, 2]),
        ),
      );
      expect(
        container.read(circularFilesActionStateProvider('c-1')).error,
        isA<CircularFilesValidationUiError>().having(
          (e) => e.validationError,
          'validationError',
          CircularFileValidationError.unsupportedType,
        ),
      );

      await controller.uploadPickedFile(
        'c-1',
        PickedCircularFile.fromBytes(
          name: 'empty.pdf',
          bytes: Uint8List(0),
        ),
      );
      expect(
        container.read(circularFilesActionStateProvider('c-1')).error,
        isA<CircularFilesValidationUiError>().having(
          (e) => e.validationError,
          'validationError',
          CircularFileValidationError.emptyFile,
        ),
      );

      var readCalled = false;
      await controller.uploadPickedFile(
        'c-1',
        PickedCircularFile(
          name: 'huge.pdf',
          sizeBytes: CircularFileValidator.maxCircularFileSizeBytes + 1,
          readBytes: () async {
            readCalled = true;
            return Uint8List(0);
          },
        ),
      );
      expect(readCalled, isFalse);
      expect(
        container.read(circularFilesActionStateProvider('c-1')).error,
        isA<CircularFilesValidationUiError>().having(
          (e) => e.validationError,
          'validationError',
          CircularFileValidationError.fileTooLarge,
        ),
      );

      await controller.uploadPickedFile(
        'c-1',
        PickedCircularFile(
          name: 'huge_photo.png',
          sizeBytes: CircularFileValidator.maxRawImageInputBytes + 1,
          readBytes: () async {
            readCalled = true;
            return Uint8List(0);
          },
        ),
      );
      expect(readCalled, isFalse);
      expect(
        container.read(circularFilesActionStateProvider('c-1')).error,
        isA<CircularFilesRawImageTooLargeUiError>(),
      );
    });

    test('tracks progress, resizes oversized images, signs URLs, and deletes',
        () async {
      final container = createContainer();
      final progressSeen = <double>[];
      final sub = container.listen(
        circularFilesActionStateProvider('c-1'),
        (_, next) {
          if (next.isUploading) {
            progressSeen.add(next.uploadProgress);
          }
        },
      );
      addTearDown(sub.close);

      final bigImage = await _createSolidPngBytes(1800, 900);
      pickedResult = PickedCircularFile.fromBytes(
        name: 'admit_scan.JPG',
        bytes: bigImage,
      );

      final uploaded = await container
          .read(circularFilesControllerProvider.notifier)
          .pickAndUploadFile('c-1');

      expect(uploaded, isNotNull);
      expect(uploaded!.fileName, 'admit_scan.png');
      expect(uploaded.mimeType, 'image/png');
      expect(uploaded.storagePath, startsWith('user-42/c-1/'));
      expect(progressSeen, containsAll([0.1, 0.15, 0.75, 1.0]));
      expect(
        container.read(circularFilesActionStateProvider('c-1')).isUploading,
        isFalse,
      );

      final storedBytes = fileRepo.blobs[uploaded.storagePath]!;
      final codec = await ui.instantiateImageCodec(storedBytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1600);
      expect(frame.image.height, 800);
      frame.image.dispose();
      codec.dispose();

      // Signed preview URL (download = false) and never public.
      final previewUri = await container
          .read(circularFilesControllerProvider.notifier)
          .createSignedPreviewUrl(uploaded);
      expect(previewUri, isNotNull);
      expect(previewUri!.path, contains('/object/sign/circular-files/'));
      expect(previewUri.path, isNot(contains('/object/public/')));
      expect(fileRepo.signedUrlRequests.last.download, isFalse);

      // Download generates signed URL with download=true and launches it.
      final downloadOk = await container
          .read(circularFilesControllerProvider.notifier)
          .downloadFile(uploaded);
      expect(downloadOk, isTrue);
      expect(fileRepo.signedUrlRequests.last.download, isTrue);
      expect(launchedUris.single.queryParameters['download'], 'admit_scan.png');

      // Delete removes both metadata row and blob.
      final deletedOk = await container
          .read(circularFilesControllerProvider.notifier)
          .deleteFile(uploaded);
      expect(deletedOk, isTrue);
      expect(fileRepo.files, isEmpty);
      expect(fileRepo.blobs, isEmpty);
    });

    test(
        'surfaces repository failures cleanly without leaving stale busy state',
        () async {
      final container = createContainer();
      final controller =
          container.read(circularFilesControllerProvider.notifier);

      fileRepo.nextError = const CircularNetworkFailure(message: 'Offline');
      final failedUpload = await controller.uploadPickedFile(
        'c-1',
        PickedCircularFile.fromBytes(
          name: 'notice.pdf',
          bytes: Uint8List.fromList([1, 2, 3, 4]),
        ),
      );
      expect(failedUpload, isNull);
      final state = container.read(circularFilesActionStateProvider('c-1'));
      expect(state.isUploading, isFalse);
      expect(state.error, isA<CircularFilesFailureUiError>());

      controller.clearError('c-1');
      expect(
        container.read(circularFilesActionStateProvider('c-1')).error,
        isNull,
      );
    });
  });
}
