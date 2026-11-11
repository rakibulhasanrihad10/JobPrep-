-- Phase 6J pgTAP suite: notifications RLS isolation, dedupe index, check constraints,
-- and user_reminder_settings per-type notification preference extensions.

BEGIN;

SELECT plan(19);

-- Seed two test auth users
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
  ('eeee6a01-1111-4111-8111-111111111111', 'notif_a@example.com', '{}'::jsonb),
  ('ffff6a02-2222-4222-8222-222222222222', 'notif_b@example.com', '{}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- (1-4) Schema, RLS, unique index, and extension columns check
SELECT is(
  (
    SELECT relrowsecurity
    FROM pg_class
    WHERE oid = 'public.notifications'::regclass
  ),
  true,
  'public.notifications has RLS enabled'
);

SELECT is(
  (
    SELECT i.indisunique
    FROM pg_index i
    JOIN pg_class c ON c.oid = i.indexrelid
    WHERE c.relname = 'idx_notifications_user_dedupe'
  ),
  true,
  'idx_notifications_user_dedupe enforces unique (user_id, dedupe_key)'
);

SELECT is(
  (
    SELECT count(*)::integer
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'notifications'
      AND indexname IN (
        'idx_notifications_user_dedupe',
        'idx_notifications_user_created',
        'idx_notifications_user_unread'
      )
  ),
  3,
  'notifications indexes are created'
);

SELECT is(
  (
    SELECT count(*)::integer
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_reminder_settings'
      AND column_name IN (
        'deadline_soon_enabled',
        'exam_soon_enabled',
        'revision_due_enabled',
        'behind_schedule_enabled',
        'weekly_review_enabled',
        'weekly_review_day'
      )
  ),
  6,
  'user_reminder_settings exposes per-type toggles and weekly_review_day'
);

-- Switch to authenticated User A
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.role', 'authenticated', true);
SELECT set_config('request.jwt.claim.sub', 'eeee6a01-1111-4111-8111-111111111111', true);

-- (5-7) Valid inserts and update for User A
SELECT lives_ok(
  $$
  INSERT INTO public.notifications (
    id, type, message_key, params, route, dedupe_key
  ) VALUES (
    'aaaa6a01-1111-4111-8111-111111111111',
    'deadline_soon',
    'notificationDeadlineSoon',
    '{"title":"47th BCS","days":3}'::jsonb,
    '/circulars/c1',
    'deadline_soon|c1|3d|2026-11-12'
  ), (
    'aaaa6a02-1111-4111-8111-111111111111',
    'weekly_review',
    'notificationWeeklyReview',
    '{"weekStart":"2026-11-08"}'::jsonb,
    '/weekly-review',
    'weekly_review|2026-11-08'
  );
  $$,
  'User A can insert valid notifications'
);

SELECT lives_ok(
  $$
  UPDATE public.notifications
  SET read_at = '2026-11-12T08:30:00Z'
  WHERE id = 'aaaa6a01-1111-4111-8111-111111111111';
  $$,
  'User A can mark own notification as read'
);

SELECT throws_ok(
  $$
  INSERT INTO public.notifications (
    type, message_key, params, route, dedupe_key
  ) VALUES (
    'deadline_soon',
    'notificationDeadlineSoon',
    '{"title":"47th BCS","days":3}'::jsonb,
    '/circulars/c1',
    'deadline_soon|c1|3d|2026-11-12'
  );
  $$,
  '23505',
  NULL,
  'Duplicate (user_id, dedupe_key) is rejected'
);

-- (8-11) Validation CHECK constraints on notifications
SELECT throws_ok(
  $$
  INSERT INTO public.notifications (
    type, message_key, params, route, dedupe_key
  ) VALUES (
    'unknown_type',
    'notificationDeadlineSoon',
    '{}'::jsonb,
    '/today',
    'k1'
  );
  $$,
  '23514',
  NULL,
  'Invalid notification type is rejected'
);

SELECT throws_ok(
  $$
  INSERT INTO public.notifications (
    type, message_key, params, route, dedupe_key
  ) VALUES (
    'exam_soon',
    'notificationExamSoon',
    '[]'::jsonb,
    '/circulars/c1',
    'k2'
  );
  $$,
  '23514',
  NULL,
  'Non-object notification params jsonb is rejected'
);

SELECT throws_ok(
  $$
  INSERT INTO public.notifications (
    type, message_key, params, route, dedupe_key
  ) VALUES (
    'revision_due',
    '   ',
    '{}'::jsonb,
    '/prep/revision',
    'k3'
  );
  $$,
  '23514',
  NULL,
  'Empty notification message_key is rejected'
);

SELECT throws_ok(
  $$
  INSERT INTO public.notifications (
    type, message_key, params, route, dedupe_key
  ) VALUES (
    'behind_schedule',
    'notificationBehindSchedule',
    '{}'::jsonb,
    '   ',
    'k4'
  );
  $$,
  '23514',
  NULL,
  'Empty notification route is rejected'
);

-- (12-13) user_reminder_settings checks for weekly_review_day & booleans
SELECT throws_ok(
  $$
  INSERT INTO public.user_reminder_settings (
    user_id, reminders_enabled, email_language, weekly_review_day
  ) VALUES (
    'eeee6a01-1111-4111-8111-111111111111', true, 'en', 7
  );
  $$,
  '23514',
  NULL,
  'weekly_review_day outside 0..6 is rejected'
);

SELECT lives_ok(
  $$
  INSERT INTO public.user_reminder_settings (
    user_id,
    reminders_enabled,
    email_language,
    deadline_soon_enabled,
    exam_soon_enabled,
    revision_due_enabled,
    behind_schedule_enabled,
    weekly_review_enabled,
    weekly_review_day
  ) VALUES (
    'eeee6a01-1111-4111-8111-111111111111',
    true,
    'bn',
    true,
    false,
    true,
    false,
    true,
    5
  );
  $$,
  'User A can configure per-type notification toggles and Friday review day'
);

-- (14) Confirm User A count
SELECT is(
  (SELECT count(*)::integer FROM public.notifications),
  2,
  'User A sees 2 own notifications'
);

-- Switch to authenticated User B
SELECT set_config('request.jwt.claim.sub', 'ffff6a02-2222-4222-8222-222222222222', true);

-- (15) Same dedupe_key is permitted for a different user
SELECT lives_ok(
  $$
  INSERT INTO public.notifications (
    id, type, message_key, params, route, dedupe_key
  ) VALUES (
    'bbbb6a01-2222-4222-8222-222222222222',
    'weekly_review',
    'notificationWeeklyReview',
    '{"weekStart":"2026-11-08"}'::jsonb,
    '/weekly-review',
    'weekly_review|2026-11-08'
  );
  $$,
  'User B can use the same dedupe_key independently of User A'
);

-- (16-19) Strict RLS isolation for User B against User A rows
SELECT is(
  (
    SELECT count(*)::integer
    FROM public.notifications
    WHERE id IN (
      'aaaa6a01-1111-4111-8111-111111111111',
      'aaaa6a02-1111-4111-8111-111111111111'
    )
  ),
  0,
  'User B cannot read User A notifications'
);

SELECT throws_ok(
  $$
  INSERT INTO public.notifications (
    user_id, type, message_key, params, route, dedupe_key
  ) VALUES (
    'eeee6a01-1111-4111-8111-111111111111',
    'revision_due',
    'notificationRevisionDue',
    '{"count":2}'::jsonb,
    '/prep/revision',
    'spoofed-dedupe'
  );
  $$,
  '42501',
  NULL,
  'User B cannot insert notification spoofed as User A'
);

WITH updated AS (
  UPDATE public.notifications
  SET read_at = now()
  WHERE id = 'aaaa6a02-1111-4111-8111-111111111111'
  RETURNING id
)
SELECT is(
  (SELECT count(*)::integer FROM updated),
  0,
  'User B cannot update User A notification'
);

WITH deleted AS (
  DELETE FROM public.notifications
  WHERE id = 'aaaa6a01-1111-4111-8111-111111111111'
  RETURNING id
)
SELECT is(
  (SELECT count(*)::integer FROM deleted),
  0,
  'User B cannot delete User A notification'
);

SELECT * FROM finish();

ROLLBACK;
