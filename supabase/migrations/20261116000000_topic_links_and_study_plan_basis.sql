-- Phase 9G: Topic links, material chapters, and study plan basis.

-- ============================================================================
-- 1. public.mock_test_topics
-- ============================================================================
CREATE TABLE public.mock_test_topics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  mock_test_id uuid NOT NULL,
  topic_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT mock_test_topics_id_user_id_key UNIQUE (id, user_id),
  CONSTRAINT mock_test_topics_unique UNIQUE (mock_test_id, topic_id),
  CONSTRAINT mock_test_topics_mock_test_fkey
    FOREIGN KEY (mock_test_id, user_id)
    REFERENCES public.mock_tests (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT mock_test_topics_topic_fkey
    FOREIGN KEY (topic_id, user_id)
    REFERENCES public.topics (id, user_id)
    ON DELETE CASCADE
);

CREATE INDEX idx_mock_test_topics_user_id
  ON public.mock_test_topics (user_id);

CREATE INDEX idx_mock_test_topics_mock_test_id
  ON public.mock_test_topics (mock_test_id);

CREATE INDEX idx_mock_test_topics_topic_id
  ON public.mock_test_topics (topic_id);

ALTER TABLE public.mock_test_topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own mock_test_topics"
  ON public.mock_test_topics
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own mock_test_topics"
  ON public.mock_test_topics
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own mock_test_topics"
  ON public.mock_test_topics
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own mock_test_topics"
  ON public.mock_test_topics
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 2. public.material_chapters
-- ============================================================================
CREATE TABLE public.material_chapters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  material_id uuid NOT NULL,
  chapter_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT material_chapters_id_user_id_key UNIQUE (id, user_id),
  CONSTRAINT material_chapters_unique UNIQUE (material_id, chapter_id),
  CONSTRAINT material_chapters_material_fkey
    FOREIGN KEY (material_id, user_id)
    REFERENCES public.materials (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT material_chapters_chapter_fkey
    FOREIGN KEY (chapter_id, user_id)
    REFERENCES public.chapters (id, user_id)
    ON DELETE CASCADE
);

CREATE INDEX idx_material_chapters_user_id
  ON public.material_chapters (user_id);

CREATE INDEX idx_material_chapters_material_id
  ON public.material_chapters (material_id);

CREATE INDEX idx_material_chapters_chapter_id
  ON public.material_chapters (chapter_id);

ALTER TABLE public.material_chapters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own material_chapters"
  ON public.material_chapters
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own material_chapters"
  ON public.material_chapters
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own material_chapters"
  ON public.material_chapters
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own material_chapters"
  ON public.material_chapters
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 3. public.study_plans: plan_basis column
-- ============================================================================
ALTER TABLE public.study_plans
  ADD COLUMN IF NOT EXISTS plan_basis text NOT NULL DEFAULT 'reading_units';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'study_plans_plan_basis_check'
  ) THEN
    ALTER TABLE public.study_plans
      ADD CONSTRAINT study_plans_plan_basis_check
      CHECK (plan_basis IN ('reading_units', 'syllabus_topics'));
  END IF;
END $$;
