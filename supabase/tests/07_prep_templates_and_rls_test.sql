-- Phase 4E: pgTAP tests verifying `prep_templates` and `prep_template_items`
-- schema, seeded Government Job (6 subjects) and Software Engineer (5 subjects)
-- packs, read-only enforcement on system packs for signed-in users, personal
-- template ownership, cross-user RLS isolation, and cascade deletion.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(31);

INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES
  (
    'aaaa1111-1111-4111-8111-111111111111',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'tpl-user-a@example.test',
    '$2a$10$mockhashforpgtaptestingonly',
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    '',
    ''
  ),
  (
    'bbbb2222-2222-4222-8222-222222222222',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'tpl-user-b@example.test',
    '$2a$10$mockhashforpgtaptestingonly',
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

-- ============================================================================
-- 1. Table Existence & RLS Metadata (Tests 1-4)
-- ============================================================================
-- (1-2) Tables exist
SELECT has_table('public'::name, 'prep_templates'::name, 'prep_templates table exists');
SELECT has_table('public'::name, 'prep_template_items'::name, 'prep_template_items table exists');

-- (3-4) RLS enabled on both tables
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'prep_templates'),
  'RLS is enabled on public.prep_templates'
);
SELECT ok(
  (SELECT c.relrowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relname = 'prep_template_items'),
  'RLS is enabled on public.prep_template_items'
);

-- ============================================================================
-- 2. Anonymous Role Isolation (Tests 5-7)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{"role":"anon"}';
SET LOCAL ROLE anon;

-- (5-6) Anon cannot read any templates or items
SELECT is_empty(
  $$SELECT id FROM public.prep_templates$$,
  'Anonymous role cannot read prep_templates'
);
SELECT is_empty(
  $$SELECT id FROM public.prep_template_items$$,
  'Anonymous role cannot read prep_template_items'
);

-- (7) Anon cannot insert a template
SELECT throws_ok(
  $sql$
    INSERT INTO public.prep_templates (title, is_system, user_id)
    VALUES ('Anon Attempt', false, NULL)
  $sql$,
  '42501',
  NULL,
  'Anonymous role cannot insert into prep_templates'
);

-- ============================================================================
-- 3. Signed-In User A: Seeded Packs & Read-Only Enforcement (Tests 8-16)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'aaaa1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"aaaa1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (8) User A sees both seeded system packs
SELECT is(
  (SELECT count(*)::integer FROM public.prep_templates WHERE is_system = true),
  2,
  'Signed-in User A can read the two seeded system packs'
);

-- (9) Government Job pack has exact 6 expected subjects
SELECT is(
  (
    SELECT string_agg(DISTINCT subject_name, '|' ORDER BY subject_name)
    FROM public.prep_template_items
    WHERE template_id = '00000000-0000-4000-8000-000000000101'
      AND total_units > 0
  ),
  'Analytical Reasoning|Bengali|Computer|English|General Knowledge|Mathematics',
  'Government Job pack seeds all 6 required subjects with positive unit counts'
);

-- (10) Software Engineer pack has exact 5 expected subjects
SELECT is(
  (
    SELECT string_agg(DISTINCT subject_name, '|' ORDER BY subject_name)
    FROM public.prep_template_items
    WHERE template_id = '00000000-0000-4000-8000-000000000102'
      AND total_units > 0
  ),
  'Data Structures and Algorithms|Database Systems|Object-Oriented Programming|Software Quality Assurance|Web Development',
  'Software Engineer pack seeds all 5 required subjects with positive unit counts'
);

-- (11) User A cannot insert a system template
SELECT throws_ok(
  $sql$
    INSERT INTO public.prep_templates (title, is_system, user_id)
    VALUES ('Rogue System Pack', true, NULL)
  $sql$,
  '42501',
  NULL,
  'Signed-in users cannot insert system templates'
);

-- (12) User A cannot update seeded system templates
SELECT is_empty(
  $sql$
    UPDATE public.prep_templates
       SET title = 'Tampered Government Job'
     WHERE id = '00000000-0000-4000-8000-000000000101'
    RETURNING id
  $sql$,
  'Signed-in users cannot update seeded system templates'
);

-- (13) User A cannot delete seeded system templates
SELECT is_empty(
  $sql$
    DELETE FROM public.prep_templates
     WHERE id = '00000000-0000-4000-8000-000000000101'
    RETURNING id
  $sql$,
  'Signed-in users cannot delete seeded system templates'
);

-- (14) User A cannot insert items into seeded system templates
SELECT throws_ok(
  $sql$
    INSERT INTO public.prep_template_items (
      template_id,
      user_id,
      subject_name,
      material_title,
      total_units
    ) VALUES (
      '00000000-0000-4000-8000-000000000101',
      'aaaa1111-1111-4111-8111-111111111111',
      'Injected Subject',
      'Injected Book',
      100
    )
  $sql$,
  '42501',
  NULL,
  'Signed-in users cannot insert items into system templates'
);

-- (15) User A cannot update seeded system template items
SELECT is_empty(
  $sql$
    UPDATE public.prep_template_items
       SET total_units = 9999
     WHERE id = '00000000-0000-4000-8101-000000000001'
    RETURNING id
  $sql$,
  'Signed-in users cannot update seeded system template items'
);

-- (16) User A cannot delete seeded system template items
SELECT is_empty(
  $sql$
    DELETE FROM public.prep_template_items
     WHERE id = '00000000-0000-4000-8101-000000000001'
    RETURNING id
  $sql$,
  'Signed-in users cannot delete seeded system template items'
);

-- ============================================================================
-- 4. User A Personal Template Creation & Self-Management (Tests 17-20)
-- ============================================================================
-- (17) User A creates personal template with material row and empty-subject row
SELECT lives_ok(
  $sql$
    INSERT INTO public.prep_templates (
      id,
      user_id,
      title,
      description,
      exam_type,
      is_system
    ) VALUES (
      'aaaa9999-0000-4000-8000-000000000001',
      'aaaa1111-1111-4111-8111-111111111111',
      'My Custom BCS Plan',
      'Personal reusable pack',
      'bcs',
      false
    );
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
      (
        'aaaa8888-0000-4000-8000-000000000001',
        'aaaa9999-0000-4000-8000-000000000001',
        'aaaa1111-1111-4111-8111-111111111111',
        'International Affairs',
        'info',
        'public',
        'bcs',
        0,
        'Global Affairs Notes',
        'notes',
        'pages',
        180,
        0
      ),
      (
        'aaaa8888-0000-4000-8000-000000000002',
        'aaaa9999-0000-4000-8000-000000000001',
        'aaaa1111-1111-4111-8111-111111111111',
        'Ethics & Governance',
        'gold',
        'gavel',
        'bcs',
        1,
        NULL,
        'book',
        'pages',
        0,
        1
      );
  $sql$,
  'User A can create a personal template and its items'
);

-- (18) User A sees 2 system packs + 1 own personal template = 3
SELECT is(
  (SELECT count(*)::integer FROM public.prep_templates),
  3,
  'User A reads both system packs and own personal template'
);

-- (19) User A can update own personal template and items
SELECT lives_ok(
  $sql$
    UPDATE public.prep_templates
       SET title = 'Updated Custom BCS Plan'
     WHERE id = 'aaaa9999-0000-4000-8000-000000000001';
    UPDATE public.prep_template_items
       SET total_units = 220
     WHERE id = 'aaaa8888-0000-4000-8000-000000000001';
  $sql$,
  'User A can update own personal template and items'
);

-- (20) User A cannot escalate own personal template into a system template
SELECT throws_ok(
  $sql$
    UPDATE public.prep_templates
       SET is_system = true, user_id = NULL
     WHERE id = 'aaaa9999-0000-4000-8000-000000000001'
  $sql$,
  '42501',
  NULL,
  'Users cannot escalate a personal template into a system template'
);

-- ============================================================================
-- 5. User B Cross-User Isolation (Tests 21-29)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'bbbb2222-2222-4222-8222-222222222222';
SET LOCAL request.jwt.claims = '{"sub":"bbbb2222-2222-4222-8222-222222222222","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (21) User B sees only the 2 seeded system packs (not User A personal pack)
SELECT is(
  (SELECT count(*)::integer FROM public.prep_templates),
  2,
  'User B reads system packs but not User A personal templates'
);

-- (22) User B cannot read User A personal template by id
SELECT is_empty(
  $$SELECT id FROM public.prep_templates WHERE id = 'aaaa9999-0000-4000-8000-000000000001'$$,
  'User B cannot read User A personal template'
);

-- (23) User B cannot read User A personal template items
SELECT is_empty(
  $$SELECT id FROM public.prep_template_items WHERE template_id = 'aaaa9999-0000-4000-8000-000000000001'$$,
  'User B cannot read User A personal template items'
);

-- (24) User B cannot forge user_id = User A on insert
SELECT throws_ok(
  $sql$
    INSERT INTO public.prep_templates (user_id, title, is_system)
    VALUES ('aaaa1111-1111-4111-8111-111111111111', 'Spoofed Template', false)
  $sql$,
  '42501',
  NULL,
  'User B cannot insert a personal template under User A user_id'
);

-- (25) User B cannot insert items into User A personal template
SELECT throws_ok(
  $sql$
    INSERT INTO public.prep_template_items (
      template_id,
      user_id,
      subject_name,
      material_title,
      total_units
    ) VALUES (
      'aaaa9999-0000-4000-8000-000000000001',
      'bbbb2222-2222-4222-8222-222222222222',
      'Cross-User Injection',
      'Sneaky Book',
      100
    )
  $sql$,
  '42501',
  NULL,
  'User B cannot attach items to User A personal template'
);

-- (26-27) User B cannot update User A personal template or items
SELECT is_empty(
  $sql$
    UPDATE public.prep_templates
       SET title = 'Tampered Personal Plan'
     WHERE id = 'aaaa9999-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot update User A personal template'
);
SELECT is_empty(
  $sql$
    UPDATE public.prep_template_items
       SET total_units = 1
     WHERE id = 'aaaa8888-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot update User A personal template items'
);

-- (28-29) User B cannot delete User A personal template or items
SELECT is_empty(
  $sql$
    DELETE FROM public.prep_templates
     WHERE id = 'aaaa9999-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot delete User A personal template'
);
SELECT is_empty(
  $sql$
    DELETE FROM public.prep_template_items
     WHERE id = 'aaaa8888-0000-4000-8000-000000000001'
    RETURNING id
  $sql$,
  'User B cannot delete User A personal template items'
);

-- ============================================================================
-- 6. User A Cascade Delete Verification (Tests 30-31)
-- ============================================================================
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'aaaa1111-1111-4111-8111-111111111111';
SET LOCAL request.jwt.claims = '{"sub":"aaaa1111-1111-4111-8111-111111111111","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (30) User A can delete own personal template
SELECT lives_ok(
  $sql$
    DELETE FROM public.prep_templates
     WHERE id = 'aaaa9999-0000-4000-8000-000000000001';
  $sql$,
  'User A can delete own personal template'
);

-- (31) Deleting personal template cascades to prep_template_items
SELECT is_empty(
  $$SELECT id FROM public.prep_template_items WHERE template_id = 'aaaa9999-0000-4000-8000-000000000001'$$,
  'Deleting a personal template cascades to prep_template_items'
);

SELECT * FROM finish();

ROLLBACK;
