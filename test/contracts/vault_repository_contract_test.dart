import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/vault/data/repositories/local_portal_account_repository.dart';
import 'package:job_prep/features/vault/data/repositories/supabase_portal_account_repository.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

import 'mock_supabase_http_client.dart';

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

    test('creates and retrieves ciphertext without plaintext leaks', () async {
      const account = PortalAccount(
        circularId: 'circ-100',
        portalUrl: 'https://alljobs.teletalk.com.bd',
        username: 'user_teletalk',
        encryptedPassword: 'ciphertext_base64_sample==',
        salt: 'salt_base64_sample==',
        nonce: 'nonce_base64_sample==',
      );

      final created = await repo.createAccount(account);
      expect(created.id, isNotEmpty);
      expect(created.encryptedPassword, equals('ciphertext_base64_sample=='));
      expect(created.username, equals('user_teletalk'));

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
  group('Local Implementation Contract', () {
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
  });

  group('Supabase Implementation Contract', () {
    late MockSupabaseHttpClient mockHttp;
    late MockSupabaseClient client;

    testVaultRepositoryContract(
      createRepository: () async {
        mockHttp = MockSupabaseHttpClient();
        client = MockSupabaseClient(mockHttpClient: mockHttp);
        return SupabasePortalAccountRepository(client);
      },
      tearDownRepository: () async {
        mockHttp.clear();
      },
    );
  });
}
