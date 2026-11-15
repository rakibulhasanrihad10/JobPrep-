# Manual Verification Checklist

Comprehensive manual verification checklist for the JobPrep web and mobile platform. Covers critical authentication, data-layer, offline guest, backup/restore, and account migration journeys.

---

## 1. Authentication & Session Setup
- [x] **Sign In with Email & Password**:
  - Navigate to `/login`.
  - Enter valid user credentials (`test@example.com` / `password123`).
  - Verify spinner / loading indicator appears on submit button.
  - Land on `/today` dashboard with personal statistics and user email shown in drawer/sidebar.
- [x] **Sign Out**:
  - Open Settings, click **Sign Out**.
  - Verify redirect back to `/login` and session storage cleared.

---

## 2. Circular Tracking & Quick Capture
- [x] **Add Circular**:
  - Navigate to `/circulars`.
  - Click **Add Circular**.
  - Fill out Title (e.g., `45th BCS General Cadre`), Organization (`BPSC`), Sector (`BCS`), and Application Deadline.
  - Save and verify circular appears in the list with correct tags, sorting, and deadline countdown.
- [x] **Add Exam Dates**:
  - In circular details, add preliminary exam date and viva date.
  - Verify exam dates sort chronologically and sync to Today overview countdown.

---

## 3. Preparation Math & Progress Recalculation
- [x] **Setup Subject & 3 Books (300, 300, 400 pages)**:
  - Create Subject: `Bangla Literature`.
  - Add Book 1: `300 pages`, `0 completed`.
  - Add Book 2: `300 pages`, `0 completed`.
  - Add Book 3: `400 pages`, `0 completed`.
- [x] **Log Progress on Book 1**:
  - Log `300 pages` done on Book 1.
  - Verify Book 1 shows `300 / 300 pages` (**100%**).
  - Verify Subject progress is exactly $\frac{300}{1000} =$ **30.0%**.
- [x] **Log Additional Progress**:
  - Log `150 pages` on Book 2.
  - Verify Book 2 shows `150 / 300 pages` (**50%**).
  - Verify Subject progress is $\frac{300 + 150}{1000} =$ **45.0%**.
- [x] **Clamping & Correction**:
  - Log `500 pages` on Book 3 (which has `400` total).
  - Verify Book 3 is strictly clamped to `400 / 400` (**100%**).
  - Add correction log of `-50 pages` on Book 2.
  - Verify Book 2 updates to `100 / 300 pages`, and does not register as study time/streak.

---

## 4. Guest Mode (Offline First)
- [x] **Start Without Account**:
  - From `/login`, click **Continue without account**.
  - Bottom sheet opens with plain-language disclosure: local device storage only, no cloud sync, uninstalling or clearing browser data deletes it, can move data later.
  - Click **I understand**.
  - Lands on `/today` in guest mode (`jobprep_app_mode: guest`).
- [x] **Offline Data Persistence**:
  - Add a guest circular and study session.
  - Hard refresh the browser (`Ctrl+F5` / reload tab).
  - App reopens directly in Guest Mode with all created circulars and progress intact.
- [x] **Feature Gating**:
  - Attempting to access account-only features (cloud sync, cloud file attachments, email reminders) shows locked indicator with **Create an account** call to action.

---

## 5. Backup & Restore (JSON Vault Format)
- [x] **Export Backup**:
  - Open **Settings -> Backup & Restore**.
  - Click **Export Backup**.
  - Choose passphrase encryption (AES-256-GCM + PBKDF2) or unencrypted JSON after warning.
  - Download backup file (`jobprep-backup-YYYY-MM-DD.json`).
  - Verify header contains `schemaVersion`, `appVersion`, `exportedAt`, `checksum`.
- [x] **Restore Backup**:
  - Pick previously exported backup file.
  - Decrypt with passphrase (if encrypted).
  - Inspect table preview summary (counts of circulars, subjects, logs, etc.).
  - Test **Merge**: new/updated records merged without deleting unmentioned records.
  - Test **Replace** (Guest mode): automatic safety backup created, require typing `REPLACE` confirmation, complete database reset with imported records.

---

## 6. Move Guest Data to Account
- [x] **Trigger Account Creation**:
  - In Guest Mode, open **Settings -> Guest section -> Create an account** (or prompt on Today screen).
  - Register or sign in with Google or Email/Password.
- [x] **Data Migration Wizard**:
  - View table count summary to be transferred.
  - Click **Move my data to my account**.
  - Watch dependency-ordered progress bar (Subjects -> Materials -> Progress Logs -> Circulars -> Auxiliary).
  - Verify upload is idempotent (client-generated UUIDs preserve identical records).
  - Confirm counts match and progress totals match exactly.
  - Download optional safety backup.
  - Confirm whether to clear local guest database.
  - App transitions to `signedIn` cloud mode seamlessly.

---

## 7. Observed Edge Cases & Hardening Notes
1. **Large Backup File Parsing**: Handled via background Dart Isolate or streaming chunk parser so UI remains at 60 fps during large JSON imports.
2. **PostgreSQL RLS on Upsert**: User B upserting on User A's ID fails or alters 0 rows; User A's data remains unmodified.
3. **Timezone Uniformity**: All timestamps stored in UTC (`toUtc()`) and rendered in user locale via `intl`.
