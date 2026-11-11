-- Phase 6B: pgTAP tests verifying `vault_verifiers` and `portal_accounts`
-- schema constraints, cascade cleanup, and cross-user RLS isolation.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(23);

INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES
  (
    'aaaa1111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'vault-user-a@example.test',
    '$2a$10$mockhashforpgtaptestingonly',
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    '',
    ''
  ),
  (
    'bbbb2222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'vault-user-b@example.test',
    '$2a$10$mockhashforpgtaptestingonly',
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

INSERT INTO public.circulars (
  id,
  user_id,
  title
) VALUES (
  'aaaa3333-0000-4000-8000-000000000001',
  'aaaa1111-1111-4111-8111-111111111111',
  '48th BCS Portal Circular'
);

-- ============================================================================
-- 1. Schema & RLS Metadata (Tests 1-4)
-- ============================================================================
-- (1-2) Tables exist
SELECT has_table('public'::name, 'vault_verifiers'::name, 'vault_verifiers table exists');
SELECT has_table('public'::name, 'portal_accounts'::name, 'portal_accounts table exists');

-- (3-4) RLS enabled on both tables
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'vault_verifiers'),
  'RLS is enabled on public.vault_verifiers'
);
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'portal_accounts'),
  'RLS is enabled on public.portal_accounts'
);

-- ============================================================================
-- 2. Anonymous Role Isolation (Tests 5-8)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{"role":"anon"}';
SET LOCAL ROLE anon;

-- (5-6) Anon cannot read either table
SELECT is_empty(
  $$SELECT id FROM public.vault_verifiers$$,
  'Anonymous role cannot read vault_verifiers'
);
SELECT is_empty(
  $$SELECT id FROM public.portal_accounts$$,
  'Anonymous role cannot read portal_accounts'
);

-- (7-8) Anon cannot insert into either table
SELECT throws_ok(
  $sql$
    INSERT INTO public.vault_verifiers (
      user_id, check_ciphertext, check_salt, check_nonce, check_iterations
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111', 'cipher', 'salt', 'nonce', 210000
    )
  $sql$,
  '42501',
  NULL,
  'Anonymous role cannot insert vault_verifiers'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.portal_accounts (
      user_id, circular_id, portal_url, username, encrypted_password, salt, nonce
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'https://bpsc.teletalk.com.bd',
      'user123',
      'cipher',
      'salt',
      'nonce'
    )
  $sql$,
  '42501',
  NULL,
  'Anonymous role cannot insert portal_accounts'
);

-- ============================================================================
-- 3. User A CRUD & Check Constraints (Tests 9-15)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'aaaa1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"aaaa1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (9) User A can insert own verifier
SELECT lives_ok(
  $sql$
    INSERT INTO public.vault_verifiers (
      id, user_id, check_ciphertext, check_salt, check_nonce, check_iterations
    ) VALUES (
      'aaaa5555-0000-4000-8000-000000000001',
      'aaaa1111-1111-4111-8111-111111111111',
      'Y2hlY2stY2lwaGVydGV4dA==',
      'cmFuZG9tLXNhbHQtMTZieXRl',
      'cmFuZG9tLW5vbmNl',
      210000
    )
  $sql$,
  'User A can insert own vault verifier'
);

-- (10) Low iteration count is rejected on vault_verifiers
SELECT throws_ok(
  $sql$
    UPDATE public.vault_verifiers
       SET check_iterations = 5000
     WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'
  $sql$,
  '23514',
  NULL,
  'vault_verifiers rejects weak iteration counts under 100,000'
);

-- (11) User A can insert encrypted portal account for own circular
SELECT lives_ok(
  $sql$
    INSERT INTO public.portal_accounts (
      id,
      user_id,
      circular_id,
      portal_url,
      username,
      encrypted_password,
      salt,
      nonce,
      notes
    ) VALUES (
      'aaaa6666-0000-4000-8000-000000000001',
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'https://bpsc.teletalk.com.bd',
      'CANDIDATE01',
      'ZW5jcnlwdGVkLXB3',
      'c2FsdC0xNi1ieXRlcw==',
      'bm9uY2UtMTItYnl0ZXM=',
      'Admit card portal'
    )
  $sql$,
  'User A can insert encrypted portal_accounts row for own circular'
);

-- (12) Empty username rejected
SELECT throws_ok(
  $sql$
    INSERT INTO public.portal_accounts (
      user_id, circular_id, username, encrypted_password, salt, nonce
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      '   ',
      'ZW5jcnlwdGVkLXB3',
      'c2FsdC0xNi1ieXRlcw==',
      'bm9uY2UtMTItYnl0ZXM='
    )
  $sql$,
  '23514',
  NULL,
  'portal_accounts rejects blank username'
);

-- (13) Empty encrypted_password rejected
SELECT throws_ok(
  $sql$
    INSERT INTO public.portal_accounts (
      user_id, circular_id, username, encrypted_password, salt, nonce
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'CANDIDATE02',
      ' ',
      'c2FsdC0xNi1ieXRlcw==',
      'bm9uY2UtMTItYnl0ZXM='
    )
  $sql$,
  '23514',
  NULL,
  'portal_accounts rejects blank encrypted_password'
);

-- (14) Invalid portal_url scheme rejected
SELECT throws_ok(
  $sql$
    INSERT INTO public.portal_accounts (
      user_id, circular_id, portal_url, username, encrypted_password, salt, nonce
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'javascript:alert(1)',
      'CANDIDATE02',
      'ZW5jcnlwdGVkLXB3',
      'c2FsdC0xNi1ieXRlcw==',
      'bm9uY2UtMTItYnl0ZXM='
    )
  $sql$,
  '23514',
  NULL,
  'portal_accounts rejects non-http(s) portal_url schemes'
);

-- (15) User A can read and update own portal account
SELECT lives_ok(
  $sql$
    UPDATE public.portal_accounts
       SET notes = 'Updated PIN note'
     WHERE id = 'aaaa6666-0000-4000-8000-000000000001';
  $sql$,
  'User A can update own portal_accounts entry'
);

-- ============================================================================
-- 4. User B Cross-User Isolation (Tests 16-22)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'bbbb2222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"bbbb2222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (16) User B cannot read User A verifier
SELECT is_empty(
  $$SELECT id FROM public.vault_verifiers WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A vault verifier'
);

-- (17) User B cannot spoof User A user_id on vault_verifiers insert
SELECT throws_ok(
  $sql$
    INSERT INTO public.vault_verifiers (
      user_id, check_ciphertext, check_salt, check_nonce, check_iterations
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111', 'c', 's', 'n', 210000
    )
  $sql$,
  '42501',
  NULL,
  'User B cannot insert vault verifier for User A'
);

-- (18) User B cannot read User A portal accounts
SELECT is_empty(
  $$SELECT id FROM public.portal_accounts WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A portal accounts'
);

-- (19) User B cannot attach own portal account to User A circular
SELECT throws_ok(
  $sql$
    INSERT INTO public.portal_accounts (
      user_id, circular_id, username, encrypted_password, salt, nonce
    ) VALUES (
      'bbbb2222-2222-4222-8222-222222222222',
      'aaaa3333-0000-4000-8000-000000000001',
      'INTRUDER',
      'ZW5jcnlwdGVkLXB3',
      'c2FsdC0xNi1ieXRlcw==',
      'bm9uY2UtMTItYnl0ZXM='
    )
  $sql$,
  '23503',
  NULL,
  'User B cannot link a portal account to User A circular'
);

-- (20) User B cannot insert portal account under User A user_id
SELECT throws_ok(
  $sql$
    INSERT INTO public.portal_accounts (
      user_id, circular_id, username, encrypted_password, salt, nonce
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'SPOOF',
      'ZW5jcnlwdGVkLXB3',
      'c2FsdC0xNi1ieXRlcw==',
      'bm9uY2UtMTItYnl0ZXM='
    )
  $sql$,
  '42501',
  NULL,
  'User B cannot insert portal account for User A'
);

-- (21) User B cannot update User A portal account
SELECT is_empty(
  $sql$
    UPDATE public.portal_accounts
       SET username = 'HIJACKED'
     WHERE id = 'aaaa6666-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot update User A portal account'
);

-- (22) User B cannot delete User A portal account
SELECT is_empty(
  $sql$
    DELETE FROM public.portal_accounts
     WHERE id = 'aaaa6666-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot delete User A portal account'
);

-- ============================================================================
-- 5. Cascade Delete Cleanup (Test 23)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'aaaa1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"aaaa1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (23) Deleting parent circular cascades to delete portal_accounts
SELECT lives_ok(
  $sql$
    DELETE FROM public.circulars
     WHERE id = 'aaaa3333-0000-4000-8000-000000000001';
  $sql$,
  'Deleting parent circular cascades cleanly to portal_accounts'
);

SELECT * FROM finish();

ROLLBACK;
