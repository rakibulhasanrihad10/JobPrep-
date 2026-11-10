import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Signature for launching external HTTP/HTTPS URLs from circular details.
typedef CircularUrlLauncher = Future<bool> Function(Uri uri);

/// Dependency-injected URL launcher callback so widget tests can intercept
/// outbound browser navigation cleanly.
final Provider<CircularUrlLauncher> circularUrlLauncherProvider =
    Provider<CircularUrlLauncher>((ref) {
  return (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
});
