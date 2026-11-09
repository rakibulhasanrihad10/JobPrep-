import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'JobPrep'**
  String get appTitle;

  /// Main title on dashboard
  ///
  /// In en, this message translates to:
  /// **'JobPrep Dashboard'**
  String get dashboardTitle;

  /// Subtitle on dashboard
  ///
  /// In en, this message translates to:
  /// **'Job Circular Tracker & Exam Prep Foundations'**
  String get dashboardSubtitle;

  /// Header for theme settings card
  ///
  /// In en, this message translates to:
  /// **'Theme Mode Switcher'**
  String get themeSwitcherTitle;

  /// Description for theme settings card
  ///
  /// In en, this message translates to:
  /// **'Choose an appearance mode (persisted with SharedPreferences)'**
  String get themeSwitcherSubtitle;

  /// System theme option label
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// Light theme option label
  ///
  /// In en, this message translates to:
  /// **'Light Theme (Navy & Gold)'**
  String get lightTheme;

  /// Dark theme option label
  ///
  /// In en, this message translates to:
  /// **'Dark Theme (Deep Navy & Gold)'**
  String get darkTheme;

  /// Header for language settings card
  ///
  /// In en, this message translates to:
  /// **'Language Switcher'**
  String get languageSwitcherTitle;

  /// Description for language settings card
  ///
  /// In en, this message translates to:
  /// **'Choose an interface language (persisted with SharedPreferences)'**
  String get languageSwitcherSubtitle;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Bangla language option
  ///
  /// In en, this message translates to:
  /// **'বাংলা (Bangla)'**
  String get languageBangla;

  /// Header for tokens preview card
  ///
  /// In en, this message translates to:
  /// **'Design Tokens Preview'**
  String get tokensPreviewTitle;

  /// Label for gold accent button
  ///
  /// In en, this message translates to:
  /// **'Gold Accent Button'**
  String get goldAccentButton;

  /// Label for outlined button
  ///
  /// In en, this message translates to:
  /// **'Outlined Button'**
  String get outlinedButton;

  /// Status badge label for success
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get statusSuccess;

  /// Status badge label for warning
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statusWarning;

  /// Status badge label for danger
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get statusDanger;

  /// Header for formatters showcase card
  ///
  /// In en, this message translates to:
  /// **'Locale Formatters & Plurals Preview'**
  String get formattersTitle;

  /// Sample localized currency
  ///
  /// In en, this message translates to:
  /// **'Application Fee: {formattedAmount}'**
  String sampleCurrency(String formattedAmount);

  /// Sample localized date
  ///
  /// In en, this message translates to:
  /// **'Exam Date: {formattedDate}'**
  String sampleDate(String formattedDate);

  /// Progress display with placeholders
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageProgress(String current, String total);

  /// Pluralized count of completed study books
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No books completed yet} =1{1 book completed} other{{count} books completed}}'**
  String booksCompleted(int count);

  /// Pluralized days remaining until application deadline
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Application deadline is today} =1{1 day remaining until deadline} other{{days} days remaining until deadline}}'**
  String deadlineDaysRemaining(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
