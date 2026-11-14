import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/core/security/vault_models.dart';
import 'package:job_prep/features/vault/data/repositories/local_portal_account_repository.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

void testVaultRepositoryContract({
  required Future<PortalAccountRepository> Function() createRepository,
  Future<void> Function()? tearDownRepository,
}) {
  group('PortalAccountRepository Contract Tests', () {
    late PortalAccountRepository repo;

    setUp(() async {
      repo = await createRepository();
    });

    tearDown(() async {
      if (tearDownRepository != null) {
        await tearDownRepository();
      }
    });

    test('saves and retrieves zero-knowledge verifier', () async {
      final initial = await repo.getVerifier();
      expect(initial, isNull);

      const verifier = VaultPayload(
        ciphertext: 'base64ciphertext==',
        salt: 'base64salt==',
        nonce: 'base64nonce==',
        iterations: 210000,
      );

      final saved = await repo.saveVerifier(verifier);
      expect(saved.ciphertext, equals('base64ciphertext=='));

      final retrieved = await repo.getVerifier();
      expect(retrieved, isNotNull);
      expect(retrieved!.ciphertext, equals('base64ciphertext=='));
      expect(retrieved.salt, equals('base64salt=='));
    });

    test('creates and retrieves ciphertext accounts only', () async {
      const account = PortalAccount(
        circularId: 'circ-100',
        username: 'applicant123',
        encryptedPassword: 'encrypted_secret_data==',
        salt: 'salt123==',
        nonce: 'nonce123==',
        portalUrl: 'https://bpsc.teletalk.com.bd',
      );

      final created = await repo.createAccount(account);
      expect(created.id, isNotEmpty);
      expect(created.username, equals('applicant123'));
      expect(created.encryptedPassword, equals('encrypted_secret_data=='));

      final all = await repo.getAllAccounts();
      expect(all, hasLength(1));

      final forCircular = await repo.getAccountsForCircular('circ-100');
      expect(forCircular, hasLength(1));
      expect(forCircular.first.id, equals(created.id));
    });

    test('updates encrypted account', () async {
      final created = await repo.createAccount(
        const PortalAccount(
          circularId: 'circ-200',
          username: 'initial_user',
          encryptedPassword: 'initial_pwd==',
          salt: 'salt==',
          nonce: 'nonce==',
        ),
      );

      final updated = await repo.updateAccount(
        created.copyWith(username: 'updated_user'),
      );
      expect(updated.username, equals('updated_user'));

      final list = await repo.getAccountsForCircular('circ-200');
      expect(list.first.username, equals('updated_user'));
    });

    test('deletes portal account', () async {
      final created = await repo.createAccount(
        const PortalAccount(
          circularId: 'circ-300',
          username: 'temp_user',
          encryptedPassword: 'pwd==',
          salt: 's==',
          nonce: 'n==',
        ),
      );

      await repo.deleteAccount(created.id);
      final list = await repo.getAccountsForCircular('circ-300');
      expect(list, isEmpty);
    });
  });
}

void main() {
  late AppDatabase db;

  testVaultRepositoryContract(
    createRepository: () async {
      db = AppDatabase(NativeDatabase.memory());
      return LocalPortalAccountRepository(db);
    },
    tearDownRepository: () async {
      await db.close();
    },
  );
}
