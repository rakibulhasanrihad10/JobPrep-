-- Phase 3A: pgTAP schema, constraint, trigger, and RLS isolation tests for
-- public.circulars, public.circular_exam_dates, and public.circular_files.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(62);

-- ============================================================================
-- 1. Seed two isolated mock users and sample records as postgres (setup only)
-- ============================================================================
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
    '11111111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'user-a@example.test',
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
    '22222222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'user-b@example.test',
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

-- Give User A's initial rows timestamps in the past so updated_at trigger tests
-- can prove BEFORE UPDATE advances updated_at inside this single transaction.
INSERT INTO public.circulars (
  id,
  user_id,
  title,
  sector,
  organization_name,
  application_status,
  admit_card_status,
  priority,
  workflow_status,
  created_at,
  updated_at
) VALUES
  (
    'aaaa1111-1111-4111-8111-111111111111',
    '11111111-1111-4111-8111-111111111111',
    'User A BCS Circular',
    'bcs',
    'BPSC',
    'not_applied',
    'not_available',
    'high',
    'preparing',
    now() - interval '1 hour',
    now() - interval '1 hour'
  ),
  (
    'bbbb2222-2222-4222-8222-222222222222',
    '22222222-2222-4222-8222-222222222222',
    'User B Bank Circular',
    'bank',
    'Bangladesh Bank',
    'applied',
    'available',
    'urgent',
    'exam_upcoming',
    now() - interval '1 hour',
    now() - interval '1 hour'
  );

INSERT INTO public.circular_exam_dates (
  id,
  circular_id,
  user_id,
  stage,
  exam_date,
  venue,
  created_at,
  updated_at
) VALUES
  (
    'aaaa1111-2222-4111-8111-111111111111',
    'aaaa1111-1111-4111-8111-111111111111',
    '11111111-1111-4111-8111-111111111111',
    'Preliminary',
    now() + interval '14 days',
    'Eden College',
    now() - interval '1 hour',
    now() - interval '1 hour'
  ),
  (
    'bbbb2222-3333-4222-8222-222222222222',
    'bbbb2222-2222-4222-8222-222222222222',
    '22222222-2222-4222-8222-222222222222',
    'Written',
    now() + interval '21 days',
    'Dhaka College',
    now() - interval '1 hour',
    now() - interval '1 hour'
  );

INSERT INTO public.circular_files (
  id,
  circular_id,
  user_id,
  storage_path,
  file_name,
  mime_type,
  size_bytes,
  created_at,
  updated_at
) VALUES
  (
    'aaaa1111-4444-4111-8111-111111111111',
    'aaaa1111-1111-4111-8111-111111111111',
    '11111111-1111-4111-8111-111111111111',
    '11111111-1111-4111-8111-111111111111/bcs-circular.pdf',
    'bcs-circular.pdf',
    'application/pdf',
    204800,
    now() - interval '1 hour',
    now() - interval '1 hour'
  ),
  (
    'bbbb2222-4444-4222-8222-222222222222',
    'bbbb2222-2222-4222-8222-222222222222',
    '22222222-2222-4222-8222-222222222222',
    '22222222-2222-4222-8222-222222222222/bank-admit.pdf',
    'bank-admit.pdf',
    'application/pdf',
    102400,
    now() - interval '1 hour',
    now() - interval '1 hour'
  );

-- ============================================================================
-- 2. Schema structure: tables, indexes, triggers, and RLS enabled (Tests 1-18)
-- ============================================================================
-- (1-3) Tables exist
SELECT has_table('public'::name, 'circulars'::name, 'circulars table exists');
SELECT has_table('public'::name, 'circular_exam_dates'::name, 'circular_exam_dates table exists');
SELECT has_table('public'::name, 'circular_files'::name, 'circular_files table exists');

-- (4-12) Required indexes exist on expected columns
SELECT has_index('public'::name, 'circulars'::name, 'idx_circulars_user_id'::name, ARRAY['user_id']::name[], 'circulars indexes user_id');
SELECT has_index('public'::name, 'circulars'::name, 'idx_circulars_deadline'::name, ARRAY['deadline']::name[], 'circulars indexes deadline');
SELECT has_index('public'::name, 'circulars'::name, 'idx_circulars_workflow_status'::name, ARRAY['workflow_status']::name[], 'circulars indexes workflow_status');
SELECT has_index('public'::name, 'circulars'::name, 'idx_circulars_user_status_deadline'::name, ARRAY['user_id', 'workflow_status', 'deadline']::name[], 'circulars indexes user_id, workflow_status, and deadline');
SELECT has_index('public'::name, 'circular_exam_dates'::name, 'idx_circular_exam_dates_user_id'::name, ARRAY['user_id']::name[], 'circular_exam_dates indexes user_id');
SELECT has_index('public'::name, 'circular_exam_dates'::name, 'idx_circular_exam_dates_circular_id'::name, ARRAY['circular_id']::name[], 'circular_exam_dates indexes circular_id');
SELECT has_index('public'::name, 'circular_exam_dates'::name, 'idx_circular_exam_dates_exam_date'::name, ARRAY['exam_date']::name[], 'circular_exam_dates indexes exam_date');
SELECT has_index('public'::name, 'circular_files'::name, 'idx_circular_files_user_id'::name, ARRAY['user_id']::name[], 'circular_files indexes user_id');
SELECT has_index('public'::name, 'circular_files'::name, 'idx_circular_files_circular_id'::name, ARRAY['circular_id']::name[], 'circular_files indexes circular_id');

-- (13-15) updated_at triggers exist
SELECT has_trigger('public'::name, 'circulars'::name, 'set_circulars_updated_at'::name, 'circulars has updated_at trigger');
SELECT has_trigger('public'::name, 'circular_exam_dates'::name, 'set_circular_exam_dates_updated_at'::name, 'circular_exam_dates has updated_at trigger');
SELECT has_trigger('public'::name, 'circular_files'::name, 'set_circular_files_updated_at'::name, 'circular_files has updated_at trigger');

-- (16-18) Row Level Security enabled on every table
SELECT ok(
  (
    SELECT c.relrowsecurity
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'circulars'
  ),
  'RLS is enabled on public.circulars'
);
SELECT ok(
  (
    SELECT c.relrowsecurity
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'circular_exam_dates'
  ),
  'RLS is enabled on public.circular_exam_dates'
);
SELECT ok(
  (
    SELECT c.relrowsecurity
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relname = 'circular_files'
  ),
  'RLS is enabled on public.circular_files'
);

-- ============================================================================
-- 3. Check constraints (Tests 19-25, tested as authenticated User A)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (19)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title, sector)
    VALUES ('11111111-1111-4111-8111-111111111111', 'Invalid Sector', 'freelance')
  $sql$,
  '23514',
  NULL,
  'circulars rejects invalid sector values'
);
-- (20)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title, application_status)
    VALUES ('11111111-1111-4111-8111-111111111111', 'Invalid App Status', 'submitted')
  $sql$,
  '23514',
  NULL,
  'circulars rejects invalid application_status values'
);
-- (21)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title, admit_card_status)
    VALUES ('11111111-1111-4111-8111-111111111111', 'Invalid Admit Status', 'pending')
  $sql$,
  '23514',
  NULL,
  'circulars rejects invalid admit_card_status values'
);
-- (22)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title, priority)
    VALUES ('11111111-1111-4111-8111-111111111111', 'Invalid Priority', 'critical')
  $sql$,
  '23514',
  NULL,
  'circulars rejects invalid priority values'
);
-- (23)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title, workflow_status)
    VALUES ('11111111-1111-4111-8111-111111111111', 'Invalid Workflow', 'done')
  $sql$,
  '23514',
  NULL,
  'circulars rejects invalid workflow_status values'
);
-- (24)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title, salary_min, salary_max)
    VALUES ('11111111-1111-4111-8111-111111111111', 'Bad Salary Range', 50000, 30000)
  $sql$,
  '23514',
  NULL,
  'circulars rejects salary_max lower than salary_min'
);
-- (25)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circular_files (circular_id, user_id, storage_path, file_name, mime_type, size_bytes)
    VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      '11111111-1111-4111-8111-111111111111',
      '11111111-1111-4111-8111-111111111111/bad.pdf',
      'bad.pdf',
      'application/pdf',
      -1
    )
  $sql$,
  '23514',
  NULL,
  'circular_files rejects negative size_bytes'
);

-- ============================================================================
-- 4. Anonymous role isolation (Tests 26-31)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{}';
SET LOCAL ROLE anon;

-- (26-28)
SELECT results_eq(
  $sql$ SELECT count(*)::integer FROM public.circulars $sql$,
  ARRAY[0],
  'anon cannot read circulars'
);
SELECT results_eq(
  $sql$ SELECT count(*)::integer FROM public.circular_exam_dates $sql$,
  ARRAY[0],
  'anon cannot read circular_exam_dates'
);
SELECT results_eq(
  $sql$ SELECT count(*)::integer FROM public.circular_files $sql$,
  ARRAY[0],
  'anon cannot read circular_files'
);

-- (29-31)
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title)
    VALUES ('11111111-1111-4111-8111-111111111111', 'Anon Circular')
  $sql$,
  '42501',
  NULL,
  'anon cannot insert into circulars'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.circular_exam_dates (circular_id, user_id, stage, exam_date)
    VALUES ('aaaa1111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'Viva', now())
  $sql$,
  '42501',
  NULL,
  'anon cannot insert into circular_exam_dates'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.circular_files (circular_id, user_id, storage_path, file_name, mime_type, size_bytes)
    VALUES ('aaaa1111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'x/y.pdf', 'y.pdf', 'application/pdf', 10)
  $sql$,
  '42501',
  NULL,
  'anon cannot insert into circular_files'
);

-- ============================================================================
-- 5. User A cannot read, insert for, cross-link, update, or delete User B rows
--    (Tests 32-46)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (32-34) SELECT only returns User A's rows, never User B's rows
SELECT results_eq(
  $sql$ SELECT id FROM public.circulars ORDER BY id $sql$,
  ARRAY['aaaa1111-1111-4111-8111-111111111111'::uuid],
  'User A only reads own circulars'
);
SELECT results_eq(
  $sql$ SELECT id FROM public.circular_exam_dates ORDER BY id $sql$,
  ARRAY['aaaa1111-2222-4111-8111-111111111111'::uuid],
  'User A only reads own circular_exam_dates'
);
SELECT results_eq(
  $sql$ SELECT id FROM public.circular_files ORDER BY id $sql$,
  ARRAY['aaaa1111-4444-4111-8111-111111111111'::uuid],
  'User A only reads own circular_files'
);

-- (35-39) INSERT impersonation and cross-tenant child attachment blocked
SELECT throws_ok(
  $sql$
    INSERT INTO public.circulars (user_id, title)
    VALUES ('22222222-2222-4222-8222-222222222222', 'Spoofed Circular')
  $sql$,
  '42501',
  NULL,
  'User A cannot insert circular owned by User B'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.circular_exam_dates (circular_id, user_id, stage, exam_date)
    VALUES ('bbbb2222-2222-4222-8222-222222222222', '22222222-2222-4222-8222-222222222222', 'Viva', now())
  $sql$,
  '42501',
  NULL,
  'User A cannot insert exam date owned by User B'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.circular_exam_dates (circular_id, user_id, stage, exam_date)
    VALUES ('bbbb2222-2222-4222-8222-222222222222', '11111111-1111-4111-8111-111111111111', 'Viva', now())
  $sql$,
  '23503',
  NULL,
  'User A cannot attach own exam date to User B circular'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.circular_files (circular_id, user_id, storage_path, file_name, mime_type, size_bytes)
    VALUES (
      'bbbb2222-2222-4222-8222-222222222222',
      '22222222-2222-4222-8222-222222222222',
      '22222222-2222-4222-8222-222222222222/spoof.pdf',
      'spoof.pdf',
      'application/pdf',
      100
    )
  $sql$,
  '42501',
  NULL,
  'User A cannot insert circular file owned by User B'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.circular_files (circular_id, user_id, storage_path, file_name, mime_type, size_bytes)
    VALUES (
      'bbbb2222-2222-4222-8222-222222222222',
      '11111111-1111-4111-8111-111111111111',
      '11111111-1111-4111-8111-111111111111/cross.pdf',
      'cross.pdf',
      'application/pdf',
      100
    )
  $sql$,
  '23503',
  NULL,
  'User A cannot attach own circular file to User B circular'
);

-- (40-43) UPDATE isolation: cannot modify User B's rows or transfer ownership
SELECT is_empty(
  $sql$
    UPDATE public.circulars
    SET title = 'Hacked by A'
    WHERE id = 'bbbb2222-2222-4222-8222-222222222222'
    RETURNING id
  $sql$,
  'User A cannot update User B circular'
);
SELECT throws_ok(
  $sql$
    UPDATE public.circulars
    SET user_id = '22222222-2222-4222-8222-222222222222'
    WHERE id = 'aaaa1111-1111-4111-8111-111111111111'
  $sql$,
  '42501',
  NULL,
  'User A cannot reassign own circular to User B'
);
SELECT is_empty(
  $sql$
    UPDATE public.circular_exam_dates
    SET venue = 'Hacked Venue'
    WHERE id = 'bbbb2222-3333-4222-8222-222222222222'
    RETURNING id
  $sql$,
  'User A cannot update User B circular_exam_dates row'
);
SELECT is_empty(
  $sql$
    UPDATE public.circular_files
    SET file_name = 'hacked.pdf'
    WHERE id = 'bbbb2222-4444-4222-8222-222222222222'
    RETURNING id
  $sql$,
  'User A cannot update User B circular_files row'
);

-- (44-46) DELETE isolation: cannot delete User B's rows
SELECT is_empty(
  $sql$
    DELETE FROM public.circulars
    WHERE id = 'bbbb2222-2222-4222-8222-222222222222'
    RETURNING id
  $sql$,
  'User A cannot delete User B circular'
);
SELECT is_empty(
  $sql$
    DELETE FROM public.circular_exam_dates
    WHERE id = 'bbbb2222-3333-4222-8222-222222222222'
    RETURNING id
  $sql$,
  'User A cannot delete User B circular_exam_dates row'
);
SELECT is_empty(
  $sql$
    DELETE FROM public.circular_files
    WHERE id = 'bbbb2222-4444-4222-8222-222222222222'
    RETURNING id
  $sql$,
  'User A cannot delete User B circular_files row'
);

-- ============================================================================
-- 6. User B sees intact rows and cannot access User A's rows (Tests 47-52)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '22222222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (47-49)
SELECT results_eq(
  $sql$ SELECT title FROM public.circulars WHERE id = 'bbbb2222-2222-4222-8222-222222222222' $sql$,
  ARRAY['User B Bank Circular'::text],
  'User B circular remains unmodified after User A attempts'
);
SELECT results_eq(
  $sql$ SELECT venue FROM public.circular_exam_dates WHERE id = 'bbbb2222-3333-4222-8222-222222222222' $sql$,
  ARRAY['Dhaka College'::text],
  'User B exam date remains unmodified after User A attempts'
);
SELECT results_eq(
  $sql$ SELECT file_name FROM public.circular_files WHERE id = 'bbbb2222-4444-4222-8222-222222222222' $sql$,
  ARRAY['bank-admit.pdf'::text],
  'User B circular file remains unmodified after User A attempts'
);

-- (50-52)
SELECT is_empty(
  $sql$ SELECT id FROM public.circulars WHERE id = 'aaaa1111-1111-4111-8111-111111111111' $sql$,
  'User B cannot read User A circular'
);
SELECT is_empty(
  $sql$
    UPDATE public.circulars
    SET title = 'Hacked by B'
    WHERE id = 'aaaa1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot update User A circular'
);
SELECT is_empty(
  $sql$
    DELETE FROM public.circulars
    WHERE id = 'aaaa1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot delete User A circular'
);

-- ============================================================================
-- 7. Positive CRUD, updated_at triggers, and cascade delete (Tests 53-62)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

SET LOCAL TIME ZONE 'Asia/Dhaka';

-- (53-54)
SELECT results_eq(
  $sql$
    UPDATE public.circulars
    SET notes = 'Updated circular note'
    WHERE id = 'aaaa1111-1111-4111-8111-111111111111'
    RETURNING notes
  $sql$,
  ARRAY['Updated circular note'::text],
  'User A can update own circular'
);
SELECT ok(
  (
    SELECT updated_at > created_at + interval '30 minutes'
    FROM public.circulars
    WHERE id = 'aaaa1111-1111-4111-8111-111111111111'
  ),
  'circulars updated_at trigger advances updated_at in non-UTC session timezone'
);

-- (55-56)
SELECT results_eq(
  $sql$
    UPDATE public.circular_exam_dates
    SET venue = 'Dhaka University'
    WHERE id = 'aaaa1111-2222-4111-8111-111111111111'
    RETURNING venue
  $sql$,
  ARRAY['Dhaka University'::text],
  'User A can update own circular_exam_dates row'
);
SELECT ok(
  (
    SELECT updated_at > created_at + interval '30 minutes'
    FROM public.circular_exam_dates
    WHERE id = 'aaaa1111-2222-4111-8111-111111111111'
  ),
  'circular_exam_dates updated_at trigger advances updated_at'
);

-- (57-58)
SELECT results_eq(
  $sql$
    UPDATE public.circular_files
    SET file_name = 'bcs-revised.pdf'
    WHERE id = 'aaaa1111-4444-4111-8111-111111111111'
    RETURNING file_name
  $sql$,
  ARRAY['bcs-revised.pdf'::text],
  'User A can update own circular_files row'
);
SELECT ok(
  (
    SELECT updated_at > created_at + interval '30 minutes'
    FROM public.circular_files
    WHERE id = 'aaaa1111-4444-4111-8111-111111111111'
  ),
  'circular_files updated_at trigger advances updated_at'
);

RESET TIME ZONE;

-- (59) Quick-capture insert using auth.uid() default for user_id
SELECT lives_ok(
  $sql$
    INSERT INTO public.circulars (title, is_quick_capture)
    VALUES ('Quick Capture Circular', true)
  $sql$,
  'User A can insert quick-capture circular using default auth.uid()'
);

-- (60-62) Own delete succeeds and cascades to child tables
SELECT results_eq(
  $sql$
    DELETE FROM public.circulars
    WHERE id = 'aaaa1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  ARRAY['aaaa1111-1111-4111-8111-111111111111'::uuid],
  'User A can delete own circular'
);
SELECT results_eq(
  $sql$
    SELECT count(*)::integer
    FROM public.circular_exam_dates
    WHERE id = 'aaaa1111-2222-4111-8111-111111111111'
  $sql$,
  ARRAY[0],
  'deleting circular cascades to circular_exam_dates'
);
SELECT results_eq(
  $sql$
    SELECT count(*)::integer
    FROM public.circular_files
    WHERE id = 'aaaa1111-4444-4111-8111-111111111111'
  $sql$,
  ARRAY[0],
  'deleting circular cascades to circular_files'
);

SELECT * FROM finish();
ROLLBACK;
