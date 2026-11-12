-- Phase 5B: pgTAP tests verifying `user_reminder_settings`, `reminder_log`,
-- database-level duplicate-send prevention, RLS isolation, and daily cron setup.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(27);

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
    'aaaa1111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'rem-user-a@example.test',
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
    'bbbb2222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'rem-user-b@example.test',
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

-- Seed parent circular & exam date for User A
INSERT INTO public.circulars (
  id,
  user_id,
  title,
  deadline
) VALUES (
  'aaaa3333-0000-4000-8000-000000000001',
  'aaaa1111-1111-4111-8111-111111111111',
  '48th BCS Circular',
  now() + interval '7 days'
);

INSERT INTO public.circular_exam_dates (
  id,
  circular_id,
  user_id,
  stage,
  exam_date
) VALUES (
  'aaaa4444-0000-4000-8000-000000000001',
  'aaaa3333-0000-4000-8000-000000000001',
  'aaaa1111-1111-4111-8111-111111111111',
  'preliminary',
  now() + interval '3 days'
);

-- ============================================================================
-- 1. Schema, RLS Metadata & Cron Function Existence (Tests 1-7)
-- ============================================================================
-- (1-2) Tables exist
SELECT has_table('public'::name, 'user_reminder_settings'::name, 'user_reminder_settings table exists');
SELECT has_table('public'::name, 'reminder_log'::name, 'reminder_log table exists');

-- (3-4) RLS enabled on both tables
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'user_reminder_settings'),
  'RLS is enabled on public.user_reminder_settings'
);
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'reminder_log'),
  'RLS is enabled on public.reminder_log'
);

-- (5) Unique deduplication index exists on reminder_log
SELECT ok(
  EXISTS (
    SELECT 1
      FROM pg_indexes
     WHERE schemaname = 'public'
       AND tablename = 'reminder_log'
       AND indexname = 'idx_reminder_log_dedup'
  ),
  'Unique deduplication index idx_reminder_log_dedup exists on reminder_log'
);

-- (6) dispatch_daily_reminders helper exists
SELECT ok(
  EXISTS (
    SELECT 1
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'public'
       AND p.proname = 'dispatch_daily_reminders'
  ),
  'dispatch_daily_reminders() helper exists'
);

-- (7) dispatch_daily_reminders safely returns NULL when Vault secrets are unset
SELECT lives_ok(
  $$SELECT public.dispatch_daily_reminders()$$,
  'dispatch_daily_reminders() runs cleanly as a no-op when Vault secrets are unset'
);

-- ============================================================================
-- 2. Anonymous Role Isolation (Tests 8-11)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{"role":"anon"}';
SET LOCAL ROLE anon;

-- (8-9) Anon cannot read user_reminder_settings or reminder_log
SELECT is_empty(
  $$SELECT id FROM public.user_reminder_settings$$,
  'Anonymous role cannot read user_reminder_settings'
);
SELECT is_empty(
  $$SELECT id FROM public.reminder_log$$,
  'Anonymous role cannot read reminder_log'
);

-- (10-11) Anon cannot insert into either table
SELECT throws_ok(
  $sql$
    INSERT INTO public.user_reminder_settings (user_id, reminders_enabled, email_language)
    VALUES ('aaaa1111-1111-4111-8111-111111111111', true, 'en')
  $sql$,
  '42501',
  NULL,
  'Anonymous role cannot insert user_reminder_settings'
);
SELECT throws_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, reminder_kind, days_before, target_date, recipient_email, email_language
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'circular_deadline',
      7,
      DATE '2026-11-17',
      'rem-user-a@example.test',
      'en'
    )
  $sql$,
  '42501',
  NULL,
  'Anonymous role cannot insert reminder_log'
);

-- ============================================================================
-- 3. User A Preferences CRUD & Constraints (Tests 12-16)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'aaaa1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"aaaa1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (12) User A can insert own reminder settings
SELECT lives_ok(
  $sql$
    INSERT INTO public.user_reminder_settings (user_id, reminders_enabled, email_language)
    VALUES ('aaaa1111-1111-4111-8111-111111111111', true, 'bn')
  $sql$,
  'User A can create own reminder settings'
);

-- (13) Check constraint rejects unsupported email_language
SELECT throws_ok(
  $sql$
    UPDATE public.user_reminder_settings
       SET email_language = 'fr'
     WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'
  $sql$,
  '23514',
  NULL,
  'Unsupported email_language is rejected by check constraint'
);

-- (14) User A can toggle reminders off/on cleanly
SELECT lives_ok(
  $sql$
    UPDATE public.user_reminder_settings
       SET reminders_enabled = false, email_language = 'en'
     WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'
  $sql$,
  'User A can update own reminder settings'
);

-- (15) User A cannot directly insert rows into reminder_log (server-managed)
SELECT throws_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, reminder_kind, days_before, target_date, recipient_email, email_language
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'circular_deadline',
      7,
      DATE '2026-11-17',
      'rem-user-a@example.test',
      'en'
    )
  $sql$,
  '42501',
  NULL,
  'Authenticated users cannot insert reminder_log rows directly'
);

-- ============================================================================
-- 4. Server-Side Duplicate Protection & Reminder Log Constraints (Tests 16-21)
-- ============================================================================
RESET ROLE;
SET LOCAL ROLE service_role;

-- (16) Inserting valid circular_deadline and exam_date reminder_log rows succeeds
SELECT lives_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, exam_date_id, reminder_kind, days_before, target_date, recipient_email, email_language, provider_message_id
    ) VALUES
      (
        'aaaa1111-1111-4111-8111-111111111111',
        'aaaa3333-0000-4000-8000-000000000001',
        NULL,
        'circular_deadline',
        7,
        DATE '2026-11-17',
        'rem-user-a@example.test',
        'bn',
        'msg-deadline-7d'
      ),
      (
        'aaaa1111-1111-4111-8111-111111111111',
        'aaaa3333-0000-4000-8000-000000000001',
        'aaaa4444-0000-4000-8000-000000000001',
        'exam_date',
        3,
        DATE '2026-11-13',
        'rem-user-a@example.test',
        'bn',
        'msg-exam-3d'
      );
  $sql$,
  'Server can record circular_deadline and exam_date reminder_log rows'
);

-- (17) Duplicate circular_deadline reminder (exam_date_id IS NULL) raises 23505
SELECT throws_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, exam_date_id, reminder_kind, days_before, target_date, recipient_email, email_language
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      NULL,
      'circular_deadline',
      7,
      DATE '2026-11-17',
      'rem-user-a@example.test',
      'bn'
    )
  $sql$,
  '23505',
  NULL,
  'Duplicate circular_deadline reminder for same user, days_before, and target_date is rejected (23505)'
);

-- (18) Duplicate exam_date reminder raises 23505
SELECT throws_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, exam_date_id, reminder_kind, days_before, target_date, recipient_email, email_language
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      'aaaa4444-0000-4000-8000-000000000001',
      'exam_date',
      3,
      DATE '2026-11-13',
      'rem-user-a@example.test',
      'bn'
    )
  $sql$,
  '23505',
  NULL,
  'Duplicate exam_date reminder for same user, exam_date_id, days_before, and target_date is rejected (23505)'
);

-- (19) Same deadline at a different lead window (3 days before) is allowed
SELECT lives_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, exam_date_id, reminder_kind, days_before, target_date, recipient_email, email_language
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      NULL,
      'circular_deadline',
      3,
      DATE '2026-11-17',
      'rem-user-a@example.test',
      'bn'
    )
  $sql$,
  'Distinct lead window (3 days before) on the same deadline is allowed'
);

-- (20) Invalid days_before (e.g. 5) is rejected by check constraint
SELECT throws_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, exam_date_id, reminder_kind, days_before, target_date, recipient_email, email_language
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      NULL,
      'circular_deadline',
      5,
      DATE '2026-11-17',
      'rem-user-a@example.test',
      'en'
    )
  $sql$,
  '23514',
  NULL,
  'Unsupported days_before value (5) is rejected'
);

-- (21) exam_date reminder missing exam_date_id is rejected by consistency check
SELECT throws_ok(
  $sql$
    INSERT INTO public.reminder_log (
      user_id, circular_id, exam_date_id, reminder_kind, days_before, target_date, recipient_email, email_language
    ) VALUES (
      'aaaa1111-1111-4111-8111-111111111111',
      'aaaa3333-0000-4000-8000-000000000001',
      NULL,
      'exam_date',
      1,
      DATE '2026-11-13',
      'rem-user-a@example.test',
      'en'
    )
  $sql$,
  '23514',
  NULL,
  'exam_date reminder without exam_date_id violates consistency constraint'
);

-- ============================================================================
-- 5. User A & User B Cross-User RLS Verification (Tests 22-26)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'aaaa1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"aaaa1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (22) User A can view own reminder logs (3 rows recorded above)
SELECT is(
  (SELECT count(*)::integer FROM public.reminder_log),
  3,
  'User A can read own reminder_log rows'
);

RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'bbbb2222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"bbbb2222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (23) User B cannot read User A reminder settings
SELECT is_empty(
  $$SELECT id FROM public.user_reminder_settings WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A reminder settings'
);

-- (24-25) User B cannot update or delete User A reminder settings
SELECT is_empty(
  $sql$
    UPDATE public.user_reminder_settings
       SET reminders_enabled = true
     WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot update User A reminder settings'
);
SELECT is_empty(
  $sql$
    DELETE FROM public.user_reminder_settings
     WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'
    RETURNING id
  $sql$,
  'User B cannot delete User A reminder settings'
);

-- (26) User B cannot read User A reminder logs
SELECT is_empty(
  $$SELECT id FROM public.reminder_log WHERE user_id = 'aaaa1111-1111-4111-8111-111111111111'$$,
  'User B cannot read User A reminder_log entries'
);

-- (27) User B cannot spoof User A user_id when inserting reminder settings
SELECT throws_ok(
  $sql$
    INSERT INTO public.user_reminder_settings (user_id, reminders_enabled, email_language)
    VALUES ('aaaa1111-1111-4111-8111-111111111111', false, 'en')
  $sql$,
  '42501',
  NULL,
  'User B cannot insert reminder settings for User A'
);

SELECT * FROM finish();

ROLLBACK;
