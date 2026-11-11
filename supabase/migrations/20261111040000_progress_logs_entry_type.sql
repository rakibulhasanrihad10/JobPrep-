-- Phase 6F: Distinguish actual study logs ('study') from manual downward
-- position corrections ('correction') on `public.progress_logs`.

ALTER TABLE public.progress_logs
  ADD COLUMN entry_type text NOT NULL DEFAULT 'study'
    CONSTRAINT progress_logs_entry_type_check
      CHECK (entry_type IN ('study', 'correction'));

CREATE INDEX IF NOT EXISTS progress_logs_user_entry_type_logged_on_idx
  ON public.progress_logs (user_id, entry_type, logged_on DESC);

COMMENT ON COLUMN public.progress_logs.entry_type IS
  'Distinguishes studied progress increments (study) from backward position adjustments (correction).';
