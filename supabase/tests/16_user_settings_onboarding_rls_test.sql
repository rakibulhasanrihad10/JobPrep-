-- Phase 6K pgTAP suite: user_settings schema, onboarding_step bounds,
-- onboarding_completed_at transitions, and strict per-user RLS isolation.

BEGIN;

SELECT plan(13);

-- Seed two test auth users
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES
  ('eeee6b01-1111-4111-8111-111111111111', 'onboard_a@example.com', '{}'::jsonb),
  ('ffff6b02-2222-4222-8222-222222222222', 'onboard_b@example.com', '{}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- (1-2) RLS and onboarding columns check
SELECT is(
  (
    SELECT relrowsecurity
    FROM pg_class
    WHERE oid = 'public.user_settings'::regclass
  ),
  true,
  'public.user_settings has RLS enabled'
);

SELECT is(
  (
    SELECT count(*)::integer
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_settings'
      AND column_name IN (
        'onboarding_completed_at',
        'onboarding_step',
        'onboarding_draft',
        'today_tips_dismissed'
      )
  ),
  4,
  'public.user_settings exposes onboarding columns'
);

-- Switch to authenticated User A
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.role', 'authenticated', true);
SELECT set_config('request.jwt.claim.sub', 'eeee6b01-1111-4111-8111-111111111111', true);

-- (3-5) Valid insert, step advance, and completion timestamp update
SELECT lives_ok(
  $$
  INSERT INTO public.user_settings (
    onboarding_step, onboarding_draft
  ) VALUES (
    3,
    '{"track":"government"}'::jsonb
  );
  $$,
  'User A can persist initial onboarding step and draft'
);

SELECT lives_ok(
  $$
  UPDATE public.user_settings
  SET onboarding_step = 6,
      onboarding_completed_at = '2026-11-12T03:00:00Z'
  WHERE user_id = 'eeee6b01-1111-4111-8111-111111111111';
  $$,
  'User A can mark onboarding completed'
);

SELECT is(
  (
    SELECT count(*)::integer
    FROM public.user_settings
    WHERE onboarding_completed_at IS NOT NULL
  ),
  1,
  'User A sees completed onboarding settings row'
);

-- (6-8) Constraint checks: onboarding_step 1..6 and object draft jsonb
SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET onboarding_step = 0
  WHERE user_id = 'eeee6b01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'onboarding_step below 1 is rejected'
);

SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET onboarding_step = 7
  WHERE user_id = 'eeee6b01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'onboarding_step above 6 is rejected'
);

SELECT throws_ok(
  $$
  UPDATE public.user_settings
  SET onboarding_draft = '[]'::jsonb
  WHERE user_id = 'eeee6b01-1111-4111-8111-111111111111';
  $$,
  '23514',
  NULL,
  'Non-object onboarding_draft jsonb is rejected'
);

-- Switch to authenticated User B
SELECT set_config('request.jwt.claim.sub', 'ffff6b02-2222-4222-8222-222222222222', true);

-- (9-13) Cross-user RLS isolation
SELECT is(
  (SELECT count(*)::integer FROM public.user_settings),
  0,
  'User B cannot read User A settings'
);

SELECT throws_ok(
  $$
  INSERT INTO public.user_settings (user_id, onboarding_step)
  VALUES ('eeee6b01-1111-4111-8111-111111111111', 2);
  $$,
  '42501',
  NULL,
  'User B cannot insert user_settings spoofed as User A'
);

WITH updated AS (
  UPDATE public.user_settings
  SET onboarding_step = 1
  WHERE user_id = 'eeee6b01-1111-4111-8111-111111111111'
  RETURNING id
)
SELECT is(
  (SELECT count(*)::integer FROM updated),
  0,
  'User B cannot update User A settings'
);

WITH deleted AS (
  DELETE FROM public.user_settings
  WHERE user_id = 'eeee6b01-1111-4111-8111-111111111111'
  RETURNING id
)
SELECT is(
  (SELECT count(*)::integer FROM deleted),
  0,
  'User B cannot delete User A settings'
);

SELECT set_config('request.jwt.claim.sub', 'eeee6b01-1111-4111-8111-111111111111', true);
SELECT is(
  (
    SELECT onboarding_step
    FROM public.user_settings
    WHERE user_id = 'eeee6b01-1111-4111-8111-111111111111'
  ),
  6,
  'User A settings row remains untouched'
);

SELECT * FROM finish();

ROLLBACK;
