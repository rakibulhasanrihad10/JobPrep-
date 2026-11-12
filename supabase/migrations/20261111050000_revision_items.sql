-- Phase 6G: Spaced-repetition revision marks and queue (`public.revision_items`).

-- Ensure composite owner-verified UNIQUE (id, user_id) constraints exist on
-- progress_logs and mock_tests so optional links cannot cross user boundaries.
ALTER TABLE public.progress_logs
  ADD CONSTRAINT progress_logs_id_user_id_key
  UNIQUE (id, user_id);

ALTER TABLE public.mock_tests
  ADD CONSTRAINT mock_tests_id_user_id_key
  UNIQUE (id, user_id);

-- ============================================================================
-- public.revision_items
-- ============================================================================
CREATE TABLE public.revision_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  material_id uuid,
  subject_id uuid NOT NULL,
  topic_id uuid,
  reference_label text NOT NULL,
  page_number integer,
  note text,
  reason text NOT NULL DEFAULT 'tricky',
  source text NOT NULL DEFAULT 'manual',
  progress_log_id uuid,
  mock_test_id uuid,
  status text NOT NULL DEFAULT 'pending',
  due_on date NOT NULL DEFAULT (CURRENT_DATE + 1),
  review_count integer NOT NULL DEFAULT 0,
  last_reviewed_on date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT revision_items_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT revision_items_material_owner_fkey
    FOREIGN KEY (material_id, user_id)
    REFERENCES public.materials (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT revision_items_topic_owner_fkey
    FOREIGN KEY (topic_id, user_id)
    REFERENCES public.topics (id, user_id)
    ON DELETE SET NULL (topic_id),
  CONSTRAINT revision_items_progress_log_owner_fkey
    FOREIGN KEY (progress_log_id, user_id)
    REFERENCES public.progress_logs (id, user_id)
    ON DELETE SET NULL (progress_log_id),
  CONSTRAINT revision_items_mock_test_owner_fkey
    FOREIGN KEY (mock_test_id, user_id)
    REFERENCES public.mock_tests (id, user_id)
    ON DELETE SET NULL (mock_test_id),
  CONSTRAINT revision_items_reference_label_not_empty CHECK (
    char_length(btrim(reference_label)) > 0
  ),
  CONSTRAINT revision_items_page_number_non_negative CHECK (
    page_number IS NULL OR page_number >= 0
  ),
  CONSTRAINT revision_items_reason_check CHECK (
    reason IN ('tricky', 'forgot', 'important', 'mistake')
  ),
  CONSTRAINT revision_items_source_check CHECK (
    source IN ('log', 'mock_test', 'manual')
  ),
  CONSTRAINT revision_items_status_check CHECK (
    status IN ('pending', 'revised', 'mastered', 'dismissed')
  ),
  CONSTRAINT revision_items_review_count_non_negative CHECK (
    review_count >= 0
  )
);

CREATE INDEX idx_revision_items_user_id
  ON public.revision_items (user_id);

CREATE INDEX idx_revision_items_status
  ON public.revision_items (status);

CREATE INDEX idx_revision_items_due_on
  ON public.revision_items (due_on);

CREATE INDEX idx_revision_items_user_status_due_on
  ON public.revision_items (user_id, status, due_on);

CREATE TRIGGER set_revision_items_updated_at
  BEFORE UPDATE ON public.revision_items
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.revision_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own revision items"
  ON public.revision_items
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own revision items"
  ON public.revision_items
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own revision items"
  ON public.revision_items
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own revision items"
  ON public.revision_items
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
