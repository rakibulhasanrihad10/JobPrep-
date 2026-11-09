# AGENTS.md

Project: Job Circular Tracker and Exam Prep Dashboard.
Stack: Flutter (web first, Android later), Supabase (PostgreSQL, Auth, Storage), Riverpod, go_router, flutter_animate.

## How to work

- Work on ONE phase at a time. Finish it, make CI green, commit, summarize what you did and what you assumed, then STOP and wait for my confirmation.
- Never start a feature before the foundation phases (0A to 0G) are done and merged.
- Never skip tests, never disable a failing check to make CI pass, and never leave a phase half finished.
- If a request conflicts with these rules, say so and ask before proceeding.

## Architecture

- Separation of concerns, single responsibility, modularity.
- Feature-first folders: lib/core, lib/features/<feature>/{data,domain,presentation}, lib/shared.
- Layers: presentation depends on domain; domain depends on nothing; data implements domain interfaces.
- Widgets NEVER call Supabase and NEVER contain business logic. Data access goes through repositories only.
- Inject dependencies with Riverpod so tests can replace them with fakes.
- Keep files small and focused. Split any file over about 300 lines.
- If you see duplicated or mixed-responsibility code, refactor it into the modular structure before adding more features.

## Design system

- Subtle, minimalist glassmorphism: deep navy and gold, 12 px card radius, 8 px button radius, no pill buttons, no loud gradients, quiet animations.
- Glass (BackdropFilter) only on cards, sidebar and dialogs, never on every list row. Animate the content inside glass, never the blur itself.
- Support a reduce effects setting that replaces blur with a solid translucent fill and skips animations.
- Progress bars and rings animate from zero and replay each time their tab is opened.

## Theming

- Dark and light mode from day one, plus a system option, persisted.
- All colors, spacing, radii, durations and text styles come from the ThemeExtension design tokens.
- NEVER hardcode a color, size or text style in a widget.

## Localization

- English and Bangla from day one using flutter_localizations, intl and ARB files (lib/l10n/app_en.arb and app_bn.arb).
- NEVER hardcode a user-facing string. Use ARB messages with placeholders and plurals, not string concatenation.
- Use Noto Sans Bengali for Bangla. Layouts must tolerate longer Bangla text.
- Format dates, numbers and currency with intl per locale.

## Security

- Never commit secrets, API keys, .env files or the Supabase service role key. Only the anon key is allowed in the app, passed with --dart-define.
- Every table has user_id and Row Level Security with policies using (user_id = auth.uid()). Every new table needs RLS tests.
- Portal passwords are encrypted on the client with AES-GCM and a PBKDF2-derived key from the user's vault passphrase. Never store, log or send the passphrase or a plain-text password.
- Never log secrets or personal data.

## Git and commits

- Branches: main, develop, and short-lived feature branches. Changes reach main only through pull requests that pass CI.
- Conventional Commits: feat, fix, docs, refactor, test, chore, ci.
- Never commit garbage: build output, generated junk, IDE files, .env files, large binaries.
- Keep line endings as LF (.gitattributes and .editorconfig).
- Pre-commit hooks run format check, analyze, fast tests, the secrets scan and the commit message check. Never bypass them.

## Testing and CI

- Every feature ships with tests: unit, widget, golden (light and dark), integration, plus database and RLS tests.
- Every bug fix starts with a failing test.
- Progress math must keep passing this example: books of 300, 300 and 400 pages; finishing book one is 100 percent for that book and 30 percent for the subject.
- flutter analyze must have zero warnings. Code must be formatted.
- CI (GitHub Actions) must pass before a phase counts as done: format, analyze, tests with coverage, goldens, secrets scan, web build, database migrations and RLS tests.

## Definition of done for every phase

1. Code follows the architecture rules above.
2. Tests written and passing, CI green.
3. No hardcoded colors or strings, works in light and dark and in English and Bangla.
4. Conventional commit made.
5. Short summary written: what changed, what was assumed, what comes next.
6. Stopped and waiting for my confirmation.

If your agent looks for a different file name (for example GEMINI.md or a rules folder), ask it to create that file too with the same content, or to point it at AGENTS.md.
