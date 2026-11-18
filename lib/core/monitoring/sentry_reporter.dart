import 'dart:async';

import 'package:job_prep/core/config/env_config.dart';
import 'package:job_prep/core/monitoring/sentry_sanitizer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Configures Sentry crash reporting for Web (and native targets) strictly from
/// runtime `--dart-define` flags without committing secrets or logging PII.
abstract final class SentryReporter {
  /// Builds sanitized Sentry options without initializing network transport.
  static void configureOptions(SentryFlutterOptions options) {
    options
      ..dsn = EnvConfig.sentryDsn.trim()
      ..environment = EnvConfig.sentryEnvironment
      ..release = 'jobprep@${EnvConfig.appVersion}'
      ..sendDefaultPii = false
      ..tracesSampleRate = EnvConfig.isProd ? 0.1 : 0.2
      ..attachStacktrace = true
      ..beforeSend = ((event, hint) => SentrySanitizer.scrubEvent(event))
      ..beforeBreadcrumb = ((breadcrumb, hint) => breadcrumb == null
          ? null
          : SentrySanitizer.scrubBreadcrumb(breadcrumb));
  }

  /// Runs [appRunner] under `SentryFlutter.init` when `SENTRY_DSN` is passed
  /// via `--dart-define`, or runs [appRunner] directly when unconfigured.
  static Future<void> runWithCrashReporting(
    FutureOr<void> Function() appRunner,
  ) async {
    if (!EnvConfig.isSentryConfigured) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      configureOptions,
      appRunner: appRunner,
    );
  }
}
