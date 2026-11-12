-- Phase 6B: Portal account password storage (`portal_accounts`) and
-- zero-knowledge passphrase check verifier (`vault_verifiers`) with RLS.

-- ============================================================================
-- 1. public.vault_verifiers
-- ============================================================================
CREATE TABLE public.vault_verifiers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  check_ciphertext text NOT NULL,
  check_salt text NOT NULL,
  check_nonce text NOT NULL,
  check_iterations integer NOT NULL DEFAULT 210000,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT vault_verifiers_ciphertext_not_empty CHECK (
    char_length(btrim(check_ciphertext)) > 0
  ),
  CONSTRAINT vault_verifiers_salt_not_empty CHECK (
    char_length(btrim(check_salt)) > 0
  ),
  CONSTRAINT vault_verifiers_nonce_not_empty CHECK (
    char_length(btrim(check_nonce)) > 0
  ),
  CONSTRAINT vault_verifiers_iterations_min CHECK (check_iterations >= 100000)
);

CREATE INDEX idx_vault_verifiers_user_id
  ON public.vault_verifiers (user_id);

CREATE TRIGGER set_vault_verifiers_updated_at
  BEFORE UPDATE ON public.vault_verifiers
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.vault_verifiers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own vault verifier"
  ON public.vault_verifiers
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own vault verifier"
  ON public.vault_verifiers
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own vault verifier"
  ON public.vault_verifiers
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own vault verifier"
  ON public.vault_verifiers
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- 2. public.portal_accounts
-- ============================================================================
CREATE TABLE public.portal_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users (id) ON DELETE CASCADE,
  circular_id uuid NOT NULL,
  portal_url text,
  username text NOT NULL,
  encrypted_password text NOT NULL,
  salt text NOT NULL,
  nonce text NOT NULL,
  iterations integer NOT NULL DEFAULT 210000,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT portal_accounts_circular_owner_fkey
    FOREIGN KEY (circular_id, user_id)
    REFERENCES public.circulars (id, user_id)
    ON DELETE CASCADE,
  CONSTRAINT portal_accounts_username_not_empty CHECK (
    char_length(btrim(username)) > 0
  ),
  CONSTRAINT portal_accounts_ciphertext_not_empty CHECK (
    char_length(btrim(encrypted_password)) > 0
  ),
  CONSTRAINT portal_accounts_salt_not_empty CHECK (
    char_length(btrim(salt)) > 0
  ),
  CONSTRAINT portal_accounts_nonce_not_empty CHECK (
    char_length(btrim(nonce)) > 0
  ),
  CONSTRAINT portal_accounts_iterations_min CHECK (iterations >= 100000),
  CONSTRAINT portal_accounts_portal_url_scheme CHECK (
    portal_url IS NULL OR portal_url ~* '^https?://'
  )
);

CREATE INDEX idx_portal_accounts_user_id
  ON public.portal_accounts (user_id);

CREATE INDEX idx_portal_accounts_circular_id
  ON public.portal_accounts (circular_id);

CREATE INDEX idx_portal_accounts_user_circular
  ON public.portal_accounts (user_id, circular_id, created_at ASC);

CREATE TRIGGER set_portal_accounts_updated_at
  BEFORE UPDATE ON public.portal_accounts
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.portal_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own portal accounts"
  ON public.portal_accounts
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own portal accounts"
  ON public.portal_accounts
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own portal accounts"
  ON public.portal_accounts
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own portal accounts"
  ON public.portal_accounts
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
