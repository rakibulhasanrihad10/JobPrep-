import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/utils/material_cover_validator.dart';

/// Result of inspecting and optionally resizing a cover image before upload.
@immutable
class PreparedCoverImageResult {
  /// Creates a [PreparedCoverImageResult].
  const PreparedCoverImageResult({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.wasResized,
    required this.width,
    required this.height,
  });

  /// Binary payload ready for upload.
  final Uint8List bytes;

  /// Effective file name matching the encoded format.
  final String fileName;

  /// Effective MIME type matching [bytes].
  final String mimeType;

  /// Whether image width exceeded `maxWidth` and was scaled down.
  final bool wasResized;

  /// Resulting pixel width.
  final int width;

  /// Resulting pixel height.
  final int height;
}

/// Callback signature for resizing cover image bytes prior to upload.
typedef MaterialCoverResizerFn = Future<PreparedCoverImageResult> Function({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  int maxWidth,
});

/// Client-side cover image resizer powered by Flutter's `dart:ui` codecs.
abstract final class MaterialCoverResizer {
  /// Resizes cover image [bytes] down proportionally when its width exceeds
  /// [maxWidth] (defaults to `600` px), re-encoding resized outputs as PNG.
  ///
  /// Images already at or below [maxWidth] px wide are returned untouched.
  static Future<PreparedCoverImageResult> resizeToMaxWidth({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    int maxWidth = MaterialCoverValidator.targetMaxWidth,
  }) async {
    if (maxWidth <= 0) {
      throw const PrepValidationFailure(
        code: 'invalid_target_width',
        message: 'Target cover width must be positive.',
      );
    }

    ui.Codec? codec;
    ui.Image? sourceImage;
    try {
      codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      sourceImage = frame.image;

      final originalWidth = sourceImage.width;
      final originalHeight = sourceImage.height;

      if (originalWidth <= maxWidth) {
        return PreparedCoverImageResult(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
          wasResized: false,
          width: originalWidth,
          height: originalHeight,
        );
      }

      final scale = maxWidth / originalWidth;
      final targetWidth = maxWidth;
      final targetHeight = math.max(1, (originalHeight * scale).round());

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final srcRect = ui.Rect.fromLTWH(
        0,
        0,
        originalWidth.toDouble(),
        originalHeight.toDouble(),
      );
      final dstRect = ui.Rect.fromLTWH(
        0,
        0,
        targetWidth.toDouble(),
        targetHeight.toDouble(),
      );
      canvas.drawImageRect(
        sourceImage,
        srcRect,
        dstRect,
        ui.Paint()..filterQuality = ui.FilterQuality.medium,
      );

      final picture = recorder.endRecording();
      ui.Image? resizedImage;
      try {
        resizedImage = await picture.toImage(targetWidth, targetHeight);
        picture.dispose();
        final encoded = await resizedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (encoded == null) {
          throw const PrepValidationFailure(
            code: 'cover_encode_failed',
            message: 'Could not encode resized cover image.',
          );
        }

        return PreparedCoverImageResult(
          bytes: encoded.buffer.asUint8List(),
          fileName: MaterialCoverValidator.replaceExtension(fileName, 'png'),
          mimeType: 'image/png',
          wasResized: true,
          width: targetWidth,
          height: targetHeight,
        );
      } finally {
        resizedImage?.dispose();
      }
    } on PrepFailure {
      rethrow;
    } on Object catch (error) {
      throw PrepValidationFailure(
        code: 'invalid_cover_image',
        message: 'Could not decode or resize cover image: $error',
      );
    } finally {
      sourceImage?.dispose();
      codec?.dispose();
    }
  }
}
