-- Phase 6F: pgTAP tests verifying `progress_logs.entry_type` default ('study'),
-- check constraint ('study' | 'correction'), completed_units recalculation
-- with backward corrections + clamping, study-only filtering, and RLS isolation.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(14);

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
    'aaaa6f01-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'book-user-a@example.test',
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
    'bbbb6f02-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'book-user-b@example.test',
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

-- (1-2) Schema metadata check
SELECT has_column(
  'public'::name,
  'progress_logs'::name,
  'entry_type'::name,
  'progress_logs has entry_type column'
);

SELECT col_default_is(
  'public'::name,
  'progress_logs'::name,
  'entry_type'::name,
  'study',
  'progress_logs.entry_type defaults to study'
);

-- Seed Subject & Book as User A
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', 'aaaa6f01-1111-4111-8111-111111111111', true);

INSERT INTO public.subjects (id, user_id, name) VALUES
  ('11116f01-0000-4000-8000-000000000001', 'aaaa6f01-1111-4111-8111-111111111111', 'Bangla Grammar');

INSERT INTO public.materials (id, user_id, subject_id, title, kind, unit_label, total_units) VALUES
  ('22226f01-0000-4000-8000-000000000001', 'aaaa6f01-1111-4111-8111-111111111111', '11116f01-0000-4000-8000-000000000001', 'MP3 Bangla', 'book', 'pages', 500);

-- (3) Omitting entry_type defaults row to 'study' and updates completed_units
INSERT INTO public.progress_logs (id, user_id, material_id, units_done, logged_on) VALUES
  ('33336f01-0000-4000-8000-000000000001', 'aaaa6f01-1111-4111-8111-111111111111', '22226f01-0000-4000-8000-000000000001', 200, '2026-11-10');

SELECT is(
  (SELECT entry_type FROM public.progress_logs WHERE id = '33336f01-0000-4000-8000-000000000001'),
  'study',
  'Inserted progress_logs row without entry_type defaults to study'
);

-- (4) Forward page increment (+45) updates material to 245
INSERT INTO public.progress_logs (id, user_id, material_id, units_done, entry_type, logged_on) VALUES
  ('33336f01-0000-4000-8000-000000000002', 'aaaa6f01-1111-4111-8111-111111111111', '22226f01-0000-4000-8000-000000000001', 45, 'study', '2026-11-11');

SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '22226f01-0000-4000-8000-000000000001'),
  245,
  'Forward book position log (+45 from 200) sets completed_units to 245'
);

-- (5) Check constraint rejects invalid entry_type
SELECT throws_ok(
  $$
  INSERT INTO public.progress_logs (user_id, material_id, units_done, entry_type, logged_on)
  VALUES ('aaaa6f01-1111-4111-8111-111111111111', '22226f01-0000-4000-8000-000000000001', 10, 'skipped', '2026-11-11');
  $$,
  '23514',
  NULL,
  'progress_logs rejects invalid entry_type outside study and correction'
);

-- (6) Backward correction (-65) reduces completed_units from 245 to 180
INSERT INTO public.progress_logs (id, user_id, material_id, units_done, entry_type, logged_on, note) VALUES
  ('33336f01-0000-4000-8000-000000000003', 'aaaa6f01-1111-4111-8111-111111111111', '22226f01-0000-4000-8000-000000000001', -65, 'correction', '2026-11-11', 'Reset to chapter start');

SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '22226f01-0000-4000-8000-000000000001'),
  180,
  'Correction entry (-65) updates material completed_units to 180'
);

-- (7) Filtering study rows preserves studied unit total (245) untouched by correction
SELECT is(
  (SELECT COALESCE(SUM(units_done), 0)::integer FROM public.progress_logs WHERE material_id = '22226f01-0000-4000-8000-000000000001' AND entry_type = 'study'),
  245,
  'Studied units filter excludes correction rows'
);

-- (8) Excess negative correction clamps completed_units at 0 cleanly
INSERT INTO public.progress_logs (id, user_id, material_id, units_done, entry_type, logged_on) VALUES
  ('33336f01-0000-4000-8000-000000000004', 'aaaa6f01-1111-4111-8111-111111111111', '22226f01-0000-4000-8000-000000000001', -500, 'correction', '2026-11-11');

SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '22226f01-0000-4000-8000-000000000001'),
  0,
  'Large negative correction clamps materials.completed_units at 0'
);

DELETE FROM public.progress_logs WHERE id = '33336f01-0000-4000-8000-000000000004';

SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '22226f01-0000-4000-8000-000000000001'),
  180,
  'Deleting excess correction restores materials.completed_units to 180'
);

-- (10-14) Cross-user RLS isolation on study and correction rows
SELECT set_config('request.jwt.claim.sub', 'bbbb6f02-2222-4222-8222-222222222222', true);

SELECT is(
  (SELECT count(*)::integer FROM public.progress_logs WHERE material_id = '22226f01-0000-4000-8000-000000000001'),
  0,
  'User B cannot read User A study or correction progress_logs'
);

SELECT throws_ok(
  $$
  INSERT INTO public.progress_logs (user_id, material_id, units_done, entry_type, logged_on)
  VALUES ('bbbb6f02-2222-4222-8222-222222222222', '22226f01-0000-4000-8000-000000000001', -10, 'correction', '2026-11-11');
  $$,
  NULL,
  NULL,
  'User B cannot insert a correction entry referencing User A material'
);

SELECT throws_ok(
  $$
  INSERT INTO public.progress_logs (user_id, material_id, units_done, entry_type, logged_on)
  VALUES ('aaaa6f01-1111-4111-8111-111111111111', '22226f01-0000-4000-8000-000000000001', -10, 'correction', '2026-11-11');
  $$,
  '42501',
  NULL,
  'User B cannot spoof User A user_id to write correction progress_logs'
);

UPDATE public.progress_logs
SET units_done = 999
WHERE id = '33336f01-0000-4000-8000-000000000003';

DELETE FROM public.progress_logs
WHERE id = '33336f01-0000-4000-8000-000000000003';

-- Switch back to User A and verify correction row was completely untouched
SELECT set_config('request.jwt.claim.sub', 'aaaa6f01-1111-4111-8111-111111111111', true);

SELECT is(
  (SELECT units_done FROM public.progress_logs WHERE id = '33336f01-0000-4000-8000-000000000003'),
  -65,
  'User B cannot update or delete User A correction progress_log'
);

SELECT is(
  (SELECT completed_units FROM public.materials WHERE id = '22226f01-0000-4000-8000-000000000001'),
  180,
  'User A material completed_units remains intact after unauthorized modification attempts'
);

SELECT * FROM finish();
ROLLBACK;
