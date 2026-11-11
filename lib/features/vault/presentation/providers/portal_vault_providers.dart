import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:job_prep/core/security/vault_clipboard_service.dart';
import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/core/security/vault_providers.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/vault/data/repositories/supabase_portal_account_repository.dart';
import 'package:job_prep/features/vault/data/repositories/unconfigured_portal_account_repository.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Dependency-injected [PortalAccountRepository] provider.
final Provider<PortalAccountRepository> portalAccountRepositoryProvider =
    Provider<PortalAccountRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredPortalAccountRepository();
  }
  return SupabasePortalAccountRepository(client);
});

/// Fetches the signed-in user's zero-knowledge vault verifier check value.
///
/// Returns `null` when the user has not set up a vault passphrase yet.
final FutureProvider<VaultPayload?> vaultVerifierProvider =
    FutureProvider<VaultPayload?>(
  (ref) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    return ref.watch(portalAccountRepositoryProvider).getVerifier();
  },
  retry: _noRetry,
);

/// Loads and decrypts portal accounts for `circularId` ONLY when the vault
/// is unlocked; returns an empty list immediately when locked.
final FutureProviderFamily<List<DecryptedPortalAccount>, String>
    circularPortalAccountsProvider =
    FutureProvider.family<List<DecryptedPortalAccount>, String>(
  (ref, circularId) async {
    final isUnlocked = ref.watch(
      vaultSessionProvider.select((session) => session.isUnlocked),
    );
    ref.watch(currentUserProvider.select((user) => user?.id));

    if (!isUnlocked || circularId.trim().isEmpty) {
      return const <DecryptedPortalAccount>[];
    }

    final repo = ref.watch(portalAccountRepositoryProvider);
    final vault = ref.read(vaultServiceProvider);
    final encryptedAccounts = await repo.getAccountsForCircular(circularId);

    final decrypted = <DecryptedPortalAccount>[];
    for (final account in encryptedAccounts) {
      final password = await vault.decrypt(account.toVaultPayload());
      decrypted.add(
        DecryptedPortalAccount(account: account, password: password),
      );
    }
    return List<DecryptedPortalAccount>.unmodifiable(decrypted);
  },
  retry: _noRetry,
);

/// Action orchestrator connecting VaultService, VaultSessionNotifier,
/// [VaultClipboardService], and [PortalAccountRepository].
class PortalVaultController extends Notifier<void> {
  @override
  void build() {}

  /// Sets up a first-time vault passphrase by encrypting a verification check
  /// value locally, persisting it, and unlocking the session in memory.
  Future<bool> setupPassphrase(String passphrase) async {
    final vault = ref.read(vaultServiceProvider);
    final repo = ref.read(portalAccountRepositoryProvider);

    final checkValue = await vault.createCheckValue(passphrase);
    final savedVerifier = await repo.saveVerifier(checkValue);
    final unlocked = await ref.read(vaultSessionProvider.notifier).unlock(
          passphrase: passphrase,
          checkValue: savedVerifier,
        );
    ref.invalidate(vaultVerifierProvider);
    return unlocked;
  }

  /// Verifies [passphrase] against the saved encrypted check value and
  /// unlocks the vault in memory.
  Future<bool> unlockWithPassphrase(String passphrase) async {
    final verifier = await ref.read(vaultVerifierProvider.future);
    if (verifier == null) return false;

    return await ref.read(vaultSessionProvider.notifier).unlock(
          passphrase: passphrase,
          checkValue: verifier,
        );
  }

  /// Immediately locks the vault, clearing passphrase, keys, and clipboard.
  void lockVault() {
    ref.read(vaultSessionProvider.notifier).lock();
  }

  /// Encrypts [draft] password client-side via VaultService before passing
  /// ciphertext metadata to [PortalAccountRepository].
  Future<PortalAccount> savePortalAccount(
    PortalAccountDraft draft, {
    PortalAccount? existing,
  }) async {
    ref.read(vaultSessionProvider.notifier).recordActivity();

    final vault = ref.read(vaultServiceProvider);
    final repo = ref.read(portalAccountRepositoryProvider);

    final payload = await vault.encrypt(draft.password);
    final cleanUrl = _normalizeOptionalText(draft.portalUrl);
    final cleanNotes = _normalizeOptionalText(draft.notes);

    final encryptedAccount = existing != null
        ? existing.copyWith(
            portalUrl: cleanUrl,
            username: draft.username.trim(),
            encryptedPassword: payload.ciphertext,
            salt: payload.salt,
            nonce: payload.nonce,
            iterations: payload.iterations,
            notes: cleanNotes,
          )
        : PortalAccount(
            circularId: draft.circularId,
            portalUrl: cleanUrl,
            username: draft.username.trim(),
            encryptedPassword: payload.ciphertext,
            salt: payload.salt,
            nonce: payload.nonce,
            iterations: payload.iterations,
            notes: cleanNotes,
          );

    final saved = existing != null
        ? await repo.updateAccount(encryptedAccount)
        : await repo.createAccount(encryptedAccount);

    ref.invalidate(circularPortalAccountsProvider(draft.circularId));
    return saved;
  }

  /// Deletes a portal account matching [id] from [circularId].
  Future<void> deletePortalAccount({
    required String id,
    required String circularId,
  }) async {
    ref.read(vaultSessionProvider.notifier).recordActivity();
    await ref.read(portalAccountRepositoryProvider).deleteAccount(id);
    ref.invalidate(circularPortalAccountsProvider(circularId));
  }

  /// Copies a portal user ID or decrypted password to the clipboard and
  /// schedules automatic clearing.
  Future<void> copySensitiveField(String value) async {
    ref.read(vaultSessionProvider.notifier).recordActivity();
    await ref.read(vaultClipboardServiceProvider).copySensitive(value);
  }

  static String? _normalizeOptionalText(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Provides [PortalVaultController] for setup, unlock, copy, and CRUD actions.
final NotifierProvider<PortalVaultController, void>
    portalVaultControllerProvider =
    NotifierProvider<PortalVaultController, void>(
  PortalVaultController.new,
);
