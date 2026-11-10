## Description

Please provide a brief summary of the changes introduced in this pull request and the problem they solve.

**Phase / Issue Reference**: Phase 0A / #...

---

## Type of Change

- [ ] `feat`: New feature (non-breaking change which adds functionality)
- [ ] `fix`: Bug fix (non-breaking change which fixes an issue)
- [ ] `docs`: Documentation only changes
- [ ] `refactor`: A code change that neither fixes a bug nor adds a feature
- [ ] `test`: Adding missing tests or correcting existing tests
- [ ] `chore`: Changes to build process, tooling, or auxiliary libraries
- [ ] `ci`: Changes to CI/CD configuration files and scripts

---

## Architectural & Quality Checklist

### Architecture & Layering
- [ ] Separation of concerns respected: Presentation, Domain, Data layers isolated.
- [ ] Widgets **never** call Supabase directly and contain **zero** business logic.
- [ ] Feature files are organized under `lib/features/<feature>/{data,domain,presentation}`.
- [ ] Dependencies are injected with Riverpod (swappable with fakes in tests).
- [ ] Source files are focused and concise (under ~300 lines).

### Design System & Theming
- [ ] No hardcoded colors, spacing, radii, durations, or text styles in widgets.
- [ ] All visual styling references `ThemeExtension` design tokens.
- [ ] Verified appearance in both **Dark Mode** and **Light Mode**.
- [ ] "Reduce Effects" setting handled (blur replaced with solid translucent fill; animations skipped).

### Localization & Internationalization
- [ ] No hardcoded user-facing strings (all strings in `app_en.arb` and `app_bn.arb`).
- [ ] Tested with Bangla text to ensure no layout overflows or text clipping.
- [ ] Date, time, currency, and numbers formatted with `intl` per locale.

### Security
- [ ] No API keys, secrets, service role keys, or `.env` files committed.
- [ ] Any new PostgreSQL tables have `user_id` and strict RLS policies (`auth.uid() = user_id`).
- [ ] Portal credentials encrypted client-side (AES-GCM + PBKDF2) before transit.

### Testing & Verification
- [ ] Unit tests, widget tests, or golden tests added/updated.
- [ ] All tests pass locally (`flutter test`).
- [ ] Code formatted (`dart format .`) and zero analyzer warnings (`flutter analyze`).
- [ ] Progress calculation matches requirements (e.g. weighted subject math).

---

## Screenshots / Screen Recordings (if applicable)

| Light Theme | Dark Theme |
|:---:|:---:|
| *(Image)* | *(Image)* |
