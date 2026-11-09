import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quality Gate 1: Conventional Commits Validation', () {
    final commitPattern = RegExp(
      '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)'
      r'(\([a-zA-Z0-9_\-\.\/]+\))?!?: [A-Za-z0-9].+',
    );

    test('accepts valid conventional commit messages', () {
      const validMessages = [
        'feat: add email password auth',
        'feat(auth): add google sign in',
        'fix: resolve progress ring overflow',
        'fix(vault): fix aes encryption key derivation',
        'docs: add AGENTS.md',
        'docs(readme): update getting started instructions',
        'style: format code with dart format',
        'refactor: extract glass card widget to shared',
        'refactor(core): split large theme extension',
        'perf: optimize progress re-render',
        'test: add weighted progress test',
        'test(math): add test for 300 300 400 page ratio',
        'build: update flutter sdk dependency constraint',
        'ci: add github actions quality gate workflow',
        'chore: scaffold repository foundations for Phase 0A',
        'chore(deps): bump very_good_analysis from 6.0.0 to 11.0.0',
        'feat!: breaking change in repository interface',
        'fix(db)!: change user_id foreign key constraint',
      ];

      for (final msg in validMessages) {
        expect(
          commitPattern.hasMatch(msg),
          isTrue,
          reason: 'Expected "$msg" to be a valid Conventional Commit',
        );
      }
    });

    test('rejects non-conventional or invalid commit messages', () {
      const invalidMessages = [
        'fixed stuff',
        'WIP',
        'WIP: working on circular tracker',
        'Update main.dart',
        'Added new feature',
        'feat without colon',
        'feat: ',
        'feat(): empty scope',
        'UNKNOWN(scope): unknown type',
        'FEAT: uppercase type not allowed',
        'fix:   multiple spaces after colon',
        'bad_prefix: something',
      ];

      for (final msg in invalidMessages) {
        expect(
          commitPattern.hasMatch(msg),
          isFalse,
          reason: 'Expected "$msg" to be rejected as invalid commit message',
        );
      }
    });
  });

  group('Quality Gate 2: Static Analysis & Strict Lints Configuration', () {
    test('analysis_options.yaml enforces strict type safety and lints', () {
      final file = File('analysis_options.yaml');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'analysis_options.yaml must exist',
      );

      final content = file.readAsStringSync();
      expect(
        content,
        contains('package:very_good_analysis/analysis_options.yaml'),
      );
      expect(content, contains('strict-casts: true'));
      expect(content, contains('strict-inference: true'));
      expect(content, contains('strict-raw-types: true'));
    });
  });

  group('Quality Gate 3: Git Hooks Configuration', () {
    test('.githooks/pre-commit contains all four required quality gates', () {
      final file = File('.githooks/pre-commit');
      expect(file.existsSync(), isTrue, reason: 'pre-commit hook must exist');

      final content = file.readAsStringSync();
      expect(content, contains('dart format'));
      expect(content, contains('dart analyze'));
      expect(content, contains('flutter test'));
      expect(content, contains('gitleaks'));
    });

    test('.githooks/commit-msg enforces Conventional Commits', () {
      final file = File('.githooks/commit-msg');
      expect(file.existsSync(), isTrue, reason: 'commit-msg hook must exist');

      final content = file.readAsStringSync();
      expect(content, contains('Conventional Commits'));
      expect(
        content,
        contains(
          'feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert',
        ),
      );
    });
  });

  group('Quality Gate 4: Secrets Detection Logic', () {
    test('detects high-risk patterns and secret markers', () {
      final secretPattern = RegExp(
        '(BEGIN PRIVATE KEY|service_role|supabase_service_role|'
        r'eyJh[a-zA-Z0-9_\-]{20,}\.[a-zA-Z0-9_\-]{20,})',
        caseSensitive: false,
      );

      const dummySecret =
          'SUPABASE_SERVICE_ROLE_KEY=eyJhbgciOiJIUzI1NiIsInR5cCI6Ikp'
          'XVCJ9.dummysecret1234567890';
      const dummyPrivateKey =
          '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASC';

      expect(secretPattern.hasMatch(dummySecret), isTrue);
      expect(secretPattern.hasMatch(dummyPrivateKey), isTrue);

      const benignContent =
          'final anonKey = const String.fromEnvironment("SUPABASE_ANON_KEY");';
      expect(secretPattern.hasMatch(benignContent), isFalse);
    });
  });

  group('Quality Gate 5: GitHub Actions CI Workflow', () {
    test(
      '.github/workflows/ci.yml defines complete CI quality gates and build',
      () {
        final file = File('.github/workflows/ci.yml');
        expect(file.existsSync(), isTrue, reason: 'ci.yml must exist');

        final content = file.readAsStringSync();
        expect(content, contains('name: CI'));
        expect(content, contains('actions/checkout@v4'));
        expect(content, contains('gitleaks/gitleaks-action@v2'));
        expect(content, contains('subosito/flutter-action@v2'));
        expect(content, contains('flutter pub get'));
        expect(
          content,
          contains('dart format --output=none --set-exit-if-changed .'),
        );
        expect(
          content,
          contains('flutter analyze --fatal-infos --fatal-warnings'),
        );
        expect(content, contains('flutter test'));
        expect(content, contains('flutter build web --release'));
      },
    );
  });
}
