import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 6B - Portal Accounts Migration & pgTAP Tests', () {
    test(
      'migration defines vault_verifiers and portal_accounts with required '
      'columns, owner FK, and RLS policies',
      () {
        final migration = File(
          'supabase/migrations/20261111010000_portal_accounts.sql',
        );
        expect(migration.existsSync(), isTrue);

        final sql = migration.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));

        expect(sql, contains('CREATE TABLE public.vault_verifiers'));
        expect(sql, contains('CREATE TABLE public.portal_accounts'));

        for (final column in [
          'user_id',
          'circular_id',
          'portal_url',
          'username',
          'encrypted_password',
          'salt',
          'nonce',
          'iterations',
          'notes',
        ]) {
          expect(sql, contains('  $column '));
        }

        expect(
          sql,
          contains('FOREIGN KEY (circular_id, user_id)'),
        );
        expect(
          sql,
          contains(
            'ALTER TABLE public.vault_verifiers ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(
          sql,
          contains(
            'ALTER TABLE public.portal_accounts ENABLE ROW LEVEL SECURITY',
          ),
        );
        expect(sql, contains('USING (user_id = auth.uid())'));
        expect(sql, contains('WITH CHECK (user_id = auth.uid())'));
        expect(sql, contains('CREATE TRIGGER set_vault_verifiers_updated_at'));
        expect(sql, contains('CREATE TRIGGER set_portal_accounts_updated_at'));
      },
    );

    test(
      'pgTAP suite verifies constraints, cascade delete, and cross-user RLS',
      () {
        final testFile = File(
          'supabase/tests/09_portal_accounts_and_rls_test.sql',
        );
        expect(testFile.existsSync(), isTrue);

        final sql = testFile.readAsStringSync();
        expect(sql, isNot(contains('\r\n')));
        expect(sql, contains('BEGIN;'));
        expect(sql, contains('SELECT plan(23);'));
        expect(
          sql,
          contains('User B cannot link a portal account to User A circular'),
        );
        expect(sql, contains('User B cannot read User A portal accounts'));
        expect(sql, contains('User B cannot update User A portal account'));
        expect(sql, contains('User B cannot delete User A portal account'));
        expect(
          sql,
          contains(
            'Deleting parent circular cascades cleanly to portal_accounts',
          ),
        );
        expect(sql, contains('SELECT * FROM finish();'));
        expect(sql, contains('ROLLBACK;'));
      },
    );
  });
}
