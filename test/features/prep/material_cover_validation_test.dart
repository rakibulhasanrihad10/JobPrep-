import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';
import 'package:job_prep/features/prep/presentation/utils/material_cover_resizer.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';

import 'fake_material_cover_repository.dart';

Future<Uint8List> _createSolidPng({
  required int width,
  required int height,
}) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFFE5A93C),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  picture.dispose();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MaterialCoverValidator', () {
    test('allows jpg, jpeg, png, webp and rejects unsupported extensions', () {
      expect(MaterialCoverValidator.resolveMimeType('cover.JPG'), 'image/jpeg');
      expect(
        MaterialCoverValidator.resolveMimeType('book.jpeg'),
        'image/jpeg',
      );
      expect(MaterialCoverValidator.resolveMimeType('notes.png'), 'image/png');
      expect(
        MaterialCoverValidator.resolveMimeType('slide.webp'),
        'image/webp',
      );
      expect(MaterialCoverValidator.resolveMimeType('doc.pdf'), isNull);
      expect(MaterialCoverValidator.resolveMimeType('vector.svg'), isNull);
      expect(MaterialCoverValidator.resolveMimeType('cover'), isNull);
      expect(
        MaterialCoverValidator.validateFileType('doc.pdf'),
        MaterialCoverValidationError.unsupportedType,
      );
    });

    test('rejects empty files and files exceeding 5 MiB limit', () {
      expect(
        MaterialCoverValidator.validateFile(
          fileName: 'cover.png',
          sizeBytes: 0,
        ),
        MaterialCoverValidationError.emptyFile,
      );
      expect(
        MaterialCoverValidator.validateFile(
          fileName: 'cover.png',
          sizeBytes: MaterialCoverValidator.maxCoverFileSizeBytes + 1,
        ),
        MaterialCoverValidationError.fileTooLarge,
      );
      expect(
        MaterialCoverValidator.validateFile(
          fileName: 'cover.webp',
          sizeBytes: 42000,
        ),
        isNull,
      );
    });

    test('validates optional cover URL syntax strictly', () {
      expect(MaterialCoverValidator.validateCoverUrl(null), isNull);
      expect(MaterialCoverValidator.validateCoverUrl('   '), isNull);
      expect(
        MaterialCoverValidator.validateCoverUrl(
          'https://cdn.example.com/a.jpg',
        ),
        isNull,
      );
      expect(
        MaterialCoverValidator.validateCoverUrl('http://example.com/b.png'),
        isNull,
      );
      expect(
        MaterialCoverValidator.validateCoverUrl('ftp://example.com/c.png'),
        MaterialCoverValidationError.invalidUrl,
      );
      expect(
        MaterialCoverValidator.validateCoverUrl('not a url'),
        MaterialCoverValidationError.invalidUrl,
      );
      expect(
        MaterialCoverValidator.validateCoverUrl('https://bad url/img.png'),
        MaterialCoverValidationError.invalidUrl,
      );
    });

    test('extracts first character safely and builds per-user paths', () {
      expect(
        MaterialCoverValidator.materialPlaceholderInitial('  anatomy atlas'),
        'A',
      );
      expect(
        MaterialCoverValidator.materialPlaceholderInitial('সাধারণ জ্ঞান'),
        'স',
      );
      expect(MaterialCoverValidator.materialPlaceholderInitial('   '), '?');

      final path = MaterialCoverValidator.buildStoragePath(
        userId: 'user-42',
        folderKey: 'mat-9',
        fileName: '../../My Book Cover?.jpg',
        timestamp: DateTime.utc(2026, 11, 10, 12),
      );
      expect(path.startsWith('user-42/mat-9/'), isTrue);
      expect(path, endsWith('_My_Book_Cover_.jpg'));
      expect(path, isNot(contains('..')));
    });
  });

  group('MaterialCoverResizer', () {
    test('scales wide images proportionally down to 600 px wide', () async {
      final wideBytes = await _createSolidPng(width: 1200, height: 1600);

      final result = await MaterialCoverResizer.resizeToMaxWidth(
        bytes: wideBytes,
        fileName: 'wide_cover.jpg',
        mimeType: 'image/jpeg',
      );

      expect(result.wasResized, isTrue);
      expect(result.width, 600);
      expect(result.height, 800);
      expect(result.fileName, 'wide_cover.png');
      expect(result.mimeType, 'image/png');
      expect(result.bytes, isNotEmpty);

      final codec = await ui.instantiateImageCodec(result.bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 600);
      expect(frame.image.height, 800);
      frame.image.dispose();
      codec.dispose();
    });

    test('keeps images with width <= 600 px untouched', () async {
      final compactBytes = await _createSolidPng(width: 500, height: 750);

      final result = await MaterialCoverResizer.resizeToMaxWidth(
        bytes: compactBytes,
        fileName: 'small_cover.png',
        mimeType: 'image/png',
      );

      expect(result.wasResized, isFalse);
      expect(result.width, 500);
      expect(result.height, 750);
      expect(result.bytes, same(compactBytes));
    });

    test('throws PrepValidationFailure on corrupt cover bytes', () async {
      await expectLater(
        () => MaterialCoverResizer.resizeToMaxWidth(
          bytes: Uint8List.fromList([1, 2, 3, 4, 5]),
          fileName: 'broken.png',
          mimeType: 'image/png',
        ),
        throwsA(isA<PrepValidationFailure>()),
      );
    });
  });

  group('PrepStyleTokens & FakeMaterialCoverRepository', () {
    test('resolves semantic subject colors in dark and light tokens', () {
      final dark = AppColorsToken.dark();
      final light = AppColorsToken.light();

      expect(
        PrepStyleTokens.resolveSubjectColor('gold', dark),
        dark.goldAccent,
      );
      expect(PrepStyleTokens.resolveSubjectColor('info', light), light.info);
      expect(
        PrepStyleTokens.resolveSubjectColor('#112233', dark),
        const Color(0xFF112233),
      );
      expect(
        PrepStyleTokens.resolveSubjectIcon('computer'),
        Icons.computer_outlined,
      );
    });

    test('stores uploads in per-user folder and issues signed URLs', () async {
      final repo = FakeMaterialCoverRepository(defaultUserId: 'uid-99');
      final png = await _createSolidPng(width: 200, height: 300);

      final path = await repo.uploadCover(
        folderKey: 'mat-1',
        fileName: 'cover.png',
        mimeType: 'image/png',
        bytes: png,
      );

      expect(path.startsWith('uid-99/mat-1/'), isTrue);
      expect(repo.uploadedBlobs.containsKey(path), isTrue);

      final signed = await repo.createSignedCoverUrl(path);
      expect(signed.toString(), contains('token=signed-'));
      expect(repo.requestedSignedPaths, contains(path));

      await repo.deleteCover(path);
      expect(repo.uploadedBlobs.containsKey(path), isFalse);
      expect(repo.deletedPaths, contains(path));
    });
  });
}
