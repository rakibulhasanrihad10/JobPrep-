import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/features/vault/data/mappers/portal_account_mapper.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/domain/errors/vault_feature_failure.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

/// In-memory fake [PortalAccountRepository] recording raw persisted payloads
/// so tests can assert the database layer only ever receives ciphertext.
class FakePortalAccountRepository implements PortalAccountRepository {
  /// Creates a [FakePortalAccountRepository].
  FakePortalAccountRepository({
    VaultPayload? initialVerifier,
    List<PortalAccount> initialAccounts = const [],
    this.defaultUserId = 'user-1',
    DateTime Function()? clock,
  })  : _verifier = initialVerifier,
        _accounts = List<PortalAccount>.of(initialAccounts),
        _clock = clock ?? (() => DateTime.utc(2026, 11, 11, 13));

  VaultPayload? _verifier;
  final List<PortalAccount> _accounts;
  final String defaultUserId;
  final DateTime Function() _clock;
  int _nextId = 1;

  /// Optional failure injected on the next read or write.
  VaultFeatureFailure? nextError;

  /// Wire-format JSON payloads passed to insert/update/verifier methods.
  final List<Map<String, dynamic>> wirePayloads = <Map<String, dynamic>>[];

  /// Current stored verifier.
  VaultPayload? get verifier => _verifier;

  /// Current stored encrypted accounts.
  List<PortalAccount> get accounts => List.unmodifiable(_accounts);

  @override
  Future<VaultPayload?> getVerifier() async {
    _consumeError();
    return _verifier;
  }

  @override
  Future<VaultPayload> saveVerifier(VaultPayload verifier) async {
    _consumeError();
    wirePayloads.add(
      PortalAccountMapper.verifierToUpsertJson(
        userId: defaultUserId,
        verifier: verifier,
      ),
    );
    return _verifier = verifier;
  }

  @override
  Future<List<PortalAccount>> getAccountsForCircular(String circularId) async {
    _consumeError();
    return List<PortalAccount>.unmodifiable(
      _accounts.where((a) => a.circularId == circularId),
    );
  }

  @override
  Future<PortalAccount> createAccount(PortalAccount account) async {
    _consumeError();
    wirePayloads.add(
      PortalAccountMapper.toInsertJson(account, userId: defaultUserId),
    );
    final now = _clock().toUtc();
    final created = account.copyWith(
      id: account.id.trim().isEmpty ? 'pa-${_nextId++}' : account.id.trim(),
      userId: account.userId.trim().isEmpty ? defaultUserId : account.userId,
      createdAt: account.createdAt ?? now,
      updatedAt: now,
    );
    _accounts.add(created);
    return created;
  }

  @override
  Future<PortalAccount> updateAccount(PortalAccount account) async {
    _consumeError();
    wirePayloads.add(PortalAccountMapper.toUpdateJson(account));
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index < 0) throw const VaultNotFoundFailure();
    final updated = account.copyWith(updatedAt: _clock().toUtc());
    _accounts[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteAccount(String id) async {
    _consumeError();
    _accounts.removeWhere((a) => a.id == id);
  }

  void _consumeError() {
    final failure = nextError;
    if (failure != null) {
      nextError = null;
      throw failure;
    }
  }
}
