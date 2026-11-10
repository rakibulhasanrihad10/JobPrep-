-- Phase 4A: pgTAP tests verifying preparation tables, progress recalculation
-- trigger bounds [0, total_units], division-by-zero guards on progress views,
-- the 300/300/400 book example (100% book one, 30% subject), and RLS isolation.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(42);

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
    '99991111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'prep-user-a@example.test',
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
    '99992222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'prep-user-b@example.test',
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

-- ============================================================================
-- 1. Schema, Views, Trigger, and RLS Metadata (Tests 1-14)
-- ============================================================================
-- (1-5) Tables exist
SELECT has_table('public'::name, 'subjects'::name, 'subjects table exists');
SELECT has_table('public'::name, 'materials'::name, 'materials table exists');
SELECT has_table('public'::name, 'progress_logs'::name, 'progress_logs table exists');
SELECT has_table('public'::name, 'topics'::name, 'topics table exists');
SELECT has_table('public'::name, 'circular_subjects'::name, 'circular_subjects table exists');

-- (6-7) Views exist
SELECT has_view('public'::name, 'material_progress'::name, 'material_progress view exists');
SELECT has_view('public'::name, 'subject_progress'::name, 'subject_progress view exists');

-- (8) Trigger exists on progress_logs
SELECT has_trigger(
  'public'::name,
  'progress_logs'::name,
  'recalculate_material_completed_units_trigger'::name,
  'progress_logs has trigger recalculating materials.completed_units'
);

-- (9-13) RLS enabled on all 5 tables
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'subjects'),
  'RLS is enabled on public.subjects'
);
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'materials'),
  'RLS is enabled on public.materials'
);
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'progress_logs'),
  'RLS is enabled on public.progress_logs'
);
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'topics'),
  'RLS is enabled on public.topics'
);
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'circular_subjects'),
  'RLS is enabled on public.circular_subjects'
);

-- (14) Progress views invoke caller permissions (security_invoker = true)
SELECT is(
  (
    SELECT count(*)::integer
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname IN ('material_progress', 'subject_progress')
      AND 'security_invoker=true' = ANY(c.reloptions)
  ),
  2,
  'Both material_progress and subject_progress use security_invoker=true'
);

-- ============================================================================
-- 2. Trigger & View Behavior Under User A (Tests 15-28)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '99991111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"99991111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (15) User A can insert empty subject, zero-unit subject/material, and circular
SELECT lives_ok(
  $sql$
    INSERT INTO public.circulars (id, user_id, title)
    VALUES (
      '9999aaaa-0000-4000-8000-000000000001',
      '99991111-1111-4111-8111-111111111111',
      '47th BCS Circular'
    );
    INSERT INTO public.subjects (id, user_id, name, exam_type)
    VALUES
      ('99991111-0000-4000-8000-000000000001', '99991111-1111-4111-8111-111111111111', 'Empty Subject', 'bcs'),
      ('99991111-0000-4000-8000-000000000002', '99991111-1111-4111-8111-111111111111', 'Zero Unit Subject', 'bcs');
    INSERT INTO public.materials (id, user_id, subject_id, title, total_units)
    VALUES (
      '99992222-0000-4000-8000-000000000000',
      '99991111-1111-4111-8111-111111111111',
      '99991111-0000-4000-8000-000000000002',
      'Zero Page Placeholder',
      0
    );
  $sql$,
  'User A can create subjects with no materials or zero total_units'
);

-- (16) Division-by-zero guard on material_progress when total_units = 0
SELECT is(
  (
    SELECT progress::numeric(10, 2)::text || '|' ||
           progress_percent::numeric(10, 2)::text
    FROM public.material_progress
    WHERE material_id = '99992222-0000-4000-8000-000000000000'
  ),
  '0.00|0.00',
  'material_progress guards against division by zero when total_units = 0'
);

-- (17) Division-by-zero guard on subject_progress with no materials & zero units
SELECT is(
  (
    SELECT count(*)::integer
    FROM public.subject_progress
    WHERE subject_id IN (
      '99991111-0000-4000-8000-000000000001',
      '99991111-0000-4000-8000-000000000002'
    )
      AND progress = 0
      AND progress_percent = 0
  ),
  2,
  'subject_progress guards against division by zero for empty and 0-unit subjects'
);

-- (18) Three books example setup: 300, 300, and 400 pages under one subject
SELECT lives_ok(
  $sql$
    INSERT INTO public.subjects (id, user_id, name, color, icon, exam_type, sort_order)
    VALUES (
      '99991111-0000-4000-8000-000000000003',
      '99991111-1111-4111-8111-111111111111',
      'Bangladesh Affairs',
      '#E5A93C',
      'menu_book',
      'bcs',
      1
    );
    INSERT INTO public.materials (id, user_id, subject_id, title, kind, unit_label, total_units)
    VALUES
      ('99992222-0000-4000-8000-000000000001', '99991111-1111-4111-8111-111111111111', '99991111-0000-4000-8000-000000000003', 'Book One', 'book', 'pages', 300),
      ('99992222-0000-4000-8000-000000000002', '99991111-1111-4111-8111-111111111111', '99991111-0000-4000-8000-000000000003', 'Book Two', 'book', 'pages', 300),
      ('99992222-0000-4000-8000-000000000003', '99991111-1111-4111-8111-111111111111', '99991111-0000-4000-8000-000000000003', 'Book Three', 'book', 'pages', 400);
  $sql$,
  'User A creates subject with three books of 300, 300, and 400 pages'
);

-- (19) Finish Book One via two progress_logs inserts (150 + 150 = 300)
SELECT lives_ok(
  $sql$
    INSERT INTO public.progress_logs (id, user_id, material_id, units_done, logged_on, note)
    VALUES
      ('99993333-0000-4000-8000-000000000001', '99991111-1111-4111-8111-111111111111', '99992222-0000-4000-8000-000000000001', 150, '2026-11-09', 'Part 1'),
      ('99993333-0000-4000-8000-000000000002', '99991111-1111-4111-8111-111111111111', '99992222-0000-4000-8000-000000000001', 150, '2026-11-10', 'Finished Book One');
  $sql$,
  'Inserting progress_logs triggers completed_units recalculation'
);

-- (20) materials.completed_units updated cleanly to 300
SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '99992222-0000-4000-8000-000000000001'),
  300,
  'Book One completed_units is recalculated to 300'
);

-- (21) Finishing Book One gives 100% (progress = 1.00) in material_progress
SELECT is(
  (
    SELECT progress::numeric(10, 2)::text || '|' ||
           progress_percent::numeric(10, 2)::text
    FROM public.material_progress
    WHERE material_id = '99992222-0000-4000-8000-000000000001'
  ),
  '1.00|100.00',
  'Book One material_progress is 1.00 (100.00%)'
);

-- (22) Subject total (300 of 1000) gives 30% (0.30) in subject_progress
SELECT is(
  (
    SELECT completed_units::text || '|' || total_units::text || '|' ||
           progress::numeric(10, 2)::text || '|' ||
           progress_percent::numeric(10, 2)::text
    FROM public.subject_progress
    WHERE subject_id = '99991111-0000-4000-8000-000000000003'
  ),
  '300|1000|0.30|30.00',
  'Subject progress across 300, 300, and 400 page books is 300/1000 (30.00%)'
);

-- (23) Trigger never lets completed_units exceed total_units
INSERT INTO public.progress_logs (id, user_id, material_id, units_done, note)
VALUES ('99993333-0000-4000-8000-000000000003', '99991111-1111-4111-8111-111111111111', '99992222-0000-4000-8000-000000000001', 250, 'Overflow test');

SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '99992222-0000-4000-8000-000000000001'),
  300,
  'Trigger clamps completed_units at total_units (300) when logs exceed total'
);

-- (24) Trigger recalculates BOTH OLD and NEW material on progress_logs UPDATE
UPDATE public.progress_logs
   SET material_id = '99992222-0000-4000-8000-000000000002',
       units_done = 50
 WHERE id = '99993333-0000-4000-8000-000000000003';

SELECT is(
  (
    SELECT completed_units::text || '|' || total_units::text || '|' ||
           progress::numeric(10, 2)::text || '|' ||
           progress_percent::numeric(10, 2)::text
    FROM public.subject_progress
    WHERE subject_id = '99991111-0000-4000-8000-000000000003'
  ),
  '350|1000|0.35|35.00',
  'Updating progress_logs recalculates both old and new materials (subject 35.00%)'
);

-- (25) Trigger never lets completed_units go below 0
INSERT INTO public.progress_logs (id, user_id, material_id, units_done, note)
VALUES ('99993333-0000-4000-8000-000000000004', '99991111-1111-4111-8111-111111111111', '99992222-0000-4000-8000-000000000002', -200, 'Negative correction test');

SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '99992222-0000-4000-8000-000000000002'),
  0,
  'Trigger clamps completed_units at 0 when sum of logs becomes negative'
);

-- (26) Trigger recalculates accurately on DELETE
DELETE FROM public.progress_logs
 WHERE id IN (
   '99993333-0000-4000-8000-000000000002',
   '99993333-0000-4000-8000-000000000003',
   '99993333-0000-4000-8000-000000000004'
 );

SELECT is(
  (
    SELECT completed_units::text || '|' || total_units::text || '|' ||
           progress::numeric(10, 2)::text || '|' ||
           progress_percent::numeric(10, 2)::text
    FROM public.subject_progress
    WHERE subject_id = '99991111-0000-4000-8000-000000000003'
  ),
  '150|1000|0.15|15.00',
  'Deleting progress_logs recalculates material and subject progress (15.00%)'
);

-- (27) Topics create and status update
SELECT lives_ok(
  $sql$
    INSERT INTO public.topics (id, user_id, subject_id, name, status)
    VALUES ('99994444-0000-4000-8000-000000000001', '99991111-1111-4111-8111-111111111111', '99991111-0000-4000-8000-000000000003', 'Liberation War History', 'not_started');
    UPDATE public.topics SET status = 'completed' WHERE id = '99994444-0000-4000-8000-000000000001';
  $sql$,
  'User A can create and update topics'
);

-- (28) circular_subjects links User A circular to User A subject
SELECT lives_ok(
  $sql$
    INSERT INTO public.circular_subjects (id, user_id, circular_id, subject_id)
    VALUES ('99995555-0000-4000-8000-000000000001', '99991111-1111-4111-8111-111111111111', '9999aaaa-0000-4000-8000-000000000001', '99991111-0000-4000-8000-000000000003');
  $sql$,
  'User A can link own circular and subject in circular_subjects'
);

-- ============================================================================
-- 3. Multi-User RLS & Cross-Tenant Isolation (Tests 29-42)
-- ============================================================================
-- Switch to User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '99992222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"99992222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (29) User B can create own subject and material
SELECT lives_ok(
  $sql$
    INSERT INTO public.subjects (id, user_id, name)
    VALUES ('99991111-0000-4000-8000-000000000099', '99992222-2222-4222-8222-222222222222', 'English Literature');
    INSERT INTO public.materials (id, user_id, subject_id, title, total_units)
    VALUES ('99992222-0000-4000-8000-000000000099', '99992222-2222-4222-8222-222222222222', '99991111-0000-4000-8000-000000000099', 'User B Book', 200);
  $sql$,
  'User B can insert own prep subjects and materials'
);

-- (30-31) Anonymous role isolation across tables and views
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{"role":"anon"}';
SET LOCAL ROLE anon;

SELECT is_empty(
  $sql$
    SELECT id FROM public.subjects
    UNION ALL SELECT id FROM public.materials
    UNION ALL SELECT id FROM public.progress_logs
    UNION ALL SELECT id FROM public.topics
    UNION ALL SELECT id FROM public.circular_subjects
  $sql$,
  'Anonymous role cannot read any prep tables'
);

SELECT is_empty(
  $sql$
    SELECT id FROM public.material_progress
    UNION ALL SELECT id FROM public.subject_progress
  $sql$,
  'Anonymous role cannot read material_progress or subject_progress views'
);

-- Switch back to authenticated User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '99992222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"99992222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (32-38) User B cannot read User A rows across any table or progress view
SELECT is_empty(
  $$SELECT id FROM public.subjects WHERE user_id = '99991111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A subjects'
);
SELECT is_empty(
  $$SELECT id FROM public.materials WHERE user_id = '99991111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A materials'
);
SELECT is_empty(
  $$SELECT id FROM public.progress_logs WHERE user_id = '99991111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A progress_logs'
);
SELECT is_empty(
  $$SELECT id FROM public.topics WHERE user_id = '99991111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A topics'
);
SELECT is_empty(
  $$SELECT id FROM public.circular_subjects WHERE user_id = '99991111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A circular_subjects'
);
SELECT is_empty(
  $$SELECT id FROM public.material_progress WHERE user_id = '99991111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A rows from material_progress view'
);
SELECT is_empty(
  $$SELECT id FROM public.subject_progress WHERE user_id = '99991111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A rows from subject_progress view'
);

-- (39-40) User B cannot update or delete User A rows
SELECT is_empty(
  $sql$
    UPDATE public.materials
       SET title = 'Tampered'
     WHERE id = '99992222-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot update User A materials'
);
SELECT is_empty(
  $sql$
    DELETE FROM public.progress_logs
     WHERE id = '99993333-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot delete User A progress_logs'
);

-- (41) User B cannot link own material to User A subject (composite FK)
SELECT throws_ok(
  $sql$
    INSERT INTO public.materials (user_id, subject_id, title, total_units)
    VALUES (
      '99992222-2222-4222-8222-222222222222',
      '99991111-0000-4000-8000-000000000003',
      'Cross-tenant Material',
      100
    )
  $sql$,
  '23503',
  NULL,
  'Composite FK blocks attaching a material to another user subject'
);

-- (42) User B cannot forge user_id = User A on insert (RLS WITH CHECK)
SELECT throws_ok(
  $sql$
    INSERT INTO public.subjects (user_id, name)
    VALUES ('99991111-1111-4111-8111-111111111111', 'Spoofed Subject')
  $sql$,
  '42501',
  NULL,
  'User B cannot insert a subject under User A user_id'
);

SELECT * FROM finish();

ROLLBACK;
