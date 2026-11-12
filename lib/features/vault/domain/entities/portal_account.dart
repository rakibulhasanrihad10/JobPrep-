import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/core/security/vault_models.dart';

/// Persisted portal login record stored in `public.portal_accounts`.
///
/// Only holds ciphertext (`encryptedPassword`, `salt`, `nonce`, `iterations`)
/// and public portal metadata; plaintext passwords never exist in this entity.
@immutable
class PortalAccount {
  /// Creates a [PortalAccount].
  const PortalAccount({
    required this.circularId,
    required this.username,
    required this.encryptedPassword,
    required this.salt,
    required this.nonce,
    this.iterations = 210000,
    this.id = '',
    this.userId = '',
    this.portalUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  /// Unique identifier (`portal_accounts.id`).
  final String id;

  /// Owner identifier (`portal_accounts.user_id`).
  final String userId;

  /// Parent circular identifier (`portal_accounts.circular_id`).
  final String circularId;

  /// Optional login portal URL.
  final String? portalUrl;

  /// Saved applicant/portal user ID or username.
  final String username;

  /// Base64-encoded AES-GCM ciphertext + auth tag.
  final String encryptedPassword;

  /// Base64-encoded PBKDF2 random salt.
  final String salt;

  /// Base64-encoded AES-GCM random nonce.
  final String nonce;

  /// PBKDF2-HMAC-SHA256 iteration count used for [encryptedPassword].
  final int iterations;

  /// Optional notes about recovery questions or portal steps.
  final String? notes;

  /// Creation timestamp managed by PostgreSQL.
  final DateTime? createdAt;

  /// Last update timestamp managed by PostgreSQL.
  final DateTime? updatedAt;

  /// Converts persisted cryptographic fields into a [VaultPayload].
  VaultPayload toVaultPayload() {
    return VaultPayload(
      ciphertext: encryptedPassword,
      salt: salt,
      nonce: nonce,
      iterations: iterations,
    );
  }

  /// Returns a copy with specified fields overridden.
  PortalAccount copyWith({
    String? id,
    String? userId,
    String? circularId,
    Object? portalUrl = _unset,
    String? username,
    String? encryptedPassword,
    String? salt,
    String? nonce,
    int? iterations,
    Object? notes = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) {
    return PortalAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      circularId: circularId ?? this.circularId,
      portalUrl:
          identical(portalUrl, _unset) ? this.portalUrl : portalUrl as String?,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      salt: salt ?? this.salt,
      nonce: nonce ?? this.nonce,
      iterations: iterations ?? this.iterations,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortalAccount &&
        other.id == id &&
        other.userId == userId &&
        other.circularId == circularId &&
        other.portalUrl == portalUrl &&
        other.username == username &&
        other.encryptedPassword == encryptedPassword &&
        other.salt == salt &&
        other.nonce == nonce &&
        other.iterations == iterations &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        circularId,
        portalUrl,
        username,
        encryptedPassword,
        salt,
        nonce,
        iterations,
        notes,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'PortalAccount(id: $id, circularId: $circularId, <redacted>)';
}

/// Ephemeral form submission input before client-side encryption.
///
/// Never passed directly to any repository or logger.
@immutable
class PortalAccountDraft {
  /// Creates a [PortalAccountDraft].
  const PortalAccountDraft({
    required this.circularId,
    required this.username,
    required this.password,
    this.id,
    this.portalUrl,
    this.notes,
  });

  /// Existing account ID when editing, or `null` when creating new.
  final String? id;

  /// Target circular identifier.
  final String circularId;

  /// Optional portal URL.
  final String? portalUrl;

  /// User ID or login identifier.
  final String username;

  /// Plaintext password entered prior to client-side AES-GCM encryption.
  final String password;

  /// Optional notes.
  final String? notes;

  @override
  String toString() =>
      'PortalAccountDraft(id: $id, circularId: $circularId, <redacted>)';
}

/// Ephemeral in-memory decrypted view shown only while the vault is unlocked.
@immutable
class DecryptedPortalAccount {
  /// Creates a [DecryptedPortalAccount].
  const DecryptedPortalAccount({
    required this.account,
    required this.password,
  });

  /// Backing encrypted account metadata.
  final PortalAccount account;

  /// Decrypted password held strictly in memory while vault is unlocked.
  final String password;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DecryptedPortalAccount &&
            other.account == account &&
            other.password == password);
  }

  @override
  int get hashCode => Object.hash(account, password);

  @override
  String toString() => 'DecryptedPortalAccount(id: ${account.id}, <redacted>)';
}
