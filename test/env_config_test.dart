import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/config/env_config.dart';

void main() {
  group('EnvConfig & AppEnvironment', () {
    test('AppEnvironment.fromString correctly parses environments', () {
      expect(AppEnvironment.fromString('dev'), equals(AppEnvironment.dev));
      expect(
        AppEnvironment.fromString('development'),
        equals(AppEnvironment.dev),
      );
      expect(
        AppEnvironment.fromString('staging'),
        equals(AppEnvironment.staging),
      );
      expect(
        AppEnvironment.fromString('stage'),
        equals(AppEnvironment.staging),
      );
      expect(AppEnvironment.fromString('prod'), equals(AppEnvironment.prod));
      expect(
        AppEnvironment.fromString('production'),
        equals(AppEnvironment.prod),
      );
      expect(AppEnvironment.fromString('unknown'), equals(AppEnvironment.dev));
    });

    test(
      'EnvConfig has default environment and empty credentials when unpassed',
      () {
        expect(EnvConfig.environment, equals(AppEnvironment.dev));
        expect(EnvConfig.isDev, isTrue);
        expect(EnvConfig.isStaging, isFalse);
        expect(EnvConfig.isProd, isFalse);
        expect(EnvConfig.supabaseUrl, isEmpty);
        expect(EnvConfig.supabaseAnonKey, isEmpty);
        expect(EnvConfig.isSupabaseConfigured, isFalse);
      },
    );
  });
}
