import 'dart:async';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/security/vault_clipboard_service.dart';
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

/// Inactivity timeout after which an unlocked vault automatically locks and
/// clears in-memory cryptographic material.
final Provider<Duration> vaultInactivityTimeoutProvider =
    Provider<Duration>((ref) => const Duration(minutes: 5));

/// Provides the in-memory [VaultService] instance, automatically wiping keys
/// and passphrase bytes when disposed.
final Provider<VaultService> vaultServiceProvider = Provider<VaultService>(
  (ref) {
    final service = VaultService();
    ref.onDispose(service.lock);
    return service;
  },
);

/// Controls vault lock/unlock transitions, enforces inactivity auto-lock, and
/// clears in-memory secrets immediately whenever the user signs out.
class VaultSessionNotifier extends Notifier<VaultSessionState> {
  Timer? _inactivityTimer;

  @override
  VaultSessionState build() {
    final service = ref.watch(vaultServiceProvider);

    ref.listen<AuthUser?>(
      currentUserProvider,
      (previous, next) {
        if (next == null || (previous != null && previous.id != next.id)) {
          lock();
        }
      },
    );

    ref.onDispose(_cancelTimer);
    return VaultSessionState(isUnlocked: service.isUnlocked);
  }

  /// Unlocks the vault in memory using [passphrase] (verifying against
  /// [checkValue] when supplied) and starts the inactivity auto-lock timer.
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
      final nowUnlocked = service.isUnlocked;
      state = VaultSessionState(isUnlocked: nowUnlocked);
      if (nowUnlocked) {
        _resetInactivityTimer();
      } else {
        _cancelTimer();
      }
    }
    return unlocked;
  }

  /// Resets the inactivity auto-lock timer while the vault is unlocked.
  void recordActivity() {
    if (!state.isUnlocked) return;
    _resetInactivityTimer();
  }

  /// Immediately wipes in-memory passphrase bytes, derived keys, and managed
  /// clipboard credentials.
  void lock() {
    _cancelTimer();
    ref.read(vaultServiceProvider).lock();
    unawaited(ref.read(vaultClipboardServiceProvider).clearIfManaged());
    state = const VaultSessionState(isUnlocked: false);
  }

  void _resetInactivityTimer() {
    _cancelTimer();
    final timeout = ref.read(vaultInactivityTimeoutProvider);
    if (timeout <= Duration.zero) return;
    _inactivityTimer = Timer(timeout, () {
      if (ref.mounted) {
        lock();
      }
    });
  }

  void _cancelTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }
}

/// Reactive provider exposing vault lock status synchronized with auth state
/// and inactivity auto-lock.
final NotifierProvider<VaultSessionNotifier, VaultSessionState>
    vaultSessionProvider =
    NotifierProvider<VaultSessionNotifier, VaultSessionState>(
  VaultSessionNotifier.new,
);
