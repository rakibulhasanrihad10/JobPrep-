import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/widgets/account_feature_gate.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestGatedWidget({
    required AppMode? mode,
    required AccountOnlyFeature feature,
    bool compact = false,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appModeProvider.overrideWith(() => _StaticModeNotifier(mode)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AccountFeatureGate(
            feature: feature,
            compact: compact,
            child: const Text('Unlocked Secret Content'),
          ),
        ),
      ),
    );
  }

  group('AccountFeatureGate Widget Tests', () {
    testWidgets('renders child widget directly when signedIn', (tester) async {
      await tester.pumpWidget(
        buildTestGatedWidget(
          mode: AppMode.signedIn,
          feature: AccountOnlyFeature.cloudSync,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unlocked Secret Content'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('account_gate_create_account_button')),
        findsNothing,
      );
    });

    testWidgets('shows locked card and button when in guest mode',
        (tester) async {
      await tester.pumpWidget(
        buildTestGatedWidget(
          mode: AppMode.guest,
          feature: AccountOnlyFeature.emailReminders,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unlocked Secret Content'), findsNothing);
      expect(
        find.byKey(const ValueKey('account_feature_gate_locked_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('account_gate_create_account_button')),
        findsOneWidget,
      );
      expect(
        find.text('Email reminders require an account'),
        findsOneWidget,
      );
    });

    testWidgets('renders compact locked row for inline actions',
        (tester) async {
      await tester.pumpWidget(
        buildTestGatedWidget(
          mode: AppMode.guest,
          feature: AccountOnlyFeature.deleteAccount,
          compact: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unlocked Secret Content'), findsNothing);
      expect(
        find.byKey(const ValueKey('account_feature_gate_locked_compact')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('account_gate_create_account_button')),
        findsOneWidget,
      );
    });
  });
}

class _StaticModeNotifier extends AppModeNotifier {
  _StaticModeNotifier(this._initialMode);

  final AppMode? _initialMode;

  @override
  AppMode? build() => _initialMode;
}
