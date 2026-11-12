import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/features/vault/data/mappers/portal_account_mapper.dart';
import 'package:job_prep/features/vault/data/mappers/vault_error_mapper.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/domain/errors/vault_feature_failure.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase PostgREST implementation of [PortalAccountRepository].
///
/// Reads and stores only client-encrypted password blobs (`encrypted_password`,
/// `salt`, `nonce`, `iterations`) and zero-knowledge check verifiers.
class SupabasePortalAccountRepository implements PortalAccountRepository {
  /// Creates a [SupabasePortalAccountRepository].
  const SupabasePortalAccountRepository(this._client);

  static const String _verifiersTable = 'vault_verifiers';
  static const String _accountsTable = 'portal_accounts';

  final supabase.SupabaseClient _client;

  @override
  Future<VaultPayload?> getVerifier() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return null;
    }

    try {
      final row = await _client
          .from(_verifiersTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) return null;
      return PortalAccountMapper.verifierFromJson(row);
    } on Object catch (error) {
      throw VaultErrorMapper.map(error);
    }
  }

  @override
  Future<VaultPayload> saveVerifier(VaultPayload verifier) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      throw const VaultPermissionFailure(code: 'unauthenticated');
    }

    try {
      final payload = PortalAccountMapper.verifierToUpsertJson(
        userId: userId,
        verifier: verifier,
      );
      final row = await _client
          .from(_verifiersTable)
          .upsert(payload, onConflict: 'user_id')
          .select()
          .single();

      return PortalAccountMapper.verifierFromJson(row);
    } on Object catch (error) {
      throw VaultErrorMapper.map(error);
    }
  }

  @override
  Future<List<PortalAccount>> getAccountsForCircular(String circularId) async {
    final trimmedId = circularId.trim();
    if (trimmedId.isEmpty) return const [];

    try {
      final rows = await _client
          .from(_accountsTable)
          .select()
          .eq('circular_id', trimmedId)
          .order('created_at', ascending: true);

      return List<PortalAccount>.unmodifiable(
        rows.map(PortalAccountMapper.fromJson),
      );
    } on Object catch (error) {
      throw VaultErrorMapper.map(error);
    }
  }

  @override
  Future<PortalAccount> createAccount(PortalAccount account) async {
    _validateCipherAccount(account);

    try {
      final currentUserId = _client.auth.currentUser?.id;
      final payload = PortalAccountMapper.toInsertJson(
        account,
        userId: account.userId.trim().isEmpty ? currentUserId : null,
      );
      final row =
          await _client.from(_accountsTable).insert(payload).select().single();
      return PortalAccountMapper.fromJson(row);
    } on Object catch (error) {
      throw VaultErrorMapper.map(error);
    }
  }

  @override
  Future<PortalAccount> updateAccount(PortalAccount account) async {
    if (account.id.trim().isEmpty) {
      throw const VaultValidationFailure(
        message: 'Portal account ID is required when updating.',
        code: 'missing_id',
      );
    }
    _validateCipherAccount(account);

    try {
      final rows = await _client
          .from(_accountsTable)
          .update(PortalAccountMapper.toUpdateJson(account))
          .eq('id', account.id.trim())
          .select();

      if (rows.isEmpty) {
        throw const VaultNotFoundFailure(code: 'not_found');
      }
      return PortalAccountMapper.fromJson(rows.first);
    } on Object catch (error) {
      throw VaultErrorMapper.map(error);
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const VaultValidationFailure(
        message: 'Portal account ID is required when deleting.',
        code: 'missing_id',
      );
    }

    try {
      await _client.from(_accountsTable).delete().eq('id', trimmedId);
    } on Object catch (error) {
      throw VaultErrorMapper.map(error);
    }
  }

  void _validateCipherAccount(PortalAccount account) {
    if (account.circularId.trim().isEmpty ||
        account.username.trim().isEmpty ||
        account.encryptedPassword.trim().isEmpty ||
        account.salt.trim().isEmpty ||
        account.nonce.trim().isEmpty) {
      throw const VaultValidationFailure(code: 'invalid_encrypted_account');
    }
  }
}
