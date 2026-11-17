-- Phase 9E: Cloud Save Upsert Safety & RLS Gate pgTAP Suite
-- Verifies that:
-- 1. Every table in public schema has Row Level Security enabled and has at least one policy.
-- 2. User A can insert a row with a client-generated UUID.
-- 3. User B upserting the same ID with different content fails or changes nothing; User A's row stays unchanged.
-- 4. User B cannot insert a row carrying User A's user_id.
-- 5. An anonymous / signed-out client cannot insert into user-owned tables.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

-- Total planned tests
SELECT plan(42);

-- ============================================================================
-- 1. Seed two isolated mock users in auth.users
-- ============================================================================
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) VALUES
  (
    '11111111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'user-a-upsert@example.test',
    '$2a$10$mockhashforpgtaptestingonly',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'user-b-upsert@example.test',
    '$2a$10$mockhashforpgtaptestingonly',
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  );

-- ============================================================================
-- 2. Schema-Wide RLS & Policy Gate Tests (Tests 1-2)
-- ============================================================================
-- (1) Every table in public schema must have relrowsecurity enabled
SELECT is_empty(
  $$
    SELECT c.relname
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relkind = 'r'
      AND NOT c.relrowsecurity
  $$,
  'RLS Gate: Every table in the public schema must have Row Level Security enabled'
);

-- (2) Every table in public schema must have at least one RLS policy defined
SELECT is_empty(
  $$
    SELECT c.relname
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_policy p ON p.polrelid = c.oid
    WHERE n.nspname = 'public'
      AND c.relkind = 'r'
    GROUP BY c.relname
    HAVING count(p.oid) = 0
  $$,
  'RLS Gate: Every table in the public schema must have at least one RLS policy'
);

-- ============================================================================
-- 3. Cloud Upsert Safety for Circulars (Tests 3-6)
-- ============================================================================
-- Step A: User A inserts a circular with a fixed client UUID
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

INSERT INTO public.circulars (id, user_id, title, sector)
VALUES ('ca000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Original User A Circular', 'bcs');

-- (3) User A's row was inserted successfully
SELECT results_eq(
  $$
    SELECT title FROM public.circulars WHERE id = 'ca000001-0000-4000-8000-000000000001'
  $$,
  $$ VALUES ('Original User A Circular'::text) $$,
  'User A can insert a circular with client-generated id'
);

-- Step B: Switch to User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '22222222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (4) User B cannot insert a row with user_id = User A
SELECT throws_ok(
  $$
    INSERT INTO public.circulars (id, user_id, title, sector)
    VALUES ('cb000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Hijacked Row', 'bcs')
  $$,
  '42501',
  NULL,
  'User B cannot insert a circular carrying User A user_id'
);

-- (5) User B attempting to upsert the same ID with user_id = User B fails or changes nothing
-- In PostgreSQL, ON CONFLICT DO UPDATE on an RLS-protected row owned by another user throws 42501 or leaves row untouched
DO $$
BEGIN
  BEGIN
    INSERT INTO public.circulars (id, user_id, title, sector)
    VALUES ('ca000001-0000-4000-8000-000000000001', '22222222-2222-4222-8222-222222222222', 'User B Attack', 'bank')
    ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;
  EXCEPTION WHEN insufficient_privilege THEN
    -- Expected: RLS rejects cross-tenant UPDATE
    NULL;
  END;
END $$;

-- Switch to postgres to inspect underlying row
RESET ROLE;
SET LOCAL ROLE postgres;

-- (6) User A's circular is intact and was not overwritten by User B
SELECT results_eq(
  $$
    SELECT title FROM public.circulars WHERE id = 'ca000001-0000-4000-8000-000000000001'
  $$,
  $$ VALUES ('Original User A Circular'::text) $$,
  'User A circular remains unmodified after User B upsert attempt'
);

-- ============================================================================
-- 4. Cloud Upsert Safety for Subjects & Materials (Tests 7-14)
-- ============================================================================
-- Step A: User A inserts Subject and Material
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

INSERT INTO public.subjects (id, user_id, name)
VALUES ('5a000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'User A Subject');

INSERT INTO public.materials (id, user_id, subject_id, title, total_units)
VALUES ('ba000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', 'User A Book 1', 300);

-- (7) User A subject verified
SELECT results_eq(
  $$ SELECT name FROM public.subjects WHERE id = '5a000001-0000-4000-8000-000000000001' $$,
  $$ VALUES ('User A Subject'::text) $$,
  'User A can insert subject with client-generated id'
);

-- (8) User A material verified
SELECT results_eq(
  $$ SELECT title FROM public.materials WHERE id = 'ba000001-0000-4000-8000-000000000001' $$,
  $$ VALUES ('User A Book 1'::text) $$,
  'User A can insert material with client-generated id'
);

-- Step B: Switch to User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '22222222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (9) User B cannot insert subject with User A's user_id
SELECT throws_ok(
  $$
    INSERT INTO public.subjects (id, user_id, name)
    VALUES ('5b000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Spoofed Subject')
  $$,
  '42501',
  NULL,
  'User B cannot insert subject carrying User A user_id'
);

-- (10) User B cannot insert material with User A's user_id
SELECT throws_ok(
  $$
    INSERT INTO public.materials (id, user_id, subject_id, title, total_units)
    VALUES ('bb000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', 'Spoofed Material', 100)
  $$,
  '42501',
  NULL,
  'User B cannot insert material carrying User A user_id'
);

-- Attempt cross-tenant upsert on subject and material
DO $$
BEGIN
  BEGIN
    INSERT INTO public.subjects (id, user_id, name)
    VALUES ('5a000001-0000-4000-8000-000000000001', '22222222-2222-4222-8222-222222222222', 'User B Subject Takeover')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    INSERT INTO public.materials (id, user_id, subject_id, title, total_units)
    VALUES ('ba000001-0000-4000-8000-000000000001', '22222222-2222-4222-8222-222222222222', '5a000001-0000-4000-8000-000000000001', 'User B Book Takeover', 999)
    ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END $$;

RESET ROLE;
SET LOCAL ROLE postgres;

-- (11) User A subject untouched
SELECT results_eq(
  $$ SELECT name FROM public.subjects WHERE id = '5a000001-0000-4000-8000-000000000001' $$,
  $$ VALUES ('User A Subject'::text) $$,
  'User A subject remains unmodified after User B upsert attempt'
);

-- (12) User A material untouched
SELECT results_eq(
  $$ SELECT title FROM public.materials WHERE id = 'ba000001-0000-4000-8000-000000000001' $$,
  $$ VALUES ('User A Book 1'::text) $$,
  'User A material remains unmodified after User B upsert attempt'
);

-- ============================================================================
-- 5. Progress Logs & 300/300/400 Invariant Upsert Safety (Tests 13-18)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

INSERT INTO public.progress_logs (id, user_id, material_id, units_done, logged_on, entry_type)
VALUES ('1a000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'ba000001-0000-4000-8000-000000000001', 300, '2026-11-14', 'study');

-- (13) Trigger recalculated completed_units to 300
SELECT results_eq(
  $$ SELECT completed_units FROM public.materials WHERE id = 'ba000001-0000-4000-8000-000000000001' $$,
  $$ VALUES (300) $$,
  'Progress log recalculation trigger sets completed_units to 300 (100% of book 1)'
);

-- Step B: User B cannot modify User A's progress log
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '22222222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

DO $$
BEGIN
  BEGIN
    INSERT INTO public.progress_logs (id, user_id, material_id, units_done, logged_on, entry_type)
    VALUES ('1a000001-0000-4000-8000-000000000001', '22222222-2222-4222-8222-222222222222', 'ba000001-0000-4000-8000-000000000001', 10, '2026-11-14', 'study')
    ON CONFLICT (id) DO UPDATE SET units_done = EXCLUDED.units_done;
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END $$;

RESET ROLE;
SET LOCAL ROLE postgres;

-- (14) User A's progress log units_done remains 300
SELECT results_eq(
  $$ SELECT units_done FROM public.progress_logs WHERE id = '1a000001-0000-4000-8000-000000000001' $$,
  $$ VALUES (300) $$,
  'User A progress log units_done is unmodified after User B upsert attempt'
);

-- ============================================================================
-- 6. Anonymous / Signed-Out Insertion Rejection (Tests 15-32)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{"role":"anon"}';
SET LOCAL ROLE anon;

-- Circulars & children
SELECT throws_ok(
  $$ INSERT INTO public.circulars (user_id, title) VALUES ('11111111-1111-4111-8111-111111111111', 'Anon') $$,
  '42501', NULL, 'Anon cannot insert circulars'
);
SELECT throws_ok(
  $$ INSERT INTO public.circular_exam_dates (circular_id, user_id, stage, exam_date) VALUES ('ca000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'preliminary', '2026-12-01') $$,
  '42501', NULL, 'Anon cannot insert circular_exam_dates'
);
SELECT throws_ok(
  $$ INSERT INTO public.circular_files (circular_id, user_id, file_name, storage_path, size_bytes, mime_type) VALUES ('ca000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'doc.pdf', 'path', 100, 'application/pdf') $$,
  '42501', NULL, 'Anon cannot insert circular_files'
);

-- Prep tables
SELECT throws_ok(
  $$ INSERT INTO public.subjects (user_id, name) VALUES ('11111111-1111-4111-8111-111111111111', 'Anon') $$,
  '42501', NULL, 'Anon cannot insert subjects'
);
SELECT throws_ok(
  $$ INSERT INTO public.materials (user_id, subject_id, title, total_units) VALUES ('11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', 'Anon', 100) $$,
  '42501', NULL, 'Anon cannot insert materials'
);
SELECT throws_ok(
  $$ INSERT INTO public.progress_logs (user_id, material_id, units_done, logged_on) VALUES ('11111111-1111-4111-8111-111111111111', 'ba000001-0000-4000-8000-000000000001', 10, '2026-11-14') $$,
  '42501', NULL, 'Anon cannot insert progress_logs'
);
SELECT throws_ok(
  $$ INSERT INTO public.topics (user_id, subject_id, name) VALUES ('11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', 'Anon') $$,
  '42501', NULL, 'Anon cannot insert topics'
);
SELECT throws_ok(
  $$ INSERT INTO public.circular_subjects (user_id, circular_id, subject_id) VALUES ('11111111-1111-4111-8111-111111111111', 'ca000001-0000-4000-8000-000000000001', '5a000001-0000-4000-8000-000000000001') $$,
  '42501', NULL, 'Anon cannot insert circular_subjects'
);

-- Auxiliary tables
SELECT throws_ok(
  $$ INSERT INTO public.user_reminder_settings (user_id) VALUES ('11111111-1111-4111-8111-111111111111') $$,
  '42501', NULL, 'Anon cannot insert user_reminder_settings'
);
SELECT throws_ok(
  $$ INSERT INTO public.reminder_log (user_id, circular_id, reminder_kind, days_before, target_date, recipient_email, email_language) VALUES ('11111111-1111-4111-8111-111111111111', 'ca000001-0000-4000-8000-000000000001', 'circular_deadline', 3, '2026-12-01', 'a@b.com', 'en') $$,
  '42501', NULL, 'Anon cannot insert reminder_log'
);
SELECT throws_ok(
  $$ INSERT INTO public.vault_verifiers (user_id, check_salt, check_nonce, check_ciphertext) VALUES ('11111111-1111-4111-8111-111111111111', 's', 'n', 'c') $$,
  '42501', NULL, 'Anon cannot insert vault_verifiers'
);
SELECT throws_ok(
  $$ INSERT INTO public.portal_accounts (user_id, circular_id, portal_url, username, encrypted_password, nonce, salt) VALUES ('11111111-1111-4111-8111-111111111111', 'ca000001-0000-4000-8000-000000000001', 'http://', 'u', 'c', 'n', 's') $$,
  '42501', NULL, 'Anon cannot insert portal_accounts'
);
SELECT throws_ok(
  $$ INSERT INTO public.study_plans (user_id, subject_id, start_date, target_date) VALUES ('11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', '2026-11-01', '2026-12-01') $$,
  '42501', NULL, 'Anon cannot insert study_plans'
);
SELECT throws_ok(
  $$ INSERT INTO public.mock_tests (user_id, subject_id, title, taken_on, marks_obtained, total_marks) VALUES ('11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', 'Test', '2026-11-14', 80, 100) $$,
  '42501', NULL, 'Anon cannot insert mock_tests'
);
SELECT throws_ok(
  $$ INSERT INTO public.revision_items (user_id, subject_id, reference_label, status) VALUES ('11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', 'p10', 'pending') $$,
  '42501', NULL, 'Anon cannot insert revision_items'
);
SELECT throws_ok(
  $$ INSERT INTO public.study_sessions (user_id, subject_id, started_at, duration_seconds) VALUES ('11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', now(), 1800) $$,
  '42501', NULL, 'Anon cannot insert study_sessions'
);
SELECT throws_ok(
  $$ INSERT INTO public.notifications (user_id, type, message_key, route, dedupe_key) VALUES ('11111111-1111-4111-8111-111111111111', 'review', 'k', '/today', 'd1') $$,
  '42501', NULL, 'Anon cannot insert notifications'
);
SELECT throws_ok(
  $$ INSERT INTO public.user_settings (user_id) VALUES ('11111111-1111-4111-8111-111111111111') $$,
  '42501', NULL, 'Anon cannot insert user_settings'
);

-- ============================================================================
-- 7. Verification of Idempotent Upsert for Legitimate Owner (Tests 33-42)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- User A saving same circular id twice produces exactly 1 row with updated title
INSERT INTO public.circulars (id, user_id, title, sector)
VALUES ('ca000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Updated User A Circular', 'bcs')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;

SELECT results_eq(
  $$ SELECT count(*)::integer FROM public.circulars WHERE id = 'ca000001-0000-4000-8000-000000000001' $$,
  $$ VALUES (1) $$,
  'Saving same circular id twice leaves exactly one row'
);
SELECT results_eq(
  $$ SELECT title FROM public.circulars WHERE id = 'ca000001-0000-4000-8000-000000000001' $$,
  $$ VALUES ('Updated User A Circular'::text) $$,
  'Saving same circular id twice updates fields cleanly'
);

-- User A saving same subject id twice produces exactly 1 row
INSERT INTO public.subjects (id, user_id, name)
VALUES ('5a000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Updated User A Subject')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

SELECT results_eq(
  $$ SELECT count(*)::integer FROM public.subjects WHERE id = '5a000001-0000-4000-8000-000000000001' $$,
  $$ VALUES (1) $$,
  'Saving same subject id twice leaves exactly one row'
);

-- User A saving same material id twice produces exactly 1 row
INSERT INTO public.materials (id, user_id, subject_id, title, total_units)
VALUES ('ba000001-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', '5a000001-0000-4000-8000-000000000001', 'Updated User A Book 1', 300)
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;

SELECT results_eq(
  $$ SELECT count(*)::integer FROM public.materials WHERE id = 'ba000001-0000-4000-8000-000000000001' $$,
  $$ VALUES (1) $$,
  'Saving same material id twice leaves exactly one row'
);

SELECT * FROM finish();
ROLLBACK;
