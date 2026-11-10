/// Null-safe JSON parsing helpers for preparation PostgREST payloads.
abstract final class PrepJsonHelpers {
  /// Reads a required string value for [key], returning `''` when absent.
  static String readRequiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  /// Reads an optional string value for [key], optionally normalizing blank
  /// strings to `null`.
  static String? readOptionalString(
    Map<String, dynamic> json,
    String key, {
    bool trimEmptyToNull = false,
  }) {
    final value = json[key];
    if (value == null) return null;
    final text = value is String ? value : value.toString();
    if (trimEmptyToNull && text.trim().isEmpty) {
      return null;
    }
    return text;
  }

  /// Reads an optional integer from `int`, `num`, or numeric `String` JSON.
  static int? readOptionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return int.tryParse(trimmed) ?? num.tryParse(trimmed)?.toInt();
    }
    return null;
  }

  /// Reads a required integer defaulting to [fallback] when absent or invalid.
  static int readRequiredInt(
    Map<String, dynamic> json,
    String key, {
    int fallback = 0,
  }) {
    return readOptionalInt(json, key) ?? fallback;
  }

  /// Parses an optional ISO-8601 `timestamptz` string or [DateTime] into UTC.
  static DateTime? readOptionalDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed)?.toUtc();
    }
    return null;
  }

  /// Parses a calendar `date` value (`YYYY-MM-DD`) into midnight `DateTime`.
  static DateTime readRequiredDateOnly(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is DateTime) {
      return DateTime(value.year, value.month, value.day);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value.trim());
      if (parsed != null) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }
    }
    return DateTime(1970);
  }

  /// Formats a [DateTime] as a PostgreSQL `date` string (`YYYY-MM-DD`).
  static String formatDateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
