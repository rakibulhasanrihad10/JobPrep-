-- Phase 6H: pgTAP tests verifying `study_sessions` schema, defaults, check
-- constraints, owner-verified FKs, indexes, and RLS isolation.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(20);

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
    'eeee6801-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'timer-user-a@example.test',
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
    'ffff6802-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'timer-user-b@example.test',
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

-- (1-6) Table existence, RLS, indexes, defaults
SELECT has_table('public'::name, 'study_sessions'::name, 'study_sessions table exists');
SELECT ok(
  (
    SELECT c.relrowsecurity
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'study_sessions'
  ),
  'RLS is enabled on public.study_sessions'
);
SELECT has_index('public'::name, 'study_sessions'::name, 'idx_study_sessions_user_id'::name, 'index exists on user_id');
SELECT has_index('public'::name, 'study_sessions'::name, 'idx_study_sessions_user_started_at'::name, 'index exists on (user_id, started_at)');
SELECT has_index('public'::name, 'study_sessions'::name, 'idx_study_sessions_active_open'::name, 'partial open-session index exists');
SELECT col_default_is('public'::name, 'study_sessions'::name, 'duration_seconds'::name, '0', 'duration_seconds defaults to 0');

-- Seed User A & User B subjects/materials
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', 'eeee6801-1111-4111-8111-111111111111', true);

INSERT INTO public.subjects (id, user_id, name) VALUES
  ('11116801-1111-4111-8111-111111111111', 'eeee6801-1111-4111-8111-111111111111', 'Mathematics');

INSERT INTO public.materials (id, user_id, subject_id, title, total_units, completed_units) VALUES
  ('22226801-1111-4111-8111-111111111111', 'eeee6801-1111-4111-8111-111111111111', '11116801-1111-4111-8111-111111111111', 'Algebra Book', 300, 100);

SELECT set_config('request.jwt.claim.sub', 'ffff6802-2222-4222-8222-222222222222', true);

INSERT INTO public.subjects (id, user_id, name) VALUES
  ('33336802-2222-4222-8222-222222222222', 'ffff6802-2222-4222-8222-222222222222', 'English');

-- Switch back to User A
SELECT set_config('request.jwt.claim.sub', 'eeee6801-1111-4111-8111-111111111111', true);

-- (7-9) Valid inserts: open focus session, completed stopwatch session, manual session
SELECT lives_ok(
  $$
  INSERT INTO public.study_sessions (
    id, subject_id, material_id, started_at, ended_at, duration_seconds, mode,
    pause_intervals, pomodoro_round, pomodoro_phase, target_duration_seconds
  ) VALUES (
    'aaaa6801-1111-4111-8111-111111111111',
    '11116801-1111-4111-8111-111111111111',
    '22226801-1111-4111-8111-111111111111',
    '2026-11-11T09:00:00Z',
    NULL,
    0,
    'focus',
    '[{"paused_at":"2026-11-11T09:10:00Z","resumed_at":"2026-11-11T09:12:00Z"}]'::jsonb,
    1,
    'focus',
    1500
  );
  $$,
  'User A can start an open focus session with pause_intervals'
);

SELECT lives_ok(
  $$
  INSERT INTO public.study_sessions (
    id, subject_id, material_id, started_at, ended_at, duration_seconds, mode, note
  ) VALUES (
    'aaaa6802-1111-4111-8111-111111111111',
    '11116801-1111-4111-8111-111111111111',
    NULL,
    '2026-11-10T17:45:00Z',
    '2026-11-10T18:15:00Z',
    1800,
    'stopwatch',
    'Evening problem set'
  );
  $$,
  'User A can insert a completed stopwatch session without material_id'
);

SELECT lives_ok(
  $$
  INSERT INTO public.study_sessions (
    id, subject_id, started_at, ended_at, duration_seconds, mode, note
  ) VALUES (
    'aaaa6803-1111-4111-8111-111111111111',
    '11116801-1111-4111-8111-111111111111',
    '2026-11-09T14:00:00Z',
    '2026-11-09T15:00:00Z',
    3600,
    'manual',
    'Offline coaching class'
  );
  $$,
  'User A can log a manual session'
);

-- (10-14) CHECK constraints
SELECT throws_ok(
  $$
  INSERT INTO public.study_sessions (subject_id, started_at, duration_seconds, mode)
  VALUES ('11116801-1111-4111-8111-111111111111', now(), -10, 'manual');
  $$,
  '23514',
  NULL,
  'Negative duration_seconds is rejected'
);

SELECT throws_ok(
  $$
  INSERT INTO public.study_sessions (subject_id, started_at, duration_seconds, mode)
  VALUES ('11116801-1111-4111-8111-111111111111', now(), 60, 'invalid_mode');
  $$,
  '23514',
  NULL,
  'Invalid study_sessions mode is rejected'
);

SELECT throws_ok(
  $$
  INSERT INTO public.study_sessions (subject_id, started_at, ended_at, duration_seconds, mode)
  VALUES (
    '11116801-1111-4111-8111-111111111111',
    '2026-11-11T10:00:00Z',
    '2026-11-11T09:50:00Z',
    60,
    'stopwatch'
  );
  $$,
  '23514',
  NULL,
  'ended_at earlier than started_at is rejected'
);

SELECT throws_ok(
  $$
  INSERT INTO public.study_sessions (subject_id, started_at, duration_seconds, mode, pause_intervals)
  VALUES ('11116801-1111-4111-8111-111111111111', now(), 0, 'focus', '{}'::jsonb);
  $$,
  '23514',
  NULL,
  'Non-array pause_intervals JSON is rejected'
);

SELECT throws_ok(
  $$
  INSERT INTO public.study_sessions (subject_id, started_at, duration_seconds, mode)
  VALUES ('33336802-2222-4222-8222-222222222222', now(), 120, 'manual');
  $$,
  '23503',
  NULL,
  'User A cannot link User B subject via foreign key'
);

-- (15-20) RLS isolation
SELECT is(
  (SELECT count(*)::integer FROM public.study_sessions),
  3,
  'User A sees all 3 own sessions'
);

SELECT set_config('request.jwt.claim.sub', 'ffff6802-2222-4222-8222-222222222222', true);

SELECT is(
  (SELECT count(*)::integer FROM public.study_sessions),
  0,
  'User B cannot read User A study sessions'
);

SELECT throws_ok(
  $$
  INSERT INTO public.study_sessions (user_id, subject_id, started_at, duration_seconds, mode)
  VALUES (
    'eeee6801-1111-4111-8111-111111111111',
    '33336802-2222-4222-8222-222222222222',
    now(),
    300,
    'manual'
  );
  $$,
  '42501',
  NULL,
  'User B cannot insert study session spoofed as User A'
);

WITH updated AS (
  UPDATE public.study_sessions
  SET note = 'tampered'
  WHERE id = 'aaaa6801-1111-4111-8111-111111111111'
  RETURNING id
)
SELECT is((SELECT count(*)::integer FROM updated), 0, 'User B cannot update User A session');

WITH deleted AS (
  DELETE FROM public.study_sessions
  WHERE id = 'aaaa6802-1111-4111-8111-111111111111'
  RETURNING id
)
SELECT is((SELECT count(*)::integer FROM deleted), 0, 'User B cannot delete User A session');

SELECT set_config('request.jwt.claim.sub', 'eeee6801-1111-4111-8111-111111111111', true);
SELECT is(
  (SELECT count(*)::integer FROM public.study_sessions),
  3,
  'User A still owns all 3 unmodified sessions'
);

SELECT * FROM finish();

ROLLBACK;
