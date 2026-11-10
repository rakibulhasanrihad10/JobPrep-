-- Phase 3G: Create private Supabase Storage bucket 'circular-files' with
-- strict per-user folder isolation policies (<user_id>/<circular_id>/<file>).

INSERT INTO storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
) VALUES (
  'circular-files',
  'circular-files',
  false,
  5242880,
  ARRAY[
    'application/pdf',
    'image/png',
    'image/jpeg',
    'image/webp'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

CREATE POLICY "Users can view own circular storage files"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'circular-files'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );

CREATE POLICY "Users can upload own circular storage files"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'circular-files'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );

CREATE POLICY "Users can update own circular storage files"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'circular-files'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  )
  WITH CHECK (
    bucket_id = 'circular-files'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );

CREATE POLICY "Users can delete own circular storage files"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'circular-files'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );
