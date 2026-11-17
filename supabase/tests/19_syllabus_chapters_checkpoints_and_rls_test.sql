-- Phase 9F: pgTAP tests for syllabus chapters, checkpoints, and RLS isolation.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(21);

-- Setup test users
INSERT INTO auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, recovery_sent_at, last_sign_in_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
) VALUES
  (
    '88881111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'syl-user-a@example.test',
    '$2a$10$mockhashforpgtaptestingonly', now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', '', ''
  ),
  (
    '88882222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'syl-user-b@example.test',
    '$2a$10$mockhashforpgtaptestingonly', now(), now(), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', '', ''
  )
ON CONFLICT (id) DO NOTHING;

-- 1. Table existence & columns
SELECT has_table('public', 'chapters', 'public.chapters table exists');
SELECT col_is_pk('public', 'chapters', 'id', 'chapters.id is primary key');
SELECT col_type_is('public', 'chapters', 'sort_order', 'integer', 'chapters.sort_order is integer');

SELECT has_column('public', 'subjects', 'enabled_checkpoints', 'subjects has enabled_checkpoints column');
SELECT has_column('public', 'topics', 'chapter_id', 'topics has chapter_id column');
SELECT has_column('public', 'topics', 'title', 'topics has title column');
SELECT has_column('public', 'topics', 'sort_order', 'topics has sort_order column');
SELECT has_column('public', 'topics', 'weight', 'topics has weight column');
SELECT has_column('public', 'topics', 'study_done_at', 'topics has study_done_at column');
SELECT has_column('public', 'topics', 'practice_done_at', 'topics has practice_done_at column');
SELECT has_column('public', 'topics', 'model_test_done_at', 'topics has model_test_done_at column');
SELECT has_column('public', 'topics', 'revision_done_at', 'topics has revision_done_at column');

-- 2. RLS enabled
SELECT table_privs_are(
  'public', 'chapters', 'authenticated',
  ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
  'authenticated has CRUD privileges on public.chapters'
);

-- User A Context
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claim.sub" = '88881111-1111-4111-8111-111111111111';
SET LOCAL "request.jwt.claim.role" = 'authenticated';
SET LOCAL request.jwt.claims = '{"sub":"88881111-1111-4111-8111-111111111111","role":"authenticated"}';

INSERT INTO public.subjects (id, user_id, name)
VALUES ('8888aaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '88881111-1111-4111-8111-111111111111', 'General Science')
ON CONFLICT (id) DO NOTHING;

-- Enabled checkpoints defaults
SELECT results_eq(
  $$ SELECT enabled_checkpoints FROM public.subjects WHERE id = '8888aaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' $$,
  $$ VALUES (ARRAY['study', 'practice', 'model_test', 'revision']::text[]) $$,
  'enabled_checkpoints defaults to all four checkpoints'
);

-- User A inserts chapter
INSERT INTO public.chapters (id, user_id, subject_id, title, sort_order)
VALUES ('8888cccc-cccc-4ccc-8ccc-cccccccccccc', '88881111-1111-4111-8111-111111111111', '8888aaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Physics', 0);

SELECT results_eq(
  $$ SELECT title FROM public.chapters WHERE id = '8888cccc-cccc-4ccc-8ccc-cccccccccccc' $$,
  $$ VALUES ('Physics'::text) $$,
  'User A can read own chapter'
);

-- User A inserts topic with checkpoints
INSERT INTO public.topics (
  id, user_id, subject_id, chapter_id, title, name, sort_order, weight, study_done_at
) VALUES (
  '8888ffff-ffff-4fff-8fff-ffffffffffff',
  '88881111-1111-4111-8111-111111111111',
  '8888aaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '8888cccc-cccc-4ccc-8ccc-cccccccccccc',
  'Mechanics', 'Mechanics', 0, 2, now()
);

SELECT results_eq(
  $$ SELECT weight FROM public.topics WHERE id = '8888ffff-ffff-4fff-8fff-ffffffffffff' $$,
  $$ VALUES (2) $$,
  'User A topic weight is preserved'
);

-- Test status migration simulation
INSERT INTO public.topics (
  id, user_id, subject_id, title, name, status
) VALUES (
  '8888bbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '88881111-1111-4111-8111-111111111111',
  '8888aaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'Chemistry', 'Chemistry', 'learning'
);

UPDATE public.topics
   SET study_done_at = COALESCE(study_done_at, updated_at, now())
 WHERE id = '8888bbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
   AND status IN ('learning', 'in_progress')
   AND study_done_at IS NULL;

SELECT is(
  (SELECT study_done_at IS NOT NULL FROM public.topics WHERE id = '8888bbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'),
  true,
  'Status migration stamps study_done_at for learning topic'
);

-- User B Context (RLS isolation)
SET LOCAL "request.jwt.claim.sub" = '88882222-2222-4222-8222-222222222222';
SET LOCAL "request.jwt.claim.role" = 'authenticated';
SET LOCAL request.jwt.claims = '{"sub":"88882222-2222-4222-8222-222222222222","role":"authenticated"}';

SELECT is_empty(
  $$ SELECT * FROM public.chapters WHERE id = '8888cccc-cccc-4ccc-8ccc-cccccccccccc' $$,
  'User B cannot read User A chapter'
);

SELECT is_empty(
  $$ SELECT * FROM public.topics WHERE id = '8888ffff-ffff-4fff-8fff-ffffffffffff' $$,
  'User B cannot read User A topic'
);

SELECT throws_ok(
  $$ INSERT INTO public.chapters (id, user_id, subject_id, title)
     VALUES ('8888cccc-2222-4ccc-8ccc-cccccccccccc', '88881111-1111-4111-8111-111111111111', '8888aaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hacked') $$,
  '42501',
  NULL,
  'User B cannot spoof user_id on chapters'
);

SELECT is_empty(
  $$ UPDATE public.chapters SET title = 'Tampered' WHERE id = '8888cccc-cccc-4ccc-8ccc-cccccccccccc' RETURNING id $$,
  'User B update on User A chapter affects 0 rows'
);

RESET ROLE;
SELECT * FROM finish();
ROLLBACK;
