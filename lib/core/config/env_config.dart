/// Supported runtime environments.
enum AppEnvironment {
  /// Development environment.
  dev,

  /// Staging / Pre-production environment.
  staging,

  /// Production environment.
  prod;

  /// Parses a string value into an [AppEnvironment].
  static AppEnvironment fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }
}

/// Central application environment configuration populated via `--dart-define`.
abstract final class EnvConfig {
  static const String _rawEnv = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// The active [AppEnvironment].
  static final AppEnvironment environment = AppEnvironment.fromString(_rawEnv);

  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  /// Supabase public anonymous key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Returns true if active environment is [AppEnvironment.dev].
  static bool get isDev => environment == AppEnvironment.dev;

  /// Returns true if active environment is [AppEnvironment.staging].
  static bool get isStaging => environment == AppEnvironment.staging;

  /// Returns true if active environment is [AppEnvironment.prod].
  static bool get isProd => environment == AppEnvironment.prod;

  /// Returns true if Supabase URL and Anon Key are configured.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
