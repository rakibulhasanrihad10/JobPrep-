-- Phase 6C: pgTAP tests verifying `study_plans` schema defaults, constraints,
-- partial unique indexes, owner FKs, cascade/set-null behavior, and RLS.

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
    'cccc1111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'study-user-a@example.test',
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
    'dddd2222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'study-user-b@example.test',
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

INSERT INTO public.subjects (
  id,
  user_id,
  name
) VALUES (
  'cccc3333-0000-4000-8000-000000000001',
  'cccc1111-1111-4111-8111-111111111111',
  'Bengali'
);

INSERT INTO public.circulars (
  id,
  user_id,
  title
) VALUES (
  'cccc4444-0000-4000-8000-000000000001',
  'cccc1111-1111-4111-8111-111111111111',
  '48th BCS Special Cadre'
);

INSERT INTO public.circular_exam_dates (
  id,
  circular_id,
  user_id,
  stage,
  exam_date
) VALUES (
  'cccc5555-0000-4000-8000-000000000001',
  'cccc4444-0000-4000-8000-000000000001',
  'cccc1111-1111-4111-8111-111111111111',
  'preliminary',
  '2027-01-20T09:00:00Z'
);

-- ============================================================================
-- 1. Schema & RLS Metadata (Tests 1-4)
-- ============================================================================
-- (1) Table exists
SELECT has_table('public'::name, 'study_plans'::name, 'study_plans table exists');

-- (2) RLS enabled
SELECT ok(
  (
    SELECT c.relrowsecurity
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE n.nspname = 'public' AND c.relname = 'study_plans'
  ),
  'RLS is enabled on public.study_plans'
);

-- (3-4) Core columns exist
SELECT has_column('public'::name, 'study_plans'::name, 'subject_id'::name, 'subject_id column exists');
SELECT has_column('public'::name, 'study_plans'::name, 'finish_buffer_days'::name, 'finish_buffer_days column exists');

-- ============================================================================
-- 2. User A Operations, Defaults & Constraints (Tests 5-13)
-- ============================================================================
SET LOCAL request.jwt.claim.sub = 'cccc1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"cccc1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (5) User A inserts an all-subjects plan (subject_id NULL, default buffer=7, rest=0)
SELECT lives_ok(
  $sql$
    INSERT INTO public.study_plans (
      id, user_id, subject_id, start_date, target_date
    ) VALUES (
      'cccc6666-0000-4000-8000-000000000001',
      'cccc1111-1111-4111-8111-111111111111',
      NULL,
      '2026-11-10',
      '2027-01-16'
    );
  $sql$,
  'User A can create an all-subjects study plan with defaults'
);

-- (6) Inserted plan applies finish_buffer_days=7 and rest_days_per_week=0 defaults
SELECT is(
  (
    SELECT finish_buffer_days::text || ':' || rest_days_per_week::text
      FROM public.study_plans
     WHERE id = 'cccc6666-0000-4000-8000-000000000001'
  ),
  '7:0',
  'study_plans defaults finish_buffer_days=7 and rest_days_per_week=0'
);

-- (7) Duplicate all-subjects plan per user rejected cleanly
SELECT throws_ok(
  $sql$
    INSERT INTO public.study_plans (
      user_id, subject_id, start_date, target_date
    ) VALUES (
      'cccc1111-1111-4111-8111-111111111111',
      NULL,
      '2026-11-11',
      '2027-02-01'
    );
  $sql$,
  '23505',
  NULL,
  'User cannot create duplicate all-subjects study plan'
);

-- (8) User A inserts a subject plan linked to circular and exam_date with max_daily_pace
SELECT lives_ok(
  $sql$
    INSERT INTO public.study_plans (
      id, user_id, subject_id, circular_id, exam_date_id,
      start_date, target_date, finish_buffer_days, rest_days_per_week, max_daily_pace
    ) VALUES (
      'cccc6666-0000-4000-8000-000000000002',
      'cccc1111-1111-4111-8111-111111111111',
      'cccc3333-0000-4000-8000-000000000001',
      'cccc4444-0000-4000-8000-000000000001',
      'cccc5555-0000-4000-8000-000000000001',
      '2026-11-10',
      '2027-01-20',
      7,
      1,
      25
    );
  $sql$,
  'User A can create subject study plan linked to own circular and exam date'
);

-- (9) Duplicate subject plan for the same user+subject rejected cleanly
SELECT throws_ok(
  $sql$
    INSERT INTO public.study_plans (
      user_id, subject_id, start_date, target_date
    ) VALUES (
      'cccc1111-1111-4111-8111-111111111111',
      'cccc3333-0000-4000-8000-000000000001',
      '2026-11-10',
      '2027-01-20'
    );
  $sql$,
  '23505',
  NULL,
  'User cannot create duplicate study plan for same subject'
);

-- (10) Negative buffer days rejected
SELECT throws_ok(
  $sql$
    UPDATE public.study_plans
       SET finish_buffer_days = -1
     WHERE id = 'cccc6666-0000-4000-8000-000000000001';
  $sql$,
  '23514',
  NULL,
  'study_plans rejects negative finish_buffer_days'
);

-- (11) Invalid rest_days_per_week = 7 rejected
SELECT throws_ok(
  $sql$
    UPDATE public.study_plans
       SET rest_days_per_week = 7
     WHERE id = 'cccc6666-0000-4000-8000-000000000001';
  $sql$,
  '23514',
  NULL,
  'study_plans rejects rest_days_per_week >= 7'
);

-- (12) Non-positive max_daily_pace rejected
SELECT throws_ok(
  $sql$
    UPDATE public.study_plans
       SET max_daily_pace = 0
     WHERE id = 'cccc6666-0000-4000-8000-000000000002';
  $sql$,
  '23514',
  NULL,
  'study_plans rejects max_daily_pace <= 0'
);

-- (13) User A can update extra_study_days and postponed_material_ids cleanly
SELECT lives_ok(
  $sql$
    UPDATE public.study_plans
       SET extra_study_days = 1,
           postponed_material_ids = ARRAY['11111111-1111-4111-8111-111111111111'::uuid]
     WHERE id = 'cccc6666-0000-4000-8000-000000000002';
  $sql$,
  'User A can update extra_study_days and postponed_material_ids'
);

-- ============================================================================
-- 3. User B Cross-User RLS & FK Isolation (Tests 14-20)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'dddd2222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"dddd2222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (14) User B cannot read User A study plans
SELECT is_empty(
  $$SELECT id FROM public.study_plans WHERE user_id = 'cccc1111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A study plans'
);

-- (15) User B cannot insert plan spoofing User A user_id
SELECT throws_ok(
  $sql$
    INSERT INTO public.study_plans (
      user_id, start_date, target_date
    ) VALUES (
      'cccc1111-1111-4111-8111-111111111111', '2026-11-10', '2027-01-20'
    );
  $sql$,
  '42501',
  NULL,
  'User B cannot insert study plan for User A'
);

-- (16) User B cannot link own plan to User A subject
SELECT throws_ok(
  $sql$
    INSERT INTO public.study_plans (
      user_id, subject_id, start_date, target_date
    ) VALUES (
      'dddd2222-2222-4222-8222-222222222222',
      'cccc3333-0000-4000-8000-000000000001',
      '2026-11-10',
      '2027-01-20'
    );
  $sql$,
  '23503',
  NULL,
  'User B cannot attach own study plan to User A subject'
);

-- (17) User B cannot link own plan to User A circular
SELECT throws_ok(
  $sql$
    INSERT INTO public.study_plans (
      user_id, circular_id, start_date, target_date
    ) VALUES (
      'dddd2222-2222-4222-8222-222222222222',
      'cccc4444-0000-4000-8000-000000000001',
      '2026-11-10',
      '2027-01-20'
    );
  $sql$,
  '23503',
  NULL,
  'User B cannot attach own study plan to User A circular'
);

-- (18) User B cannot link own plan to User A exam_date
SELECT throws_ok(
  $sql$
    INSERT INTO public.study_plans (
      user_id, exam_date_id, start_date, target_date
    ) VALUES (
      'dddd2222-2222-4222-8222-222222222222',
      'cccc5555-0000-4000-8000-000000000001',
      '2026-11-10',
      '2027-01-20'
    );
  $sql$,
  '23503',
  NULL,
  'User B cannot attach own study plan to User A exam date'
);

-- (19) User B cannot update User A study plan
SELECT is_empty(
  $sql$
    UPDATE public.study_plans
       SET finish_buffer_days = 0
     WHERE id = 'cccc6666-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot update User A study plan'
);

-- (20) User B cannot delete User A study plan
SELECT is_empty(
  $sql$
    DELETE FROM public.study_plans
     WHERE id = 'cccc6666-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot delete User A study plan'
);

-- ============================================================================
-- 4. Linked Record Lifecycle (Tests 21-23)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'cccc1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"cccc1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (21) Deleting circular nullifies circular_id/exam_date_id while preserving plan
SELECT lives_ok(
  $sql$
    DELETE FROM public.circulars
     WHERE id = 'cccc4444-0000-4000-8000-000000000001';
  $sql$,
  'Deleting linked circular preserves study_plans row with nullified links'
);

-- (22) Confirm User A plan survived with NULL circular_id and exam_date_id
SELECT is(
  (
    SELECT count(*)::integer
      FROM public.study_plans
     WHERE id = 'cccc6666-0000-4000-8000-000000000002'
       AND circular_id IS NULL
       AND exam_date_id IS NULL
  ),
  1,
  'Study plan clears circular_id and exam_date_id after circular deletion'
);

-- (23) Deleting parent subject cascades cleanly to subject study plan
SELECT lives_ok(
  $sql$
    DELETE FROM public.subjects
     WHERE id = 'cccc3333-0000-4000-8000-000000000001';
  $sql$,
  'Deleting parent subject cascades to subject study plan'
);

SELECT * FROM finish();

ROLLBACK;
