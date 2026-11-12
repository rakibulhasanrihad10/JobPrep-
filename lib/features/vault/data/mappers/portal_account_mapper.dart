import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';

/// Serialization helpers for `public.portal_accounts` and
/// `public.vault_verifiers` rows.
abstract final class PortalAccountMapper {
  /// Converts a `vault_verifiers` row into a [VaultPayload].
  static VaultPayload verifierFromJson(Map<String, dynamic> json) {
    return VaultPayload(
      ciphertext: (json['check_ciphertext'] as String?) ?? '',
      salt: (json['check_salt'] as String?) ?? '',
      nonce: (json['check_nonce'] as String?) ?? '',
      iterations: (json['check_iterations'] as int?) ?? 210000,
    );
  }

  /// Builds an upsert payload for `public.vault_verifiers`.
  static Map<String, dynamic> verifierToUpsertJson({
    required String userId,
    required VaultPayload verifier,
  }) {
    return <String, dynamic>{
      'user_id': userId,
      'check_ciphertext': verifier.ciphertext,
      'check_salt': verifier.salt,
      'check_nonce': verifier.nonce,
      'check_iterations': verifier.iterations,
    };
  }

  /// Converts a `portal_accounts` row into an encrypted [PortalAccount].
  static PortalAccount fromJson(Map<String, dynamic> json) {
    return PortalAccount(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      circularId: (json['circular_id'] as String?) ?? '',
      portalUrl: json['portal_url'] as String?,
      username: (json['username'] as String?) ?? '',
      encryptedPassword: (json['encrypted_password'] as String?) ?? '',
      salt: (json['salt'] as String?) ?? '',
      nonce: (json['nonce'] as String?) ?? '',
      iterations: (json['iterations'] as int?) ?? 210000,
      notes: json['notes'] as String?,
      createdAt: _parseTimestamp(json['created_at']),
      updatedAt: _parseTimestamp(json['updated_at']),
    );
  }

  /// Builds an insert payload for `public.portal_accounts`.
  static Map<String, dynamic> toInsertJson(
    PortalAccount account, {
    String? userId,
  }) {
    final effectiveUserId = (userId ?? account.userId).trim();
    return <String, dynamic>{
      if (effectiveUserId.isNotEmpty) 'user_id': effectiveUserId,
      'circular_id': account.circularId,
      'portal_url': _trimToNull(account.portalUrl),
      'username': account.username.trim(),
      'encrypted_password': account.encryptedPassword,
      'salt': account.salt,
      'nonce': account.nonce,
      'iterations': account.iterations,
      'notes': _trimToNull(account.notes),
    };
  }

  /// Builds an update payload for `public.portal_accounts`.
  static Map<String, dynamic> toUpdateJson(PortalAccount account) {
    return <String, dynamic>{
      'portal_url': _trimToNull(account.portalUrl),
      'username': account.username.trim(),
      'encrypted_password': account.encryptedPassword,
      'salt': account.salt,
      'nonce': account.nonce,
      'iterations': account.iterations,
      'notes': _trimToNull(account.notes),
    };
  }

  static String? _trimToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _parseTimestamp(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim());
    }
    return null;
  }
}
