import 'package:sentry_flutter/sentry_flutter.dart';

/// Pure scrubbing utilities ensuring crash reports and breadcrumbs never leak
/// user PII, vault passphrases, tokens, or signed Supabase URLs.
abstract final class SentrySanitizer {
  static const String _redacted = '[REDACTED]';

  static final RegExp _sensitiveKeyPattern = RegExp(
    '(password|passphrase|secret|token|apikey|api_key|authorization|'
    'cookie|signed|bearer|service_role|eyj[a-zA-Z0-9_-]{8,})',
    caseSensitive: false,
  );

  static final RegExp _jwtPattern = RegExp(
    r'eyJ[a-zA-Z0-9_-]{8,}\.[a-zA-Z0-9_-]{8,}\.[a-zA-Z0-9_-]{4,}',
  );

  static final RegExp _emailPattern = RegExp(
    r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}',
  );

  /// Scrubs PII, query params, auth headers, and token strings from [event].
  static SentryEvent scrubEvent(SentryEvent event) {
    event.user = null;

    if (event.request != null) {
      event.request = scrubRequest(event.request!);
    }

    if (event.message != null) {
      final msg = event.message!;
      msg.formatted = scrubText(msg.formatted);
    }

    if (event.breadcrumbs != null) {
      event.breadcrumbs =
          event.breadcrumbs!.map(scrubBreadcrumb).toList(growable: false);
    }

    if (event.exceptions != null) {
      for (final ex in event.exceptions!) {
        ex.value = ex.value == null ? null : scrubText(ex.value!);
      }
    }

    return event;
  }

  /// Scrubs sensitive data from [breadcrumb].
  static Breadcrumb scrubBreadcrumb(Breadcrumb breadcrumb) {
    final scrubbedMessage =
        breadcrumb.message == null ? null : scrubText(breadcrumb.message!);
    final scrubbedData = _scrubMap(breadcrumb.data);
    return Breadcrumb(
      message: scrubbedMessage,
      timestamp: breadcrumb.timestamp,
      category: breadcrumb.category,
      data: scrubbedData,
      level: breadcrumb.level,
      type: breadcrumb.type,
    );
  }

  /// Strips query params, cookies, and sensitive headers from [request].
  static SentryRequest scrubRequest(SentryRequest request) {
    final scrubbedUrl = request.url == null ? null : scrubUrl(request.url!);
    final cleanHeaders = <String, String>{};
    for (final entry in request.headers.entries) {
      cleanHeaders[entry.key] =
          _sensitiveKeyPattern.hasMatch(entry.key) ? _redacted : entry.value;
    }

    return SentryRequest(
      url: scrubbedUrl,
      method: request.method,
      queryString: request.queryString == null || request.queryString!.isEmpty
          ? null
          : _redacted,
      cookies: request.cookies == null || request.cookies!.isEmpty
          ? null
          : _redacted,
      headers: cleanHeaders,
    );
  }

  /// Drops query parameters and fragment tokens from [rawUrl].
  static String scrubUrl(String rawUrl) {
    final parsed = Uri.tryParse(rawUrl);
    if (parsed == null) return scrubText(rawUrl);
    if (!parsed.hasQuery && !parsed.hasFragment) return rawUrl;
    return parsed
        .replace(query: '', fragment: '')
        .toString()
        .replaceAll(RegExp(r'[?#]+$'), '');
  }

  /// Redacts JWTs, email addresses, and inline secret query params in [text].
  static String scrubText(String text) {
    var result = text.replaceAll(_jwtPattern, _redacted);
    result = result.replaceAll(_emailPattern, '[EMAIL_REDACTED]');
    result = result.replaceAllMapped(
      RegExp(
        r'([?&](?:access_token|refresh_token|token|apikey|password|passphrase)=)[^&\s#]+',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}$_redacted',
    );
    return result;
  }

  static Map<String, dynamic>? _scrubMap(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return data;
    final clean = <String, dynamic>{};
    for (final entry in data.entries) {
      if (_sensitiveKeyPattern.hasMatch(entry.key)) {
        clean[entry.key] = _redacted;
      } else if (entry.value is String) {
        clean[entry.key] = scrubText(entry.value as String);
      } else {
        clean[entry.key] = entry.value;
      }
    }
    return clean;
  }
}
