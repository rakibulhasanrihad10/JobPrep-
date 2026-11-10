-- Phase 4C: pgTAP tests verifying private 'material-covers' Storage bucket
-- configuration and strict per-user folder isolation in storage.objects.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
SET LOCAL search_path = public, extensions;

SELECT plan(13);

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
    '99999999-9999-4999-8999-999999999991',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'cover-user-a@example.test',
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
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'cover-user-b@example.test',
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
  (SELECT public FROM storage.buckets WHERE id = 'material-covers'),
  false,
  'material-covers Storage bucket exists and is private'
);

-- (2) Bucket configures 5 MiB limit
SELECT is(
  (SELECT file_size_limit FROM storage.buckets WHERE id = 'material-covers'),
  5242880::bigint,
  'material-covers Storage bucket enforces 5 MiB file size limit'
);

-- (3) Bucket allows jpg/png/webp image MIME types only
SELECT is(
  (SELECT allowed_mime_types FROM storage.buckets WHERE id = 'material-covers'),
  ARRAY['image/jpeg', 'image/png', 'image/webp']::text[],
  'material-covers bucket restricts allowed MIME types to jpeg, png, and webp'
);

-- Switch to authenticated User A
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '99999999-9999-4999-8999-999999999991';
SET LOCAL request.jwt.claims = '{"sub":"99999999-9999-4999-8999-999999999991","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (4) User A can insert an object inside their own user_id folder
SELECT lives_ok(
  $sql$
    INSERT INTO storage.objects (bucket_id, name, owner, owner_id)
    VALUES (
      'material-covers',
      '99999999-9999-4999-8999-999999999991/mat-1/cover.png',
      '99999999-9999-4999-8999-999999999991',
      '99999999-9999-4999-8999-999999999991'
    )
  $sql$,
  'User A can upload material cover into own user_id folder'
);

-- (5) User A can read own uploaded cover
SELECT is(
  (
    SELECT count(*)::integer
    FROM storage.objects
    WHERE bucket_id = 'material-covers'
      AND name = '99999999-9999-4999-8999-999999999991/mat-1/cover.png'
  ),
  1,
  'User A can read own cover in material-covers bucket'
);

-- (6) User A cannot upload outside own folder (into User B folder)
SELECT throws_ok(
  $sql$
    INSERT INTO storage.objects (bucket_id, name, owner, owner_id)
    VALUES (
      'material-covers',
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2/mat-1/spoof.png',
      '99999999-9999-4999-8999-999999999991',
      '99999999-9999-4999-8999-999999999991'
    )
  $sql$,
  '42501',
  NULL,
  'User A cannot upload cover into User B folder'
);

-- (7) User A cannot upload at bucket root without user_id folder prefix
SELECT throws_ok(
  $sql$
    INSERT INTO storage.objects (bucket_id, name, owner, owner_id)
    VALUES (
      'material-covers',
      '99999999-9999-4999-8999-999999999991',
      '99999999-9999-4999-8999-999999999991',
      '99999999-9999-4999-8999-999999999991'
    )
  $sql$,
  '42501',
  NULL,
  'Cover files must live inside user_id/ subfolder rather than bucket root'
);

-- (8) Anonymous role cannot read User A cover
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '';
SET LOCAL request.jwt.claims = '{"role":"anon"}';
SET LOCAL ROLE anon;

SELECT is_empty(
  $sql$
    SELECT id FROM storage.objects
    WHERE bucket_id = 'material-covers'
      AND name = '99999999-9999-4999-8999-999999999991/mat-1/cover.png'
  $sql$,
  'Anonymous role cannot read files in private material-covers bucket'
);

-- Switch to authenticated User B
RESET ROLE;
SET LOCAL request.jwt.claim.sub = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2';
SET LOCAL request.jwt.claims = '{"sub":"aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (9) User B cannot read User A cover
SELECT is_empty(
  $sql$
    SELECT id FROM storage.objects
    WHERE bucket_id = 'material-covers'
      AND name = '99999999-9999-4999-8999-999999999991/mat-1/cover.png'
  $sql$,
  'User B cannot read User A cover in material-covers bucket'
);

-- (10) User B cannot update User A cover
SELECT is_empty(
  $sql$
    UPDATE storage.objects
    SET metadata = '{"tampered":true}'::jsonb
    WHERE bucket_id = 'material-covers'
      AND name = '99999999-9999-4999-8999-999999999991/mat-1/cover.png'
    RETURNING id
  $sql$,
  'User B cannot update User A cover in material-covers bucket'
);

-- (11) User B cannot delete User A cover
SELECT is_empty(
  $sql$
    DELETE FROM storage.objects
    WHERE bucket_id = 'material-covers'
      AND name = '99999999-9999-4999-8999-999999999991/mat-1/cover.png'
    RETURNING id
  $sql$,
  'User B cannot delete User A cover in material-covers bucket'
);

-- Switch back to User A and verify object cannot be moved across user folders
RESET ROLE;
SET LOCAL request.jwt.claim.sub = '99999999-9999-4999-8999-999999999991';
SET LOCAL request.jwt.claims = '{"sub":"99999999-9999-4999-8999-999999999991","role":"authenticated"}';
SET LOCAL ROLE authenticated;

-- (12) User A cannot move cover out of own folder into User B folder
SELECT throws_ok(
  $sql$
    UPDATE storage.objects
    SET name = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2/mat-1/moved.png'
    WHERE bucket_id = 'material-covers'
      AND name = '99999999-9999-4999-8999-999999999991/mat-1/cover.png'
  $sql$,
  '42501',
  NULL,
  'User A cannot move cover object into User B folder'
);

-- (13) User A can delete own cover
SELECT is(
  (
    SELECT count(*)::integer
    FROM (
      DELETE FROM storage.objects
      WHERE bucket_id = 'material-covers'
        AND name = '99999999-9999-4999-8999-999999999991/mat-1/cover.png'
      RETURNING id
    ) deleted
  ),
  1,
  'User A can delete own cover from material-covers bucket'
);

SELECT * FROM finish();

ROLLBACK;
