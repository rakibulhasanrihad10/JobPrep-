import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/circular_file_validator.dart';

/// Result of inspecting and optionally resizing an image before upload.
@immutable
class PreparedImageResult {
  /// Creates a [PreparedImageResult].
  const PreparedImageResult({
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

  /// Whether image dimensions exceeded `maxDimension` and were scaled down.
  final bool wasResized;

  /// Final pixel width (`0` for non-image files).
  final int width;

  /// Final pixel height (`0` for non-image files).
  final int height;
}

/// Callback signature for preparing/resizing image bytes prior to upload.
typedef CircularImageResizerFn = Future<PreparedImageResult> Function({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  int maxDimension,
});

/// Client-side image resizer powered by Flutter's `dart:ui` codecs.
abstract final class CircularImageResizer {
  /// Default maximum pixel edge (width or height) preserved before upload.
  static const int defaultMaxDimension = 1600;

  /// Resizes image [bytes] down proportionally if width or height exceeds
  /// [maxDimension], re-encoding resized outputs as PNG.
  ///
  /// Returns the original payload untouched when [mimeType] is not an image or
  /// the image already fits within [maxDimension].
  static Future<PreparedImageResult> resizeIfNeeded({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    int maxDimension = defaultMaxDimension,
  }) async {
    if (!CircularFileValidator.isImageMimeType(mimeType)) {
      return PreparedImageResult(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        wasResized: false,
        width: 0,
        height: 0,
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

      if (originalWidth <= maxDimension && originalHeight <= maxDimension) {
        return PreparedImageResult(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
          wasResized: false,
          width: originalWidth,
          height: originalHeight,
        );
      }

      final scale = maxDimension / math.max(originalWidth, originalHeight);
      final targetWidth = math.max(1, (originalWidth * scale).round());
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
          throw const CircularValidationFailure(
            message: 'Could not encode resized image.',
          );
        }

        return PreparedImageResult(
          bytes: encoded.buffer.asUint8List(),
          fileName: CircularFileValidator.replaceExtension(fileName, 'png'),
          mimeType: 'image/png',
          wasResized: true,
          width: targetWidth,
          height: targetHeight,
        );
      } finally {
        resizedImage?.dispose();
      }
    } on CircularFailure {
      rethrow;
    } on Object catch (error) {
      throw CircularValidationFailure(
        message: 'Could not decode or resize image: $error',
      );
    } finally {
      sourceImage?.dispose();
      codec?.dispose();
    }
  }
}
