import 'package:job_prep/features/circulars/domain/entities/circular.dart';

/// Typed validation errors for the required circular title field.
enum CircularTitleValidationError {
  required,
}

/// Typed validation errors for optional URL fields (`organizationWebsite`,
/// `circularUrl`, `applicationUrl`).
enum CircularUrlValidationError {
  invalidFormat,
}

/// Typed validation errors for optional numeric inputs.
enum CircularNumberValidationError {
  invalidNonNegativeInt,
  invalidNonNegativeAmount,
}

/// Typed validation errors for cross-field salary range checks.
enum CircularSalaryRangeValidationError {
  maxBelowMin,
}

/// Pure validation and duplicate-detection helpers for circular add/edit forms.
abstract final class CircularFormValidators {
  static const List<String> _banglaDigits = [
    '০',
    '১',
    '২',
    '৩',
    '৪',
    '৫',
    '৬',
    '৭',
    '৮',
    '৯',
  ];

  /// Validates the required circular [title].
  static CircularTitleValidationError? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return CircularTitleValidationError.required;
    }
    return null;
  }

  /// Validates an optional HTTP/HTTPS [url]. Empty or null values are valid.
  static CircularUrlValidationError? validateOptionalUrl(String? url) {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    if (trimmed.contains(RegExp(r'\s'))) {
      return CircularUrlValidationError.invalidFormat;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return CircularUrlValidationError.invalidFormat;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return CircularUrlValidationError.invalidFormat;
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty || (!host.contains('.') && host != 'localhost')) {
      return CircularUrlValidationError.invalidFormat;
    }

    return null;
  }

  /// Validates an optional non-negative integer field (e.g. `vacancies`).
  static CircularNumberValidationError? validateOptionalNonNegativeInt(
    String? raw,
  ) {
    final normalized = _normalizeNumericText(raw);
    if (normalized == null) return null;

    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return CircularNumberValidationError.invalidNonNegativeInt;
    }
    return null;
  }

  /// Validates an optional non-negative decimal amount (salary/fee).
  static CircularNumberValidationError? validateOptionalNonNegativeNumber(
    String? raw,
  ) {
    final normalized = _normalizeNumericText(raw);
    if (normalized == null) return null;

    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return CircularNumberValidationError.invalidNonNegativeAmount;
    }
    return null;
  }

  /// Validates that parsed [salaryMaxText] is not below [salaryMinText] when
  /// both values are valid numbers.
  static CircularSalaryRangeValidationError? validateSalaryRange({
    required String? salaryMinText,
    required String? salaryMaxText,
  }) {
    final min = parseOptionalDouble(salaryMinText);
    final max = parseOptionalDouble(salaryMaxText);
    if (min == null || max == null) return null;
    if (max < min) {
      return CircularSalaryRangeValidationError.maxBelowMin;
    }
    return null;
  }

  /// Parses an optional non-negative integer from ASCII or Bangla digits.
  static int? parseOptionalInt(String? raw) {
    final normalized = _normalizeNumericText(raw);
    if (normalized == null) return null;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  /// Parses an optional non-negative decimal number from ASCII/Bangla digits.
  static double? parseOptionalDouble(String? raw) {
    final normalized = _normalizeNumericText(raw);
    if (normalized == null) return null;
    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite || parsed < 0) return null;
    return parsed;
  }

  /// Normalizes URLs for duplicate comparison (lowercase scheme/host, trimmed
  /// trailing slashes on non-root paths). Returns `null` when empty or invalid.
  static String? normalizeCircularUrl(String? raw) {
    if (validateOptionalUrl(raw) != null) return null;
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    final uri = Uri.parse(trimmed);
    var path = uri.path;
    while (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path == '/') {
      path = '';
    }

    return uri
        .replace(
          scheme: uri.scheme.toLowerCase(),
          host: uri.host.toLowerCase(),
          path: path,
        )
        .removeFragment()
        .toString();
  }

  /// Finds an existing circular matching normalized [circularUrl], ignoring
  /// the record matching [editingCircularId].
  static Circular? findDuplicateCircularByLink({
    required String? circularUrl,
    required List<Circular> existingCirculars,
    String? editingCircularId,
  }) {
    final targetNormalized = normalizeCircularUrl(circularUrl);
    if (targetNormalized == null) return null;

    final trimmedEditingId = editingCircularId?.trim() ?? '';
    for (final existing in existingCirculars) {
      if (trimmedEditingId.isNotEmpty && existing.id == trimmedEditingId) {
        continue;
      }
      final existingNormalized = normalizeCircularUrl(existing.circularUrl);
      if (existingNormalized == targetNormalized) {
        return existing;
      }
    }
    return null;
  }

  static String? _normalizeNumericText(String? raw) {
    if (raw == null) return null;
    var text = raw.trim();
    if (text.isEmpty) return null;

    for (var i = 0; i < 10; i++) {
      text = text.replaceAll(_banglaDigits[i], '$i');
    }
    text = text.replaceAll(',', '').replaceAll(' ', '');
    return text.isEmpty ? null : text;
  }
}
