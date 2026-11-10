import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:job_prep/features/auth/data/repositories/unconfigured_auth_repository.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/domain/repositories/auth_repository.dart';

/// Dependency-injected [AuthRepository] provider.
///
/// Override this provider in tests with a fake [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredAuthRepository();
  }
  return SupabaseAuthRepository(client);
});

/// Manages reactive authentication session state backed by
/// [AuthRepository.onSessionStateChange], including `passwordRecovery` events.
class AuthSessionNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() {
    final repository = ref.watch(authRepositoryProvider);

    final subscription = repository.onSessionStateChange.listen(
      (nextState) {
        state = nextState;
      },
      onError: (Object error, StackTrace stackTrace) {
        // Keep the existing session state on transient background refresh
        // network errors; unrecoverable expirations emit an explicit sign-out.
      },
    );

    ref.onDispose(subscription.cancel);
    return repository.currentSession;
  }
}

/// Provides the live [AuthSessionState] across the application.
final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);

/// Convenience provider exposing the current signed-in [AuthUser], if any.
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authSessionProvider).user;
});
