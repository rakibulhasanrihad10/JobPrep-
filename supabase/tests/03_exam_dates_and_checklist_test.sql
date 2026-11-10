-- Phase 3F: pgTAP tests covering application checklist persistence under RLS
-- and exam date management (preliminary, written, viva, practical, other) in
-- public.circular_exam_dates.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(10);

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
    '55555555-5555-4555-8555-555555555555',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'detail-user-a@example.test',
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
    '66666666-6666-4666-8666-666666666666',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'detail-user-b@example.test',
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
SET LOCAL request.jwt.claim.sub = '55555555-5555-4555-8555-555555555555';
SET LOCAL request.jwt.claims = '{"sub":"55555555-5555-4555-8555-555555555555","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (1) Create circular and verify checklist columns default to false
SELECT lives_ok(
  $sql$
    INSERT INTO public.circulars (id, user_id, title)
    VALUES (
      'dddd1111-1111-4111-8111-111111111111',
      '55555555-5555-4555-8555-555555555555',
      '47th BCS Detail Circular'
    )
  $sql$,
  'User A can insert circular with default false checklist columns'
);

-- (2) Verify default checklist booleans are false
SELECT is(
  (
    SELECT checklist_photo::text || ',' ||
           checklist_certificates::text || ',' ||
           checklist_fee_paid::text || ',' ||
           checklist_submitted::text || ',' ||
           checklist_admit_card_downloaded::text
    FROM public.circulars
    WHERE id = 'dddd1111-1111-4111-8111-111111111111'
  ),
  'false,false,false,false,false',
  'All five application checklist booleans default to false'
);

-- (3) User A can tick checklist items and quick-change statuses
SELECT lives_ok(
  $sql$
    UPDATE public.circulars
    SET checklist_photo = true,
        checklist_certificates = true,
        checklist_fee_paid = true,
        application_status = 'fee_paid',
        workflow_status = 'preparing',
        admit_card_status = 'available'
    WHERE id = 'dddd1111-1111-4111-8111-111111111111'
  $sql$,
  'User A can update checklist items and circular statuses'
);

-- (4) Insert ordered exam stages for User A
SELECT lives_ok(
  $sql$
    INSERT INTO public.circular_exam_dates (id, circular_id, user_id, stage, exam_date, venue, notes)
    VALUES
      (
        'eeee1111-1111-4111-8111-111111111111',
        'dddd1111-1111-4111-8111-111111111111',
        '55555555-5555-4555-8555-555555555555',
        'written',
        now() + interval '20 days',
        'BUET Hall',
        'Bring black ink pen'
      ),
      (
        'eeee2222-2222-4222-8222-222222222222',
        'dddd1111-1111-4111-8111-111111111111',
        '55555555-5555-4555-8555-555555555555',
        'preliminary',
        now() + interval '5 days',
        'Dhaka College',
        'MCQ round'
      )
  $sql$,
  'User A can insert multiple exam stage dates'
);

-- (5) Verify chronological ordering by exam_date
SELECT results_eq(
  $sql$
    SELECT stage
    FROM public.circular_exam_dates
    WHERE circular_id = 'dddd1111-1111-4111-8111-111111111111'
    ORDER BY exam_date ASC
  $sql$,
  ARRAY['preliminary', 'written']::text[],
  'Exam dates query returns upcoming exams ordered by exam_date'
);

-- (6) User A can edit an exam date row
SELECT lives_ok(
  $sql$
    UPDATE public.circular_exam_dates
    SET stage = 'viva', venue = 'BPSC HQ'
    WHERE id = 'eeee1111-1111-4111-8111-111111111111'
  $sql$,
  'User A can update own exam date'
);

-- Switch to authenticated User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '66666666-6666-4666-8666-666666666666';
SET LOCAL request.jwt.claims = '{"sub":"66666666-6666-4666-8666-666666666666","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (7) User B cannot read User A exam dates
SELECT is_empty(
  $sql$
    SELECT id FROM public.circular_exam_dates
    WHERE circular_id = 'dddd1111-1111-4111-8111-111111111111'
  $sql$,
  'User B cannot view User A circular_exam_dates'
);

-- (8) User B cannot update User A exam date
SELECT is_empty(
  $sql$
    UPDATE public.circular_exam_dates
    SET venue = 'Hacked'
    WHERE id = 'eeee1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot update User A circular_exam_dates'
);

-- (9) User B cannot delete User A exam date
SELECT is_empty(
  $sql$
    DELETE FROM public.circular_exam_dates
    WHERE id = 'eeee1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot delete User A circular_exam_dates'
);

-- Switch back to User A to delete exam date
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '55555555-5555-4555-8555-555555555555';
SET LOCAL request.jwt.claims = '{"sub":"55555555-5555-4555-8555-555555555555","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (10) User A can delete own exam date
SELECT lives_ok(
  $sql$
    DELETE FROM public.circular_exam_dates
    WHERE id = 'eeee1111-1111-4111-8111-111111111111'
  $sql$,
  'User A can delete own exam date'
);

SELECT * FROM finish();

ROLLBACK;
