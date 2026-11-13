import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/flows/auth_and_onboarding_e2e.dart';
import '../../integration_test/flows/circulars_and_inbox_e2e.dart';
import '../../integration_test/flows/prep_math_and_timer_e2e.dart';
import '../../integration_test/flows/vault_and_settings_e2e.dart';

/// End-to-end user journey test suite executable directly with `flutter test`.
void main() {
  group('JobPrep End-to-End Suite', () {
    runAuthAndOnboardingE2ETests();
    runCircularsAndInboxE2ETests();
    runPrepMathAndTimerE2ETests();
    runVaultAndSettingsE2ETests();
  });
}
