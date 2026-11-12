# Changelog

All notable changes to **JobPrep** are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Release Pipeline (Phase 7C)**:
  - Opt-in Web crash reporting via `sentry_flutter` configured strictly through `--dart-define=SENTRY_DSN` with PII/token scrubbing (`SentrySanitizer`).
  - Automated staging deployment workflow on merges/pushes to `develop` (Cloudflare Pages staging preview + Staging Supabase project).
  - Automated production tag release workflow (`v*.*.*` on `main`) running quality gates, production Supabase migrations, WebAssembly + CanvasKit release build, PWA/Lighthouse check, Cloudflare Pages deploy, and GitHub Release notes generated from `CHANGELOG.md` and Conventional Commits (`scripts/generate_release_notes.dart`).
  - Dependabot weekly automated dependency updates for `pub` and `github-actions` targeting `develop` (`.github/dependabot.yml`).
  - Release and tested rollback playbook (`RELEASING.md`).
- **PWA & Performance (Phase 7B)**:
  - Installable web manifest, branded navy/gold standard + maskable PNG icons, opaque 180x180 `apple-touch-icon.png`, custom service worker (`web/sw.js`), lightweight branded startup overlay, and `--wasm` + JS fallback build script (`scripts/build_web.dart`).
  - Performance pass restricting `BackdropFilter` strictly to cards, navigation chrome/sidebar, and dialogs; sliver list virtualization on circulars & inbox; bounded lazy image decoding (`MaterialCoverThumbnail`); and CI Lighthouse + mobile-throttled runtime audit (`scripts/pwa_lighthouse_check.mjs`).
- **Settings, Onboarding & Daily Prep Features (Phases 0–7A)**:
  - Foundation architecture, deep navy/gold glassmorphism tokens (`reduceEffects`), English/Bangla localization with Noto Sans Bengali, Supabase schema with strict RLS, encrypted Portal Credential Vault (client-side AES-GCM + PBKDF2), Job Circulars & Inbox triage, Dashboard, Prep Workspace (Subjects, Materials, Covers, 3D Book Progress View, Study Plans, Mock Tests, Revision Marks & Spaced Repetition Queue, Timestamp Study Timer, Study Analytics), Today Priority Screen, In-App Notifications & Weekly Review, 6-Step Onboarding Wizard, and full Settings with `user_settings` sync, CSV/JSON backup export, and self-service account deletion.
