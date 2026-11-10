-- Phase 4C: Create private Supabase Storage bucket 'material-covers' with
-- strict per-user folder isolation policies (<user_id>/<material_key>/<file>).

INSERT INTO storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
) VALUES (
  'material-covers',
  'material-covers',
  false,
  5242880,
  ARRAY[
    'image/jpeg',
    'image/png',
    'image/webp'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

CREATE POLICY "Users can view own material cover images"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'material-covers'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );

CREATE POLICY "Users can upload own material cover images"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'material-covers'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );

CREATE POLICY "Users can update own material cover images"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'material-covers'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  )
  WITH CHECK (
    bucket_id = 'material-covers'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );

CREATE POLICY "Users can delete own material cover images"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'material-covers'
    AND auth.uid() IS NOT NULL
    AND split_part(name, '/', 1) = auth.uid()::text
    AND strpos(name, '/') > 0
  );
