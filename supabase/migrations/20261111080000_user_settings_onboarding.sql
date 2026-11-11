-- Phase 6K: User settings (`public.user_settings`) with onboarding progress &
-- completion tracking (`onboarding_completed_at`, `onboarding_step`, draft state,
-- Today tips dismissal) and strict per-user Row Level Security.

-- ============================================================================
-- public.user_settings
-- ============================================================================
CREATE TABLE public.user_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  onboarding_completed_at timestamptz,
  onboarding_step integer NOT NULL DEFAULT 1,
  onboarding_draft jsonb NOT NULL DEFAULT '{}'::jsonb,
  today_tips_dismissed boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_settings_onboarding_step_check CHECK (
    onboarding_step BETWEEN 1 AND 6
  ),
  CONSTRAINT user_settings_onboarding_draft_object_check CHECK (
    jsonb_typeof(onboarding_draft) = 'object'
  )
);

CREATE INDEX idx_user_settings_user_id
  ON public.user_settings (user_id);

CREATE TRIGGER set_user_settings_updated_at
  BEFORE UPDATE ON public.user_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own settings"
  ON public.user_settings
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own settings"
  ON public.user_settings
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own settings"
  ON public.user_settings
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own settings"
  ON public.user_settings
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
