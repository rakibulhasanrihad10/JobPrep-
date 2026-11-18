import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';

/// Validation errors for the required link input in Quick Capture.
enum QuickCaptureLinkValidationError {
  required,
  invalidFormat,
}

/// Validates the required HTTP/HTTPS [url] entered during Quick Capture.
QuickCaptureLinkValidationError? validateRequiredCircularLink(String? url) {
  final trimmed = url?.trim() ?? '';
  if (trimmed.isEmpty) {
    return QuickCaptureLinkValidationError.required;
  }
  if (CircularFormValidators.validateOptionalUrl(trimmed) != null) {
    return QuickCaptureLinkValidationError.invalidFormat;
  }
  return null;
}

/// Derives a clean, non-empty fallback circular title from [rawUrl] when the
/// user saves from Quick Capture with only a link.
String deriveTitleFromCircularUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return '';

  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.host.trim().isNotEmpty) {
    var host = uri.host.trim().toLowerCase();
    if (host.startsWith('www.') && host.length > 4) {
      host = host.substring(4);
    }
    return host;
  }
  return trimmed;
}

/// Extracts an incoming link passed in [uri] via `?capture=...` (or `?url=...`
/// on `/capture`) so browser bookmarklets and iOS Shortcuts can trigger Quick
/// Capture automatically.
String? extractCaptureLinkFromUri(Uri uri) {
  final direct = uri.queryParameters['capture']?.trim();
  if (direct != null && direct.isNotEmpty) {
    return direct;
  }

  final normalizedPath = uri.path.endsWith('/') && uri.path.length > 1
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;
  if (normalizedPath == '/capture') {
    final fallbackUrl = uri.queryParameters['url']?.trim();
    if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
      return fallbackUrl;
    }
  }
  return null;
}

/// Removes capture query parameters (`capture` and `/capture`'s `url`) from
/// [uri] while leaving all other path segments and query parameters intact.
Uri stripCaptureQueryParams(Uri uri) {
  final remaining = Map<String, String>.from(uri.queryParameters)
    ..remove('capture');

  final normalizedPath = uri.path.endsWith('/') && uri.path.length > 1
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;
  if (normalizedPath == '/capture') {
    remaining.remove('url');
  }

  return Uri(
    scheme: uri.hasScheme ? uri.scheme : null,
    userInfo: uri.userInfo.isEmpty ? null : uri.userInfo,
    host: uri.hasAuthority ? uri.host : null,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
    queryParameters: remaining.isEmpty ? null : remaining,
    fragment: uri.hasFragment ? uri.fragment : null,
  );
}

/// Returns [targetPath] preserving any `capture` query link present in
/// [sourceUri] so auth redirects and root redirects do not drop deep links.
String buildLocationWithCapture(
  String targetPath, {
  required Uri sourceUri,
}) {
  final captureLink = extractCaptureLinkFromUri(sourceUri);
  if (captureLink == null) {
    return targetPath;
  }
  return Uri(
    path: targetPath,
    queryParameters: {'capture': captureLink},
  ).toString();
}

/// Regex matching HTTP and HTTPS URLs embedded within shared text or social
/// posts.
final _embeddedUrlRegex = RegExp(
  r'https?:\/\/[^\s<>"{}|\\^`]+',
  caseSensitive: false,
);

/// Extracts the first valid HTTP or HTTPS URL from [sharedText] (such as a
/// shared Facebook post, social media share, or browser URL), stripping
/// trailing punctuation. Returns `null` if no URL is identified.
String? extractUrlFromSharedText(String? sharedText) {
  if (sharedText == null) return null;
  final trimmed = sharedText.trim();
  if (trimmed.isEmpty) return null;

  final match = _embeddedUrlRegex.firstMatch(trimmed);
  if (match != null) {
    var url = match.group(0)!;
    // Strip trailing punctuation frequently attached to URLs in social posts
    while (url.isNotEmpty &&
        (url.endsWith('.') ||
            url.endsWith(',') ||
            url.endsWith(')') ||
            url.endsWith(']') ||
            url.endsWith(';') ||
            url.endsWith(':') ||
            url.endsWith('!'))) {
      url = url.substring(0, url.length - 1);
    }
    return url.isNotEmpty ? url : null;
  }

  // Fallback: check if the trimmed string itself is a valid absolute URI
  final parsed = Uri.tryParse(trimmed);
  if (parsed != null &&
      parsed.hasScheme &&
      (parsed.scheme == 'http' || parsed.scheme == 'https') &&
      parsed.hasAuthority) {
    return trimmed;
  }
  return null;
}
