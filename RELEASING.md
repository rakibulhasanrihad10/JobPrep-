# Releasing JobPrep

This document describes the CI/CD release pipeline, required GitHub Actions secrets, staging deployments, production releases, and tested rollback procedures.

---

## Architecture Overview

1. **Pull Requests (`develop`, `main`) — `.github/workflows/ci.yml`**
   - Runs Gitleaks secrets scan, `dart format --output=none --set-exit-if-changed .`, `flutter analyze --fatal-infos --fatal-warnings`, `scripts/check_hardcoded_strings.dart`, `flutter test`, `scripts/build_web.dart` (`--wasm` with JS/CanvasKit fallback), `scripts/pwa_lighthouse_check.mjs` (installability + Lighthouse), `supabase db reset` + `supabase test db` (pgTAP RLS verification), and Deno Edge Function checks.
   - Weekly Dependabot PRs (`.github/dependabot.yml`, targeting `develop`) automatically execute these same gates.

2. **Staging Deployments (`develop`) — `.github/workflows/deploy-staging.yml`**
   - Every push/merge to `develop` builds the Flutter Web bundle using the **staging Supabase project** (`ENVIRONMENT=staging`) and deploys to the Cloudflare Pages `staging` branch preview.
   - If staging hosting/Supabase secrets are not configured yet, the deploy steps skip safely with a setup notice so feature CI stays green.

3. **Production Releases (`v*.*.*` tag on `main`) — `.github/workflows/release.yml`**
   - Verifies the tagged commit is reachable from `origin/main` (tags on non-`main` branches are rejected).
   - Runs full quality gates (Gitleaks, format, analyzer, tests, Edge Function tests).
   - Applies pending SQL migrations in `supabase/migrations/` to the **production Supabase project** (`supabase db push`).
   - Builds the production WebAssembly + CanvasKit bundle (`ENVIRONMENT=prod`, `SENTRY_ENVIRONMENT=production`, `APP_VERSION=<tag>`, plus `--dart-define` Supabase/Sentry values).
   - Runs `scripts/pwa_lighthouse_check.mjs`, deploys `build/web` to Cloudflare Pages production (`--branch=main`), generates release notes from `CHANGELOG.md` + Conventional Commits (`scripts/generate_release_notes.dart`), and publishes a GitHub Release.

---

## Required GitHub Actions Secrets

Never commit secrets or DSNs to git. Configure them in **GitHub Repository Settings > Secrets and variables > Actions**:

| Secret Name | Scope | Purpose |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | Staging & Prod | Cloudflare API token with `Cloudflare Pages: Edit` |
| `CLOUDFLARE_ACCOUNT_ID` | Staging & Prod | Cloudflare account identifier |
| `CLOUDFLARE_PAGES_PROJECT` | Staging & Prod | Cloudflare Pages project name (e.g. `jobprep-web`) |
| `SUPABASE_ACCESS_TOKEN` | Staging & Prod | Supabase CLI personal/org access token for `supabase link` & `db push` |
| `STAGING_SUPABASE_PROJECT_REF` | Staging | Staging Supabase project reference ID |
| `STAGING_SUPABASE_DB_PASSWORD` | Staging | Staging Postgres password for `supabase db push` |
| `STAGING_SUPABASE_URL` | Staging | Staging project URL passed via `--dart-define=SUPABASE_URL` |
| `STAGING_SUPABASE_ANON_KEY` | Staging | Staging public anon key passed via `--dart-define=SUPABASE_ANON_KEY` |
| `PROD_SUPABASE_PROJECT_REF` | Production | Production Supabase project reference ID |
| `PROD_SUPABASE_DB_PASSWORD` | Production | Production Postgres password for `supabase db push` |
| `PROD_SUPABASE_URL` | Production | Production project URL passed via `--dart-define=SUPABASE_URL` |
| `PROD_SUPABASE_ANON_KEY` | Production | Production public anon key passed via `--dart-define=SUPABASE_ANON_KEY` |
| `SENTRY_DSN` | Staging & Prod | Optional Sentry Web DSN passed via `--dart-define=SENTRY_DSN` |

> Never put `SUPABASE_SERVICE_ROLE_KEY` into client build secrets. Only the public `anon` key is compiled into the Flutter Web bundle.

---

## Cutting a Production Release

1. Ensure `develop` is clean and all CI checks pass, including database pgTAP tests and Lighthouse audit.
2. Update `CHANGELOG.md`:
   - Move tested items from `## [Unreleased]` under a new `## [X.Y.Z] - YYYY-MM-DD` heading.
   - Bump `version:` in `pubspec.yaml` if needed (`X.Y.Z+N`) and open a PR `develop -> main`.
3. Preview generated release notes locally before tagging:
   ```bash
   dart run scripts/generate_release_notes.dart --tag=vX.Y.Z --changelog=CHANGELOG.md
   ```
4. Merge the PR into `main` via GitHub (never force-push `main`).
5. Pull `main` locally, create a signed/annotated tag, and push the tag:
   ```bash
   git checkout main
   git pull origin main
   git tag -a vX.Y.Z -m "release: vX.Y.Z"
   git push origin vX.Y.Z
   ```
6. Monitor `.github/workflows/release.yml` in **Actions**:
   - Confirm migrations apply cleanly, production Lighthouse check passes, Cloudflare Pages deploy finishes, and GitHub Release `vX.Y.Z` is published.
7. Smoke-test the production URL (sign in, inspect Sentry for zero unhandled boot errors, check active service worker).

---

## Tested Rollback Procedures

Follow these verified procedures when a production release introduces a regression. Always check whether a database migration was included before rolling back frontend code.

### 1. Roll Back the Web App (Redeploy Previous Tag)

Option A — **GitHub Actions Tag Replay (Recommended, reproducible)**:
1. Open **Actions > Release Production > Run workflow**.
2. Enter the last known-good version tag in the **`tag`** input (for example `v1.2.0`), leave `skip_migrations` as `true` (so newer backward-compatible DB schemas are preserved without re-running migrations), and start the workflow.
3. The workflow checks out `v1.2.0`, runs `scripts/build_web.dart` with production `--dart-define`s, verifies Lighthouse, and redeploys `build/web` to Cloudflare Pages production (`--branch=main`).
4. Verify the live site version and check Sentry (`release: jobprep@v1.2.0`). Users receive the previous service worker shell automatically on navigation (`sw.js` uses network-first for `index.html` and `flutter_bootstrap.js`).

Option B — **Instant Cloudflare Pages Rollback**:
1. Open **Cloudflare Dashboard > Workers & Pages > `jobprep-web` > Deployments**.
2. Locate the previous production deployment, click **… > Rollback to this deployment**.
3. Follow up with a `fix(...)` PR on `develop` -> `main` and a new patch tag (`v1.2.2`) so git history matches production.

### 2. Revert a Bad Database Migration Safely

> [!CAUTION]
> **Never delete or edit an already-applied migration file in `supabase/migrations/` and never run blind `DROP TABLE` / `TRUNCATE` in production.** Supabase tracks applied timestamps in `supabase_migrations.schema_migrations`; editing old SQL causes checksum drift and fails future deployments.

Use the **forward compensating migration** pattern:

1. **Assess blast radius first**:
   - **Additive column / index / policy change**: Safe to revert cleanly with a new compensating migration without losing user data.
   - **Destructive corruption or accidental data overwrite**: Trigger Supabase **Point-in-Time Recovery (PITR)** / daily backup restore in **Supabase Dashboard > Database > Backups** BEFORE deploying schema fixes.

2. **Create a forward compensating migration locally**:
   ```bash
   npx supabase migration new revert_<bad_migration_short_name>
   ```
   Write idempotent SQL inside the new timestamped file under `supabase/migrations/`:
   ```sql
   -- Example: safely revert an unintended trigger, view, index, or policy
   -- without destroying existing user rows.
   DROP INDEX IF EXISTS public.idx_unwanted_index;

   -- Restore previous RLS policy cleanly:
   DROP POLICY IF EXISTS "bad_policy_name" ON public.target_table;
   CREATE POLICY "previous_policy_name"
     ON public.target_table
     FOR ALL
     TO authenticated
     USING (user_id = auth.uid())
     WITH CHECK (user_id = auth.uid());
   ```
   *(If a new non-empty column must be retired, drop its `NOT NULL` constraint or mark it nullable first rather than dropping user-populated columns immediately—keeping expand/contract compatibility so the rolled-back web app continues working.)*

3. **Test the revert migration locally before touching production**:
   ```bash
   npx supabase db reset
   npx supabase test db
   ```
   Confirm every existing migration + the new revert migration + all pgTAP RLS tests pass from scratch.

4. **Ship through CI cleanly**:
   - Commit with `fix(db): revert <change> cleanly`, open a PR to `develop` -> `main`, verify CI's `Supabase Migrations & Database Verification` job passes, and push the next patch tag (`vX.Y.(Z+1)`).
   - `release.yml` applies the compensating migration via `supabase db push` and publishes the fixed production build.

### Rollback Verification Checklist (Locally Tested)
- [x] Verified `scripts/generate_release_notes.dart` parses `CHANGELOG.md` + `git log` conventional commits cleanly across tag ranges.
- [x] Verified `workflow_dispatch` tag-replay path in `.github/workflows/release.yml` skips re-running DB migrations cleanly while validating `origin/main` ancestry.
- [x] Verified compensating migration workflow (`supabase db reset` + `supabase test db`) enforces all RLS and schema invariants forward-only in CI.
