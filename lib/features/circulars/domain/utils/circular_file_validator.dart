/// Validation errors for circular attachment uploads.
enum CircularFileValidationError {
  unsupportedType,
  emptyFile,
  fileTooLarge,
}

/// Pure validation, MIME detection, and storage path helpers for
/// `public.circular_files` attachments.
abstract final class CircularFileValidator {
  /// Maximum allowed uploaded file size (5 MiB = 5,242,880 bytes).
  static const int maxCircularFileSizeBytes = 5 * 1024 * 1024;

  /// Maximum raw input size accepted before attempting client-side image resize
  /// (25 MiB) to guard browser memory.
  static const int maxRawImageInputBytes = 25 * 1024 * 1024;

  /// Allowed dotless file extensions for circular attachments.
  static const List<String> allowedExtensions = <String>[
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'webp',
  ];

  static const Map<String, String> _extensionToMime = <String, String>{
    'pdf': 'application/pdf',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'webp': 'image/webp',
  };

  /// Resolves the allowed MIME type from [fileName]'s extension, or returns
  /// `null` when the file type is unsupported.
  static String? resolveMimeType(String fileName) {
    final trimmed = fileName.trim();
    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex >= trimmed.length - 1) {
      return null;
    }
    final ext = trimmed.substring(dotIndex + 1).toLowerCase();
    return _extensionToMime[ext];
  }

  /// Whether [mimeType] represents a supported image attachment.
  static bool isImageMimeType(String mimeType) {
    return mimeType.trim().toLowerCase().startsWith('image/');
  }

  /// Whether [mimeType] represents a PDF attachment.
  static bool isPdfMimeType(String mimeType) {
    return mimeType.trim().toLowerCase() == 'application/pdf';
  }

  /// Validates only the file extension/type before reading or resizing.
  static CircularFileValidationError? validateFileType(String fileName) {
    if (resolveMimeType(fileName) == null) {
      return CircularFileValidationError.unsupportedType;
    }
    return null;
  }

  /// Validates file type, non-empty payload, and size limit (`<= 5 MiB`).
  static CircularFileValidationError? validateFile({
    required String fileName,
    required int sizeBytes,
    int maxBytes = maxCircularFileSizeBytes,
  }) {
    final typeError = validateFileType(fileName);
    if (typeError != null) return typeError;

    if (sizeBytes <= 0) {
      return CircularFileValidationError.emptyFile;
    }
    if (sizeBytes > maxBytes) {
      return CircularFileValidationError.fileTooLarge;
    }
    return null;
  }

  /// Sanitizes [fileName] so it is safe to embed in a Storage object path.
  static String sanitizeFileName(String fileName) {
    final baseName = fileName.trim().split(RegExp(r'[/\\]')).last;
    final cleaned = baseName
        .replaceAll(RegExp('[^A-Za-z0-9._-]'), '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^\.+'), '');
    if (cleaned.isEmpty) {
      return 'attachment';
    }
    return cleaned;
  }

  /// Replaces the extension of [fileName] with [newExtension] (without dot).
  static String replaceExtension(String fileName, String newExtension) {
    final trimmed = fileName.trim();
    final dotIndex = trimmed.lastIndexOf('.');
    final stem = dotIndex > 0 ? trimmed.substring(0, dotIndex) : trimmed;
    final cleanExt = newExtension.replaceFirst(RegExp(r'^\.+'), '');
    return '$stem.$cleanExt';
  }

  /// Builds a deterministic Storage object path strictly scoped under
  /// `<userId>/<circularId>/...`.
  static String buildStoragePath({
    required String userId,
    required String circularId,
    required String fileName,
    int? timestampMs,
  }) {
    final safeUserId = userId.trim();
    final safeCircularId = circularId.trim();
    final safeName = sanitizeFileName(fileName);
    final stamp = timestampMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    return '$safeUserId/$safeCircularId/${stamp}_$safeName';
  }
}
