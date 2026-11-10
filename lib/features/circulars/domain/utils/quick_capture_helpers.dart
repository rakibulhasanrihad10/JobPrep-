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
