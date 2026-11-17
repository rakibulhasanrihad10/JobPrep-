-- Phase 9G pgTAP test: Topic Links (mock_test_topics, material_chapters),
-- StudyPlan plan_basis, and RLS multi-tenant isolation.

BEGIN;
SELECT plan(18);

-- 1. Table existence
SELECT has_table('public', 'mock_test_topics', 'Table mock_test_topics exists');
SELECT has_table('public', 'material_chapters', 'Table material_chapters exists');
SELECT has_column('public', 'study_plans', 'plan_basis', 'Column study_plans.plan_basis exists');

-- 2. RLS is enabled
SELECT table_privs_are(
  'public', 'mock_test_topics', 'authenticated', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
  'Authenticated role has standard CRUD on mock_test_topics'
);

SELECT table_privs_are(
  'public', 'material_chapters', 'authenticated', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
  'Authenticated role has standard CRUD on material_chapters'
);

-- Setup test users
DO $$
DECLARE
  v_user_a uuid := 'aaaa0000-0000-0000-0000-000000000001'::uuid;
  v_user_b uuid := 'bbbb0000-0000-0000-0000-000000000002'::uuid;
  v_subj_a uuid := '11110000-0000-0000-0000-000000000001'::uuid;
  v_chap_a uuid := '22220000-0000-0000-0000-000000000001'::uuid;
  v_top_a  uuid := '33330000-0000-0000-0000-000000000001'::uuid;
  v_mat_a  uuid := '44440000-0000-0000-0000-000000000001'::uuid;
  v_mock_a uuid := '55550000-0000-0000-0000-000000000001'::uuid;
BEGIN
  -- Insert mock auth users
  INSERT INTO auth.users (id, email) VALUES
    (v_user_a, 'user_a_links@test.com'),
    (v_user_b, 'user_b_links@test.com')
  ON CONFLICT (id) DO NOTHING;

  -- Create prerequisite records for User A
  INSERT INTO public.subjects (id, user_id, name)
  VALUES (v_subj_a, v_user_a, 'Physics');

  INSERT INTO public.chapters (id, user_id, subject_id, title)
  VALUES (v_chap_a, v_user_a, v_subj_a, 'Mechanics');

  INSERT INTO public.topics (id, user_id, subject_id, chapter_id, title, name)
  VALUES (v_top_a, v_user_a, v_subj_a, v_chap_a, 'Newtonian Laws', 'Newtonian Laws');

  INSERT INTO public.materials (id, user_id, subject_id, title)
  VALUES (v_mat_a, v_user_a, v_subj_a, 'University Physics Book');

  INSERT INTO public.mock_tests (id, user_id, subject_id, title, taken_on, marks_obtained, total_marks)
  VALUES (v_mock_a, v_user_a, v_subj_a, 'Physics Model 1', now(), 80, 100);
END $$;

-- 3. Act as User A: insert mock_test_topic and material_chapter
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claim.sub" = 'aaaa0000-0000-0000-0000-000000000001';

INSERT INTO public.mock_test_topics (id, user_id, mock_test_id, topic_id)
VALUES (
  '66660000-0000-0000-0000-000000000001'::uuid,
  'aaaa0000-0000-0000-0000-000000000001'::uuid,
  '55550000-0000-0000-0000-000000000001'::uuid,
  '33330000-0000-0000-0000-000000000001'::uuid
);

INSERT INTO public.material_chapters (id, user_id, material_id, chapter_id)
VALUES (
  '77770000-0000-0000-0000-000000000001'::uuid,
  'aaaa0000-0000-0000-0000-000000000001'::uuid,
  '44440000-0000-0000-0000-000000000001'::uuid,
  '22220000-0000-0000-0000-000000000001'::uuid
);

SELECT results_eq(
  $$ SELECT count(*)::int FROM public.mock_test_topics WHERE user_id = 'aaaa0000-0000-0000-0000-000000000001'::uuid $$,
  ARRAY[1],
  'User A sees their 1 mock_test_topic'
);

SELECT results_eq(
  $$ SELECT count(*)::int FROM public.material_chapters WHERE user_id = 'aaaa0000-0000-0000-0000-000000000001'::uuid $$,
  ARRAY[1],
  'User A sees their 1 material_chapter'
);

-- 4. Act as User B: cannot see User A's links
SET LOCAL "request.jwt.claim.sub" = 'bbbb0000-0000-0000-0000-000000000002';

SELECT is_empty(
  $$ SELECT * FROM public.mock_test_topics WHERE id = '66660000-0000-0000-0000-000000000001'::uuid $$,
  'User B cannot select User A mock_test_topic'
);

SELECT is_empty(
  $$ SELECT * FROM public.material_chapters WHERE id = '77770000-0000-0000-0000-000000000001'::uuid $$,
  'User B cannot select User A material_chapter'
);

-- User B cannot delete User A's links
DELETE FROM public.mock_test_topics WHERE id = '66660000-0000-0000-0000-000000000001'::uuid;
DELETE FROM public.material_chapters WHERE id = '77770000-0000-0000-0000-000000000001'::uuid;

-- User B cannot hijack with user_a user_id
SELECT throws_ok(
  $$ INSERT INTO public.mock_test_topics (id, user_id, mock_test_id, topic_id)
     VALUES ('88880000-0000-0000-0000-000000000001'::uuid, 'aaaa0000-0000-0000-0000-000000000001'::uuid,
             '55550000-0000-0000-0000-000000000001'::uuid, '33330000-0000-0000-0000-000000000001'::uuid) $$,
  '42501',
  NULL,
  'User B cannot insert mock_test_topic with User A user_id'
);

SELECT throws_ok(
  $$ INSERT INTO public.material_chapters (id, user_id, material_id, chapter_id)
     VALUES ('99990000-0000-0000-0000-000000000001'::uuid, 'aaaa0000-0000-0000-0000-000000000001'::uuid,
             '44440000-0000-0000-0000-000000000001'::uuid, '22220000-0000-0000-0000-000000000001'::uuid) $$,
  '42501',
  NULL,
  'User B cannot insert material_chapter with User A user_id'
);

-- Switch back to User A to confirm data is untouched
SET LOCAL "request.jwt.claim.sub" = 'aaaa0000-0000-0000-0000-000000000001';

SELECT results_eq(
  $$ SELECT count(*)::int FROM public.mock_test_topics WHERE id = '66660000-0000-0000-0000-000000000001'::uuid $$,
  ARRAY[1],
  'User A mock_test_topic survived User B delete attempt'
);

SELECT results_eq(
  $$ SELECT count(*)::int FROM public.material_chapters WHERE id = '77770000-0000-0000-0000-000000000001'::uuid $$,
  ARRAY[1],
  'User A material_chapter survived User B delete attempt'
);

-- Test study_plans plan_basis constraint
INSERT INTO public.study_plans (
  id, user_id, subject_id, start_date, target_date, plan_basis
) VALUES (
  'eeee0000-0000-0000-0000-000000000001'::uuid,
  'aaaa0000-0000-0000-0000-000000000001'::uuid,
  '11110000-0000-0000-0000-000000000001'::uuid,
  now(), now() + interval '30 days', 'syllabus_topics'
);

SELECT results_eq(
  $$ SELECT plan_basis FROM public.study_plans WHERE id = 'eeee0000-0000-0000-0000-000000000001'::uuid $$,
  ARRAY['syllabus_topics'],
  'Study plan accepts syllabus_topics as plan_basis'
);

SELECT throws_ok(
  $$ INSERT INTO public.study_plans (id, user_id, subject_id, start_date, target_date, plan_basis)
     VALUES ('ffff0000-0000-0000-0000-000000000001'::uuid, 'aaaa0000-0000-0000-0000-000000000001'::uuid,
             '11110000-0000-0000-0000-000000000001'::uuid, now(), now() + interval '30 days', 'invalid_basis') $$,
  '23514',
  NULL,
  'Study plan rejects invalid plan_basis value'
);

-- Signed-out cannot insert
SET LOCAL ROLE anon;

SELECT throws_ok(
  $$ INSERT INTO public.mock_test_topics (id, mock_test_id, topic_id)
     VALUES ('00000000-0000-0000-0000-000000000099'::uuid,
             '55550000-0000-0000-0000-000000000001'::uuid,
             '33330000-0000-0000-0000-000000000001'::uuid) $$,
  '42501',
  NULL,
  'Anon cannot insert mock_test_topics'
);

SELECT throws_ok(
  $$ INSERT INTO public.material_chapters (id, material_id, chapter_id)
     VALUES ('00000000-0000-0000-0000-000000000098'::uuid,
             '44440000-0000-0000-0000-000000000001'::uuid,
             '22220000-0000-0000-0000-000000000001'::uuid) $$,
  '42501',
  NULL,
  'Anon cannot insert material_chapters'
);

-- Test all public tables have RLS and policies
SELECT ok(
  NOT EXISTS (
    SELECT 1 FROM pg_tables
    WHERE schemaname = 'public'
      AND rowsecurity = false
  ),
  'Every public table has Row Level Security enabled'
);

SELECT * FROM finish();
ROLLBACK;
