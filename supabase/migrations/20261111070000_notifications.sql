-- Phase 6J: In-app notifications (`public.notifications`), per-type reminder
-- preferences & weekly review day on `public.user_reminder_settings`,
-- deduplication index `(user_id, dedupe_key)`, Realtime publication, and RLS.

-- ============================================================================
-- 1. public.notifications
-- ============================================================================
CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  type text NOT NULL,
  message_key text NOT NULL,
  params jsonb NOT NULL DEFAULT '{}'::jsonb,
  route text NOT NULL,
  dedupe_key text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  read_at timestamptz,
  CONSTRAINT notifications_type_check CHECK (
    type IN (
      'deadline_soon',
      'exam_soon',
      'revision_due',
      'behind_schedule',
      'weekly_review'
    )
  ),
  CONSTRAINT notifications_message_key_not_empty CHECK (
    char_length(btrim(message_key)) > 0
  ),
  CONSTRAINT notifications_params_object_check CHECK (
    jsonb_typeof(params) = 'object'
  ),
  CONSTRAINT notifications_route_not_empty CHECK (
    char_length(btrim(route)) > 0
  ),
  CONSTRAINT notifications_dedupe_key_not_empty CHECK (
    char_length(btrim(dedupe_key)) > 0
  )
);

CREATE UNIQUE INDEX idx_notifications_user_dedupe
  ON public.notifications (user_id, dedupe_key);

CREATE INDEX idx_notifications_user_created
  ON public.notifications (user_id, created_at DESC);

CREATE INDEX idx_notifications_user_unread
  ON public.notifications (user_id, read_at)
  WHERE read_at IS NULL;

ALTER TABLE public.notifications REPLICA IDENTITY FULL;

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own notifications"
  ON public.notifications
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own notifications"
  ON public.notifications
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON public.notifications
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own notifications"
  ON public.notifications
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_publication
    WHERE pubname = 'supabase_realtime'
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = 'notifications'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    END IF;
  END IF;
END;
$$;

-- ============================================================================
-- 2. Extend public.user_reminder_settings with per-type toggles & review day
-- ============================================================================
ALTER TABLE public.user_reminder_settings
  ADD COLUMN deadline_soon_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN exam_soon_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN revision_due_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN behind_schedule_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN weekly_review_enabled boolean NOT NULL DEFAULT true,
  ADD COLUMN weekly_review_day integer NOT NULL DEFAULT 0;

ALTER TABLE public.user_reminder_settings
  ADD CONSTRAINT user_reminder_settings_weekly_review_day_check CHECK (
    weekly_review_day BETWEEN 0 AND 6
  );

COMMENT ON COLUMN public.user_reminder_settings.weekly_review_day IS
  'Preferred day of week for generating weekly_review notifications (0 = Sunday .. 6 = Saturday).';
