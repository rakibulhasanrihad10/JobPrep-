import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/config/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for [SupabaseClient] injected via Riverpod.
///
/// In tests, this provider can be overridden in [ProviderScope] with a mock
/// or fake client without requiring an active Supabase backend.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!EnvConfig.isSupabaseConfigured) {
    throw StateError(
      'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY '
      'via --dart-define or override supabaseClientProvider in ProviderScope.',
    );
  }
  return Supabase.instance.client;
});
