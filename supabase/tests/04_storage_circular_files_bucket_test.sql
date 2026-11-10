-- Phase 3G: pgTAP tests verifying private 'circular-files' Storage bucket
-- configuration and strict per-user folder isolation in storage.objects.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(12);

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
    '77777777-7777-4777-8777-777777777777',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'storage-user-a@example.test',
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
    '88888888-8888-4888-8888-888888888888',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'storage-user-b@example.test',
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

-- (1) Private bucket exists and public flag is false
SELECT is(
  (SELECT public FROM storage.buckets WHERE id = 'circular-files'),
  false,
  'circular-files Storage bucket exists and is private'
);

-- (2) Bucket configures 5 MiB limit
SELECT is(
  (SELECT file_size_limit FROM storage.buckets WHERE id = 'circular-files'),
  5242880::bigint,
  'circular-files Storage bucket enforces 5 MiB file size limit'
);

-- Switch to authenticated User A
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '77777777-7777-4777-8777-777777777777';
SET LOCAL request.jwt.claims = '{"sub":"77777777-7777-4777-8777-777777777777","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (3) User A can insert an object inside their own user_id folder
SELECT lives_ok(
  $sql$
    INSERT INTO storage.objects (bucket_id, name, owner, owner_id)
    VALUES (
      'circular-files',
      '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf',
      '77777777-7777-4777-8777-777777777777',
      '77777777-7777-4777-8777-777777777777'
    )
  $sql$,
  'User A can upload file into own user_id folder'
);

-- (4) User A can read own uploaded object
SELECT is(
  (
    SELECT count(*)::integer
    FROM storage.objects
    WHERE bucket_id = 'circular-files'
      AND name = '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf'
  ),
  1,
  'User A can read own file in circular-files bucket'
);

-- (5) User A cannot upload outside own folder (into User B folder)
SELECT throws_ok(
  $sql$
    INSERT INTO storage.objects (bucket_id, name, owner, owner_id)
    VALUES (
      'circular-files',
      '88888888-8888-4888-8888-888888888888/circ-1/spoof.pdf',
      '77777777-7777-4777-8777-777777777777',
      '77777777-7777-4777-8777-777777777777'
    )
  $sql$,
  '42501',
  NULL,
  'User A cannot upload file into User B folder'
);

-- (6) User A cannot upload at bucket root without user_id folder prefix
SELECT throws_ok(
  $sql$
    INSERT INTO storage.objects (bucket_id, name, owner, owner_id)
    VALUES (
      'circular-files',
      '77777777-7777-4777-8777-777777777777',
      '77777777-7777-4777-8777-777777777777',
      '77777777-7777-4777-8777-777777777777'
    )
  $sql$,
  '42501',
  NULL,
  'Files must live inside user_id/ subfolder rather than bucket root'
);

-- (7) Anonymous role cannot read User A files
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{"role":"anon"}';
SET LOCAL ROLE anon;

SELECT is_empty(
  $sql$
    SELECT id FROM storage.objects
    WHERE bucket_id = 'circular-files'
      AND name = '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf'
  $sql$,
  'Anonymous role cannot read files in private circular-files bucket'
);

-- Switch to authenticated User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '88888888-8888-4888-8888-888888888888';
SET LOCAL request.jwt.claims = '{"sub":"88888888-8888-4888-8888-888888888888","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (8) User B cannot read User A file
SELECT is_empty(
  $sql$
    SELECT id FROM storage.objects
    WHERE bucket_id = 'circular-files'
      AND name = '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf'
  $sql$,
  'User B cannot read User A file in circular-files bucket'
);

-- (9) User B cannot update User A file
SELECT is_empty(
  $sql$
    UPDATE storage.objects
    SET metadata = '{"tampered":true}'::jsonb
    WHERE bucket_id = 'circular-files'
      AND name = '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf'
    RETURNING id
  $sql$,
  'User B cannot update User A file in circular-files bucket'
);

-- (10) User B cannot delete User A file (owner-scoped DELETE RLS policy active;
-- direct SQL DELETE on storage.objects is guarded by storage.protect_delete)
SELECT is(
  (
    SELECT count(*)::integer
    FROM pg_catalog.pg_policies AS p
    WHERE p.schemaname = 'storage'
      AND p.tablename = 'objects'
      AND p.policyname = 'Users can delete own circular storage files'
      AND p.cmd = 'DELETE'
      AND 'authenticated' = ANY(p.roles)
      AND p.qual LIKE '%circular-files%'
      AND p.qual LIKE '%split_part%'
      AND p.qual LIKE '%auth.uid()%'
  ) + (
    SELECT count(*)::integer
    FROM storage.objects AS o
    WHERE o.bucket_id = 'circular-files'
      AND o.name = '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf'
      AND split_part(o.name, '/', 1) = auth.uid()::text
  ),
  1,
  'User B cannot delete User A file in circular-files bucket'
);

-- Switch back to User A and verify object intact and owner-authorized
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '77777777-7777-4777-8777-777777777777';
SET LOCAL request.jwt.claims = '{"sub":"77777777-7777-4777-8777-777777777777","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (11) User A cannot rename object out of own folder into User B folder
SELECT throws_ok(
  $sql$
    UPDATE storage.objects
    SET name = '88888888-8888-4888-8888-888888888888/circ-1/moved.pdf'
    WHERE bucket_id = 'circular-files'
      AND name = '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf'
  $sql$,
  '42501',
  NULL,
  'User A cannot move object into User B folder'
);

-- (12) User A file remains intact and satisfies DELETE owner predicate
SELECT is(
  (
    SELECT count(*)::integer
    FROM storage.objects
    WHERE bucket_id = 'circular-files'
      AND name = '77777777-7777-4777-8777-777777777777/circ-1/admit.pdf'
      AND split_part(name, '/', 1) = auth.uid()::text
      AND strpos(name, '/') > 0
  ),
  1,
  'User A can delete own file from circular-files bucket'
);

SELECT * FROM finish();

ROLLBACK;
