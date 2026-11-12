import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/config/env_config.dart';
import 'package:job_prep/core/monitoring/sentry_reporter.dart';
import 'package:job_prep/core/monitoring/sentry_sanitizer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../scripts/release_notes_lib.dart';

void main() {
  group('Sentry Web Crash Reporting & Sanitizer', () {
    test('EnvConfig keeps SENTRY_DSN empty unless supplied via --dart-define',
        () {
      expect(EnvConfig.sentryDsn, isEmpty);
      expect(EnvConfig.isSentryConfigured, isFalse);
      expect(EnvConfig.sentryEnvironment, equals('dev'));
    });

    test('SentryReporter.configureOptions enforces sendDefaultPii = false', () {
      final options = SentryFlutterOptions();
      SentryReporter.configureOptions(options);
      expect(options.sendDefaultPii, isFalse);
      expect(options.beforeSend, isNotNull);
      expect(options.beforeBreadcrumb, isNotNull);
    });

    test('SentrySanitizer strips user PII, tokens, emails, and query secrets',
        () {
      final event = SentryEvent(
        user: SentryUser(
          id: 'u-1',
          email: 'aspirant@example.com',
          username: 'rakib',
          ipAddress: '203.0.113.10',
        ),
        message: SentryMessage(
          'Auth failed for user@example.com with token '
          'eyJhbGciOiJIUzI1NiIs.eyJzdWIiOiIxMjMifQ.sig1234',
        ),
        request: SentryRequest(
          url: 'https://api.example.com/auth?access_token=secret123#frag',
          method: 'POST',
          queryString: 'access_token=secret123',
          cookies: 'session=abc',
          headers: {
            'Authorization': 'Bearer super-secret',
            'Content-Type': 'application/json',
          },
        ),
        breadcrumbs: [
          Breadcrumb(
            message: 'Opened https://site.test/reset?token=xyz999',
            data: {
              'vaultPassphrase': 'my-secret-passphrase',
              'route': '/today',
            },
          ),
        ],
        exceptions: [
          SentryException(
            type: 'AuthException',
            value: 'Rejected aspirant@example.com at ?apikey=live_key',
          ),
        ],
      );

      final scrubbed = SentrySanitizer.scrubEvent(event);

      expect(scrubbed.user, isNull);
      expect(scrubbed.message?.formatted, isNot(contains('user@example.com')));
      expect(scrubbed.message?.formatted, isNot(contains('eyJhbGci')));
      expect(scrubbed.message?.formatted, contains('[REDACTED]'));
      expect(
        scrubbed.request?.url,
        equals('https://api.example.com/auth'),
      );
      expect(scrubbed.request?.queryString, equals('[REDACTED]'));
      expect(scrubbed.request?.cookies, equals('[REDACTED]'));
      expect(
        scrubbed.request?.headers['Authorization'],
        equals('[REDACTED]'),
      );
      expect(
        scrubbed.request?.headers['Content-Type'],
        equals('application/json'),
      );
      expect(
        scrubbed.breadcrumbs?.first.message,
        contains('[REDACTED]'),
      );
      expect(
        scrubbed.breadcrumbs?.first.data?['vaultPassphrase'],
        equals('[REDACTED]'),
      );
      expect(
        scrubbed.breadcrumbs?.first.data?['route'],
        equals('/today'),
      );
      expect(
        scrubbed.exceptions?.first.value,
        isNot(contains('aspirant@example.com')),
      );
      expect(
        scrubbed.exceptions?.first.value,
        isNot(contains('live_key')),
      );
    });
  });

  group('Release Notes & Changelog Generator', () {
    test('parseConventionalCommits categorizes scopes and breaking flags', () {
      final parsed = parseConventionalCommits([
        'abc1234\tfeat(settings): add data export',
        'def5678\tfix(timer): restore session after reload',
        '111aaaa\tperf(pwa)!: switch release build to wasm',
        '222bbbb\tdocs: update RELEASING guide',
      ]);

      expect(parsed, hasLength(4));
      expect(parsed[0].type, equals('feat'));
      expect(parsed[0].scope, equals('settings'));
      expect(parsed[1].type, equals('fix'));
      expect(parsed[2].isBreaking, isTrue);
      expect(parsed[3].scope, isNull);
    });

    test('extractChangelogSection reads exact version or falls back cleanly',
        () {
      const sample = '''
# Changelog

## [Unreleased]
- Unreleased item

## [1.2.0] - 2026-11-12
- Released feature
''';

      expect(
        extractChangelogSection(sample, 'v1.2.0'),
        equals('- Released feature'),
      );
      expect(
        extractChangelogSection(sample, 'v9.9.9'),
        equals('- Unreleased item'),
      );
    });

    test('renderReleaseNotes combines changelog highlights and grouped commits',
        () {
      final notes = renderReleaseNotes(
        tag: 'v1.2.0',
        previousTag: 'v1.1.0',
        changelogSection: '### Added\n- Settings screen',
        repositorySlug: 'owner/jobprep',
        commits: parseConventionalCommits([
          'a1b2c3d\tfeat(today): prioritize overdue revision items',
          'd4e5f6a\tfix(vault): preserve salt on passphrase rotation',
        ]),
      );

      expect(notes, contains('# JobPrep v1.2.0'));
      expect(notes, contains('## Changelog Highlights'));
      expect(notes, contains('## Features'));
      expect(notes, contains('**today:** prioritize overdue revision items'));
      expect(notes, contains('## Bug Fixes'));
      expect(
        notes,
        contains('https://github.com/owner/jobprep/compare/v1.1.0...v1.2.0'),
      );
    });
  });

  group('Phase 7C CI/CD Workflows, Rollback Docs & Dependabot', () {
    test('staging, release, dependabot, and rollback docs exist cleanly', () {
      final staging =
          File('.github/workflows/deploy-staging.yml').readAsStringSync();
      expect(staging, contains('branches:\n      - develop'));
      expect(staging, contains('--dart-define=ENVIRONMENT=staging'));
      expect(staging, contains('secrets.STAGING_SUPABASE_URL'));
      expect(staging, contains('secrets.SENTRY_DSN'));
      expect(staging, contains('cloudflare/wrangler-action@v3'));

      final release = File('.github/workflows/release.yml').readAsStringSync();
      expect(release, contains("tags:\n      - 'v*.*.*'"));
      expect(release, contains('git merge-base --is-ancestor'));
      expect(release, contains('supabase db push'));
      expect(release, contains('--dart-define=ENVIRONMENT=prod'));
      expect(release, contains('generate_release_notes.dart'));
      expect(release, contains('softprops/action-gh-release@v2'));
      expect(release, contains('skip_migrations'));

      final dependabot = File('.github/dependabot.yml').readAsStringSync();
      expect(dependabot, contains('package-ecosystem: "pub"'));
      expect(dependabot, contains('package-ecosystem: "github-actions"'));
      expect(dependabot, contains('interval: "weekly"'));
      expect(dependabot, contains('target-branch: "develop"'));

      final releasing = File('RELEASING.md').readAsStringSync();
      expect(releasing, contains('Roll Back the Web App'));
      expect(releasing, contains('Revert a Bad Database Migration Safely'));
      expect(File('CHANGELOG.md').existsSync(), isTrue);
    });
  });
}
