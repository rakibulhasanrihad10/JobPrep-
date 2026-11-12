import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/domain/errors/vault_feature_failure.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

/// Safe fallback [PortalAccountRepository] used when Supabase environment keys
/// are not configured.
class UnconfiguredPortalAccountRepository implements PortalAccountRepository {
  /// Creates an [UnconfiguredPortalAccountRepository].
  const UnconfiguredPortalAccountRepository();

  static const _notConfiguredError = UnknownVaultFailure(
    code: 'supabase_not_configured',
    message: 'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_ANON_KEY via --dart-define.',
  );

  @override
  Future<VaultPayload?> getVerifier() async => null;

  @override
  Future<VaultPayload> saveVerifier(VaultPayload verifier) =>
      Future.error(_notConfiguredError);

  @override
  Future<List<PortalAccount>> getAccountsForCircular(String circularId) async =>
      const [];

  @override
  Future<PortalAccount> createAccount(PortalAccount account) =>
      Future.error(_notConfiguredError);

  @override
  Future<PortalAccount> updateAccount(PortalAccount account) =>
      Future.error(_notConfiguredError);

  @override
  Future<void> deleteAccount(String id) => Future.error(_notConfiguredError);
}
