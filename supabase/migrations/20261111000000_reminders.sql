-- Phase 5B: Reminder preferences (`user_reminder_settings`), deduplication log
-- (`reminder_log`), RLS policies, and daily pg_cron Edge Function trigger.

-- ============================================================================
-- 1. public.user_reminder_settings
-- ============================================================================
CREATE TABLE public.user_reminder_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  reminders_enabled boolean NOT NULL DEFAULT true,
  email_language text NOT NULL DEFAULT 'en',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_reminder_settings_email_language_check CHECK (
    email_language IN ('en', 'bn')
  )
);

CREATE INDEX idx_user_reminder_settings_user_id
  ON public.user_reminder_settings (user_id);

CREATE TRIGGER set_user_reminder_settings_updated_at
  BEFORE UPDATE ON public.user_reminder_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.user_reminder_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own reminder settings"
  ON public.user_reminder_settings
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own reminder settings"
  ON public.user_reminder_settings
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own reminder settings"
  ON public.user_reminder_settings
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own reminder settings"
  ON public.user_reminder_settings
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 2. public.reminder_log
-- ============================================================================
CREATE TABLE public.reminder_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  circular_id uuid NOT NULL REFERENCES public.circulars (id) ON DELETE CASCADE,
  exam_date_id uuid REFERENCES public.circular_exam_dates (id) ON DELETE CASCADE,
  reminder_kind text NOT NULL,
  days_before integer NOT NULL,
  target_date date NOT NULL,
  recipient_email text NOT NULL,
  email_language text NOT NULL,
  provider text NOT NULL DEFAULT 'resend',
  provider_message_id text,
  sent_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT reminder_log_kind_check CHECK (
    reminder_kind IN ('circular_deadline', 'exam_date')
  ),
  CONSTRAINT reminder_log_days_before_check CHECK (
    days_before IN (7, 3, 1)
  ),
  CONSTRAINT reminder_log_email_language_check CHECK (
    email_language IN ('en', 'bn')
  ),
  CONSTRAINT reminder_log_recipient_not_empty CHECK (
    char_length(btrim(recipient_email)) > 0
  ),
  CONSTRAINT reminder_log_provider_not_empty CHECK (
    char_length(btrim(provider)) > 0
  ),
  CONSTRAINT reminder_log_exam_date_consistency CHECK (
    (reminder_kind = 'circular_deadline' AND exam_date_id IS NULL)
    OR (reminder_kind = 'exam_date' AND exam_date_id IS NOT NULL)
  )
);

-- Prevents duplicate delivery for the same user, event, lead window, and date
-- even when exam_date_id IS NULL on circular deadline reminders.
CREATE UNIQUE INDEX idx_reminder_log_dedup
  ON public.reminder_log (
    user_id,
    reminder_kind,
    circular_id,
    COALESCE(exam_date_id, '00000000-0000-0000-0000-000000000000'::uuid),
    days_before,
    target_date
  );

CREATE INDEX idx_reminder_log_user_sent_at
  ON public.reminder_log (user_id, sent_at DESC);

ALTER TABLE public.reminder_log ENABLE ROW LEVEL SECURITY;

-- Signed-in users can view their own sent reminder logs; writes come exclusively
-- from the server-side Edge Function using service_role.
CREATE POLICY "Users can read own reminder logs"
  ON public.reminder_log
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 3. Daily pg_cron Edge Function Dispatch
-- ============================================================================
DO $$
BEGIN
  CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;
EXCEPTION
  WHEN insufficient_privilege OR undefined_file OR feature_not_supported THEN
    RAISE NOTICE 'pg_cron setup skipped: %', SQLERRM;
END $$;

DO $$
BEGIN
  CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;
EXCEPTION
  WHEN insufficient_privilege OR undefined_file OR feature_not_supported THEN
    RAISE NOTICE 'pg_net setup skipped: %', SQLERRM;
END $$;

-- Dispatches daily email reminders via pg_net + Supabase Vault secrets
-- (`project_url` and `reminder_cron_secret`). Safe no-op if secrets are unset.
CREATE OR REPLACE FUNCTION public.dispatch_daily_reminders()
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
  v_project_url text;
  v_cron_secret text;
  v_endpoint text;
  v_headers jsonb;
  v_body jsonb;
  v_request_id bigint;
BEGIN
  IF to_regclass('vault.decrypted_secrets') IS NULL THEN
    RAISE NOTICE 'Supabase Vault is unavailable; skipping reminder dispatch.';
    RETURN NULL;
  END IF;

  EXECUTE $q$
    SELECT NULLIF(btrim(decrypted_secret), '')
      FROM vault.decrypted_secrets
     WHERE name = 'project_url'
     LIMIT 1
  $q$ INTO v_project_url;

  EXECUTE $q$
    SELECT NULLIF(btrim(decrypted_secret), '')
      FROM vault.decrypted_secrets
     WHERE name = 'reminder_cron_secret'
     LIMIT 1
  $q$ INTO v_cron_secret;

  IF v_project_url IS NULL OR v_cron_secret IS NULL THEN
    RAISE NOTICE 'Vault secrets project_url or reminder_cron_secret are not set; skipping reminder dispatch.';
    RETURN NULL;
  END IF;

  IF to_regnamespace('net') IS NULL THEN
    RAISE NOTICE 'pg_net schema net is unavailable; skipping reminder dispatch.';
    RETURN NULL;
  END IF;

  v_endpoint := rtrim(v_project_url, '/') || '/functions/v1/send-reminders';
  v_headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'x-cron-secret', v_cron_secret
  );
  v_body := jsonb_build_object(
    'source', 'pg_cron',
    'triggeredAt', now()
  );

  EXECUTE 'SELECT net.http_post(url := $1, headers := $2, body := $3)'
     INTO v_request_id
    USING v_endpoint, v_headers, v_body;

  RETURN v_request_id;
END;
$$;

REVOKE ALL ON FUNCTION public.dispatch_daily_reminders()
  FROM PUBLIC, anon, authenticated;

-- Register daily schedule at 02:00 UTC (08:00 AM Asia/Dhaka) when pg_cron exists.
DO $$
BEGIN
  IF to_regnamespace('cron') IS NOT NULL THEN
    IF EXISTS (
      SELECT 1 FROM cron.job WHERE jobname = 'jobprep-daily-reminders'
    ) THEN
      PERFORM cron.unschedule('jobprep-daily-reminders');
    END IF;

    PERFORM cron.schedule(
      'jobprep-daily-reminders',
      '0 2 * * *',
      'SELECT public.dispatch_daily_reminders();'
    );
  END IF;
EXCEPTION
  WHEN insufficient_privilege THEN
    RAISE NOTICE 'pg_cron schedule registration skipped: %', SQLERRM;
END $$;
