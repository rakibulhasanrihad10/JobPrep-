-- Phase 4A: Preparation schema (`subjects`, `materials`, `progress_logs`,
-- `topics`, `circular_subjects`), progress calculation trigger & views
-- (`material_progress`, `subject_progress`), and Row Level Security.

-- ============================================================================
-- 1. public.subjects
-- ============================================================================
CREATE TABLE public.subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  name text NOT NULL,
  color text NOT NULL DEFAULT 'gold',
  icon text NOT NULL DEFAULT 'menu_book',
  exam_type text NOT NULL DEFAULT 'general',
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT subjects_id_user_id_key UNIQUE (id, user_id),
  CONSTRAINT subjects_name_not_empty CHECK (char_length(btrim(name)) > 0),
  CONSTRAINT subjects_color_not_empty CHECK (char_length(btrim(color)) > 0),
  CONSTRAINT subjects_icon_not_empty CHECK (char_length(btrim(icon)) > 0),
  CONSTRAINT subjects_exam_type_not_empty CHECK (
    char_length(btrim(exam_type)) > 0
  ),
  CONSTRAINT subjects_sort_order_non_negative CHECK (sort_order >= 0)
);

CREATE INDEX idx_subjects_user_id
  ON public.subjects (user_id);

CREATE INDEX idx_subjects_user_sort_order
  ON public.subjects (user_id, sort_order, created_at);

CREATE TRIGGER set_subjects_updated_at
  BEFORE UPDATE ON public.subjects
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subjects"
  ON public.subjects
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own subjects"
  ON public.subjects
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own subjects"
  ON public.subjects
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own subjects"
  ON public.subjects
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 2. public.materials
-- ============================================================================
CREATE TABLE public.materials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  subject_id uuid NOT NULL,
  title text NOT NULL,
  kind text NOT NULL DEFAULT 'book',
  unit_label text NOT NULL DEFAULT 'pages',
  total_units integer NOT NULL DEFAULT 0,
  completed_units integer NOT NULL DEFAULT 0,
  cover_image_path text,
  cover_image_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT materials_id_user_id_key UNIQUE (id, user_id),
  CONSTRAINT materials_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT materials_title_not_empty CHECK (char_length(btrim(title)) > 0),
  CONSTRAINT materials_kind_check CHECK (
    kind IN (
      'book',
      'video_course',
      'lecture_sheet',
      'question_bank',
      'notes',
      'mock_test',
      'other'
    )
  ),
  CONSTRAINT materials_unit_label_not_empty CHECK (
    char_length(btrim(unit_label)) > 0
  ),
  CONSTRAINT materials_total_units_non_negative CHECK (total_units >= 0),
  CONSTRAINT materials_completed_units_bounds CHECK (
    completed_units >= 0 AND completed_units <= total_units
  )
);

CREATE INDEX idx_materials_user_id
  ON public.materials (user_id);

CREATE INDEX idx_materials_subject_id
  ON public.materials (subject_id);

-- Keeps materials.completed_units within [0, total_units] if total_units is
-- reduced below current progress or seeded out of range.
CREATE OR REPLACE FUNCTION public.clamp_material_completed_units()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF NEW.total_units >= 0 THEN
    NEW.completed_units := LEAST(
      NEW.total_units,
      GREATEST(0, COALESCE(NEW.completed_units, 0))
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER clamp_material_completed_units_trigger
  BEFORE INSERT OR UPDATE ON public.materials
  FOR EACH ROW
  EXECUTE FUNCTION public.clamp_material_completed_units();

CREATE TRIGGER set_materials_updated_at
  BEFORE UPDATE ON public.materials
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.materials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own materials"
  ON public.materials
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own materials"
  ON public.materials
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own materials"
  ON public.materials
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own materials"
  ON public.materials
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 3. public.progress_logs
-- ============================================================================
CREATE TABLE public.progress_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  material_id uuid NOT NULL,
  units_done integer NOT NULL DEFAULT 0,
  logged_on date NOT NULL DEFAULT CURRENT_DATE,
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT progress_logs_material_owner_fkey
    FOREIGN KEY (material_id, user_id)
    REFERENCES public.materials (id, user_id)
    ON DELETE CASCADE
);

CREATE INDEX idx_progress_logs_user_id
  ON public.progress_logs (user_id);

CREATE INDEX idx_progress_logs_material_id
  ON public.progress_logs (material_id);

CREATE INDEX idx_progress_logs_logged_on
  ON public.progress_logs (user_id, logged_on DESC);

CREATE TRIGGER set_progress_logs_updated_at
  BEFORE UPDATE ON public.progress_logs
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

-- Recalculates parent material completed_units after progress_logs INSERT,
-- UPDATE, or DELETE, clamping cleanly between 0 and total_units.
CREATE OR REPLACE FUNCTION public.recalculate_material_completed_units()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  v_sum bigint;
BEGIN
  IF TG_OP = 'DELETE' OR (
    TG_OP = 'UPDATE' AND OLD.material_id IS DISTINCT FROM NEW.material_id
  ) THEN
    SELECT COALESCE(SUM(pl.units_done), 0)
      INTO v_sum
      FROM public.progress_logs AS pl
     WHERE pl.material_id = OLD.material_id;

    UPDATE public.materials AS m
       SET completed_units = LEAST(m.total_units, GREATEST(0, v_sum))::integer
     WHERE m.id = OLD.material_id;
  END IF;

  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    SELECT COALESCE(SUM(pl.units_done), 0)
      INTO v_sum
      FROM public.progress_logs AS pl
     WHERE pl.material_id = NEW.material_id;

    UPDATE public.materials AS m
       SET completed_units = LEAST(m.total_units, GREATEST(0, v_sum))::integer
     WHERE m.id = NEW.material_id;
  END IF;

  RETURN NULL;
END;
$$;

CREATE TRIGGER recalculate_material_completed_units_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.progress_logs
  FOR EACH ROW
  EXECUTE FUNCTION public.recalculate_material_completed_units();

ALTER TABLE public.progress_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own progress logs"
  ON public.progress_logs
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own progress logs"
  ON public.progress_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own progress logs"
  ON public.progress_logs
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own progress logs"
  ON public.progress_logs
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 4. public.topics
-- ============================================================================
CREATE TABLE public.topics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  subject_id uuid NOT NULL,
  name text NOT NULL,
  status text NOT NULL DEFAULT 'not_started',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT topics_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT topics_name_not_empty CHECK (char_length(btrim(name)) > 0),
  CONSTRAINT topics_status_check CHECK (
    status IN ('not_started', 'in_progress', 'needs_revision', 'completed')
  )
);

CREATE INDEX idx_topics_user_id
  ON public.topics (user_id);

CREATE INDEX idx_topics_subject_id
  ON public.topics (subject_id);

CREATE TRIGGER set_topics_updated_at
  BEFORE UPDATE ON public.topics
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own topics"
  ON public.topics
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own topics"
  ON public.topics
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own topics"
  ON public.topics
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own topics"
  ON public.topics
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 5. public.circular_subjects
-- ============================================================================
CREATE TABLE public.circular_subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  circular_id uuid NOT NULL,
  subject_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT circular_subjects_circular_owner_fkey
    FOREIGN KEY (circular_id, user_id)
    REFERENCES public.circulars (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT circular_subjects_subject_owner_fkey
    FOREIGN KEY (subject_id, user_id)
    REFERENCES public.subjects (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT circular_subjects_circular_subject_unique
    UNIQUE (circular_id, subject_id)
);

CREATE INDEX idx_circular_subjects_user_id
  ON public.circular_subjects (user_id);

CREATE INDEX idx_circular_subjects_circular_id
  ON public.circular_subjects (circular_id);

CREATE INDEX idx_circular_subjects_subject_id
  ON public.circular_subjects (subject_id);

CREATE TRIGGER set_circular_subjects_updated_at
  BEFORE UPDATE ON public.circular_subjects
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.circular_subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own circular subjects"
  ON public.circular_subjects
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own circular subjects"
  ON public.circular_subjects
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own circular subjects"
  ON public.circular_subjects
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own circular subjects"
  ON public.circular_subjects
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 6. Progress Views (security_invoker = true so underlying RLS applies)
-- ============================================================================
CREATE VIEW public.material_progress
WITH (security_invoker = true) AS
SELECT
  m.id,
  m.id AS material_id,
  m.user_id,
  m.subject_id,
  m.title,
  m.kind,
  m.unit_label,
  m.completed_units,
  m.total_units,
  CASE
    WHEN m.total_units > 0 THEN m.completed_units::numeric / m.total_units::numeric
    ELSE 0::numeric
  END AS progress,
  ROUND(
    CASE
      WHEN m.total_units > 0
        THEN (m.completed_units::numeric * 100.0) / m.total_units::numeric
      ELSE 0::numeric
    END,
    2
  ) AS progress_percent,
  m.cover_image_path,
  m.cover_image_url,
  m.created_at,
  m.updated_at
FROM public.materials AS m;

CREATE VIEW public.subject_progress
WITH (security_invoker = true) AS
SELECT
  s.id,
  s.id AS subject_id,
  s.user_id,
  s.name,
  s.color,
  s.icon,
  s.exam_type,
  s.sort_order,
  COUNT(m.id)::integer AS material_count,
  COALESCE(SUM(m.completed_units), 0)::bigint AS completed_units,
  COALESCE(SUM(m.total_units), 0)::bigint AS total_units,
  CASE
    WHEN COALESCE(SUM(m.total_units), 0) > 0
      THEN COALESCE(SUM(m.completed_units), 0)::numeric / SUM(m.total_units)::numeric
    ELSE 0::numeric
  END AS progress,
  ROUND(
    CASE
      WHEN COALESCE(SUM(m.total_units), 0) > 0
        THEN (COALESCE(SUM(m.completed_units), 0)::numeric * 100.0) / SUM(m.total_units)::numeric
      ELSE 0::numeric
    END,
    2
  ) AS progress_percent,
  s.created_at,
  s.updated_at
FROM public.subjects AS s
LEFT JOIN public.materials AS m
  ON m.subject_id = s.id
 AND m.user_id = s.user_id
GROUP BY
  s.id,
  s.user_id,
  s.name,
  s.color,
  s.icon,
  s.exam_type,
  s.sort_order,
  s.created_at,
  s.updated_at;

GRANT SELECT ON public.material_progress TO authenticated;
GRANT SELECT ON public.subject_progress TO authenticated;
