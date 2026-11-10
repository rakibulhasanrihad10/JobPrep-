/// Validation errors for material cover image uploads and URLs.
enum MaterialCoverValidationError {
  unsupportedType,
  emptyFile,
  fileTooLarge,
  invalidUrl,
}

/// Pure validation, MIME detection, initial extraction, and storage path
/// helpers for material cover images (`material-covers` private bucket).
abstract final class MaterialCoverValidator {
  /// Maximum allowed uploaded cover file size (5 MiB = 5,242,880 bytes).
  static const int maxCoverFileSizeBytes = 5 * 1024 * 1024;

  /// Maximum raw input size accepted before attempting client-side resize
  /// (25 MiB) to guard browser memory.
  static const int maxRawImageInputBytes = 25 * 1024 * 1024;

  /// Target maximum width (~600 px) when resizing cover photos before upload.
  static const int targetMaxWidth = 600;

  /// Allowed dotless file extensions for uploaded cover images.
  static const List<String> allowedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  static const Map<String, String> _extensionToMime = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  /// Resolves the allowed MIME type from [fileName]'s extension, or `null`
  /// when the extension is not `jpg`, `jpeg`, `png`, or `webp`.
  static String? resolveMimeType(String fileName) {
    final trimmed = fileName.trim();
    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex >= trimmed.length - 1) {
      return null;
    }
    final ext = trimmed.substring(dotIndex + 1).toLowerCase();
    return _extensionToMime[ext];
  }

  /// Validates only the image file extension (`jpg`, `png`, or `webp`).
  static MaterialCoverValidationError? validateFileType(
    String fileName,
  ) {
    if (resolveMimeType(fileName) == null) {
      return MaterialCoverValidationError.unsupportedType;
    }
    return null;
  }

  /// Validates cover image type, non-empty payload, and 5 MiB limit.
  static MaterialCoverValidationError? validateFile({
    required String fileName,
    required int sizeBytes,
    int maxBytes = maxCoverFileSizeBytes,
  }) {
    final typeError = validateFileType(fileName);
    if (typeError != null) return typeError;

    if (sizeBytes <= 0) {
      return MaterialCoverValidationError.emptyFile;
    }
    if (sizeBytes > maxBytes) {
      return MaterialCoverValidationError.fileTooLarge;
    }
    return null;
  }

  /// Validates an optional pasted cover image URL.
  ///
  /// Empty or whitespace-only inputs are valid (representing no external link).
  /// Non-empty values must parse cleanly as `http` or `https` URLs with a host.
  static MaterialCoverValidationError? validateCoverUrl(String? rawUrl) {
    final trimmed = rawUrl?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.contains(RegExp(r'\s'))) {
      return MaterialCoverValidationError.invalidUrl;
    }
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) {
      return MaterialCoverValidationError.invalidUrl;
    }
    final scheme = parsed.scheme.toLowerCase();
    if ((scheme != 'http' && scheme != 'https') || parsed.host.trim().isEmpty) {
      return MaterialCoverValidationError.invalidUrl;
    }
    return null;
  }

  /// Extracts a clean display initial for glass placeholders without a cover.
  static String materialPlaceholderInitial(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    final first = String.fromCharCode(trimmed.runes.first);
    return first.toUpperCase();
  }

  /// Sanitizes [fileName] so it is safe to embed in a Storage object path.
  static String sanitizeFileName(String fileName) {
    final baseName = fileName.trim().split(RegExp(r'[/\\]')).last;
    final cleaned = baseName
        .replaceAll(RegExp('[^A-Za-z0-9._-]'), '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^\.+'), '');
    if (cleaned.isEmpty) {
      return 'cover.png';
    }
    return cleaned;
  }

  /// Replaces the extension of [fileName] with [newExtension] (without dot).
  static String replaceExtension(String fileName, String newExtension) {
    final trimmed = fileName.trim();
    final dotIndex = trimmed.lastIndexOf('.');
    final stem = dotIndex > 0 ? trimmed.substring(0, dotIndex) : trimmed;
    final cleanExt = newExtension.replaceAll('.', '').trim();
    return '$stem.$cleanExt';
  }

  /// Builds the strict per-user Storage object path:
  /// `<userId>/<folderKey>/<timestampMs>_<sanitizedFileName>`.
  static String buildStoragePath({
    required String userId,
    required String folderKey,
    required String fileName,
    DateTime? timestamp,
  }) {
    final cleanUser = userId.trim();
    final cleanFolder =
        folderKey.trim().replaceAll(RegExp('[^A-Za-z0-9_-]'), '_');
    final safeName = sanitizeFileName(fileName);
    final stamp = (timestamp ?? DateTime.now().toUtc()).millisecondsSinceEpoch;
    return '$cleanUser/$cleanFolder/${stamp}_$safeName';
  }
}
