import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/domain/errors/vault_feature_failure.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Local Drift SQLite implementation of [PortalAccountRepository].
///
/// Strictly handles ciphertext metadata only, ensuring plaintext credentials
/// are never persisted or exposed.
class LocalPortalAccountRepository implements PortalAccountRepository {
  /// Creates a [LocalPortalAccountRepository].
  LocalPortalAccountRepository(this._db, [this._prefs]);

  final AppDatabase _db;
  final SharedPreferences? _prefs;

  static const String _verifierKey = 'local_vault_verifier';
  VaultPayload? _memoryVerifier;

  @override
  Future<VaultPayload?> getVerifier() async {
    final prefs = _prefs;
    if (prefs != null) {
      final raw = prefs.getString(_verifierKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          return VaultPayload.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          );
        } on Object catch (_) {}
      }
    }
    return _memoryVerifier;
  }

  @override
  Future<VaultPayload> saveVerifier(VaultPayload verifier) async {
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_verifierKey, jsonEncode(verifier.toJson()));
    }
    _memoryVerifier = verifier;
    return verifier;
  }

  @override
  Future<List<PortalAccount>> getAllAccounts() async {
    final query = _db.select(_db.localPortalAccounts)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<List<PortalAccount>> getAccountsForCircular(String circularId) async {
    final trimmedId = circularId.trim();
    if (trimmedId.isEmpty) return const [];

    final query = _db.select(_db.localPortalAccounts)
      ..where((t) => t.circularId.equals(trimmedId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    final rows = await query.get();
    return List.unmodifiable(rows.map(_mapRow));
  }

  @override
  Future<PortalAccount> createAccount(PortalAccount account) async {
    _validateCipherAccount(account);

    final id =
        account.id.trim().isEmpty ? const Uuid().v4() : account.id.trim();
    final now = DateTime.now().toUtc();
    final entry = _toCompanion(account, id: id, now: now);

    await _db.into(_db.localPortalAccounts).insertOnConflictUpdate(entry);
    return account.copyWith(
      id: id,
      createdAt: account.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Future<PortalAccount> updateAccount(PortalAccount account) async {
    final trimmedId = account.id.trim();
    if (trimmedId.isEmpty) {
      throw const VaultValidationFailure(
        code: 'missing_id',
        message: 'Portal account ID is required when updating.',
      );
    }
    _validateCipherAccount(account);

    final existing = await (_db.select(_db.localPortalAccounts)
          ..where((t) => t.id.equals(trimmedId)))
        .getSingleOrNull();
    if (existing == null) {
      throw const VaultNotFoundFailure(code: 'not_found');
    }

    final now = DateTime.now().toUtc();
    final entry = _toCompanion(
      account,
      id: trimmedId,
      now: now,
      createdAt: existing.createdAt,
    );

    await _db.update(_db.localPortalAccounts).replace(entry);
    return account.copyWith(
      id: trimmedId,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const VaultValidationFailure(
        code: 'missing_id',
        message: 'Portal account ID is required when deleting.',
      );
    }

    await (_db.delete(_db.localPortalAccounts)
          ..where((t) => t.id.equals(trimmedId)))
        .go();
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

  LocalPortalAccountsCompanion _toCompanion(
    PortalAccount a, {
    required String id,
    required DateTime now,
    DateTime? createdAt,
  }) {
    return LocalPortalAccountsCompanion(
      id: Value(id),
      circularId: Value(a.circularId.trim()),
      portalUrl: Value(a.portalUrl?.trim()),
      username: Value(a.username.trim()),
      encryptedPassword: Value(a.encryptedPassword.trim()),
      salt: Value(a.salt.trim()),
      nonce: Value(a.nonce.trim()),
      iterations: Value(a.iterations <= 0 ? 210000 : a.iterations),
      notes: Value(a.notes?.trim()),
      createdAt: Value(a.createdAt ?? createdAt ?? now),
      updatedAt: Value(now),
    );
  }

  PortalAccount _mapRow(LocalPortalAccount row) {
    return PortalAccount(
      id: row.id,
      circularId: row.circularId,
      portalUrl: row.portalUrl,
      username: row.username,
      encryptedPassword: row.encryptedPassword,
      salt: row.salt,
      nonce: row.nonce,
      iterations: row.iterations,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
