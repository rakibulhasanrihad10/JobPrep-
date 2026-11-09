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

## Git Workflow & Conventions

- **Branches**:
  - `main`: Production-ready code. Protected branch.
  - `develop`: Integration branch for completed foundation and feature phases.
  - `feat/*`, `fix/*`, `chore/*`: Short-lived feature/task branches.
- **Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `ci:`).
- **Line Endings**: LF enforced across all operating systems via `.gitattributes` and `.editorconfig`.
- **Quality Gates**: Every pull request must pass automated checks (format, lint with warnings as errors, unit/widget/golden tests, secrets scanning, and build verification).

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
