-- Phase 3A: Circulars, exam dates, and circular file metadata schema with
-- constraints, indexes, updated_at triggers, and Row Level Security.

-- Shared trigger helper maintaining UTC updated_at timestamps across tables.
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- ============================================================================
-- 1. public.circulars
-- ============================================================================
CREATE TABLE public.circulars (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  title text NOT NULL,
  sector text NOT NULL DEFAULT 'government',
  organization_name text,
  organization_website text,
  circular_url text,
  application_url text,
  deadline timestamptz,
  vacancies integer,
  salary_min numeric(12, 2),
  salary_max numeric(12, 2),
  salary_note text,
  application_fee numeric(12, 2),
  fee_note text,
  application_status text NOT NULL DEFAULT 'not_applied',
  admit_card_status text NOT NULL DEFAULT 'not_available',
  priority text NOT NULL DEFAULT 'medium',
  workflow_status text NOT NULL DEFAULT 'saved',
  instructions text,
  notes text,
  syllabus text,
  is_quick_capture boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT circulars_id_user_id_key UNIQUE (id, user_id),
  CONSTRAINT circulars_title_not_empty CHECK (char_length(btrim(title)) > 0),
  CONSTRAINT circulars_sector_check CHECK (
    sector IN (
      'government',
      'bcs',
      'bank',
      'autonomous',
      'private',
      'ngo',
      'defense',
      'other'
    )
  ),
  CONSTRAINT circulars_vacancies_non_negative CHECK (
    vacancies IS NULL OR vacancies >= 0
  ),
  CONSTRAINT circulars_salary_min_non_negative CHECK (
    salary_min IS NULL OR salary_min >= 0
  ),
  CONSTRAINT circulars_salary_max_non_negative CHECK (
    salary_max IS NULL OR salary_max >= 0
  ),
  CONSTRAINT circulars_salary_range_check CHECK (
    salary_min IS NULL OR salary_max IS NULL OR salary_max >= salary_min
  ),
  CONSTRAINT circulars_application_fee_non_negative CHECK (
    application_fee IS NULL OR application_fee >= 0
  ),
  CONSTRAINT circulars_application_status_check CHECK (
    application_status IN (
      'not_applied',
      'in_progress',
      'applied',
      'fee_paid',
      'exempt',
      'missed',
      'not_applicable'
    )
  ),
  CONSTRAINT circulars_admit_card_status_check CHECK (
    admit_card_status IN (
      'not_available',
      'available',
      'downloaded',
      'not_applicable'
    )
  ),
  CONSTRAINT circulars_priority_check CHECK (
    priority IN ('low', 'medium', 'high', 'urgent')
  ),
  CONSTRAINT circulars_workflow_status_check CHECK (
    workflow_status IN (
      'saved',
      'preparing',
      'applied',
      'exam_upcoming',
      'result_awaited',
      'archived'
    )
  )
);

CREATE INDEX idx_circulars_user_id
  ON public.circulars (user_id);

CREATE INDEX idx_circulars_deadline
  ON public.circulars (deadline);

CREATE INDEX idx_circulars_workflow_status
  ON public.circulars (workflow_status);

CREATE INDEX idx_circulars_user_status_deadline
  ON public.circulars (user_id, workflow_status, deadline);

CREATE TRIGGER set_circulars_updated_at
  BEFORE UPDATE ON public.circulars
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.circulars ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own circulars"
  ON public.circulars
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own circulars"
  ON public.circulars
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own circulars"
  ON public.circulars
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own circulars"
  ON public.circulars
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 2. public.circular_exam_dates
-- ============================================================================
CREATE TABLE public.circular_exam_dates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  circular_id uuid NOT NULL,
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  stage text NOT NULL,
  exam_date timestamptz NOT NULL,
  venue text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT circular_exam_dates_circular_owner_fkey
    FOREIGN KEY (circular_id, user_id)
    REFERENCES public.circulars (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT circular_exam_dates_stage_not_empty CHECK (
    char_length(btrim(stage)) > 0
  )
);

CREATE INDEX idx_circular_exam_dates_user_id
  ON public.circular_exam_dates (user_id);

CREATE INDEX idx_circular_exam_dates_circular_id
  ON public.circular_exam_dates (circular_id);

CREATE INDEX idx_circular_exam_dates_exam_date
  ON public.circular_exam_dates (exam_date);

CREATE TRIGGER set_circular_exam_dates_updated_at
  BEFORE UPDATE ON public.circular_exam_dates
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.circular_exam_dates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own circular exam dates"
  ON public.circular_exam_dates
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own circular exam dates"
  ON public.circular_exam_dates
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own circular exam dates"
  ON public.circular_exam_dates
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own circular exam dates"
  ON public.circular_exam_dates
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 3. public.circular_files
-- ============================================================================
CREATE TABLE public.circular_files (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  circular_id uuid NOT NULL,
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  storage_path text NOT NULL,
  file_name text NOT NULL,
  mime_type text NOT NULL,
  size_bytes bigint NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT circular_files_circular_owner_fkey
    FOREIGN KEY (circular_id, user_id)
    REFERENCES public.circulars (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT circular_files_storage_path_not_empty CHECK (
    char_length(btrim(storage_path)) > 0
  ),
  CONSTRAINT circular_files_file_name_not_empty CHECK (
    char_length(btrim(file_name)) > 0
  ),
  CONSTRAINT circular_files_mime_type_not_empty CHECK (
    char_length(btrim(mime_type)) > 0
  ),
  CONSTRAINT circular_files_size_bytes_non_negative CHECK (
    size_bytes >= 0
  )
);

CREATE INDEX idx_circular_files_user_id
  ON public.circular_files (user_id);

CREATE INDEX idx_circular_files_circular_id
  ON public.circular_files (circular_id);

CREATE TRIGGER set_circular_files_updated_at
  BEFORE UPDATE ON public.circular_files
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.circular_files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own circular files"
  ON public.circular_files
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own circular files"
  ON public.circular_files
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own circular files"
  ON public.circular_files
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own circular files"
  ON public.circular_files
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
