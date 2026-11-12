-- Phase 6H: Timestamp-driven study timer sessions (`public.study_sessions`).

-- ============================================================================
-- public.study_sessions
-- ============================================================================
CREATE TABLE public.study_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  subject_id uuid NOT NULL,
  material_id uuid,
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  duration_seconds integer NOT NULL DEFAULT 0,
  mode text NOT NULL DEFAULT 'focus',
  note text,
  pause_intervals jsonb NOT NULL DEFAULT '[]'::jsonb,
  phase_started_at timestamptz,
  target_duration_seconds integer,
  pomodoro_round integer,
  pomodoro_phase text,
  focus_minutes integer NOT NULL DEFAULT 25,
  short_break_minutes integer NOT NULL DEFAULT 5,
  long_break_minutes integer NOT NULL DEFAULT 15,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT study_sessions_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT study_sessions_material_owner_fkey
    FOREIGN KEY (material_id, user_id)
    REFERENCES public.materials (id, user_id)
    ON DELETE SET NULL (material_id),
  CONSTRAINT study_sessions_duration_non_negative CHECK (
    duration_seconds >= 0
  ),
  CONSTRAINT study_sessions_mode_check CHECK (
    mode IN ('focus', 'stopwatch', 'manual')
  ),
  CONSTRAINT study_sessions_ended_after_start CHECK (
    ended_at IS NULL OR ended_at >= started_at
  ),
  CONSTRAINT study_sessions_pause_intervals_array CHECK (
    jsonb_typeof(pause_intervals) = 'array'
  ),
  CONSTRAINT study_sessions_target_duration_non_negative CHECK (
    target_duration_seconds IS NULL OR target_duration_seconds >= 0
  ),
  CONSTRAINT study_sessions_pomodoro_phase_check CHECK (
    pomodoro_phase IS NULL OR pomodoro_phase IN ('focus', 'short_break', 'long_break')
  ),
  CONSTRAINT study_sessions_pomodoro_round_positive CHECK (
    pomodoro_round IS NULL OR pomodoro_round >= 1
  ),
  CONSTRAINT study_sessions_pomodoro_lengths_positive CHECK (
    focus_minutes > 0 AND short_break_minutes > 0 AND long_break_minutes > 0
  )
);

CREATE INDEX idx_study_sessions_user_id
  ON public.study_sessions (user_id);

CREATE INDEX idx_study_sessions_user_started_at
  ON public.study_sessions (user_id, started_at DESC);

CREATE INDEX idx_study_sessions_subject_id
  ON public.study_sessions (subject_id);

CREATE INDEX idx_study_sessions_active_open
  ON public.study_sessions (user_id)
  WHERE ended_at IS NULL;

CREATE TRIGGER set_study_sessions_updated_at
  BEFORE UPDATE ON public.study_sessions
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.study_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own study sessions"
  ON public.study_sessions
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own study sessions"
  ON public.study_sessions
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own study sessions"
  ON public.study_sessions
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own study sessions"
  ON public.study_sessions
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
