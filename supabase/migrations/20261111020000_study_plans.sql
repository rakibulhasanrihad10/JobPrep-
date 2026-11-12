-- Phase 6C: Study plans (`study_plans`) with exam date countdown, finish buffer,
-- weekly rest days, optional circular/exam date linkage, max daily pace limit,
-- postponed material tracking, and strict per-user Row Level Security.

-- Allow composite owner-verified FK from study_plans to circular_exam_dates.
ALTER TABLE public.circular_exam_dates
  ADD CONSTRAINT circular_exam_dates_id_user_id_key
  UNIQUE (id, user_id);

-- ============================================================================
-- public.study_plans
-- ============================================================================
CREATE TABLE public.study_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  subject_id uuid,
  circular_id uuid,
  exam_date_id uuid,
  start_date date NOT NULL DEFAULT CURRENT_DATE,
  target_date date NOT NULL,
  finish_buffer_days integer NOT NULL DEFAULT 7,
  rest_days_per_week integer NOT NULL DEFAULT 0,
  extra_study_days integer NOT NULL DEFAULT 0,
  max_daily_pace integer,
  initial_completed_units integer NOT NULL DEFAULT 0,
  postponed_material_ids uuid[] NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT study_plans_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT study_plans_circular_owner_fkey
    FOREIGN KEY (circular_id, user_id)
    REFERENCES public.circulars (id, user_id)
    ON DELETE SET NULL (circular_id),
  CONSTRAINT study_plans_exam_date_owner_fkey
    FOREIGN KEY (exam_date_id, user_id)
    REFERENCES public.circular_exam_dates (id, user_id)
    ON DELETE SET NULL (exam_date_id),
  CONSTRAINT study_plans_buffer_bounds CHECK (
    finish_buffer_days >= 0 AND finish_buffer_days <= 365
  ),
  CONSTRAINT study_plans_rest_days_bounds CHECK (
    rest_days_per_week >= 0 AND rest_days_per_week <= 6
  ),
  CONSTRAINT study_plans_extra_study_days_non_negative CHECK (
    extra_study_days >= 0
  ),
  CONSTRAINT study_plans_max_daily_pace_positive CHECK (
    max_daily_pace IS NULL OR max_daily_pace > 0
  ),
  CONSTRAINT study_plans_initial_completed_non_negative CHECK (
    initial_completed_units >= 0
  )
);

CREATE INDEX idx_study_plans_user_id
  ON public.study_plans (user_id);

CREATE INDEX idx_study_plans_target_date
  ON public.study_plans (user_id, target_date ASC);

CREATE UNIQUE INDEX idx_study_plans_user_all_subjects_unique
  ON public.study_plans (user_id)
  WHERE subject_id IS NULL;

CREATE UNIQUE INDEX idx_study_plans_user_subject_unique
  ON public.study_plans (user_id, subject_id)
  WHERE subject_id IS NOT NULL;

CREATE TRIGGER set_study_plans_updated_at
  BEFORE UPDATE ON public.study_plans
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.study_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own study plans"
  ON public.study_plans
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own study plans"
  ON public.study_plans
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own study plans"
  ON public.study_plans
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own study plans"
  ON public.study_plans
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
