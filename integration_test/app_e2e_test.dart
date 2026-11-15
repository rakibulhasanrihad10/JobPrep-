import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'flows/auth_and_onboarding_e2e.dart';
import 'flows/backup_and_restore_e2e.dart';
import 'flows/circulars_and_inbox_e2e.dart';
import 'flows/guest_mode_e2e.dart';
import 'flows/guest_to_account_migration_e2e.dart';
import 'flows/prep_math_and_timer_e2e.dart';
import 'flows/vault_and_settings_e2e.dart';

/// Main end-to-end integration test suite running in headless Chrome & CI.
///
/// Covers:
/// 1. Sign up and sign in.
/// 2. Add circular & add exam dates.
/// 3. Quick capture and complete from inbox.
/// 4. Create subject with 3 books (300, 300, 400 pages) and verify
///    progress math: finishing book 1 is 100% for that book and 30% for
///    the subject.
/// 5. Lock and unlock vault with secret passphrase.
/// 6. Switch theme (dark/light) and language (English/Bangla).
/// 7. Complete onboarding wizard as a new user.
/// 8. Mark page for revision and clear from revision queue.
/// 9. Run, pause, and save a study timer session.
/// 10. Guest mode session persistence & local storage.
/// 11. Full backup and restore round trip (JSON encryption & 300/300/400 preservation).
/// 12. Move guest data to account in dependency order.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('JobPrep End-to-End Integration Suite', () {
    runAuthAndOnboardingE2ETests();
    runGuestModeE2ETests();
    runCircularsAndInboxE2ETests();
    runPrepMathAndTimerE2ETests();
    runVaultAndSettingsE2ETests();
    runBackupAndRestoreE2ETests();
    runGuestToAccountMigrationE2ETests();
  });
}
