# Job Circular Tracker and Exam Prep Dashboard

A modern, responsive Flutter application (Web first, Android later) designed to streamline job tracking, circular management, application portal logins, and exam preparation with customizable study plans.

---

## Overview

The **Job Circular Tracker and Exam Prep Dashboard** combines two essential workflows for competitive job aspirants:

1. **Job Circular Tracking & Vault**:
   - Manage circulars, application deadlines, admit card releases, and exam dates.
   - Securely store and autofill application portal credentials via client-side AES-GCM encryption with PBKDF2 key derivation.
   - Attach and organize circular PDFs, admit cards, and application forms in Supabase Storage.

2. **Exam Preparation Dashboard**:
   - Create custom subjects, modules, and study materials (e.g., books with granular page counts).
   - Accurate weighted progress calculations (e.g., three books of 300, 300, and 400 pages correctly aggregate to subject progress).
   - Animated progress rings and bars that replay smoothly upon viewing.

3. **Design & User Experience**:
   - Subtle, minimalist glassmorphism with deep navy and gold palette.
   - First-class Dark and Light modes backed by design tokens.
   - Accessibility-focused "Reduce Effects" toggle replacing blurs with translucent fills.
   - Full bilingual support in English and Bangla (with Noto Sans Bengali and optional Bangla numerals).

---

## Tech Stack

| Component | Technology |
|---|---|
| **Framework** | Flutter (Web first, Android later) |
| **State Management & DI** | Riverpod |
| **Routing** | go_router |
| **Backend & Database** | Supabase (PostgreSQL with Row Level Security, Auth, Storage) |
| **Animations** | flutter_animate |
| **Localization** | flutter_localizations, intl, ARB (`app_en.arb`, `app_bn.arb`) |
| **Testing** | Flutter Test, Golden Toolkit, Supabase DB & RLS tests |

---

## Architecture

This project strictly adheres to clean, modular architecture:

```
lib/
├── core/                  # Core abstractions, theme extensions, utilities, errors, network
├── features/              # Feature-first modules
│   └── <feature_name>/
│       ├── data/          # Models, data sources, repository implementations
│       ├── domain/        # Entities, repository interfaces, use cases
│       └── presentation/  # Widgets, Riverpod controllers/providers, screens
└── shared/                # Reusable design system widgets, glassmorphism containers
```

### Architectural Guardrails
- **Presentation Layer**: UI widgets observe Riverpod providers. **Widgets never invoke Supabase directly** and never hold business logic.
- **Domain Layer**: Clean, pure Dart entities and abstract repository definitions independent of third-party frameworks.
- **Data Layer**: Implements domain repositories, handles Supabase communication and local storage caching.
- **Design Tokens**: All colors, typography, border radii, spacing, and transition durations are consumed via a `ThemeExtension`. No hardcoded colors or sizes in widgets.
- **Security**: PostgreSQL Row Level Security (RLS) enforces `auth.uid() = user_id` on every table. Portal credentials are encrypted client-side with user-held passphrase derivations.

---

## Development Workflow

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- Git (configured with LF line endings)

### Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/JobPrep.git
   cd JobPrep
   ```

2. **Checkout develop branch**:
   ```bash
   git checkout develop
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run code generation & localization**:
   ```bash
   flutter gen-l10n
   ```

5. **Launch the web application**:
   ```bash
   flutter run -d chrome
   ```

---

## Supabase Setup & Local Development

### 1. Local Supabase Development

The repository includes a configured `supabase/` directory with `config.toml` and baseline migrations in `supabase/migrations/`.

- **Start local Supabase** (PostgreSQL, Auth, Storage, Studio):
  ```bash
  npx supabase start
  ```
- **Inspect local credentials and URLs**:
  ```bash
  npx supabase status
  ```
  This displays the local API URL (typically `http://127.0.0.1:54321`), the local anonymous key, database URL, and Supabase Studio dashboard URL (`http://127.0.0.1:54323`).
- **Reset local database & apply all migrations**:
  ```bash
  npx supabase db reset
  ```
- **Stop local Supabase**:
  ```bash
  npx supabase stop
  ```

---

### 2. Creating the Production / Cloud Supabase Project

To create a real Supabase backend:

1. Sign in or sign up at [supabase.com](https://supabase.com/).
2. Click **New Project** and select your organization.
3. Configure project details:
   - **Name**: `JobPrep` (or your choice).
   - **Database Password**: Generate and securely store a strong password.
   - **Region**: Choose a region closest to your primary users (e.g., `Singapore (ap-southeast-1)`).
4. Retrieve API credentials:
   - Navigate to **Project Settings** (gear icon in the sidebar) > **API**.
   - Copy the **Project URL** (e.g. `https://<your-project-id>.supabase.co`).
   - Copy the **Project API Keys** -> `anon` / `public` key.

> [!CAUTION]
> **Security Requirement**: Never put the `service_role` key in the client application or commit it to the repository. The client application only permits the public `anon` key, provided at runtime via `--dart-define`.

---

### 3. Running Flutter with Supabase Configuration

Pass your project credentials at build or runtime using `--dart-define`:

- **Local Development**:
  ```bash
  flutter run -d chrome \
    --dart-define=ENVIRONMENT=dev \
    --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
    --dart-define=SUPABASE_ANON_KEY=<local-anon-key-from-supabase-status>
  ```

- **Staging / Production**:
  ```bash
  flutter run -d chrome \
    --dart-define=ENVIRONMENT=prod \
    --dart-define=SUPABASE_URL=https://<your-project-id>.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
  ```

---

### 4. Authentication Providers & Redirect URLs

Configure authentication providers and allowed redirect URLs in the **Supabase Dashboard** before testing Email or Google sign-in:

#### Email Provider Setup
1. Open your Supabase project dashboard and go to **Authentication** > **Providers** > **Email**.
2. Ensure **Enable Email provider** is toggled on.
3. Configure **Confirm email**:
   - **Recommended for staging/prod**: Keep **Confirm email** enabled so new users confirm ownership before signing in.
   - **Local dev**: `supabase/config.toml` captures outbound confirmation and password-reset emails in local Inbucket (`http://127.0.0.1:54324`).
4. Ensure password policy requirements match your environment (e.g., minimum password length of 8+ characters).

#### Google OAuth Provider Setup
1. Open [Google Cloud Console](https://console.cloud.google.com/) and select or create a project.
2. Navigate to **APIs & Services** > **OAuth consent screen** and configure the app name, support email, and scopes (`openid`, `email`, `profile`).
3. Navigate to **APIs & Services** > **Credentials** > **Create Credentials** > **OAuth client ID** (**Web application**).
4. Under **Authorized JavaScript origins**, add your web app origins:
   - Local dev: `http://localhost:3000`, `http://127.0.0.1:3000` (or the port used by `flutter run`)
   - Production: `https://<your-production-domain>`
5. Under **Authorized redirect URIs**, add the Supabase OAuth callback URL shown in your Supabase dashboard:
   - `https://<your-project-id>.supabase.co/auth/v1/callback`
6. Copy the generated **Client ID** and **Client Secret**.
7. In the **Supabase Dashboard**, go to **Authentication** > **Providers** > **Google**:
   - Enable the **Google** provider.
   - Paste the **Client ID** and **Client Secret**, then click **Save**.

#### URL Configuration & Redirect URLs
1. In the **Supabase Dashboard**, go to **Authentication** > **URL Configuration**.
2. Set **Site URL** to your primary web application URL:
   - Production: `https://<your-production-domain>`
   - Local testing: `http://127.0.0.1:3000` (or fixed `--web-port` if using `flutter run -d chrome --web-port=3000`)
3. Under **Redirect URLs**, add every allowed post-auth and password-recovery destination:
   - `http://localhost:3000/**`
   - `http://127.0.0.1:3000/**`
   - `https://<your-production-domain>/`
   - `https://<your-production-domain>/reset-password`
   - Mobile deep links (for future Android builds): `io.supabase.jobprep://login-callback` and `io.supabase.jobprep://reset-password`

> [!TIP]
> When running Flutter Web locally with `flutter run`, pass `--web-port=3000` so the local browser origin stays deterministic and matches Supabase's allow-listed Redirect URLs (`http://localhost:3000/reset-password` and `http://localhost:3000`).

---

## Git Workflow & Conventions

- **Branches**:
  - `main`: Production-ready code. Protected branch.
  - `develop`: Integration branch for completed foundation and feature phases.
  - `feat/*`, `fix/*`, `chore/*`: Short-lived feature/task branches.
- **Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ci:`).
- **Line Endings**: LF enforced across all operating systems via `.gitattributes` and `.editorconfig`.
- **Quality Gates**: Every pull request must pass automated checks (format, lint with warnings as errors, unit/widget/golden tests, secrets scanning, and build verification).

---

## Continuous Integration (CI) & Quality Gates

Automated CI runs via GitHub Actions ([.github/workflows/ci.yml](.github/workflows/ci.yml)) on every pull request and push targeting `main` or `develop`.

The pipeline executes the following checks sequentially:
1. **Gitleaks Secrets Scan**: Scans repository history to block any exposed credentials or secret keys.
2. **Flutter Setup & Caching**: Initializes Flutter stable SDK with automated tool caching.
3. **Dependency Resolution**: Runs `flutter pub get`.
4. **Code Formatting Check**: Enforces `dart format --output=none --set-exit-if-changed .`.
5. **Strict Static Analysis**: Enforces `flutter analyze --fatal-infos --fatal-warnings`.
6. **Automated Test Suite**: Executes unit and widget tests with `flutter test`.
7. **Web Compilation Verification**: Compiles production web bundle (`flutter build web --release`).

---

## Branch Protection Setup for `main`

To ensure code quality and prevent unauthorized direct commits to `main`:

1. In GitHub, go to **Settings** > **Branches**.
2. Under **Branch protection rules**, click **Add branch protection rule**.
3. Set **Branch name pattern** to `main`.
4. Enable the following settings:
   - **Require a pull request before merging**:
     - Check **Require approvals** (at least 1 reviewer).
     - Check **Dismiss stale pull request approvals when new commits are pushed**.
   - **Require status checks to pass before merging**:
     - Check **Require branches to be up to date before merging**.
     - In the search bar under **Status checks that are required**, select:
        - `Quality Gates & Web Build` (job defined in `ci.yml`).
        - `Supabase Migrations & Database Verification` (job defined in `ci.yml`).
   - **Require linear history**:
     - Enforces clean Git history adhering to Conventional Commits.
   - **Do not allow bypassing the above settings**:
     - Ensures protection applies to everyone, including repository administrators.
5. Click **Save changes** (or **Create**).

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
