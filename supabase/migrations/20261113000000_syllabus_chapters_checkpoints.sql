-- Phase 9F: Syllabus tree and checkpoints (chapters, checkpoint timestamps,
-- enabled_checkpoints array, topic weights, and status migration).

-- ============================================================================
-- 1. public.chapters
-- ============================================================================
CREATE TABLE public.chapters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  subject_id uuid NOT NULL,
  title text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chapters_id_user_id_key UNIQUE (id, user_id),
  CONSTRAINT chapters_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT chapters_title_not_empty CHECK (char_length(btrim(title)) > 0),
  CONSTRAINT chapters_sort_order_non_negative CHECK (sort_order >= 0)
);

CREATE INDEX idx_chapters_user_id
  ON public.chapters (user_id);

CREATE INDEX idx_chapters_subject_id
  ON public.chapters (subject_id);

CREATE INDEX idx_chapters_user_subject_sort
  ON public.chapters (user_id, subject_id, sort_order, created_at);

CREATE TRIGGER set_chapters_updated_at
  BEFORE UPDATE ON public.chapters
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own chapters"
  ON public.chapters
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own chapters"
  ON public.chapters
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own chapters"
  ON public.chapters
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own chapters"
  ON public.chapters
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

REVOKE TRUNCATE, REFERENCES, TRIGGER ON public.chapters FROM authenticated, anon;

-- ============================================================================
-- 2. Extend public.subjects with enabled_checkpoints
-- ============================================================================
ALTER TABLE public.subjects
  ADD COLUMN IF NOT EXISTS enabled_checkpoints text[]
  NOT NULL DEFAULT ARRAY['study', 'practice', 'model_test', 'revision'];

-- ============================================================================
-- 3. Extend public.topics with chapter_id, title, sort_order, weight & checkpoints
-- ============================================================================
ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS chapter_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'topics_chapter_owner_fkey'
  ) THEN
    ALTER TABLE public.topics
      ADD CONSTRAINT topics_chapter_owner_fkey
      FOREIGN KEY (chapter_id, user_id)
      REFERENCES public.chapters (id, user_id)
      ON DELETE CASCADE;
  END IF;
END $$;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS title text;

-- Populate title from legacy name if present
UPDATE public.topics
   SET title = name
 WHERE title IS NULL;

-- Automatically synchronize name and title for backward and forward compatibility
CREATE OR REPLACE FUNCTION public.sync_topic_name_and_title()
RETURNS trigger AS $$
BEGIN
  IF NEW.title IS NULL AND NEW.name IS NOT NULL THEN
    NEW.title := NEW.name;
  ELSIF NEW.name IS NULL AND NEW.title IS NOT NULL THEN
    NEW.name := NEW.title;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_sync_topic_name_and_title ON public.topics;
CREATE TRIGGER trigger_sync_topic_name_and_title
  BEFORE INSERT OR UPDATE ON public.topics
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_topic_name_and_title();

ALTER TABLE public.topics
  ALTER COLUMN name DROP NOT NULL;

ALTER TABLE public.topics
  ALTER COLUMN title SET NOT NULL;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS sort_order integer NOT NULL DEFAULT 0;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS weight integer NOT NULL DEFAULT 1;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'topics_weight_non_negative'
  ) THEN
    ALTER TABLE public.topics
      ADD CONSTRAINT topics_weight_non_negative CHECK (weight >= 0);
  END IF;
END $$;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS study_done_at timestamptz;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS practice_done_at timestamptz;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS model_test_done_at timestamptz;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS revision_done_at timestamptz;

ALTER TABLE public.topics
  ADD COLUMN IF NOT EXISTS notes text;

CREATE INDEX IF NOT EXISTS idx_topics_chapter_id
  ON public.topics (chapter_id);

CREATE INDEX IF NOT EXISTS idx_topics_sort_order
  ON public.topics (subject_id, sort_order);

-- ============================================================================
-- 4. Migrate legacy topics.status into checkpoint timestamps
-- ============================================================================
-- Status: learning / in_progress -> study done
UPDATE public.topics
   SET study_done_at = COALESCE(study_done_at, updated_at, now())
 WHERE status IN ('learning', 'in_progress')
   AND study_done_at IS NULL;

-- Status: revised / needs_revision -> study and revision done
UPDATE public.topics
   SET study_done_at = COALESCE(study_done_at, updated_at, now()),
       revision_done_at = COALESCE(revision_done_at, updated_at, now())
 WHERE status IN ('revised', 'needs_revision');

-- Status: mastered / completed -> all four checkpoints done
UPDATE public.topics
   SET study_done_at = COALESCE(study_done_at, updated_at, now()),
       practice_done_at = COALESCE(practice_done_at, updated_at, now()),
       model_test_done_at = COALESCE(model_test_done_at, updated_at, now()),
       revision_done_at = COALESCE(revision_done_at, updated_at, now())
 WHERE status IN ('mastered', 'completed');
