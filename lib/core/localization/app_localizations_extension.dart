import 'package:flutter/widgets.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Extension on [BuildContext] to access [AppLocalizations] cleanly.
extension AppLocalizationsX on BuildContext {
  /// Retrieves the localized strings for this context.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
