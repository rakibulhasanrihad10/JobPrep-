-- Phase 7A: Extend `public.user_settings` with synced user preferences
-- (display name, appearance, language, and study timer defaults) and add a
-- self-service account deletion RPC safe for authenticated clients.

-- ============================================================================
-- public.user_settings preference columns & constraints
-- ============================================================================
ALTER TABLE public.user_settings
  ADD COLUMN display_name text,
  ADD COLUMN theme_mode text NOT NULL DEFAULT 'system',
  ADD COLUMN reduce_effects boolean NOT NULL DEFAULT false,
  ADD COLUMN locale_code text NOT NULL DEFAULT 'en',
  ADD COLUMN bangla_digits boolean NOT NULL DEFAULT false,
  ADD COLUMN focus_minutes integer NOT NULL DEFAULT 25,
  ADD COLUMN short_break_minutes integer NOT NULL DEFAULT 5,
  ADD COLUMN long_break_minutes integer NOT NULL DEFAULT 15;

ALTER TABLE public.user_settings
  ADD CONSTRAINT user_settings_display_name_check CHECK (
    display_name IS NULL OR char_length(trim(display_name)) <= 120
  ),
  ADD CONSTRAINT user_settings_theme_mode_check CHECK (
    theme_mode IN ('system', 'light', 'dark')
  ),
  ADD CONSTRAINT user_settings_locale_code_check CHECK (
    locale_code IN ('en', 'bn')
  ),
  ADD CONSTRAINT user_settings_focus_minutes_check CHECK (
    focus_minutes BETWEEN 5 AND 180
  ),
  ADD CONSTRAINT user_settings_short_break_minutes_check CHECK (
    short_break_minutes BETWEEN 1 AND 60
  ),
  ADD CONSTRAINT user_settings_long_break_minutes_check CHECK (
    long_break_minutes BETWEEN 5 AND 90
  );

-- ============================================================================
-- Self-service account deletion RPC (cascades all user-owned data)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  DELETE FROM auth.users
  WHERE id = v_uid;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;
