-- Phase 6D: Mock test tracker (`mock_tests`) with marks bounds checks,
-- optional attachments to circulars, materials, and syllabus topics, and RLS.

-- Allow composite owner-verified FK from mock_tests to public.topics.
ALTER TABLE public.topics
  ADD CONSTRAINT topics_id_user_id_key
  UNIQUE (id, user_id);

-- ============================================================================
-- public.mock_tests
-- ============================================================================
CREATE TABLE public.mock_tests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  subject_id uuid NOT NULL,
  circular_id uuid,
  material_id uuid,
  topic_id uuid,
  title text NOT NULL,
  source text,
  taken_on date NOT NULL DEFAULT CURRENT_DATE,
  marks_obtained numeric(8, 2) NOT NULL,
  total_marks numeric(8, 2) NOT NULL,
  negative_marks numeric(8, 2),
  time_taken_minutes integer,
  time_limit_minutes integer,
  weak_topics text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT mock_tests_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT mock_tests_circular_owner_fkey
    FOREIGN KEY (circular_id, user_id)
    REFERENCES public.circulars (id, user_id)
    ON DELETE SET NULL (circular_id),
  CONSTRAINT mock_tests_material_owner_fkey
    FOREIGN KEY (material_id, user_id)
    REFERENCES public.materials (id, user_id)
    ON DELETE SET NULL (material_id),
  CONSTRAINT mock_tests_topic_owner_fkey
    FOREIGN KEY (topic_id, user_id)
    REFERENCES public.topics (id, user_id)
    ON DELETE SET NULL (topic_id),
  CONSTRAINT mock_tests_title_not_empty CHECK (
    char_length(btrim(title)) > 0
  ),
  CONSTRAINT mock_tests_total_marks_positive CHECK (total_marks > 0),
  CONSTRAINT mock_tests_marks_bounds CHECK (
    marks_obtained >= 0 AND marks_obtained <= total_marks
  ),
  CONSTRAINT mock_tests_negative_marks_bounds CHECK (
    negative_marks IS NULL OR (negative_marks >= 0 AND negative_marks <= total_marks)
  ),
  CONSTRAINT mock_tests_time_taken_non_negative CHECK (
    time_taken_minutes IS NULL OR time_taken_minutes >= 0
  ),
  CONSTRAINT mock_tests_time_limit_positive CHECK (
    time_limit_minutes IS NULL OR time_limit_minutes > 0
  )
);

CREATE INDEX idx_mock_tests_user_id
  ON public.mock_tests (user_id);

CREATE INDEX idx_mock_tests_user_subject_date
  ON public.mock_tests (user_id, subject_id, taken_on DESC, created_at DESC);

CREATE INDEX idx_mock_tests_user_date
  ON public.mock_tests (user_id, taken_on DESC, created_at DESC);

CREATE TRIGGER set_mock_tests_updated_at
  BEFORE UPDATE ON public.mock_tests
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.mock_tests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own mock tests"
  ON public.mock_tests
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own mock tests"
  ON public.mock_tests
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own mock tests"
  ON public.mock_tests
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own mock tests"
  ON public.mock_tests
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
