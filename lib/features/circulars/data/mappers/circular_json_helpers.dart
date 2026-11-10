/// Shared null-safe JSON parsing helpers for circulars PostgREST payloads.
abstract final class CircularJsonHelpers {
  /// Reads a required string value for [key], returning an empty string if
  /// missing or non-string.
  static String readRequiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  /// Reads an optional string value for [key], trimming empty strings to `null`
  /// only when [trimEmptyToNull] is `true`.
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

  /// Reads an optional double from `num` or PostgreSQL `numeric` string JSON.
  static double? readOptionalDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  /// Reads a boolean value, returning [fallback] when missing or non-bool.
  static bool readBool(
    Map<String, dynamic> json,
    String key, {
    bool fallback = false,
  }) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return fallback;
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

  /// Reads a required [DateTime], falling back to Unix epoch UTC if absent.
  static DateTime readRequiredDateTime(
    Map<String, dynamic> json,
    String key, {
    DateTime? fallback,
  }) {
    return readOptionalDateTime(json, key) ??
        (fallback ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
  }

  /// Reads a JSON list of object maps for nested PostgREST relations.
  static List<Map<String, dynamic>> readJsonList(
    Map<String, dynamic> json,
    String key,
  ) {
    final raw = json[key];
    if (raw is! List) return const [];
    final items = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        items.add(entry);
      } else if (entry is Map) {
        items.add(Map<String, dynamic>.from(entry));
      }
    }
    return items;
  }
}
