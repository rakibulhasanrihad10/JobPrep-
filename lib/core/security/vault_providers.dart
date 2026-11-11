import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/core/security/vault_service.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';

/// Immutable session state reflecting whether the in-memory vault is unlocked.
@immutable
class VaultSessionState {
  /// Creates a [VaultSessionState].
  const VaultSessionState({
    required this.isUnlocked,
  });

  /// Whether [VaultService] currently holds a passphrase/keys in memory.
  final bool isUnlocked;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VaultSessionState && other.isUnlocked == isUnlocked);
  }

  @override
  int get hashCode => isUnlocked.hashCode;
}

/// Provides the in-memory [VaultService] instance, automatically wiping keys
/// and passphrase bytes when disposed.
final Provider<VaultService> vaultServiceProvider = Provider<VaultService>(
  (ref) {
    final service = VaultService();
    ref.onDispose(service.lock);
    return service;
  },
);

/// Controls vault lock/unlock transitions and clears all in-memory cryptographic
/// material immediately whenever the user signs out or switches accounts.
class VaultSessionNotifier extends Notifier<VaultSessionState> {
  @override
  VaultSessionState build() {
    final service = ref.watch(vaultServiceProvider);

    ref.listen<AuthUser?>(
      currentUserProvider,
      (previous, next) {
        if (next == null || (previous != null && previous.id != next.id)) {
          service.lock();
          state = const VaultSessionState(isUnlocked: false);
        }
      },
    );

    return VaultSessionState(isUnlocked: service.isUnlocked);
  }

  /// Unlocks the vault in memory using [passphrase] (verifying against
  /// [checkValue] when supplied).
  Future<bool> unlock({
    required String passphrase,
    VaultPayload? checkValue,
  }) async {
    final service = ref.read(vaultServiceProvider);
    final unlocked = await service.unlock(
      passphrase: passphrase,
      checkValue: checkValue,
    );
    if (ref.mounted) {
      state = VaultSessionState(isUnlocked: service.isUnlocked);
    }
    return unlocked;
  }

  /// Immediately wipes in-memory passphrase bytes and derived encryption keys.
  void lock() {
    ref.read(vaultServiceProvider).lock();
    state = const VaultSessionState(isUnlocked: false);
  }
}

/// Reactive provider exposing vault lock status synchronized with auth state.
final NotifierProvider<VaultSessionNotifier, VaultSessionState>
    vaultSessionProvider =
    NotifierProvider<VaultSessionNotifier, VaultSessionState>(
  VaultSessionNotifier.new,
);
