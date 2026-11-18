-- Phase 7A pgTAP suite: user_settings preference columns, check constraints,
-- cross-user RLS isolation, and self-service delete_my_account() scope.

BEGIN;

SELECT plan(14);

INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
  ('aaaa7a01-1111-4111-8111-111111111111', 'pref_a@example.com', '{}'::jsonb),
  ('bbbb7a02-2222-4222-8222-222222222222', 'pref_b@example.com', '{}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- (1) Preference columns exist
SELECT is(
  (
    SELECT count(*)::integer
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_settings'
      AND column_name IN (
        'display_name',
        'theme_mode',
        'reduce_effects',
        'locale_code',
        'bangla_digits',
        'focus_minutes',
        'short_break_minutes',
        'long_break_minutes'
      )
  ),
  8,
  'public.user_settings exposes all 8 Phase 7A preference columns'
);

-- (2) Anon cannot execute delete_my_account
SET LOCAL ROLE anon;
SELECT set_config('request.jwt.claim.role', 'anon', true);
SELECT set_config('request.jwt.claim.sub', '', true);
SELECT throws_ok(
  $$ SELECT public.delete_my_account(); $$,
  '42501',
  NULL,
  'Anonymous caller is rejected from delete_my_account()'
);

-- Switch to authenticated User A
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.role', 'authenticated', true);
SELECT set_config('request.jwt.claim.sub', 'aaaa7a01-1111-4111-8111-111111111111', true);

-- (3) User A inserts and updates preferences cleanly
SELECT lives_ok(
  $$
  INSERT INTO public.user_settings (
    display_name, theme_mode, reduce_effects, locale_code,
    bangla_digits, focus_minutes, short_break_minutes, long_break_minutes
  ) VALUES (
    'Tasnim', 'dark', true, 'bn', true, 45, 10, 20
  );
  $$,
  'User A can persist synced preference settings'
);

SELECT is(
  (
    SELECT focus_minutes
    FROM public.user_settings
    WHERE user_id = 'aaaa7a01-1111-4111-8111-111111111111'
  ),
  45,
  'User A reads back updated focus_minutes'
);

-- (5-9) Constraint checks reject invalid values
SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET theme_mode = 'neon'
  WHERE user_id = 'aaaa7a01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'Invalid theme_mode is rejected'
);

SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET locale_code = 'fr'
  WHERE user_id = 'aaaa7a01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'Unsupported locale_code is rejected'
);

SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET focus_minutes = 4
  WHERE user_id = 'aaaa7a01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'focus_minutes below 5 is rejected'
);

SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET short_break_minutes = 61
  WHERE user_id = 'aaaa7a01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'short_break_minutes above 60 is rejected'
);

SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET long_break_minutes = 4
  WHERE user_id = 'aaaa7a01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'long_break_minutes below 5 is rejected'
);

-- Switch to authenticated User B and seed own row
SELECT set_config('request.jwt.claim.sub', 'bbbb7a02-2222-4222-8222-222222222222', true);

SELECT is(
  (SELECT count(*)::integer FROM public.user_settings),
  0,
  'User B cannot read User A preference settings'
);

WITH updated AS (
  UPDATE public.user_settings
  SET display_name = 'Hijacked'
  WHERE user_id = 'aaaa7a01-1111-4111-8111-111111111111'
  RETURNING id
)
SELECT is(
  (SELECT count(*)::integer FROM updated),
  0,
  'User B cannot update User A preference settings'
);

SELECT lives_ok(
  $$
  INSERT INTO public.user_settings (display_name) VALUES ('User B');
  $$,
  'User B can create own preference settings'
);

-- Switch back to User A and execute self-service delete_my_account()
SELECT set_config('request.jwt.claim.sub', 'aaaa7a01-1111-4111-8111-111111111111', true);

SELECT lives_ok(
  $$ SELECT public.delete_my_account(); $$,
  'User A can execute delete_my_account()'
);

-- Verify User B row still exists while User A was cascade deleted
SELECT set_config('request.jwt.claim.sub', 'bbbb7a02-2222-4222-8222-222222222222', true);
SELECT is(
  (SELECT count(*)::integer FROM public.user_settings),
  1,
  'User B settings remain intact after User A deletes account'
);

SELECT * FROM finish();

ROLLBACK;
