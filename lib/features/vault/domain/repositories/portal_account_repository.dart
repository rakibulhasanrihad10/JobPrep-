import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';

/// Persistence contract for encrypted portal accounts and passphrase check
/// verifiers.
///
/// Methods strictly accept and return ciphertext metadata ([PortalAccount] and
/// [VaultPayload]) and never touch plaintext passphrases or passwords.
abstract interface class PortalAccountRepository {
  /// Fetches the active user's encrypted passphrase check value, or `null`
  /// when the user has not set up a vault passphrase yet.
  Future<VaultPayload?> getVerifier();

  /// Persists the encrypted passphrase check value for the active user.
  Future<VaultPayload> saveVerifier(VaultPayload verifier);

  /// Lists all encrypted portal accounts attached to [circularId].
  Future<List<PortalAccount>> getAccountsForCircular(String circularId);

  /// Persists a newly encrypted [PortalAccount].
  Future<PortalAccount> createAccount(PortalAccount account);

  /// Updates an existing encrypted [PortalAccount].
  Future<PortalAccount> updateAccount(PortalAccount account);

  /// Deletes a portal account matching [id].
  Future<void> deleteAccount(String id);
}
