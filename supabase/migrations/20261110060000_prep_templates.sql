-- Phase 4E: Preparation starter & personal template tables
-- (`prep_templates`, `prep_template_items`), Row Level Security policies, and
-- seeded Government Job & Software Engineer packs.

-- ============================================================================
-- 1. public.prep_templates
-- ============================================================================
CREATE TABLE public.prep_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  slug text,
  title text NOT NULL,
  description text,
  exam_type text NOT NULL DEFAULT 'general',
  is_system boolean NOT NULL DEFAULT false,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT prep_templates_title_not_empty CHECK (
    char_length(btrim(title)) > 0
  ),
  CONSTRAINT prep_templates_exam_type_not_empty CHECK (
    char_length(btrim(exam_type)) > 0
  ),
  CONSTRAINT prep_templates_sort_order_non_negative CHECK (sort_order >= 0),
  CONSTRAINT prep_templates_slug_not_empty CHECK (
    slug IS NULL OR char_length(btrim(slug)) > 0
  ),
  CONSTRAINT prep_templates_ownership_check CHECK (
    (is_system = true AND user_id IS NULL)
    OR (is_system = false AND user_id IS NOT NULL)
  )
);

CREATE UNIQUE INDEX idx_prep_templates_slug_unique
  ON public.prep_templates (slug)
  WHERE slug IS NOT NULL;

CREATE INDEX idx_prep_templates_user_id
  ON public.prep_templates (user_id);

CREATE INDEX idx_prep_templates_display_order
  ON public.prep_templates (is_system DESC, sort_order ASC, created_at ASC);

CREATE TRIGGER set_prep_templates_updated_at
  BEFORE UPDATE ON public.prep_templates
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.prep_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Signed-in users can read system and own prep templates"
  ON public.prep_templates
  FOR SELECT
  TO authenticated
  USING (
    (is_system = true AND auth.uid() IS NOT NULL)
    OR (is_system = false AND user_id = auth.uid())
  );

CREATE POLICY "Users can insert own personal prep templates"
  ON public.prep_templates
  FOR INSERT
  TO authenticated
  WITH CHECK (
    is_system = false
    AND user_id = auth.uid()
  );

CREATE POLICY "Users can update own personal prep templates"
  ON public.prep_templates
  FOR UPDATE
  TO authenticated
  USING (
    is_system = false
    AND user_id = auth.uid()
  )
  WITH CHECK (
    is_system = false
    AND user_id = auth.uid()
  );

CREATE POLICY "Users can delete own personal prep templates"
  ON public.prep_templates
  FOR DELETE
  TO authenticated
  USING (
    is_system = false
    AND user_id = auth.uid()
  );

-- ============================================================================
-- 2. public.prep_template_items
-- ============================================================================
CREATE TABLE public.prep_template_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id uuid NOT NULL REFERENCES public.prep_templates (id) ON DELETE CASCADE,
  user_id uuid DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  subject_name text NOT NULL,
  subject_color text NOT NULL DEFAULT 'gold',
  subject_icon text NOT NULL DEFAULT 'menu_book',
  exam_type text NOT NULL DEFAULT 'general',
  subject_sort_order integer NOT NULL DEFAULT 0,
  material_title text,
  material_kind text NOT NULL DEFAULT 'book',
  unit_label text NOT NULL DEFAULT 'pages',
  total_units integer NOT NULL DEFAULT 0,
  item_sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT prep_template_items_subject_name_not_empty CHECK (
    char_length(btrim(subject_name)) > 0
  ),
  CONSTRAINT prep_template_items_subject_color_not_empty CHECK (
    char_length(btrim(subject_color)) > 0
  ),
  CONSTRAINT prep_template_items_subject_icon_not_empty CHECK (
    char_length(btrim(subject_icon)) > 0
  ),
  CONSTRAINT prep_template_items_exam_type_not_empty CHECK (
    char_length(btrim(exam_type)) > 0
  ),
  CONSTRAINT prep_template_items_subject_sort_non_negative CHECK (
    subject_sort_order >= 0
  ),
  CONSTRAINT prep_template_items_material_title_not_empty CHECK (
    material_title IS NULL OR char_length(btrim(material_title)) > 0
  ),
  CONSTRAINT prep_template_items_material_kind_check CHECK (
    material_kind IN (
      'book',
      'video_course',
      'lecture_sheet',
      'question_bank',
      'notes',
      'mock_test',
      'other'
    )
  ),
  CONSTRAINT prep_template_items_unit_label_not_empty CHECK (
    char_length(btrim(unit_label)) > 0
  ),
  CONSTRAINT prep_template_items_total_units_non_negative CHECK (
    total_units >= 0
  ),
  CONSTRAINT prep_template_items_item_sort_non_negative CHECK (
    item_sort_order >= 0
  )
);

CREATE INDEX idx_prep_template_items_template_id
  ON public.prep_template_items (template_id, subject_sort_order, item_sort_order);

CREATE INDEX idx_prep_template_items_user_id
  ON public.prep_template_items (user_id);

-- Verifies after RLS checks that template items match their parent template's owner.
CREATE OR REPLACE FUNCTION public.validate_prep_template_item_owner()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_parent record;
BEGIN
  SELECT pt.is_system, pt.user_id
    INTO v_parent
    FROM public.prep_templates AS pt
   WHERE pt.id = NEW.template_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Referenced prep_templates row % does not exist.', NEW.template_id
      USING ERRCODE = '23503';
  END IF;

  IF v_parent.is_system THEN
    IF NEW.user_id IS NOT NULL THEN
      RAISE EXCEPTION 'System prep template items must have NULL user_id.'
        USING ERRCODE = '42501';
    END IF;
  ELSE
    IF NEW.user_id IS DISTINCT FROM v_parent.user_id THEN
      RAISE EXCEPTION 'Personal prep template items must match parent template owner.'
        USING ERRCODE = '42501';
    END IF;
  END IF;

  RETURN NULL;
END;
$$;

CREATE TRIGGER validate_prep_template_item_owner_trigger
  AFTER INSERT OR UPDATE ON public.prep_template_items
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_prep_template_item_owner();

CREATE TRIGGER set_prep_template_items_updated_at
  BEFORE UPDATE ON public.prep_template_items
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.prep_template_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Signed-in users can read system and own template items"
  ON public.prep_template_items
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
        FROM public.prep_templates AS pt
       WHERE pt.id = template_id
         AND (
           (pt.is_system = true AND auth.uid() IS NOT NULL)
           OR (pt.is_system = false AND pt.user_id = auth.uid() AND user_id = auth.uid())
         )
    )
  );

CREATE POLICY "Users can insert items into own personal templates"
  ON public.prep_template_items
  FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1
        FROM public.prep_templates AS pt
       WHERE pt.id = template_id
         AND pt.is_system = false
         AND pt.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update items in own personal templates"
  ON public.prep_template_items
  FOR UPDATE
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1
        FROM public.prep_templates AS pt
       WHERE pt.id = template_id
         AND pt.is_system = false
         AND pt.user_id = auth.uid()
    )
  )
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1
        FROM public.prep_templates AS pt
       WHERE pt.id = template_id
         AND pt.is_system = false
         AND pt.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete items in own personal templates"
  ON public.prep_template_items
  FOR DELETE
  TO authenticated
  USING (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1
        FROM public.prep_templates AS pt
       WHERE pt.id = template_id
         AND pt.is_system = false
         AND pt.user_id = auth.uid()
    )
  );

-- ============================================================================
-- 3. Seed System Template Packs (Government Job & Software Engineer)
-- ============================================================================
INSERT INTO public.prep_templates (
  id,
  user_id,
  slug,
  title,
  description,
  exam_type,
  is_system,
  sort_order
) VALUES
  (
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'government_job',
    'Government Job',
    'Core BCS, bank, and public recruitment syllabus covering Bengali, English, GK, Mathematics, Analytical Reasoning, and Computer.',
    'government',
    true,
    0
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'software_engineer',
    'Software Engineer',
    'Technical interview and CS fundamentals across Data Structures & Algorithms, Database Systems, OOP, Web Development, and SQA.',
    'engineering',
    true,
    1
  )
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.prep_template_items (
  id,
  template_id,
  user_id,
  subject_name,
  subject_color,
  subject_icon,
  exam_type,
  subject_sort_order,
  material_title,
  material_kind,
  unit_label,
  total_units,
  item_sort_order
) VALUES
  -- Government Job -> 1. Bengali (300/300/400 pages)
  (
    '00000000-0000-4000-8101-000000000001',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'Bengali',
    'gold',
    'language',
    'government',
    0,
    'Bengali Literature Guide',
    'book',
    'pages',
    300,
    0
  ),
  (
    '00000000-0000-4000-8101-000000000002',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'Bengali',
    'gold',
    'language',
    'government',
    0,
    'Bengali Grammar Practice',
    'book',
    'pages',
    300,
    1
  ),
  (
    '00000000-0000-4000-8101-000000000003',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'Bengali',
    'gold',
    'language',
    'government',
    0,
    'Bangla Model Digest',
    'book',
    'pages',
    400,
    2
  ),
  -- Government Job -> 2. English
  (
    '00000000-0000-4000-8101-000000000004',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'English',
    'info',
    'menu_book',
    'government',
    1,
    'Competitive English Grammar',
    'book',
    'pages',
    300,
    3
  ),
  (
    '00000000-0000-4000-8101-000000000005',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'English',
    'info',
    'menu_book',
    'government',
    1,
    'Vocabulary & Passage Bank',
    'question_bank',
    'questions',
    400,
    4
  ),
  -- Government Job -> 3. General Knowledge
  (
    '00000000-0000-4000-8101-000000000006',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'General Knowledge',
    'success',
    'public',
    'government',
    2,
    'Bangladesh Affairs Digest',
    'book',
    'pages',
    250,
    5
  ),
  (
    '00000000-0000-4000-8101-000000000007',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'General Knowledge',
    'success',
    'public',
    'government',
    2,
    'International Affairs Notes',
    'notes',
    'pages',
    180,
    6
  ),
  -- Government Job -> 4. Mathematics
  (
    '00000000-0000-4000-8101-000000000008',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'Mathematics',
    'warning',
    'calculate',
    'government',
    3,
    'Arithmetic & Algebra Workbook',
    'book',
    'pages',
    300,
    7
  ),
  (
    '00000000-0000-4000-8101-000000000009',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'Mathematics',
    'warning',
    'calculate',
    'government',
    3,
    'Quantitative Question Bank',
    'question_bank',
    'questions',
    500,
    8
  ),
  -- Government Job -> 5. Analytical Reasoning
  (
    '00000000-0000-4000-8101-000000000010',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'Analytical Reasoning',
    'accent_secondary',
    'psychology',
    'government',
    4,
    'Mental Ability & Puzzles',
    'question_bank',
    'questions',
    300,
    9
  ),
  -- Government Job -> 6. Computer
  (
    '00000000-0000-4000-8101-000000000011',
    '00000000-0000-4000-8000-000000000101',
    NULL,
    'Computer',
    'info',
    'computer',
    'government',
    5,
    'Computer & ICT Fundamentals',
    'book',
    'pages',
    200,
    10
  ),
  -- Software Engineer -> 1. Data Structures and Algorithms
  (
    '00000000-0000-4000-8102-000000000001',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Data Structures and Algorithms',
    'gold',
    'computer',
    'engineering',
    0,
    'Core DSA Problem Set',
    'question_bank',
    'questions',
    150,
    0
  ),
  (
    '00000000-0000-4000-8102-000000000002',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Data Structures and Algorithms',
    'gold',
    'computer',
    'engineering',
    0,
    'Algorithms Reference Notes',
    'notes',
    'chapters',
    16,
    1
  ),
  -- Software Engineer -> 2. Database Systems
  (
    '00000000-0000-4000-8102-000000000003',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Database Systems',
    'info',
    'account_balance',
    'engineering',
    1,
    'SQL & Relational Modeling',
    'book',
    'chapters',
    14,
    2
  ),
  (
    '00000000-0000-4000-8102-000000000004',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Database Systems',
    'info',
    'account_balance',
    'engineering',
    1,
    'Query Tuning & Indexing Bank',
    'question_bank',
    'questions',
    100,
    3
  ),
  -- Software Engineer -> 3. Object-Oriented Programming
  (
    '00000000-0000-4000-8102-000000000005',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Object-Oriented Programming',
    'accent_secondary',
    'menu_book',
    'engineering',
    2,
    'OOP & Design Patterns',
    'book',
    'chapters',
    12,
    4
  ),
  -- Software Engineer -> 4. Web Development
  (
    '00000000-0000-4000-8102-000000000006',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Web Development',
    'success',
    'public',
    'engineering',
    3,
    'HTTP, REST & Security Handbook',
    'notes',
    'chapters',
    15,
    5
  ),
  (
    '00000000-0000-4000-8102-000000000007',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Web Development',
    'success',
    'public',
    'engineering',
    3,
    'Full-Stack Practice Mock Tests',
    'mock_test',
    'tests',
    10,
    6
  ),
  -- Software Engineer -> 5. Software Quality Assurance
  (
    '00000000-0000-4000-8102-000000000008',
    '00000000-0000-4000-8000-000000000102',
    NULL,
    'Software Quality Assurance',
    'warning',
    'quiz',
    'engineering',
    4,
    'Testing & Automation Guide',
    'book',
    'pages',
    180,
    7
  )
ON CONFLICT (id) DO NOTHING;
