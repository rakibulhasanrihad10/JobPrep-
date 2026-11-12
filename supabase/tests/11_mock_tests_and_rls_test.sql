-- Phase 6D: pgTAP tests verifying `mock_tests` schema constraints,
-- non-negative & upper marks bounds, owner FKs, SET NULL on optional links,
-- CASCADE on owning subject deletion, and cross-user RLS isolation.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(24);

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
    'eeee1111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'mock-user-a@example.test',
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
    'ffff2222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'mock-user-b@example.test',
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

INSERT INTO public.subjects (id, user_id, name) VALUES (
  'eeee3333-0000-4000-8000-000000000001',
  'eeee1111-1111-4111-8111-111111111111',
  'English Grammar'
);

INSERT INTO public.circulars (id, user_id, title) VALUES (
  'eeee4444-0000-4000-8000-000000000001',
  'eeee1111-1111-4111-8111-111111111111',
  '48th BCS Special Cadre'
);

INSERT INTO public.materials (id, user_id, subject_id, title, total_units) VALUES (
  'eeee5555-0000-4000-8000-000000000001',
  'eeee1111-1111-4111-8111-111111111111',
  'eeee3333-0000-4000-8000-000000000001',
  'Master English Book',
  300
);

INSERT INTO public.topics (id, user_id, subject_id, name) VALUES (
  'eeee6666-0000-4000-8000-000000000001',
  'eeee1111-1111-4111-8111-111111111111',
  'eeee3333-0000-4000-8000-000000000001',
  'Prepositions'
);

-- ============================================================================
-- 1. Schema & RLS Metadata (Tests 1-4)
-- ============================================================================
SELECT has_table('public'::name, 'mock_tests'::name, 'mock_tests table exists');

SELECT ok(
  (
    SELECT c.relrowsecurity
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE n.nspname = 'public' AND c.relname = 'mock_tests'
  ),
  'RLS is enabled on public.mock_tests'
);

SELECT has_column('public'::name, 'mock_tests'::name, 'subject_id'::name, 'subject_id column exists');
SELECT has_column('public'::name, 'mock_tests'::name, 'marks_obtained'::name, 'marks_obtained column exists');

-- ============================================================================
-- 2. User A Inserts & Check Constraints (Tests 5-13)
-- ============================================================================
SET LOCAL request.jwt.claim.sub = 'eeee1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"eeee1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (5) User A inserts valid mock test linked to circular, material, and topic
SELECT lives_ok(
  $sql$
    INSERT INTO public.mock_tests (
      id, user_id, subject_id, circular_id, material_id, topic_id,
      title, source, taken_on, marks_obtained, total_marks, negative_marks,
      time_taken_minutes, time_limit_minutes, weak_topics, notes
    ) VALUES (
      'eeee7777-0000-4000-8000-000000000001',
      'eeee1111-1111-4111-8111-111111111111',
      'eeee3333-0000-4000-8000-000000000001',
      'eeee4444-0000-4000-8000-000000000001',
      'eeee5555-0000-4000-8000-000000000001',
      'eeee6666-0000-4000-8000-000000000001',
      'LiveMCQ BCS Model 12',
      'LiveMCQ',
      '2026-11-10',
      72.50,
      100.00,
      4.50,
      55,
      60,
      'Prepositions, Clauses',
      'Careful with negative marking on idioms'
    );
  $sql$,
  'User A can insert valid mock test attached to subject, circular, material, topic'
);

-- (6) Rejects negative marks_obtained
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'eeee1111-1111-4111-8111-111111111111',
      'eeee3333-0000-4000-8000-000000000001',
      'Invalid Negative Marks',
      '2026-11-10',
      -1,
      100
    );
  $sql$,
  '23514',
  NULL,
  'mock_tests rejects negative marks_obtained'
);

-- (7) Rejects marks_obtained above total_marks
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'eeee1111-1111-4111-8111-111111111111',
      'eeee3333-0000-4000-8000-000000000001',
      'Above Total',
      '2026-11-10',
      101,
      100
    );
  $sql$,
  '23514',
  NULL,
  'mock_tests rejects marks_obtained above total_marks'
);

-- (8) Rejects zero or negative total_marks
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'eeee1111-1111-4111-8111-111111111111',
      'eeee3333-0000-4000-8000-000000000001',
      'Zero Total',
      '2026-11-10',
      0,
      0
    );
  $sql$,
  '23514',
  NULL,
  'mock_tests rejects zero total_marks'
);

-- (9) Rejects negative negative_marks
SELECT throws_ok(
  $sql$
    UPDATE public.mock_tests
       SET negative_marks = -0.5
     WHERE id = 'eeee7777-0000-4000-8000-000000000001';
  $sql$,
  '23514',
  NULL,
  'mock_tests rejects negative penalty marks'
);

-- (10) Rejects negative time_taken_minutes
SELECT throws_ok(
  $sql$
    UPDATE public.mock_tests
       SET time_taken_minutes = -5
     WHERE id = 'eeee7777-0000-4000-8000-000000000001';
  $sql$,
  '23514',
  NULL,
  'mock_tests rejects negative time_taken_minutes'
);

-- (11) Rejects zero time_limit_minutes
SELECT throws_ok(
  $sql$
    UPDATE public.mock_tests
       SET time_limit_minutes = 0
     WHERE id = 'eeee7777-0000-4000-8000-000000000001';
  $sql$,
  '23514',
  NULL,
  'mock_tests rejects zero time_limit_minutes'
);

-- (12) Rejects blank title
SELECT throws_ok(
  $sql$
    UPDATE public.mock_tests
       SET title = '   '
     WHERE id = 'eeee7777-0000-4000-8000-000000000001';
  $sql$,
  '23514',
  NULL,
  'mock_tests rejects blank title'
);

-- (13) User A updates own mock test cleanly
SELECT lives_ok(
  $sql$
    UPDATE public.mock_tests
       SET weak_topics = 'Clauses, Idioms'
     WHERE id = 'eeee7777-0000-4000-8000-000000000001';
  $sql$,
  'User A can update own mock_tests entry'
);

-- ============================================================================
-- 3. User B Cross-User RLS & FK Isolation (Tests 14-21)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'ffff2222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"ffff2222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (14) User B cannot read User A mock tests
SELECT is_empty(
  $$SELECT id FROM public.mock_tests WHERE user_id = 'eeee1111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A mock tests'
);

-- (15) User B cannot spoof User A user_id
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'eeee1111-1111-4111-8111-111111111111',
      'eeee3333-0000-4000-8000-000000000001',
      'Spoof Test',
      '2026-11-10',
      50,
      100
    );
  $sql$,
  '42501',
  NULL,
  'User B cannot insert mock test for User A'
);

-- (16) User B cannot attach own mock test to User A subject
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'ffff2222-2222-4222-8222-222222222222',
      'eeee3333-0000-4000-8000-000000000001',
      'Hijack Subject',
      '2026-11-10',
      50,
      100
    );
  $sql$,
  '23503',
  NULL,
  'User B cannot attach own mock test to User A subject'
);

INSERT INTO public.subjects (id, user_id, name) VALUES (
  'ffff3333-0000-4000-8000-000000000001',
  'ffff2222-2222-4222-8222-222222222222',
  'User B Subject'
);

-- (17) User B cannot attach own mock test to User A circular
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, circular_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'ffff2222-2222-4222-8222-222222222222',
      'ffff3333-0000-4000-8000-000000000001',
      'eeee4444-0000-4000-8000-000000000001',
      'Hijack Circular',
      '2026-11-10',
      50,
      100
    );
  $sql$,
  '23503',
  NULL,
  'User B cannot attach own mock test to User A circular'
);

-- (18) User B cannot attach own mock test to User A material
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, material_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'ffff2222-2222-4222-8222-222222222222',
      'ffff3333-0000-4000-8000-000000000001',
      'eeee5555-0000-4000-8000-000000000001',
      'Hijack Material',
      '2026-11-10',
      50,
      100
    );
  $sql$,
  '23503',
  NULL,
  'User B cannot attach own mock test to User A material'
);

-- (19) User B cannot attach own mock test to User A topic
SELECT throws_ok(
  $sql$
    INSERT INTO public.mock_tests (
      user_id, subject_id, topic_id, title, taken_on, marks_obtained, total_marks
    ) VALUES (
      'ffff2222-2222-4222-8222-222222222222',
      'ffff3333-0000-4000-8000-000000000001',
      'eeee6666-0000-4000-8000-000000000001',
      'Hijack Topic',
      '2026-11-10',
      50,
      100
    );
  $sql$,
  '23503',
  NULL,
  'User B cannot attach own mock test to User A topic'
);

-- (20) User B cannot update User A mock test
SELECT is_empty(
  $sql$
    UPDATE public.mock_tests
       SET marks_obtained = 99
     WHERE id = 'eeee7777-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot update User A mock test'
);

-- (21) User B cannot delete User A mock test
SELECT is_empty(
  $sql$
    DELETE FROM public.mock_tests
     WHERE id = 'eeee7777-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot delete User A mock test'
);

-- ============================================================================
-- 4. Linked Record Lifecycle (Tests 22-24)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'eeee1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"eeee1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (22) Deleting linked circular, material, and topic preserves mock_tests row
SELECT lives_ok(
  $sql$
    DELETE FROM public.circulars WHERE id = 'eeee4444-0000-4000-8000-000000000001';
    DELETE FROM public.materials WHERE id = 'eeee5555-0000-4000-8000-000000000001';
    DELETE FROM public.topics WHERE id = 'eeee6666-0000-4000-8000-000000000001';
  $sql$,
  'Deleting optional attached records sets mock_tests links null cleanly'
);

-- (23) Confirm User A mock test still exists with NULL optional FKs
SELECT is(
  (
    SELECT count(*)::integer
      FROM public.mock_tests
     WHERE id = 'eeee7777-0000-4000-8000-000000000001'
       AND circular_id IS NULL
       AND material_id IS NULL
       AND topic_id IS NULL
  ),
  1,
  'mock_tests keeps entry when attached circular, material, and topic are deleted'
);

-- (24) Deleting parent subject cascades to delete subject mock tests
SELECT lives_ok(
  $sql$
    DELETE FROM public.subjects WHERE id = 'eeee3333-0000-4000-8000-000000000001';
  $sql$,
  'Deleting parent subject cascades to mock_tests'
);

SELECT * FROM finish();

ROLLBACK;
