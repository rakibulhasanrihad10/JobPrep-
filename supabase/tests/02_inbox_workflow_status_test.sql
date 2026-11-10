-- Phase 3E: pgTAP tests proving workflow_status = 'inbox' with
-- is_quick_capture = true works under RLS isolation across users.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(9);

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
    '33333333-3333-4333-8333-333333333333',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'inbox-user-a@example.test',
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
    '44444444-4444-4444-8444-444444444444',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'inbox-user-b@example.test',
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

-- Switch to authenticated User A
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '33333333-3333-4333-8333-333333333333';
SET LOCAL request.jwt.claims = '{"sub":"33333333-3333-4333-8333-333333333333","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (1) User A can insert quick-captured inbox item
SELECT lives_ok(
  $sql$
    INSERT INTO public.circulars (
      id,
      user_id,
      title,
      circular_url,
      workflow_status,
      is_quick_capture
    ) VALUES (
      'cccc1111-1111-4111-8111-111111111111',
      '33333333-3333-4333-8333-333333333333',
      'bpsc.gov.bd',
      'https://bpsc.gov.bd/notices/47',
      'inbox',
      true
    )
  $sql$,
  'User A can quick-capture a circular with workflow_status inbox'
);

-- (2) Inbox item stores expected flags
SELECT is(
  (
    SELECT workflow_status || ':' || is_quick_capture::text
    FROM public.circulars
    WHERE id = 'cccc1111-1111-4111-8111-111111111111'
  ),
  'inbox:true',
  'Quick-captured circular retains inbox workflow_status and is_quick_capture true'
);

-- Switch to authenticated User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '44444444-4444-4444-8444-444444444444';
SET LOCAL request.jwt.claims = '{"sub":"44444444-4444-4444-8444-444444444444","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (3) User B cannot read User A's inbox item
SELECT is_empty(
  $sql$
    SELECT id FROM public.circulars WHERE id = 'cccc1111-1111-4111-8111-111111111111'
  $sql$,
  'User B cannot read User A inbox circular'
);

-- (4) User B cannot update User A's inbox item
SELECT is_empty(
  $sql$
    UPDATE public.circulars
    SET workflow_status = 'archived'
    WHERE id = 'cccc1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot update User A inbox circular'
);

-- (5) User B cannot delete User A's inbox item
SELECT is_empty(
  $sql$
    DELETE FROM public.circulars
    WHERE id = 'cccc1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot delete User A inbox circular'
);

-- Switch back to authenticated User A
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '33333333-3333-4333-8333-333333333333';
SET LOCAL request.jwt.claims = '{"sub":"33333333-3333-4333-8333-333333333333","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (6) User A's inbox circular remained unchanged after User B probes
SELECT is(
  (SELECT workflow_status FROM public.circulars WHERE id = 'cccc1111-1111-4111-8111-111111111111'),
  'inbox',
  'User A inbox circular remains intact after User B attempts'
);

-- (7) Completing details transitions inbox -> saved
SELECT lives_ok(
  $sql$
    UPDATE public.circulars
    SET title = '47th BCS Circular', workflow_status = 'saved'
    WHERE id = 'cccc1111-1111-4111-8111-111111111111'
  $sql$,
  'User A can complete details transitioning inbox to saved'
);

-- (8) Skipping transitions inbox/saved -> archived
SELECT lives_ok(
  $sql$
    UPDATE public.circulars
    SET workflow_status = 'archived'
    WHERE id = 'cccc1111-1111-4111-8111-111111111111'
  $sql$,
  'User A can skip/archive quick-captured circular'
);

-- (9) User A can delete own quick-captured circular
SELECT lives_ok(
  $sql$
    DELETE FROM public.circulars
    WHERE id = 'cccc1111-1111-4111-8111-111111111111'
  $sql$,
  'User A can delete own quick-captured circular'
);

SELECT * FROM finish();

ROLLBACK;
