-- Phase 6G: pgTAP tests verifying `revision_items` schema, defaults, check
-- constraints, owner-verified FKs, indexes on user_id/status/due_on, and RLS.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(22);

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
    'cccc6701-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'revision-user-a@example.test',
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
    'dddd6702-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'revision-user-b@example.test',
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

-- (1-6) Schema, defaults, RLS enabled, and indexes
SELECT has_table('public'::name, 'revision_items'::name, 'revision_items table exists');
SELECT ok(
  (
    SELECT c.relrowsecurity
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'revision_items'
  ),
  'RLS is enabled on public.revision_items'
);
SELECT has_index('public'::name, 'revision_items'::name, 'idx_revision_items_user_id'::name, 'index exists on user_id');
SELECT has_index('public'::name, 'revision_items'::name, 'idx_revision_items_status'::name, 'index exists on status');
SELECT has_index('public'::name, 'revision_items'::name, 'idx_revision_items_due_on'::name, 'index exists on due_on');
SELECT col_default_is('public'::name, 'revision_items'::name, 'review_count'::name, '0', 'review_count defaults to 0');

-- Seed User A data
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', 'cccc6701-1111-4111-8111-111111111111', true);

INSERT INTO public.subjects (id, user_id, name) VALUES
  ('11116701-0000-4000-8000-000000000001', 'cccc6701-1111-4111-8111-111111111111', 'Mathematics');

INSERT INTO public.materials (id, user_id, subject_id, title, kind, unit_label, total_units) VALUES
  ('22226701-0000-4000-8000-000000000001', 'cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', 'Khairul Basic Math', 'book', 'pages', 450);

INSERT INTO public.progress_logs (id, user_id, material_id, units_done, logged_on) VALUES
  ('33336701-0000-4000-8000-000000000001', 'cccc6701-1111-4111-8111-111111111111', '22226701-0000-4000-8000-000000000001', 128, '2026-11-10');

INSERT INTO public.mock_tests (id, user_id, subject_id, title, marks_obtained, total_marks, weak_topics) VALUES
  ('44446701-0000-4000-8000-000000000001', 'cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', 'Speed Mock 1', 72, 100, 'Probability');

-- (7-8) Insert from progress log and from mock test without material_id
INSERT INTO public.revision_items (
  id, user_id, material_id, subject_id, reference_label, page_number,
  reason, source, progress_log_id, due_on
) VALUES (
  '55556701-0000-4000-8000-000000000001',
  'cccc6701-1111-4111-8111-111111111111',
  '22226701-0000-4000-8000-000000000001',
  '11116701-0000-4000-8000-000000000001',
  'p. 128 Problem 14',
  128,
  'tricky',
  'log',
  '33336701-0000-4000-8000-000000000001',
  '2026-11-11'
);

SELECT is(
  (SELECT status FROM public.revision_items WHERE id = '55556701-0000-4000-8000-000000000001'),
  'pending',
  'New revision item defaults to pending status'
);

INSERT INTO public.revision_items (
  id, user_id, subject_id, reference_label, reason, source, mock_test_id, due_on
) VALUES (
  '55556701-0000-4000-8000-000000000002',
  'cccc6701-1111-4111-8111-111111111111',
  '11116701-0000-4000-8000-000000000001',
  'Probability',
  'mistake',
  'mock_test',
  '44446701-0000-4000-8000-000000000001',
  '2026-11-11'
);

SELECT is(
  (SELECT count(*)::integer FROM public.revision_items WHERE user_id = 'cccc6701-1111-4111-8111-111111111111'),
  2,
  'User A can insert both log-linked and subject-level mock_test revision items'
);

-- (9-14) Check constraints enforcement
SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label)
  VALUES ('cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', '   ');
  $$,
  '23514',
  NULL,
  'revision_items rejects empty or blank reference_label'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label, page_number)
  VALUES ('cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', 'p. 10', -1);
  $$,
  '23514',
  NULL,
  'revision_items rejects negative page_number'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label, reason)
  VALUES ('cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', 'p. 10', 'other');
  $$,
  '23514',
  NULL,
  'revision_items rejects invalid reason'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label, source)
  VALUES ('cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', 'p. 10', 'import');
  $$,
  '23514',
  NULL,
  'revision_items rejects invalid source'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label, status)
  VALUES ('cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', 'p. 10', 'archived');
  $$,
  '23514',
  NULL,
  'revision_items rejects invalid status'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label, review_count)
  VALUES ('cccc6701-1111-4111-8111-111111111111', '11116701-0000-4000-8000-000000000001', 'p. 10', -2);
  $$,
  '23514',
  NULL,
  'revision_items rejects negative review_count'
);

-- (15) Revision items never alter progress_logs or completed_units
SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '22226701-0000-4000-8000-000000000001'),
  128,
  'Flagging revision items preserves material completed_units untouched'
);

-- (16-22) Cross-user RLS and owner-FK isolation
SELECT set_config('request.jwt.claim.sub', 'dddd6702-2222-4222-8222-222222222222', true);

INSERT INTO public.subjects (id, user_id, name) VALUES
  ('11116702-0000-4000-8000-000000000002', 'dddd6702-2222-4222-8222-222222222222', 'English');

SELECT is(
  (SELECT count(*)::integer FROM public.revision_items WHERE subject_id = '11116701-0000-4000-8000-000000000001'),
  0,
  'User B cannot read User A revision items'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label)
  VALUES ('cccc6701-1111-4111-8111-111111111111', '11116702-0000-4000-8000-000000000002', 'Spoofed');
  $$,
  '42501',
  NULL,
  'User B cannot spoof User A user_id when inserting revision_items'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, reference_label)
  VALUES ('dddd6702-2222-4222-8222-222222222222', '11116701-0000-4000-8000-000000000001', 'Hijacked Subject');
  $$,
  NULL,
  NULL,
  'User B cannot link own revision item to User A subject'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, material_id, reference_label)
  VALUES ('dddd6702-2222-4222-8222-222222222222', '11116702-0000-4000-8000-000000000002', '22226701-0000-4000-8000-000000000001', 'Hijacked Material');
  $$,
  NULL,
  NULL,
  'User B cannot link own revision item to User A material'
);

SELECT throws_ok(
  $$
  INSERT INTO public.revision_items (user_id, subject_id, mock_test_id, reference_label)
  VALUES ('dddd6702-2222-4222-8222-222222222222', '11116702-0000-4000-8000-000000000002', '44446701-0000-4000-8000-000000000001', 'Hijacked Mock');
  $$,
  NULL,
  NULL,
  'User B cannot link own revision item to User A mock test'
);

UPDATE public.revision_items
SET status = 'dismissed'
WHERE id = '55556701-0000-4000-8000-000000000001';

DELETE FROM public.revision_items
WHERE id = '55556701-0000-4000-8000-000000000001';

SELECT set_config('request.jwt.claim.sub', 'cccc6701-1111-4111-8111-111111111111', true);

SELECT is(
  (SELECT status FROM public.revision_items WHERE id = '55556701-0000-4000-8000-000000000001'),
  'pending',
  'User B cannot update User A revision item'
);

SELECT is(
  (SELECT count(*)::integer FROM public.revision_items WHERE id = '55556701-0000-4000-8000-000000000001'),
  1,
  'User B cannot delete User A revision item'
);

SELECT * FROM finish();
ROLLBACK;
