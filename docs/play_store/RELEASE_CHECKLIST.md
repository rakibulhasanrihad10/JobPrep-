# Google Play Release & Staged Rollout Checklist

This checklist defines the operational steps for progressing **JobPrep** from an internal build through Google Play's 20-tester closed testing gate to a production release.

---

## Stage 1: Internal Testing Track

The **Internal Testing** track provides instant distribution (no Google review delay) to up to 100 authorized testers.

### Pre-requisites & Upload
- [ ] Ensure CI has compiled and signed the release Android App Bundle (`app-release.aab`).
- [ ] In Google Play Console under **Release > Internal testing**, upload the bundle (or verify automated CI upload).
- [ ] Add internal testers by email list or Google Group.

### Verification Matrix on Physical Hardware
- [ ] **First Launch & Splash Screen**:
  - Splash screen matches navy & gold design tokens (`#0A0E1A` dark / `#F4F6FB` light).
  - No visual flickering or blank white screens during Flutter boot.
- [ ] **Authentication & Google Sign-In**:
  - Sign in with email and password.
  - Sign in with Google: verify SHA-1 fingerprint of the release keystore matches the Google Cloud OAuth client.
- [ ] **Deep Linking**:
  - Open `io.supabase.jobprep://login-callback` and `io.supabase.jobprep://reset-password` from Android browser or ADB.
- [ ] **Share Intent Capture (Phase 8B)**:
  - Open Facebook app or Chrome, tap **Share**, select **JobPrep**.
  - Verify JobPrep opens the **Quick Capture dialog** with the URL prefilled.
  - Tap **Save to Inbox** and verify the circular is persisted in the user's Inbox.
- [ ] **Encrypted Vault**:
  - Set passphrase, save portal password, lock vault, verify plaintext password never shows when locked.
- [ ] **Bilingual & Reduce Effects**:
  - Switch between English and Bangla; check Bangla numerals.
  - Enable **Reduce Effects**; verify animations and blur filters disable cleanly.

---

## Stage 2: Closed Testing (Google Play 20-Tester / 14-Day Gate)

Google Play requires all personal developer accounts created after November 2023 to run a closed test with **at least 20 testers opted in for at least 14 days continuously** before applying for production access.

### Setup
- [ ] Create a Closed Testing track in Play Console named `Closed Testing (Alpha)`.
- [ ] Create a Google Group (e.g. `jobprep-testers@googlegroups.com`) containing at least 25-30 committed testers (accounting for attrition).
- [ ] Promote the verified AAB build from Internal Testing to Closed Testing.
- [ ] Submit the closed testing release for Google review (typically 1-3 business days).
- [ ] Send the Play Store opt-in link (`https://play.google.com/apps/testing/com.jobprep.app`) to all testers.

### 14-Day Monitoring & Feedback Collection
- [ ] Confirm in Play Console dashboard that **at least 20 testers are actively opted in**.
- [ ] Keep testers opted in for **14 consecutive days**.
- [ ] Collect user feedback on device compatibility, battery drain, and notification delivery.
- [ ] Push bugfix updates to the Closed track if needed (minor updates do not reset the 14-day clock).

### Applying for Production Access
- [ ] After 14 full days, click **Apply for production** in the Play Console dashboard.
- [ ] Complete the questionnaire detailing:
  - How testers were recruited.
  - Summary of feedback received during the test period.
  - Changes or bugfixes made in response to tester feedback.
  - Confirmation that the app is ready for production distribution.

---

## Stage 3: Production Release (Phased Rollout)

Once Google approves production access, initiate a staged rollout to catch unexpected real-world regressions before reaching 100% of users.

### Store Listing Verification
- [ ] App Title, Short Description, and Full Description in English (`en-US`) and Bangla (`bn-BD`) from `docs/play_store/LISTING.md`.
- [ ] 7+ Phone screenshots, 7-inch tablet screenshots, and 10-inch tablet screenshots uploaded.
- [ ] App Icon (512x512) and Feature Graphic (1024x500) uploaded.
- [ ] Privacy Policy URL set to `https://jobprep.app/privacy`.
- [ ] Data Safety form completed according to `docs/play_store/LISTING.md`.
- [ ] Content rating questionnaire submitted (IARC 3+ / Everyone).

### Staged Rollout Schedule
1. **Day 1 - 10% Rollout**:
   - Release to 10% of users.
   - Monitor Sentry crash dashboard for unexpected exceptions.
   - Monitor Google Play **Android Vitals**:
     - User-perceived crash rate must stay below **1.09%**.
     - User-perceived ANR rate must stay below **0.47%**.
2. **Day 3 - 25% Rollout**:
   - Increase to 25% if crash rate is clean.
   - Check user reviews and support feedback for edge cases.
3. **Day 5 - 50% Rollout**:
   - Increase to 50%. Check backend database traffic and Supabase Auth loads.
4. **Day 7 - 100% Full Rollout**:
   - Complete rollout to 100% of users.

### Rollback / Emergency Halt Plan
- If a critical bug is detected during staged rollout:
  1. Click **Halt rollout** in Google Play Console immediately to prevent new users from downloading the affected version.
  2. The existing users remain on the version while an emergency hotfix build is prepared.
  3. Increment version code (e.g. `0.1.1+2`), commit fix, build signed AAB via CI, and release directly to 100% to replace the faulty build.
