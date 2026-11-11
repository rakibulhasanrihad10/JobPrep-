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

  /// Navigation label for Dashboard tab
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation label for Circulars tab
  ///
  /// In en, this message translates to:
  /// **'Circulars'**
  String get navCirculars;

  /// Navigation label for Prep tab
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get navPrep;

  /// Navigation label for Calendar tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Navigation label for Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Title on Circulars screen
  ///
  /// In en, this message translates to:
  /// **'Job Circulars'**
  String get circularsTitle;

  /// Subtitle on Circulars screen
  ///
  /// In en, this message translates to:
  /// **'Track active job circulars, deadlines, and requirements'**
  String get circularsSubtitle;

  /// Title on Prep screen
  ///
  /// In en, this message translates to:
  /// **'Exam Preparation'**
  String get prepTitle;

  /// Subtitle on Prep screen
  ///
  /// In en, this message translates to:
  /// **'Subject-wise syllabus, targets, and book tracking'**
  String get prepSubtitle;

  /// Title on Calendar screen
  ///
  /// In en, this message translates to:
  /// **'Exam Calendar'**
  String get calendarTitle;

  /// Subtitle on Calendar screen
  ///
  /// In en, this message translates to:
  /// **'Upcoming application deadlines and exam schedules'**
  String get calendarSubtitle;

  /// Title on Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Subtitle on Settings screen
  ///
  /// In en, this message translates to:
  /// **'App preferences, appearance, and configurations'**
  String get settingsSubtitle;

  /// Tooltip showing navigation keyboard shortcut
  ///
  /// In en, this message translates to:
  /// **'Shortcut: {shortcut}'**
  String navShortcutTooltip(String shortcut);

  /// Keyboard shortcut badge
  ///
  /// In en, this message translates to:
  /// **'Alt+{digit}'**
  String navShortcutBadge(String digit);

  /// Title on the login route placeholder
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginRouteTitle;

  /// Title on the reset password route placeholder
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPasswordRouteTitle;

  /// Heading for sign-in mode on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authSignInTitle;

  /// Subtitle for sign-in mode on login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your job circulars and exam prep'**
  String get authSignInSubtitle;

  /// Heading for sign-up mode on login screen
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authSignUpTitle;

  /// Subtitle for sign-up mode on login screen
  ///
  /// In en, this message translates to:
  /// **'Start tracking circulars and study progress securely'**
  String get authSignUpSubtitle;

  /// Heading for forgot password mode
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotPasswordTitle;

  /// Subtitle for forgot password mode
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a password reset link'**
  String get authForgotPasswordSubtitle;

  /// Heading for /reset-password screen
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get authResetPasswordTitle;

  /// Subtitle for /reset-password screen
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password of at least 8 characters'**
  String get authResetPasswordSubtitle;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailLabel;

  /// Hint for email input field
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Hint for password input field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// Label for new password field on reset password screen
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// Hint for new password field
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authNewPasswordHint;

  /// Label for confirm new password field
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmPasswordLabel;

  /// Hint for confirm new password field
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get authConfirmPasswordHint;

  /// Helper text showing minimum 8 character requirement
  ///
  /// In en, this message translates to:
  /// **'Must be at least 8 characters'**
  String get authPasswordMinLengthHelper;

  /// Tooltip for revealing obscured password
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPasswordTooltip;

  /// Tooltip for hiding visible password
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePasswordTooltip;

  /// Primary button label for sign in
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// Primary button label for sign up
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// Primary button label for sending password reset email
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLinkButton;

  /// Primary button label for saving new password
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authUpdatePasswordButton;

  /// Google OAuth button label
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Short separator label between email auth and OAuth
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDivider;

  /// Link label to enter forgot password flow
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordLink;

  /// Button or link label to return to sign in
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// Prompt preceding create account toggle
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccountPrompt;

  /// Prompt preceding sign in toggle
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccountPrompt;

  /// Toggle link text switching to sign up mode
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSwitchToSignUp;

  /// Toggle link text switching to sign in mode
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSwitchToSignIn;

  /// Success title shown after sign up
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authCheckEmailTitle;

  /// Success body shown after sign up
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. Open the link in your inbox to confirm your account before signing in.'**
  String authCheckEmailMessage(String email);

  /// Success title shown after sending password reset email
  ///
  /// In en, this message translates to:
  /// **'Reset link sent'**
  String get authResetLinkSentTitle;

  /// Success body shown after sending password reset email
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, we sent instructions to reset your password.'**
  String authResetLinkSentMessage(String email);

  /// Success title shown after updating password
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get authPasswordUpdatedTitle;

  /// Success body shown after updating password
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully. You can now continue to your dashboard.'**
  String get authPasswordUpdatedMessage;

  /// Button label after password update completes
  ///
  /// In en, this message translates to:
  /// **'Continue to dashboard'**
  String get authContinueToDashboard;

  /// Validation error when email is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get authValidationEmailRequired;

  /// Validation error when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authValidationEmailInvalid;

  /// Validation error when password is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get authValidationPasswordRequired;

  /// Validation error when password is fewer than 8 characters
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get authValidationPasswordTooShort;

  /// Validation error when confirm password is empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password.'**
  String get authValidationConfirmPasswordRequired;

  /// Validation error when password confirmation does not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authValidationPasswordsDoNotMatch;

  /// Localized message for InvalidCredentialsFailure
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please check your details and try again.'**
  String get authErrorInvalidCredentials;

  /// Localized message for EmailNotConfirmedFailure
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email address before signing in. Check your inbox for the verification link.'**
  String get authErrorEmailNotConfirmed;

  /// Localized message for AccountAlreadyExistsFailure
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in instead.'**
  String get authErrorAccountAlreadyExists;

  /// Localized message for TooManyRequestsFailure
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authErrorTooManyRequests;

  /// Localized message for NetworkFailure
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again.'**
  String get authErrorNetwork;

  /// Localized message for WeakPasswordFailure
  ///
  /// In en, this message translates to:
  /// **'Your password is too weak. Use at least 8 characters with letters and numbers.'**
  String get authErrorWeakPassword;

  /// Localized message for UnknownAuthFailure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong during authentication. Please try again.'**
  String get authErrorUnknown;

  /// Pluralized count of visible job circulars
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No circulars} =1{{formattedCount} circular} other{{formattedCount} circulars}}'**
  String circularsCount(int count, String formattedCount);

  /// Placeholder text for circular search input
  ///
  /// In en, this message translates to:
  /// **'Search by title or organization...'**
  String get circularsSearchHint;

  /// Tooltip on search clear button
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get circularsClearSearchTooltip;

  /// Button label to expand or collapse filter controls
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get circularsFilterToggle;

  /// Button label to clear active filters and search
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get circularsClearFilters;

  /// Label prefix for circular sort dropdown
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get circularsSortLabel;

  /// Tooltip on circular list refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh circulars'**
  String get circularsRefreshTooltip;

  /// Sort option ordering soonest deadlines first
  ///
  /// In en, this message translates to:
  /// **'Deadline (soonest)'**
  String get circularsSortDeadline;

  /// Sort option ordering highest priority first
  ///
  /// In en, this message translates to:
  /// **'Priority (highest)'**
  String get circularsSortPriority;

  /// Sort option ordering newest created circulars first
  ///
  /// In en, this message translates to:
  /// **'Created date (newest)'**
  String get circularsSortCreated;

  /// Sort option ordering recently updated circulars first
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get circularsSortUpdated;

  /// Sort option ordering titles alphabetically
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get circularsSortTitle;

  /// Filter group header for employment sector
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get circularsFilterSector;

  /// Filter group header for application status
  ///
  /// In en, this message translates to:
  /// **'Application Status'**
  String get circularsFilterApplicationStatus;

  /// Filter group header for circular priority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get circularsFilterPriority;

  /// Filter group header for workflow status
  ///
  /// In en, this message translates to:
  /// **'Workflow Status'**
  String get circularsFilterWorkflowStatus;

  /// Filter group header for deadline range and urgency
  ///
  /// In en, this message translates to:
  /// **'Deadline Range'**
  String get circularsFilterDeadlineRange;

  /// Preset chip clearing deadline filter
  ///
  /// In en, this message translates to:
  /// **'All deadlines'**
  String get circularsDeadlineRangeAll;

  /// Preset chip for red band circulars
  ///
  /// In en, this message translates to:
  /// **'Under 3 days / Overdue'**
  String get circularsDeadlineRangeUnder3OrOverdue;

  /// Preset chip for amber band circulars
  ///
  /// In en, this message translates to:
  /// **'3 to 7 days'**
  String get circularsDeadlineRange3To7Days;

  /// Preset chip for green band circulars
  ///
  /// In en, this message translates to:
  /// **'Above 7 days'**
  String get circularsDeadlineRangeOver7Days;

  /// Preset chip filtering deadlines in the next 30 calendar days
  ///
  /// In en, this message translates to:
  /// **'Next 30 days'**
  String get circularsDeadlineRangeNext30Days;

  /// Start date picker button label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get circularsDeadlineFromLabel;

  /// End date picker button label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get circularsDeadlineToLabel;

  /// Tooltip to clear selected custom deadline dates
  ///
  /// In en, this message translates to:
  /// **'Clear date range'**
  String get circularsClearDatesTooltip;

  /// Desktop table column header for title and organization
  ///
  /// In en, this message translates to:
  /// **'Circular & Organization'**
  String get circularsColumnTitle;

  /// Desktop table column header for sector
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get circularsColumnSector;

  /// Desktop table column header for deadline countdown
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get circularsColumnDeadline;

  /// Desktop table column header for vacancy count
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get circularsColumnVacancies;

  /// Desktop table column header for circular status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get circularsColumnStatus;

  /// Pluralized vacancy post count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No vacancies} =1{{formattedCount} post} other{{formattedCount} posts}}'**
  String circularsVacanciesCount(int count, String formattedCount);

  /// Fallback when vacancy count is unset
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get circularsVacanciesUnspecified;

  /// Fallback when organization name is unset
  ///
  /// In en, this message translates to:
  /// **'Organization not specified'**
  String get circularsOrganizationUnspecified;

  /// Countdown label when circular has no deadline
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get circularsCountdownNoDeadline;

  /// Countdown label when deadline is later today
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get circularsCountdownToday;

  /// Pluralized days remaining until deadline
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{formattedDays} day left} other{{formattedDays} days left}}'**
  String circularsCountdownDaysLeft(int days, String formattedDays);

  /// Pluralized overdue countdown label
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Expired today} =1{{formattedDays} day overdue} other{{formattedDays} days overdue}}'**
  String circularsCountdownOverdueDays(int days, String formattedDays);

  /// Label for government sector
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get circularSectorGovernment;

  /// Label for BCS sector
  ///
  /// In en, this message translates to:
  /// **'BCS'**
  String get circularSectorBcs;

  /// Label for bank sector
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get circularSectorBank;

  /// Label for autonomous sector
  ///
  /// In en, this message translates to:
  /// **'Autonomous'**
  String get circularSectorAutonomous;

  /// Label for private sector
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get circularSectorPrivate;

  /// Label for NGO sector
  ///
  /// In en, this message translates to:
  /// **'NGO'**
  String get circularSectorNgo;

  /// Label for defense sector
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get circularSectorDefense;

  /// Label for other sector
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get circularSectorOther;

  /// Label for not_applied application status
  ///
  /// In en, this message translates to:
  /// **'Not applied'**
  String get circularAppStatusNotApplied;

  /// Label for in_progress application status
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get circularAppStatusInProgress;

  /// Label for applied application status
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get circularAppStatusApplied;

  /// Label for fee_paid application status
  ///
  /// In en, this message translates to:
  /// **'Fee paid'**
  String get circularAppStatusFeePaid;

  /// Label for exempt application status
  ///
  /// In en, this message translates to:
  /// **'Fee exempt'**
  String get circularAppStatusExempt;

  /// Label for missed application status
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get circularAppStatusMissed;

  /// Label for not_applicable application status
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get circularAppStatusNotApplicable;

  /// Label for low circular priority
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get circularPriorityLow;

  /// Label for medium circular priority
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get circularPriorityMedium;

  /// Label for high circular priority
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get circularPriorityHigh;

  /// Label for urgent circular priority
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get circularPriorityUrgent;

  /// Label for saved workflow status
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get circularWorkflowSaved;

  /// Label for preparing workflow status
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get circularWorkflowPreparing;

  /// Label for applied workflow status
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get circularWorkflowApplied;

  /// Label for exam_upcoming workflow status
  ///
  /// In en, this message translates to:
  /// **'Exam upcoming'**
  String get circularWorkflowExamUpcoming;

  /// Label for result_awaited workflow status
  ///
  /// In en, this message translates to:
  /// **'Result awaited'**
  String get circularWorkflowResultAwaited;

  /// Label for archived workflow status
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get circularWorkflowArchived;

  /// Message displayed while circulars are loading
  ///
  /// In en, this message translates to:
  /// **'Loading job circulars...'**
  String get circularsLoadingMessage;

  /// Title shown when the circular list has no entries
  ///
  /// In en, this message translates to:
  /// **'No job circulars yet'**
  String get circularsEmptyTitle;

  /// Body shown when the circular list has no entries
  ///
  /// In en, this message translates to:
  /// **'Tracked job circulars will appear here once added.'**
  String get circularsEmptyMessage;

  /// Title shown when active search or filters return zero matches
  ///
  /// In en, this message translates to:
  /// **'No matching circulars'**
  String get circularsFilteredEmptyTitle;

  /// Body shown when active search or filters return zero matches
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search query or clearing active filters.'**
  String get circularsFilteredEmptyMessage;

  /// Heading shown when loading circulars fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load circulars'**
  String get circularsErrorTitle;

  /// Retry action button label on circular load failure
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get circularsRetryButton;

  /// Localized error when permission is denied
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view these circulars.'**
  String get circularsErrorPermission;

  /// Localized error when network request fails
  ///
  /// In en, this message translates to:
  /// **'Network error while loading circulars. Check your connection and try again.'**
  String get circularsErrorNetwork;

  /// Fallback localized error message for circular list failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading circulars. Please try again.'**
  String get circularsErrorUnknown;

  /// Button label on Circulars list toolbar to open create form
  ///
  /// In en, this message translates to:
  /// **'Add circular'**
  String get circularsAddButton;

  /// Page title when creating a new circular
  ///
  /// In en, this message translates to:
  /// **'Add Job Circular'**
  String get circularFormAddTitle;

  /// Page subtitle when creating a new circular
  ///
  /// In en, this message translates to:
  /// **'Save deadlines, fees, links, and status details for a job circular.'**
  String get circularFormAddSubtitle;

  /// Page title when editing an existing circular
  ///
  /// In en, this message translates to:
  /// **'Edit Job Circular'**
  String get circularFormEditTitle;

  /// Page subtitle when editing an existing circular
  ///
  /// In en, this message translates to:
  /// **'Update circular details, tracking status, or personal notes.'**
  String get circularFormEditSubtitle;

  /// Submit button label when creating a circular
  ///
  /// In en, this message translates to:
  /// **'Save circular'**
  String get circularFormSaveButton;

  /// Submit button label when saving edits to a circular
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get circularFormUpdateButton;

  /// Cancel button label on circular form
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get circularFormCancelButton;

  /// Heading shown when editing a circular id that cannot be found
  ///
  /// In en, this message translates to:
  /// **'Circular not found'**
  String get circularFormNotFoundTitle;

  /// Message shown when requested circular for editing is missing
  ///
  /// In en, this message translates to:
  /// **'This job circular may have been deleted or is no longer available.'**
  String get circularFormNotFoundMessage;

  /// Button navigating back to the circulars list
  ///
  /// In en, this message translates to:
  /// **'Back to circulars'**
  String get circularFormBackToList;

  /// Section title for title, sector, and organization info
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get circularFormSectionBasics;

  /// Section title for circular and application links
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get circularFormSectionLinks;

  /// Section title for deadline, vacancies, salary, and fees
  ///
  /// In en, this message translates to:
  /// **'Dates & Numbers'**
  String get circularFormSectionDatesAndNumbers;

  /// Section title for workflow, application, admit card, and priority
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get circularFormSectionStatus;

  /// Section title for instructions, personal notes, and syllabus
  ///
  /// In en, this message translates to:
  /// **'Instructions & Notes'**
  String get circularFormSectionText;

  /// Label for required circular title field
  ///
  /// In en, this message translates to:
  /// **'Circular title'**
  String get circularFieldTitleLabel;

  /// Hint text for circular title field
  ///
  /// In en, this message translates to:
  /// **'e.g. 47th BCS General Cadre'**
  String get circularFieldTitleHint;

  /// Label for circular sector dropdown
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get circularFieldSectorLabel;

  /// Label for organization name field
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get circularFieldOrgNameLabel;

  /// Hint text for organization name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Bangladesh Public Service Commission'**
  String get circularFieldOrgNameHint;

  /// Label for organization website URL field
  ///
  /// In en, this message translates to:
  /// **'Organization website'**
  String get circularFieldOrgWebsiteLabel;

  /// Hint text for organization website URL field
  ///
  /// In en, this message translates to:
  /// **'https://example.gov.bd'**
  String get circularFieldOrgWebsiteHint;

  /// Label for original circular announcement link
  ///
  /// In en, this message translates to:
  /// **'Original circular link'**
  String get circularFieldCircularUrlLabel;

  /// Hint text for original circular link
  ///
  /// In en, this message translates to:
  /// **'https://example.gov.bd/circular'**
  String get circularFieldCircularUrlHint;

  /// Label for online application portal link
  ///
  /// In en, this message translates to:
  /// **'Application portal link'**
  String get circularFieldApplicationUrlLabel;

  /// Hint text for application portal link
  ///
  /// In en, this message translates to:
  /// **'https://apply.example.gov.bd'**
  String get circularFieldApplicationUrlHint;

  /// Label for circular deadline date picker
  ///
  /// In en, this message translates to:
  /// **'Application deadline'**
  String get circularFieldDeadlineLabel;

  /// Placeholder text when no deadline date is chosen
  ///
  /// In en, this message translates to:
  /// **'Select deadline date'**
  String get circularFieldDeadlineNone;

  /// Tooltip on button clearing selected deadline
  ///
  /// In en, this message translates to:
  /// **'Clear deadline'**
  String get circularFieldClearDeadlineTooltip;

  /// Label for vacancy count numeric field
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get circularFieldVacanciesLabel;

  /// Hint text for vacancies field
  ///
  /// In en, this message translates to:
  /// **'e.g. 150'**
  String get circularFieldVacanciesHint;

  /// Label for minimum salary input
  ///
  /// In en, this message translates to:
  /// **'Minimum salary'**
  String get circularFieldSalaryMinLabel;

  /// Hint text for minimum salary
  ///
  /// In en, this message translates to:
  /// **'e.g. 22000'**
  String get circularFieldSalaryMinHint;

  /// Label for maximum salary input
  ///
  /// In en, this message translates to:
  /// **'Maximum salary'**
  String get circularFieldSalaryMaxLabel;

  /// Hint text for maximum salary
  ///
  /// In en, this message translates to:
  /// **'e.g. 53060'**
  String get circularFieldSalaryMaxHint;

  /// Label for pay scale or benefits note
  ///
  /// In en, this message translates to:
  /// **'Salary & benefits note'**
  String get circularFieldSalaryNoteLabel;

  /// Hint text for salary note
  ///
  /// In en, this message translates to:
  /// **'e.g. Grade 9 National Pay Scale'**
  String get circularFieldSalaryNoteHint;

  /// Label for application fee input
  ///
  /// In en, this message translates to:
  /// **'Application fee'**
  String get circularFieldFeeLabel;

  /// Hint text for application fee
  ///
  /// In en, this message translates to:
  /// **'e.g. 200'**
  String get circularFieldFeeHint;

  /// Label for fee payment note
  ///
  /// In en, this message translates to:
  /// **'Fee note'**
  String get circularFieldFeeNoteLabel;

  /// Hint text for fee note
  ///
  /// In en, this message translates to:
  /// **'e.g. Payable via Teletalk / bKash'**
  String get circularFieldFeeNoteHint;

  /// Label for application status dropdown
  ///
  /// In en, this message translates to:
  /// **'Application status'**
  String get circularFieldAppStatusLabel;

  /// Label for admit card status dropdown
  ///
  /// In en, this message translates to:
  /// **'Admit card status'**
  String get circularFieldAdmitStatusLabel;

  /// Label for priority dropdown
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get circularFieldPriorityLabel;

  /// Label for workflow status dropdown
  ///
  /// In en, this message translates to:
  /// **'Workflow status'**
  String get circularFieldWorkflowStatusLabel;

  /// Label for instructions multiline field
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get circularFieldInstructionsLabel;

  /// Hint text for instructions field
  ///
  /// In en, this message translates to:
  /// **'Eligibility criteria, required documents, photo dimensions...'**
  String get circularFieldInstructionsHint;

  /// Label for personal notes multiline field
  ///
  /// In en, this message translates to:
  /// **'Personal notes'**
  String get circularFieldNotesLabel;

  /// Hint text for personal notes field
  ///
  /// In en, this message translates to:
  /// **'Reminders, preparation ideas, tracking notes...'**
  String get circularFieldNotesHint;

  /// Label for syllabus multiline field
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get circularFieldSyllabusLabel;

  /// Hint text for syllabus field
  ///
  /// In en, this message translates to:
  /// **'Exam subjects, mark distribution, key topics...'**
  String get circularFieldSyllabusHint;

  /// Label for not_available admit card status
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get circularAdmitStatusNotAvailable;

  /// Label for available admit card status
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get circularAdmitStatusAvailable;

  /// Label for downloaded admit card status
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get circularAdmitStatusDownloaded;

  /// Label for not_applicable admit card status
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get circularAdmitStatusNotApplicable;

  /// Validation error when title is blank
  ///
  /// In en, this message translates to:
  /// **'Please enter a circular title.'**
  String get circularValidationTitleRequired;

  /// Validation error for malformed URL inputs
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL starting with http:// or https://.'**
  String get circularValidationInvalidUrl;

  /// Validation error for non-integer or negative vacancies
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number (0 or greater).'**
  String get circularValidationInvalidInt;

  /// Validation error for negative or malformed monetary amount
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number (0 or greater).'**
  String get circularValidationInvalidNumber;

  /// Validation error when salaryMax < salaryMin
  ///
  /// In en, this message translates to:
  /// **'Maximum salary cannot be lower than minimum salary.'**
  String get circularValidationSalaryRange;

  /// Warning banner when another saved circular shares the same circular link
  ///
  /// In en, this message translates to:
  /// **'Warning: \"{title}\" already uses this circular link.'**
  String circularDuplicateLinkWarning(String title);

  /// Error banner message for server-side validation failures
  ///
  /// In en, this message translates to:
  /// **'Submitted circular details failed validation checks.'**
  String get circularFormErrorValidation;

  /// Confirmation dialog title before discarding dirty circular form
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get circularDiscardDialogTitle;

  /// Confirmation dialog body before discarding unsaved edits
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes on this circular. Leaving now will discard them.'**
  String get circularDiscardDialogMessage;

  /// Cancel button in discard confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get circularDiscardKeepEditing;

  /// Confirm button in discard confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get circularDiscardConfirm;

  /// Navigation label for Inbox tab
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// Accessibility label for Inbox navigation item with pending count
  ///
  /// In en, this message translates to:
  /// **'{label}, {formattedCount} waiting'**
  String navInboxCountSemantic(String label, String formattedCount);

  /// Workflow status label for quick-captured circulars in inbox
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get circularWorkflowInbox;

  /// Button label to open the quick capture circular dialog
  ///
  /// In en, this message translates to:
  /// **'Quick capture'**
  String get quickCaptureButton;

  /// Tooltip showing Quick capture action and keyboard shortcut
  ///
  /// In en, this message translates to:
  /// **'Quick capture ({shortcut})'**
  String quickCaptureShortcutTooltip(String shortcut);

  /// Title of quick capture glass dialog
  ///
  /// In en, this message translates to:
  /// **'Quick capture'**
  String get quickCaptureDialogTitle;

  /// Subtitle inside quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Paste a circular link now and fill in the rest later from your Inbox.'**
  String get quickCaptureDialogSubtitle;

  /// Label for required link field in quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Circular link'**
  String get quickCaptureLinkLabel;

  /// Placeholder hint for required link field in quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get quickCaptureLinkHint;

  /// Validation error when circular link is empty in quick capture
  ///
  /// In en, this message translates to:
  /// **'Please enter the circular link.'**
  String get quickCaptureLinkRequired;

  /// Label for optional title field in quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get quickCaptureTitleLabel;

  /// Placeholder hint for optional title field in quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Optional — uses website name if left blank'**
  String get quickCaptureTitleHint;

  /// Label for optional deadline field in quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Deadline (optional)'**
  String get quickCaptureDeadlineLabel;

  /// Primary submit button label inside quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Save to Inbox'**
  String get quickCaptureSaveAction;

  /// Loading button label inside quick capture dialog
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get quickCaptureSavingAction;

  /// Snackbar shown after saving a quick-captured circular
  ///
  /// In en, this message translates to:
  /// **'Saved \"{title}\" to Inbox.'**
  String quickCaptureSavedSnackbar(String title);

  /// Snackbar action navigating directly to the Inbox screen
  ///
  /// In en, this message translates to:
  /// **'View Inbox'**
  String get quickCaptureViewInboxAction;

  /// Heading of the Inbox triage screen
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxTitle;

  /// Subtitle displaying total quick-captured items in Inbox
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No quick-captured items waiting} =1{1 quick-captured item waiting} other{{formattedCount} quick-captured items waiting}}'**
  String inboxCount(int count, String formattedCount);

  /// Empty state heading when no circulars remain in Inbox
  ///
  /// In en, this message translates to:
  /// **'Your Inbox is clear'**
  String get inboxEmptyTitle;

  /// Empty state guidance explaining how to use Quick capture
  ///
  /// In en, this message translates to:
  /// **'Use Quick capture (or press Alt+Q on web) from any screen to drop a circular link here for later triage.'**
  String get inboxEmptyMessage;

  /// Metadata text showing when an item was quick-captured
  ///
  /// In en, this message translates to:
  /// **'Captured {formattedDate}'**
  String inboxCapturedOn(String formattedDate);

  /// Primary action opening full circular edit form from an Inbox item
  ///
  /// In en, this message translates to:
  /// **'Complete details'**
  String get inboxCompleteDetailsAction;

  /// Action dismissing an Inbox item to archive without deleting
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get inboxSkipAction;

  /// Action permanently deleting an Inbox item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get inboxDeleteAction;

  /// Tooltip for Inbox manual refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh inbox'**
  String get inboxRefreshTooltip;

  /// Feedback shown after skipping an Inbox circular
  ///
  /// In en, this message translates to:
  /// **'Moved \"{title}\" out of Inbox.'**
  String inboxActionSkipped(String title);

  /// Feedback shown after deleting an Inbox circular
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{title}\".'**
  String inboxActionDeleted(String title);

  /// Tooltip on back button in mobile/full-screen circular detail view
  ///
  /// In en, this message translates to:
  /// **'Back to circulars'**
  String get circularDetailBackTooltip;

  /// Tooltip on close button in desktop master-detail pane
  ///
  /// In en, this message translates to:
  /// **'Close details'**
  String get circularDetailCloseTooltip;

  /// Action opening the edit circular form from detail screen
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get circularDetailEditAction;

  /// Action deleting the circular from detail screen
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get circularDetailDeleteAction;

  /// Confirmation dialog title before deleting a circular
  ///
  /// In en, this message translates to:
  /// **'Delete this circular?'**
  String get circularDetailDeleteTitle;

  /// Confirmation dialog body before deleting a circular
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" and any scheduled exam dates will be removed permanently.'**
  String circularDetailDeleteMessage(String title);

  /// Subtle badge shown on circulars created through Quick Capture
  ///
  /// In en, this message translates to:
  /// **'Quick captured'**
  String get circularDetailQuickCaptureBadge;

  /// Error snackbar shown when launching an external circular link fails
  ///
  /// In en, this message translates to:
  /// **'Unable to open this link right now.'**
  String get circularDetailLaunchFailed;

  /// Section title for quick status selectors and application checklist
  ///
  /// In en, this message translates to:
  /// **'Quick status & checklist'**
  String get circularDetailQuickActionsTitle;

  /// Heading above application milestone checkboxes
  ///
  /// In en, this message translates to:
  /// **'Application checklist'**
  String get circularDetailChecklistTitle;

  /// Completion progress label above checklist progress bar
  ///
  /// In en, this message translates to:
  /// **'{formattedDone} of {formattedTotal} done'**
  String circularDetailChecklistProgress(
      String formattedDone, String formattedTotal);

  /// Checklist item for scanned/printed photo preparation
  ///
  /// In en, this message translates to:
  /// **'Photo prepared'**
  String get checklistPhoto;

  /// Checklist item for academic and supporting certificates
  ///
  /// In en, this message translates to:
  /// **'Certificates ready'**
  String get checklistCertificates;

  /// Checklist item for completing application fee payment
  ///
  /// In en, this message translates to:
  /// **'Fee paid'**
  String get checklistFeePaid;

  /// Checklist item for submitting the application form
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get checklistSubmitted;

  /// Checklist item for downloading the admit card
  ///
  /// In en, this message translates to:
  /// **'Admit card downloaded'**
  String get checklistAdmitCardDownloaded;

  /// Section title for external circular, application portal, and organization links
  ///
  /// In en, this message translates to:
  /// **'Official links'**
  String get circularDetailLinksTitle;

  /// Button opening the original circular announcement URL
  ///
  /// In en, this message translates to:
  /// **'Original circular link'**
  String get circularDetailOpenCircularLink;

  /// Button opening the online application portal URL
  ///
  /// In en, this message translates to:
  /// **'Application portal'**
  String get circularDetailOpenApplicationPortal;

  /// Button opening the recruiting organization's website URL
  ///
  /// In en, this message translates to:
  /// **'Organization website'**
  String get circularDetailOpenOrgWebsite;

  /// Subtitle shown when an optional external URL is empty
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get circularDetailLinkMissing;

  /// Section title for circular metadata, dates, salary, and fee fields
  ///
  /// In en, this message translates to:
  /// **'Overview & compensation'**
  String get circularDetailOverviewTitle;

  /// Overview label for application deadline
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get circularDetailFieldDeadline;

  /// Overview label for advertised vacancy count
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get circularDetailFieldVacancies;

  /// Overview label for salary minimum/maximum
  ///
  /// In en, this message translates to:
  /// **'Salary range'**
  String get circularDetailFieldSalary;

  /// Overview label for pay scale benefits note
  ///
  /// In en, this message translates to:
  /// **'Salary note'**
  String get circularDetailFieldSalaryNote;

  /// Overview label for application fee amount
  ///
  /// In en, this message translates to:
  /// **'Application fee'**
  String get circularDetailFieldFee;

  /// Overview label for application fee exemption or payment note
  ///
  /// In en, this message translates to:
  /// **'Fee note'**
  String get circularDetailFieldFeeNote;

  /// Overview label for creation date
  ///
  /// In en, this message translates to:
  /// **'Added on'**
  String get circularDetailFieldCreated;

  /// Overview label for last update date
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get circularDetailFieldUpdated;

  /// Placeholder text when an optional field has no value
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get circularDetailNotProvided;

  /// Formatted salary range between minimum and maximum
  ///
  /// In en, this message translates to:
  /// **'{min} - {max}'**
  String circularDetailSalaryRange(String min, String max);

  /// Formatted salary when only minimum is specified
  ///
  /// In en, this message translates to:
  /// **'From {min}'**
  String circularDetailSalaryFrom(String min);

  /// Formatted salary when only maximum is specified
  ///
  /// In en, this message translates to:
  /// **'Up to {max}'**
  String circularDetailSalaryUpTo(String max);

  /// Section heading for scheduled exam dates
  ///
  /// In en, this message translates to:
  /// **'Exam dates'**
  String get circularDetailExamDatesTitle;

  /// Button opening the add exam date dialog
  ///
  /// In en, this message translates to:
  /// **'Add exam date'**
  String get examDateAddAction;

  /// Subheading above future or today's exam dates ordered chronologically
  ///
  /// In en, this message translates to:
  /// **'Upcoming exams'**
  String get examDateUpcomingHeading;

  /// Subheading above completed or past exam dates
  ///
  /// In en, this message translates to:
  /// **'Past exams'**
  String get examDatePastHeading;

  /// Empty state copy inside Exam Dates section
  ///
  /// In en, this message translates to:
  /// **'No exam dates added yet. Track preliminary, written, viva, or practical stages here.'**
  String get examDateEmptyMessage;

  /// Field label for exam stage dropdown
  ///
  /// In en, this message translates to:
  /// **'Exam stage'**
  String get examDateStageLabel;

  /// Preliminary exam stage label
  ///
  /// In en, this message translates to:
  /// **'Preliminary'**
  String get examDateStagePreliminary;

  /// Written exam stage label
  ///
  /// In en, this message translates to:
  /// **'Written'**
  String get examDateStageWritten;

  /// Viva / oral interview stage label
  ///
  /// In en, this message translates to:
  /// **'Viva'**
  String get examDateStageViva;

  /// Practical skill test stage label
  ///
  /// In en, this message translates to:
  /// **'Practical'**
  String get examDateStagePractical;

  /// Other exam stage label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get examDateStageOther;

  /// Label for scheduled date and time picker controls
  ///
  /// In en, this message translates to:
  /// **'Exam date & time'**
  String get examDateDateLabel;

  /// Button changing the scheduled exam date
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get examDatePickDateAction;

  /// Button changing the scheduled exam time
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get examDatePickTimeAction;

  /// Input label for exam venue
  ///
  /// In en, this message translates to:
  /// **'Venue (optional)'**
  String get examDateVenueLabel;

  /// Input hint for exam venue
  ///
  /// In en, this message translates to:
  /// **'e.g. Dhaka College / BPSC HQ'**
  String get examDateVenueHint;

  /// Input label for exam stage notes
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get examDateNotesLabel;

  /// Input hint for exam stage notes
  ///
  /// In en, this message translates to:
  /// **'Reporting time, seat plan, documents...'**
  String get examDateNotesHint;

  /// Dialog heading when creating an exam date
  ///
  /// In en, this message translates to:
  /// **'Add exam date'**
  String get examDateDialogAddTitle;

  /// Dialog heading when editing an existing exam date
  ///
  /// In en, this message translates to:
  /// **'Edit exam date'**
  String get examDateDialogEditTitle;

  /// Tooltip on edit exam date button
  ///
  /// In en, this message translates to:
  /// **'Edit exam date'**
  String get examDateEditTooltip;

  /// Tooltip on delete exam date button
  ///
  /// In en, this message translates to:
  /// **'Delete exam date'**
  String get examDateDeleteTooltip;

  /// Section title for circular instructions, personal notes, and syllabus
  ///
  /// In en, this message translates to:
  /// **'Instructions, notes & syllabus'**
  String get circularDetailNotesTitle;

  /// Section title for circular attachments and uploaded files
  ///
  /// In en, this message translates to:
  /// **'Files & attachments'**
  String get circularFilesTitle;

  /// Helper showing allowed attachment types and maximum file size
  ///
  /// In en, this message translates to:
  /// **'PDF, PNG, JPG, WEBP • Max {maxSize} (large images are resized)'**
  String circularFilesAllowedHelper(String maxSize);

  /// Button label to pick and upload a circular attachment
  ///
  /// In en, this message translates to:
  /// **'Upload file'**
  String get circularFilesUploadButton;

  /// Progress text while uploading an attachment
  ///
  /// In en, this message translates to:
  /// **'Uploading {fileName} ({percent}%)'**
  String circularFilesUploading(String fileName, String percent);

  /// Empty state copy when a circular has no uploaded attachments
  ///
  /// In en, this message translates to:
  /// **'No files attached yet. Upload a circular PDF, admit card, or image.'**
  String get circularFilesEmpty;

  /// Error message when circular attachments fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load attachments right now.'**
  String get circularFilesLoadError;

  /// Retry button label in attachments section
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get circularFilesRetry;

  /// Action label and tooltip to preview an attached file
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get circularFilesPreviewAction;

  /// Action label and tooltip to download an attached file
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get circularFilesDownloadAction;

  /// Action label and tooltip to delete an attached file
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get circularFilesDeleteAction;

  /// Title of the file preview dialog
  ///
  /// In en, this message translates to:
  /// **'File preview'**
  String get circularFilesPreviewTitle;

  /// Explanation shown when previewing a PDF attachment via signed URL
  ///
  /// In en, this message translates to:
  /// **'PDF files open with a temporary signed link in your browser or PDF viewer.'**
  String get circularFilesPreviewPdfMessage;

  /// Button label to open the signed URL externally
  ///
  /// In en, this message translates to:
  /// **'Open signed link'**
  String get circularFilesOpenSignedLink;

  /// Fallback message when an image preview cannot be rendered inline
  ///
  /// In en, this message translates to:
  /// **'Could not display preview inline. Open the temporary signed link instead.'**
  String get circularFilesPreviewLoadError;

  /// Button label to close the file preview dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get circularFilesCloseAction;

  /// Security note reminding that files use temporary signed URLs
  ///
  /// In en, this message translates to:
  /// **'Protected with a temporary signed URL (never public).'**
  String get circularFilesSignedUrlSecurityNote;

  /// Confirmation dialog title when deleting an attachment
  ///
  /// In en, this message translates to:
  /// **'Delete attachment?'**
  String get circularFilesDeleteConfirmTitle;

  /// Confirmation dialog body before deleting a file
  ///
  /// In en, this message translates to:
  /// **'Remove \"{fileName}\" permanently from this circular?'**
  String circularFilesDeleteConfirmBody(String fileName);

  /// Cancel button label in delete attachment confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get circularFilesCancelAction;

  /// Confirm delete button label in delete attachment confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get circularFilesConfirmDeleteAction;

  /// Validation error when an unsupported file extension or MIME type is chosen
  ///
  /// In en, this message translates to:
  /// **'Only PDF, PNG, JPG, JPEG, and WEBP files are supported.'**
  String get circularFilesErrorUnsupportedType;

  /// Validation error when a zero-byte file is selected
  ///
  /// In en, this message translates to:
  /// **'The selected file is empty.'**
  String get circularFilesErrorEmptyFile;

  /// Validation error when a file exceeds the allowed upload size limit
  ///
  /// In en, this message translates to:
  /// **'File exceeds the {maxSize} limit.'**
  String circularFilesErrorFileTooLarge(String maxSize);

  /// Validation error when a raw image exceeds the pre-resize safety limit
  ///
  /// In en, this message translates to:
  /// **'Image is too large to process (max {maxSize}).'**
  String circularFilesErrorRawImageTooLarge(String maxSize);

  /// Error shown when launching a signed file URL fails
  ///
  /// In en, this message translates to:
  /// **'Could not open the signed file link.'**
  String get circularFilesErrorOpenLinkFailed;

  /// Formatted file size in bytes
  ///
  /// In en, this message translates to:
  /// **'{count} B'**
  String circularFilesSizeBytes(String count);

  /// Formatted file size in kilobytes
  ///
  /// In en, this message translates to:
  /// **'{count} KB'**
  String circularFilesSizeKb(String count);

  /// Formatted file size in megabytes
  ///
  /// In en, this message translates to:
  /// **'{count} MB'**
  String circularFilesSizeMb(String count);

  /// Pluralized count of attached files
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 files} =1{1 file} other{{formattedCount} files}}'**
  String circularFilesCount(int count, String formattedCount);

  /// Badge label for PDF file
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get circularFilesTypePdf;

  /// Badge label for image file
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get circularFilesTypeImage;

  /// Tooltip for navigating to the previous month on calendar
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonthTooltip;

  /// Tooltip for navigating to the next month on calendar
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonthTooltip;

  /// Button label jumping calendar selection to today's date
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarTodayButton;

  /// Legend and badge label for application deadline events
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get calendarEventDeadline;

  /// Legend and badge label for preliminary exam events
  ///
  /// In en, this message translates to:
  /// **'Preliminary'**
  String get calendarEventPreliminary;

  /// Legend and badge label for written exam events
  ///
  /// In en, this message translates to:
  /// **'Written'**
  String get calendarEventWritten;

  /// Legend and badge label for viva exam events
  ///
  /// In en, this message translates to:
  /// **'Viva'**
  String get calendarEventViva;

  /// Legend and badge label for practical exam events
  ///
  /// In en, this message translates to:
  /// **'Practical'**
  String get calendarEventPractical;

  /// Legend and badge label for other exam events
  ///
  /// In en, this message translates to:
  /// **'Other exam'**
  String get calendarEventOther;

  /// Heading for calendar event color legend
  ///
  /// In en, this message translates to:
  /// **'Color legend'**
  String get calendarLegendTitle;

  /// Pluralized count of calendar events for the selected day
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events} =1{1 event} other{{formattedCount} events}}'**
  String calendarAgendaCount(int count, String formattedCount);

  /// Empty state copy when selected day has no scheduled calendar events
  ///
  /// In en, this message translates to:
  /// **'No deadlines or exam dates on this day.'**
  String get calendarAgendaEmptyDay;

  /// Subtle guidance shown when the displayed month has no scheduled events
  ///
  /// In en, this message translates to:
  /// **'Add deadlines or exam dates to your circulars to track them on this calendar.'**
  String get calendarEmptyMonthHint;

  /// Error banner message when circulars fail to load on Calendar screen
  ///
  /// In en, this message translates to:
  /// **'Could not load your schedule right now.'**
  String get calendarLoadError;

  /// Retry button label on Calendar screen
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get calendarRetry;

  /// Accessible action hint on calendar agenda tiles
  ///
  /// In en, this message translates to:
  /// **'Open circular'**
  String get calendarOpenCircularAction;

  /// Overflow indicator count when a calendar day has additional events
  ///
  /// In en, this message translates to:
  /// **'+{formattedCount}'**
  String calendarMoreEvents(String formattedCount);

  /// Helper showing the locale-determined starting day of week
  ///
  /// In en, this message translates to:
  /// **'Week starts on {dayName}'**
  String calendarWeekStartsNote(String dayName);

  /// Header for the subjects list in Preparation manager
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get prepSubjectsSectionTitle;

  /// Label above overall preparation progress ring and summary
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get prepOverallProgressLabel;

  /// Pluralized count of subjects
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No subjects} =1{1 subject} other{{formattedCount} subjects}}'**
  String prepSubjectCount(int count, String formattedCount);

  /// Pluralized count of materials
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No materials} =1{1 material} other{{formattedCount} materials}}'**
  String prepMaterialCount(int count, String formattedCount);

  /// Primary button label to create a new subject
  ///
  /// In en, this message translates to:
  /// **'Add subject'**
  String get prepAddSubjectButton;

  /// Primary button label to add a study material to a subject
  ///
  /// In en, this message translates to:
  /// **'Add material'**
  String get prepAddMaterialButton;

  /// Tooltip for refreshing prep data
  ///
  /// In en, this message translates to:
  /// **'Refresh subjects and materials'**
  String get prepRefreshTooltip;

  /// Error banner when loading prep subjects fails
  ///
  /// In en, this message translates to:
  /// **'Could not load preparation subjects right now.'**
  String get prepLoadError;

  /// Desktop detail pane prompt when no subject is selected
  ///
  /// In en, this message translates to:
  /// **'Select a subject from the list to view and manage its study materials.'**
  String get prepSelectSubjectPrompt;

  /// Empty state title when the user has created zero subjects
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get prepEmptySubjectsTitle;

  /// Empty state body explaining user-defined subjects
  ///
  /// In en, this message translates to:
  /// **'Create subjects for your target career or exam track, then add books, courses, notes, or question banks inside each.'**
  String get prepEmptySubjectsBody;

  /// Empty state title inside a subject with zero materials
  ///
  /// In en, this message translates to:
  /// **'No materials in {subjectName}'**
  String prepEmptyMaterialsTitle(String subjectName);

  /// Empty state body explaining user-defined materials
  ///
  /// In en, this message translates to:
  /// **'Add books, lecture sheets, video courses, or mock tests with any unit label you prefer.'**
  String get prepEmptyMaterialsBody;

  /// Back action label on mobile subject detail screen
  ///
  /// In en, this message translates to:
  /// **'Back to subjects'**
  String get prepBackToSubjects;

  /// Dialog title for creating a new subject
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get prepCreateSubjectTitle;

  /// Dialog title for editing an existing subject
  ///
  /// In en, this message translates to:
  /// **'Edit subject'**
  String get prepEditSubjectTitle;

  /// Input label for subject name
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get prepSubjectNameLabel;

  /// Hint showing career-agnostic subject names
  ///
  /// In en, this message translates to:
  /// **'e.g. English Grammar, Anatomy, Data Structures'**
  String get prepSubjectNameHint;

  /// Validation error when subject name is blank
  ///
  /// In en, this message translates to:
  /// **'Subject name is required.'**
  String get prepSubjectNameRequired;

  /// Input label for user-defined exam or career track
  ///
  /// In en, this message translates to:
  /// **'Exam or career track'**
  String get prepExamTypeLabel;

  /// Hint for free-form exam type field
  ///
  /// In en, this message translates to:
  /// **'Type any track or pick a suggestion below'**
  String get prepExamTypeHint;

  /// Validation error when exam type is blank
  ///
  /// In en, this message translates to:
  /// **'Exam or career track is required.'**
  String get prepExamTypeRequired;

  /// Quick suggestion chip for general preparation
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get prepExamTrackGeneral;

  /// Quick suggestion chip for BCS
  ///
  /// In en, this message translates to:
  /// **'BCS'**
  String get prepExamTrackBcs;

  /// Quick suggestion chip for bank recruitment
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get prepExamTrackBank;

  /// Quick suggestion chip for government jobs
  ///
  /// In en, this message translates to:
  /// **'Govt Job'**
  String get prepExamTrackGovt;

  /// Quick suggestion chip for medical track
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get prepExamTrackMedical;

  /// Quick suggestion chip for engineering track
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get prepExamTrackEngineering;

  /// Quick suggestion chip for IELTS
  ///
  /// In en, this message translates to:
  /// **'IELTS'**
  String get prepExamTrackIelts;

  /// Section label for picking subject color
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get prepSubjectColorLabel;

  /// Accessible label for gold subject color
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get prepColorGold;

  /// Accessible label for sky blue subject color
  ///
  /// In en, this message translates to:
  /// **'Sky Blue'**
  String get prepColorInfo;

  /// Accessible label for emerald subject color
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get prepColorSuccess;

  /// Accessible label for amber subject color
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get prepColorWarning;

  /// Accessible label for red subject color
  ///
  /// In en, this message translates to:
  /// **'Coral Red'**
  String get prepColorDanger;

  /// Accessible label for violet subject color
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get prepColorAccentSecondary;

  /// Section label for picking subject icon
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get prepSubjectIconLabel;

  /// Label for book icon option
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get prepIconMenuBook;

  /// Label for math icon option
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get prepIconCalculate;

  /// Label for language icon option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get prepIconLanguage;

  /// Label for global studies icon option
  ///
  /// In en, this message translates to:
  /// **'Global / GK'**
  String get prepIconPublic;

  /// Label for science icon option
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get prepIconScience;

  /// Label for computing icon option
  ///
  /// In en, this message translates to:
  /// **'Computing'**
  String get prepIconComputer;

  /// Label for finance and governance icon option
  ///
  /// In en, this message translates to:
  /// **'Finance / Law'**
  String get prepIconAccountBalance;

  /// Label for mental ability icon option
  ///
  /// In en, this message translates to:
  /// **'Aptitude'**
  String get prepIconPsychology;

  /// Label for law/constitution icon option
  ///
  /// In en, this message translates to:
  /// **'Constitution'**
  String get prepIconGavel;

  /// Label for quiz/practice icon option
  ///
  /// In en, this message translates to:
  /// **'Quiz / Mock'**
  String get prepIconQuiz;

  /// Save action label in prep dialogs
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get prepSaveButton;

  /// Cancel action label in prep dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get prepCancelButton;

  /// Edit tooltip or button label in prep manager
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get prepEditAction;

  /// Delete tooltip or button label in prep manager
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get prepDeleteAction;

  /// Tooltip for moving a subject higher in order
  ///
  /// In en, this message translates to:
  /// **'Move subject up'**
  String get prepMoveUpTooltip;

  /// Tooltip for moving a subject lower in order
  ///
  /// In en, this message translates to:
  /// **'Move subject down'**
  String get prepMoveDownTooltip;

  /// Tooltip for drag reorder handle on subject rows
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get prepDragReorderTooltip;

  /// Dialog title for creating a new study material
  ///
  /// In en, this message translates to:
  /// **'New material'**
  String get prepCreateMaterialTitle;

  /// Dialog title for editing a study material
  ///
  /// In en, this message translates to:
  /// **'Edit material'**
  String get prepEditMaterialTitle;

  /// Input label for material title
  ///
  /// In en, this message translates to:
  /// **'Material title'**
  String get prepMaterialTitleLabel;

  /// Hint showing example material titles
  ///
  /// In en, this message translates to:
  /// **'e.g. Official Guide, Clinical Handbook, System Design'**
  String get prepMaterialTitleHint;

  /// Validation error when material title is blank
  ///
  /// In en, this message translates to:
  /// **'Material title is required.'**
  String get prepMaterialTitleRequired;

  /// Section label for material kind selector
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get prepMaterialKindLabel;

  /// Material kind label for Book
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get prepMaterialKindBook;

  /// Material kind label for Video course
  ///
  /// In en, this message translates to:
  /// **'Video course'**
  String get prepMaterialKindVideoCourse;

  /// Material kind label for Lecture sheet
  ///
  /// In en, this message translates to:
  /// **'Lecture sheet'**
  String get prepMaterialKindLectureSheet;

  /// Material kind label for Question bank
  ///
  /// In en, this message translates to:
  /// **'Question bank'**
  String get prepMaterialKindQuestionBank;

  /// Material kind label for Notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get prepMaterialKindNotes;

  /// Material kind label for Mock test
  ///
  /// In en, this message translates to:
  /// **'Mock test'**
  String get prepMaterialKindMockTest;

  /// Material kind label for Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get prepMaterialKindOther;

  /// Input label for material unit label
  ///
  /// In en, this message translates to:
  /// **'Unit label'**
  String get prepUnitLabelFieldLabel;

  /// Hint for free-form unit label input
  ///
  /// In en, this message translates to:
  /// **'e.g. pages, lectures, chapters, sets'**
  String get prepUnitLabelHint;

  /// Validation error when unit label is blank
  ///
  /// In en, this message translates to:
  /// **'Unit label is required.'**
  String get prepUnitLabelRequired;

  /// Quick preset chip for pages
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get prepUnitPresetPages;

  /// Quick preset chip for chapters
  ///
  /// In en, this message translates to:
  /// **'chapters'**
  String get prepUnitPresetChapters;

  /// Quick preset chip for lectures
  ///
  /// In en, this message translates to:
  /// **'lectures'**
  String get prepUnitPresetLectures;

  /// Quick preset chip for videos
  ///
  /// In en, this message translates to:
  /// **'videos'**
  String get prepUnitPresetVideos;

  /// Quick preset chip for questions
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get prepUnitPresetQuestions;

  /// Quick preset chip for tests
  ///
  /// In en, this message translates to:
  /// **'tests'**
  String get prepUnitPresetTests;

  /// Input label for total unit count
  ///
  /// In en, this message translates to:
  /// **'Total units'**
  String get prepTotalUnitsLabel;

  /// Hint for total units numeric input
  ///
  /// In en, this message translates to:
  /// **'e.g. 300'**
  String get prepTotalUnitsHint;

  /// Validation error when total units is invalid or negative
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number greater than or equal to 0.'**
  String get prepTotalUnitsInvalid;

  /// Completed over total units display for a study material
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} {unitLabel}'**
  String prepMaterialProgressSummary(
      String completed, String total, String unitLabel);

  /// Percentage completion label
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String prepPercentComplete(String percent);

  /// Section header for cover upload or image link
  ///
  /// In en, this message translates to:
  /// **'Cover image (optional)'**
  String get prepCoverSectionLabel;

  /// Cover mode toggle indicating no cover image
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get prepCoverModeNone;

  /// Cover mode toggle to upload a photo file
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get prepCoverModeUpload;

  /// Cover mode toggle to paste an external image link
  ///
  /// In en, this message translates to:
  /// **'Paste link'**
  String get prepCoverModeUrl;

  /// Button to open file picker for cover image
  ///
  /// In en, this message translates to:
  /// **'Choose JPG, PNG or WEBP'**
  String get prepCoverPickButton;

  /// Button to choose a replacement cover photo
  ///
  /// In en, this message translates to:
  /// **'Replace photo'**
  String get prepCoverReplaceButton;

  /// Button to remove current cover photo
  ///
  /// In en, this message translates to:
  /// **'Remove cover'**
  String get prepCoverRemoveButton;

  /// Note shown when selected image was scaled to max ~600 px width
  ///
  /// In en, this message translates to:
  /// **'Resized to {formattedWidth} px wide for upload.'**
  String prepCoverResizedNote(String formattedWidth);

  /// Text field label for pasting an external image URL
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get prepCoverUrlLabel;

  /// Placeholder hint for cover image URL
  ///
  /// In en, this message translates to:
  /// **'https://example.com/cover.jpg'**
  String get prepCoverUrlHint;

  /// Helper explaining glass placeholder when no cover is chosen
  ///
  /// In en, this message translates to:
  /// **'Without a cover image, a glass initial badge is displayed automatically.'**
  String get prepCoverPlaceholderHint;

  /// Validation error for unsupported cover image file types
  ///
  /// In en, this message translates to:
  /// **'Only JPG, PNG, and WEBP images are supported.'**
  String get prepCoverErrorUnsupportedType;

  /// Validation error when selected cover file has zero bytes
  ///
  /// In en, this message translates to:
  /// **'The selected cover image is empty.'**
  String get prepCoverErrorEmptyFile;

  /// Validation error when cover exceeds upload size limit
  ///
  /// In en, this message translates to:
  /// **'Cover image exceeds the {maxSize} limit.'**
  String prepCoverErrorTooLarge(String maxSize);

  /// Validation error when raw image before resize exceeds memory cap
  ///
  /// In en, this message translates to:
  /// **'Image is too large to process (max {maxSize}).'**
  String prepCoverErrorRawTooLarge(String maxSize);

  /// Validation error for malformed cover image URL
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http:// or https:// image URL.'**
  String get prepCoverErrorInvalidUrl;

  /// Status message while resizing and uploading cover photo
  ///
  /// In en, this message translates to:
  /// **'Resizing and uploading cover...'**
  String get prepCoverUploadProgress;

  /// Confirmation dialog title when deleting a subject
  ///
  /// In en, this message translates to:
  /// **'Delete \"{subjectName}\"?'**
  String prepDeleteSubjectTitle(String subjectName);

  /// Confirmation body for deleting a subject
  ///
  /// In en, this message translates to:
  /// **'This will remove the subject and all materials inside it.'**
  String get prepDeleteSubjectBody;

  /// Warning displayed before deleting a subject that has logged progress
  ///
  /// In en, this message translates to:
  /// **'Warning: this subject has logged progress ({formattedUnits} completed units across materials). Deleting it will permanently remove that progress.'**
  String prepDeleteSubjectProgressWarning(String formattedUnits);

  /// Confirmation dialog title when deleting a material
  ///
  /// In en, this message translates to:
  /// **'Delete \"{materialTitle}\"?'**
  String prepDeleteMaterialTitle(String materialTitle);

  /// Confirmation body for deleting a material
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this material from the subject?'**
  String get prepDeleteMaterialBody;

  /// Warning displayed before deleting a material that has logged progress
  ///
  /// In en, this message translates to:
  /// **'Warning: you have already logged {formattedCompleted} of {formattedTotal} {unitLabel} ({percent}% complete). Deleting this material will also remove its logged progress.'**
  String prepDeleteMaterialProgressWarning(String formattedCompleted,
      String formattedTotal, String unitLabel, String percent);

  /// Confirm button label in delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get prepDeleteConfirmButton;

  /// Error banner for PrepPermissionFailure
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update this preparation item.'**
  String get prepErrorPermission;

  /// Error banner for PrepNetworkFailure
  ///
  /// In en, this message translates to:
  /// **'Network issue while saving. Please try again.'**
  String get prepErrorNetwork;

  /// Error banner for PrepNotFoundFailure
  ///
  /// In en, this message translates to:
  /// **'That preparation item could not be found.'**
  String get prepErrorNotFound;

  /// Fallback error banner for prep errors
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while updating preparation data.'**
  String get prepErrorUnknown;

  /// Total completed over planned units across all prep materials
  ///
  /// In en, this message translates to:
  /// **'{formattedCompleted} / {formattedTotal} total units'**
  String prepOverallUnitsSummary(
      String formattedCompleted, String formattedTotal);

  /// Quick log button label for fixed increment like +10, +20, +50
  ///
  /// In en, this message translates to:
  /// **'+{formattedAmount}'**
  String prepQuickLogPlus(String formattedAmount);

  /// Button opening custom study log and history dialog for a material
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get prepLogButton;

  /// Dialog header for logging or managing study progress logs
  ///
  /// In en, this message translates to:
  /// **'Log progress'**
  String get prepLogDialogTitle;

  /// Numeric field label for custom progress log units
  ///
  /// In en, this message translates to:
  /// **'Units completed'**
  String get prepCustomUnitsLabel;

  /// Hint for custom progress log units
  ///
  /// In en, this message translates to:
  /// **'e.g. 25'**
  String get prepCustomUnitsHint;

  /// Validation error when custom log units is not positive
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number greater than 0.'**
  String get prepCustomUnitsInvalid;

  /// Date selector label inside progress log dialog
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get prepLogDateLabel;

  /// Optional note text field label inside progress log dialog
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get prepLogNoteLabel;

  /// Hint for optional study session note
  ///
  /// In en, this message translates to:
  /// **'e.g. Chapters 1-3, revision set'**
  String get prepLogNoteHint;

  /// Primary submit button to add a new progress log
  ///
  /// In en, this message translates to:
  /// **'Save log'**
  String get prepLogSaveButton;

  /// Primary submit button when editing an existing progress log
  ///
  /// In en, this message translates to:
  /// **'Update log'**
  String get prepLogUpdateButton;

  /// Cancels editing an existing progress log
  ///
  /// In en, this message translates to:
  /// **'Cancel edit'**
  String get prepLogCancelEditButton;

  /// Banner indicating the log form is currently editing a past log
  ///
  /// In en, this message translates to:
  /// **'Editing existing log entry'**
  String get prepEditingLogBanner;

  /// Section title above past logs list for a material
  ///
  /// In en, this message translates to:
  /// **'Past study logs'**
  String get prepPastLogsTitle;

  /// Empty message when a material has zero logged study entries
  ///
  /// In en, this message translates to:
  /// **'No study logs recorded for this material yet.'**
  String get prepNoPastLogs;

  /// Displayed unit delta inside a past log tile
  ///
  /// In en, this message translates to:
  /// **'+{formattedUnits} {unitLabel}'**
  String prepLogUnitsSummary(String formattedUnits, String unitLabel);

  /// Header inside empty prep state offering starter templates
  ///
  /// In en, this message translates to:
  /// **'Start quickly with a template'**
  String get prepTemplatesTitle;

  /// Subtitle explaining starter prep templates
  ///
  /// In en, this message translates to:
  /// **'Apply a preset study plan you can freely customize, reorder, or delete anytime.'**
  String get prepTemplatesSubtitle;

  /// Button label on each starter template card
  ///
  /// In en, this message translates to:
  /// **'Apply template'**
  String get prepApplyTemplateButton;

  /// Header button label opening starter and personal templates
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get prepTemplatesOpenButton;

  /// Dialog heading listing starter packs and personal templates
  ///
  /// In en, this message translates to:
  /// **'Study Templates'**
  String get prepTemplatesDialogTitle;

  /// Section heading for seeded read-only template packs
  ///
  /// In en, this message translates to:
  /// **'Starter packs'**
  String get prepTemplatesSystemSection;

  /// Section heading for user-saved reusable templates
  ///
  /// In en, this message translates to:
  /// **'Your personal templates'**
  String get prepTemplatesPersonalSection;

  /// Empty guidance text when user has not saved any personal templates
  ///
  /// In en, this message translates to:
  /// **'Save your current subjects as a personal template so you can reuse or share your plan anytime.'**
  String get prepTemplatesPersonalEmpty;

  /// Badge identifying a read-only system starter pack
  ///
  /// In en, this message translates to:
  /// **'Starter pack'**
  String get prepTemplateSystemBadge;

  /// Badge identifying a user-created personal template
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get prepTemplatePersonalBadge;

  /// Badge shown when all subjects and materials of a template already exist
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get prepTemplateAppliedBadge;

  /// Button opening preview dialog where users adjust template unit counts before copying
  ///
  /// In en, this message translates to:
  /// **'Edit units'**
  String get prepTemplateCustomizeButton;

  /// Button label when template items are already in user plan
  ///
  /// In en, this message translates to:
  /// **'Re-apply'**
  String get prepTemplateApplyAgainButton;

  /// Title of preview modal allowing unit customization before applying template
  ///
  /// In en, this message translates to:
  /// **'Customize & apply \"{title}\"'**
  String prepTemplateApplyConfirmTitle(String title);

  /// Subtitle explaining unit adjustments and post-copy editability
  ///
  /// In en, this message translates to:
  /// **'Adjust unit counts below before copying into your own prep subjects. Everything remains fully editable afterward.'**
  String get prepTemplateApplyConfirmSubtitle;

  /// Primary confirm button inside template customize dialog
  ///
  /// In en, this message translates to:
  /// **'Copy to my prep plan'**
  String get prepTemplateConfirmApplyAction;

  /// Snackbar confirmation showing count of copied subjects and materials
  ///
  /// In en, this message translates to:
  /// **'Copied {subjectCount, plural, =0{0 subjects} =1{1 subject} other{{formattedSubjects} subjects}} and {materialCount, plural, =0{0 materials} =1{1 material} other{{formattedMaterials} materials}} from \"{title}\".'**
  String prepTemplateAppliedSnackbar(int subjectCount, String formattedSubjects,
      int materialCount, String formattedMaterials, String title);

  /// Snackbar message when applying a template that is already present
  ///
  /// In en, this message translates to:
  /// **'All subjects and materials from \"{title}\" are already in your plan (no duplicates created).'**
  String prepTemplateAlreadyAppliedSnackbar(String title);

  /// Button label opening dialog to save current subjects as a personal template
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get prepSaveAsTemplateButton;

  /// Heading of dialog for saving current user subjects as a template
  ///
  /// In en, this message translates to:
  /// **'Save personal template'**
  String get prepSaveTemplateDialogTitle;

  /// Text field label for personal template name
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get prepSaveTemplateTitleLabel;

  /// Hint text for personal template name field
  ///
  /// In en, this message translates to:
  /// **'e.g. 48th BCS Core Plan'**
  String get prepSaveTemplateTitleHint;

  /// Validation error when personal template title is blank
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name.'**
  String get prepSaveTemplateTitleRequired;

  /// Text field label for optional template description
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get prepSaveTemplateDescLabel;

  /// Hint text for optional personal template description
  ///
  /// In en, this message translates to:
  /// **'Short summary of subjects and target role'**
  String get prepSaveTemplateDescHint;

  /// Text field label for personal template career/exam track
  ///
  /// In en, this message translates to:
  /// **'Career or exam track'**
  String get prepSaveTemplateExamLabel;

  /// Summary inside save-personal-template dialog showing snapshot size
  ///
  /// In en, this message translates to:
  /// **'Copies {formattedSubjects} subjects and {formattedMaterials} materials into this reusable template'**
  String prepSaveTemplatePreviewSummary(
      String formattedSubjects, String formattedMaterials);

  /// Primary button saving a personal prep template
  ///
  /// In en, this message translates to:
  /// **'Save template'**
  String get prepSaveTemplateSaveAction;

  /// Snackbar shown after saving a personal template
  ///
  /// In en, this message translates to:
  /// **'Saved personal template \"{title}\".'**
  String prepSaveTemplateSavedSnackbar(String title);

  /// Confirmation dialog heading before deleting a personal template
  ///
  /// In en, this message translates to:
  /// **'Delete personal template?'**
  String get prepDeleteTemplateTitle;

  /// Confirmation message before deleting a personal template
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? Any subjects and materials already copied into your prep dashboard stay untouched.'**
  String prepDeleteTemplateMessage(String title);

  /// Snackbar shown after deleting a personal template
  ///
  /// In en, this message translates to:
  /// **'Deleted personal template \"{title}\".'**
  String prepDeleteTemplateDeletedSnackbar(String title);

  /// Validation error inside template customization dialog for invalid unit count
  ///
  /// In en, this message translates to:
  /// **'Enter zero or a positive whole number.'**
  String get prepTemplateUnitsInvalid;

  /// Localized title for seeded Government Job pack
  ///
  /// In en, this message translates to:
  /// **'Government Job'**
  String get prepSeededGovJobTitle;

  /// Localized summary for seeded Government Job pack
  ///
  /// In en, this message translates to:
  /// **'Bengali, English, General Knowledge, Mathematics, Analytical Reasoning, and Computer with customizable materials.'**
  String get prepSeededGovJobSubtitle;

  /// Localized title for seeded Software Engineer pack
  ///
  /// In en, this message translates to:
  /// **'Software Engineer'**
  String get prepSeededSweTitle;

  /// Localized summary for seeded Software Engineer pack
  ///
  /// In en, this message translates to:
  /// **'Data Structures & Algorithms, Database Systems, OOP, Web Development, and Software Quality Assurance.'**
  String get prepSeededSweSubtitle;

  /// Subtitle on the Phase 5A home dashboard header
  ///
  /// In en, this message translates to:
  /// **'Your job circulars, upcoming dates, and study momentum at a glance.'**
  String get dashboardHomeSubtitle;

  /// Tooltip for manual refresh icon on home dashboard
  ///
  /// In en, this message translates to:
  /// **'Refresh dashboard'**
  String get dashboardRefreshTooltip;

  /// Error banner message when dashboard queries fail
  ///
  /// In en, this message translates to:
  /// **'Could not load dashboard summary.'**
  String get dashboardLoadError;

  /// Onboarding card title shown to new users with no data yet
  ///
  /// In en, this message translates to:
  /// **'Welcome to JobPrep'**
  String get dashboardWelcomeTitle;

  /// Onboarding card body shown to new users with no data yet
  ///
  /// In en, this message translates to:
  /// **'Track job circulars, checklists, exam dates, and study progress in one calm workspace.'**
  String get dashboardWelcomeBody;

  /// CTA button in new-user welcome card to create a circular
  ///
  /// In en, this message translates to:
  /// **'Add first circular'**
  String get dashboardWelcomeAddCircular;

  /// CTA button in new-user welcome card to open Prep screen
  ///
  /// In en, this message translates to:
  /// **'Set up study plan'**
  String get dashboardWelcomeSetupPrep;

  /// Metric card label counting deadlines in the next 7 days
  ///
  /// In en, this message translates to:
  /// **'Deadlines this week'**
  String get dashboardMetricDeadlinesWeek;

  /// Metric card label counting quick-captured inbox circulars
  ///
  /// In en, this message translates to:
  /// **'Inbox items'**
  String get dashboardMetricInbox;

  /// Metric card label counting exam dates in the next 14 days
  ///
  /// In en, this message translates to:
  /// **'Exams in 14 days'**
  String get dashboardMetricExams14Days;

  /// Metric card label counting submitted circular applications
  ///
  /// In en, this message translates to:
  /// **'Applications submitted'**
  String get dashboardMetricSubmitted;

  /// Metric card label for animated overall preparation progress ring
  ///
  /// In en, this message translates to:
  /// **'Overall prep'**
  String get dashboardMetricOverallPrep;

  /// Section card heading for the most recently logged study material shortcut
  ///
  /// In en, this message translates to:
  /// **'Continue studying'**
  String get dashboardContinueStudyingTitle;

  /// Primary button opening the most recently logged material
  ///
  /// In en, this message translates to:
  /// **'Continue studying'**
  String get dashboardContinueStudyingAction;

  /// Summary of the most recent study progress log
  ///
  /// In en, this message translates to:
  /// **'+{formattedUnits} {unitLabel} on {formattedDate}'**
  String dashboardContinueStudyingLastLogged(
      String formattedUnits, String unitLabel, String formattedDate);

  /// Material completion ratio and percentage line inside continue studying card
  ///
  /// In en, this message translates to:
  /// **'{formattedCompleted} / {formattedTotal} {unitLabel} ({percent}%)'**
  String dashboardMaterialProgressLine(String formattedCompleted,
      String formattedTotal, String unitLabel, String percent);

  /// Empty state title inside continue studying card
  ///
  /// In en, this message translates to:
  /// **'No study logs yet'**
  String get dashboardContinueStudyingEmptyTitle;

  /// Empty state body inside continue studying card
  ///
  /// In en, this message translates to:
  /// **'Log a study session in Prep and jump straight back into your book or course from here.'**
  String get dashboardContinueStudyingEmptyBody;

  /// CTA button opening Prep screen from empty continue studying state
  ///
  /// In en, this message translates to:
  /// **'Open Prep'**
  String get dashboardContinueStudyingEmptyAction;

  /// Card heading for upcoming circular deadlines list
  ///
  /// In en, this message translates to:
  /// **'Upcoming deadlines'**
  String get dashboardUpcomingDeadlinesTitle;

  /// Empty state title inside upcoming deadlines card
  ///
  /// In en, this message translates to:
  /// **'No upcoming deadlines'**
  String get dashboardUpcomingDeadlinesEmptyTitle;

  /// Empty state body inside upcoming deadlines card
  ///
  /// In en, this message translates to:
  /// **'Saved circulars with future deadlines will appear here with color-coded countdowns.'**
  String get dashboardUpcomingDeadlinesEmptyBody;

  /// Secondary button navigating from dashboard card to full list
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashboardViewAllAction;

  /// Card heading for upcoming circular exam dates list
  ///
  /// In en, this message translates to:
  /// **'Upcoming exams'**
  String get dashboardUpcomingExamsTitle;

  /// Empty state title inside upcoming exams card
  ///
  /// In en, this message translates to:
  /// **'No upcoming exams scheduled'**
  String get dashboardUpcomingExamsEmptyTitle;

  /// Empty state body inside upcoming exams card
  ///
  /// In en, this message translates to:
  /// **'Add Preliminary, Written, or Viva dates on a circular to keep track of upcoming sittings here.'**
  String get dashboardUpcomingExamsEmptyBody;

  /// Action button navigating from upcoming exams card to calendar screen
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get dashboardOpenCalendarAction;

  /// Countdown badge label when an exam takes place today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardExamToday;

  /// Countdown badge label for an exam scheduled N days from today
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In 1 day} other{In {formattedCount} days}}'**
  String dashboardExamInDays(int count, String formattedCount);

  /// Heading for per-user daily email reminder settings card
  ///
  /// In en, this message translates to:
  /// **'Email Reminders'**
  String get settingsRemindersTitle;

  /// Description under email reminder settings heading
  ///
  /// In en, this message translates to:
  /// **'Receive daily alerts for circular deadlines and exam dates 7, 3, and 1 days ahead.'**
  String get settingsRemindersSubtitle;

  /// Switch label turning daily email reminders on or off
  ///
  /// In en, this message translates to:
  /// **'Enable daily email reminders'**
  String get settingsRemindersToggleLabel;

  /// Helper text shown when email reminders are enabled
  ///
  /// In en, this message translates to:
  /// **'Reminders are sent once per milestone using your saved account email.'**
  String get settingsRemindersToggleHintEnabled;

  /// Helper text shown when email reminders are turned off
  ///
  /// In en, this message translates to:
  /// **'Email reminders are paused. Turn them on anytime without losing saved circulars.'**
  String get settingsRemindersToggleHintDisabled;

  /// Subheading above English/Bangla email language selector
  ///
  /// In en, this message translates to:
  /// **'Reminder email language'**
  String get settingsRemindersLanguageTitle;

  /// Description explaining email language selection
  ///
  /// In en, this message translates to:
  /// **'Choose which language daily reminder emails are written in.'**
  String get settingsRemindersLanguageSubtitle;

  /// Snackbar or banner message when saving reminder settings fails
  ///
  /// In en, this message translates to:
  /// **'Could not save reminder settings. Please try again.'**
  String get settingsRemindersSaveError;

  /// Error banner shown when reminder settings fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load reminder settings.'**
  String get settingsRemindersLoadError;

  /// Notice shown when running without a connected Supabase backend
  ///
  /// In en, this message translates to:
  /// **'Connect Supabase to persist email reminder preferences across devices.'**
  String get settingsRemindersOfflineHint;

  /// Title for client-side encrypted portal vault
  ///
  /// In en, this message translates to:
  /// **'Portal Vault'**
  String get vaultTitle;

  /// Subtitle explaining portal vault security
  ///
  /// In en, this message translates to:
  /// **'Protect saved application portal logins with your local vault passphrase.'**
  String get vaultSubtitle;

  /// Badge label when portal vault is locked
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get vaultStatusLocked;

  /// Badge label when portal vault is unlocked
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get vaultStatusUnlocked;

  /// Button opening first-time vault passphrase setup dialog
  ///
  /// In en, this message translates to:
  /// **'Set up vault'**
  String get vaultSetupButton;

  /// Button opening vault unlock dialog
  ///
  /// In en, this message translates to:
  /// **'Unlock vault'**
  String get vaultUnlockButton;

  /// Button locking the vault immediately and wiping keys
  ///
  /// In en, this message translates to:
  /// **'Lock vault'**
  String get vaultLockButton;

  /// Dialog title for first-time vault setup
  ///
  /// In en, this message translates to:
  /// **'Create Vault Passphrase'**
  String get vaultSetupDialogTitle;

  /// Introductory explanation inside first-time vault setup dialog
  ///
  /// In en, this message translates to:
  /// **'Choose a strong passphrase to encrypt your portal passwords on this device.'**
  String get vaultSetupDialogBody;

  /// Prominent non-recoverable warning displayed during vault setup
  ///
  /// In en, this message translates to:
  /// **'Important: A forgotten passphrase cannot be recovered or reset. Any saved passwords cannot be decrypted without it.'**
  String get vaultUnrecoverableWarning;

  /// Checkbox label confirming user read the recovery warning
  ///
  /// In en, this message translates to:
  /// **'I understand that a forgotten passphrase cannot be recovered.'**
  String get vaultAcknowledgeWarningLabel;

  /// Validation error if user tries submitting setup without acknowledging warning
  ///
  /// In en, this message translates to:
  /// **'Please confirm that you understand the recovery warning.'**
  String get vaultAcknowledgeRequiredError;

  /// Text field label for vault passphrase
  ///
  /// In en, this message translates to:
  /// **'Vault passphrase'**
  String get vaultPassphraseLabel;

  /// Text field label for confirming new vault passphrase
  ///
  /// In en, this message translates to:
  /// **'Confirm passphrase'**
  String get vaultPassphraseConfirmLabel;

  /// Validation error when vault passphrase is shorter than 8 characters
  ///
  /// In en, this message translates to:
  /// **'Enter at least 8 characters.'**
  String get vaultPassphraseTooShortError;

  /// Validation error when confirmation passphrase does not match
  ///
  /// In en, this message translates to:
  /// **'Passphrases do not match.'**
  String get vaultPassphraseMismatchError;

  /// Submit button creating vault check value and unlocking session
  ///
  /// In en, this message translates to:
  /// **'Create & unlock'**
  String get vaultCreateAndUnlockAction;

  /// Dialog title prompting for existing vault passphrase
  ///
  /// In en, this message translates to:
  /// **'Unlock Portal Vault'**
  String get vaultUnlockDialogTitle;

  /// Description text inside vault unlock dialog
  ///
  /// In en, this message translates to:
  /// **'Enter your vault passphrase to view, copy, and manage saved portal accounts.'**
  String get vaultUnlockDialogBody;

  /// Error displayed when vault unlock verification fails
  ///
  /// In en, this message translates to:
  /// **'Incorrect vault passphrase. Please try again.'**
  String get vaultWrongPassphraseError;

  /// Informational caption explaining automatic vault locking
  ///
  /// In en, this message translates to:
  /// **'Auto-locks after inactivity and whenever you sign out.'**
  String get vaultAutoLockNote;

  /// Locked placeholder text on circular detail screen
  ///
  /// In en, this message translates to:
  /// **'Portal logins are hidden while the vault is locked.'**
  String get vaultPortalLockedHint;

  /// Section title for portal accounts inside circular detail view
  ///
  /// In en, this message translates to:
  /// **'Portal Login'**
  String get portalSectionTitle;

  /// Button adding a portal account to the active circular
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get portalAddAccountButton;

  /// Empty state shown when vault is unlocked and circular has no accounts
  ///
  /// In en, this message translates to:
  /// **'No portal accounts saved for this circular yet.'**
  String get portalEmptyState;

  /// Dialog title for adding a portal login
  ///
  /// In en, this message translates to:
  /// **'Add Portal Account'**
  String get portalAddDialogTitle;

  /// Dialog title for editing a portal login
  ///
  /// In en, this message translates to:
  /// **'Edit Portal Account'**
  String get portalEditDialogTitle;

  /// Input label for portal login web link
  ///
  /// In en, this message translates to:
  /// **'Portal URL (optional)'**
  String get portalUrlLabel;

  /// Input label for portal login username or applicant ID
  ///
  /// In en, this message translates to:
  /// **'User ID / Username'**
  String get portalUsernameLabel;

  /// Validation error when portal username is blank
  ///
  /// In en, this message translates to:
  /// **'User ID is required.'**
  String get portalUsernameRequiredError;

  /// Input label for portal account password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get portalPasswordLabel;

  /// Validation error when portal password is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get portalPasswordRequiredError;

  /// Input label for optional portal account notes
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get portalNotesLabel;

  /// Button copying portal user ID to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get portalCopyUserIdAction;

  /// Button copying decrypted portal password to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get portalCopyPasswordAction;

  /// Button opening external application portal URL
  ///
  /// In en, this message translates to:
  /// **'Open portal'**
  String get portalOpenUrlAction;

  /// Tooltip toggling masked portal password visibility
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get portalRevealPasswordTooltip;

  /// Tooltip hiding revealed portal password
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get portalHidePasswordTooltip;

  /// Snackbar notification confirming clipboard copy and auto-clear countdown
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard — clears in {formattedSeconds}s.'**
  String portalCopiedClipboardNotice(String formattedSeconds);

  /// Confirmation dialog title before deleting a portal account
  ///
  /// In en, this message translates to:
  /// **'Delete portal account?'**
  String get portalDeleteConfirmTitle;

  /// Confirmation dialog body before deleting a portal account
  ///
  /// In en, this message translates to:
  /// **'Remove saved portal login \"{username}\" from this circular?'**
  String portalDeleteConfirmMessage(String username);

  /// Error shown when saving or deleting a portal account fails
  ///
  /// In en, this message translates to:
  /// **'Could not save portal account. Please try again.'**
  String get portalSaveError;

  /// Error shown when loading or decrypting portal accounts fails
  ///
  /// In en, this message translates to:
  /// **'Could not load portal accounts.'**
  String get portalLoadError;

  /// Heading for the combined and per-subject study plans section
  ///
  /// In en, this message translates to:
  /// **'Study Plans'**
  String get prepStudyPlanSectionTitle;

  /// Button opening dialog to create a new study plan
  ///
  /// In en, this message translates to:
  /// **'Set study plan'**
  String get prepStudyPlanAddButton;

  /// Dialog title when creating a study plan
  ///
  /// In en, this message translates to:
  /// **'Create Study Plan'**
  String get prepStudyPlanCreateTitle;

  /// Dialog title when editing an existing study plan
  ///
  /// In en, this message translates to:
  /// **'Edit Study Plan'**
  String get prepStudyPlanEditTitle;

  /// Label for selecting all subjects or a specific subject
  ///
  /// In en, this message translates to:
  /// **'Plan scope'**
  String get prepStudyPlanScopeLabel;

  /// Label representing the combined all-subjects study plan
  ///
  /// In en, this message translates to:
  /// **'All subjects (combined)'**
  String get prepStudyPlanAllSubjectsLabel;

  /// Label for optional circular dropdown in study plan form
  ///
  /// In en, this message translates to:
  /// **'Linked exam circular (optional)'**
  String get prepStudyPlanCircularLabel;

  /// Option representing no linked circular on a study plan
  ///
  /// In en, this message translates to:
  /// **'No circular link (custom date)'**
  String get prepStudyPlanNoCircularOption;

  /// Label for choosing a specific exam stage date from a linked circular
  ///
  /// In en, this message translates to:
  /// **'Circular exam stage (optional)'**
  String get prepStudyPlanExamStageLabel;

  /// Label for study plan start date picker
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get prepStudyPlanStartDateLabel;

  /// Formatted button label displaying chosen plan start date
  ///
  /// In en, this message translates to:
  /// **'Start date: {formattedDate}'**
  String prepStudyPlanStartDateValue(String formattedDate);

  /// Label for study plan target exam date picker
  ///
  /// In en, this message translates to:
  /// **'Exam date'**
  String get prepStudyPlanTargetDateLabel;

  /// Formatted button label displaying chosen exam date
  ///
  /// In en, this message translates to:
  /// **'Exam date: {formattedDate}'**
  String prepStudyPlanTargetDateValue(String formattedDate);

  /// Label for revision buffer days input
  ///
  /// In en, this message translates to:
  /// **'Finish buffer (days before exam)'**
  String get prepStudyPlanBufferDaysLabel;

  /// Label for rest days per week selector
  ///
  /// In en, this message translates to:
  /// **'Rest days per week'**
  String get prepStudyPlanRestDaysLabel;

  /// Label for maximum comfortable daily study pace limit
  ///
  /// In en, this message translates to:
  /// **'Max daily pace limit (units/day, optional)'**
  String get prepStudyPlanMaxPaceLabel;

  /// Hint text for optional maximum daily pace limit field
  ///
  /// In en, this message translates to:
  /// **'Leave blank for no pace cap'**
  String get prepStudyPlanMaxPaceHint;

  /// Submit button saving a study plan
  ///
  /// In en, this message translates to:
  /// **'Save plan'**
  String get prepStudyPlanSaveButton;

  /// Confirmation title before deleting a study plan
  ///
  /// In en, this message translates to:
  /// **'Delete study plan?'**
  String get prepStudyPlanDeleteTitle;

  /// Confirmation body before deleting a study plan
  ///
  /// In en, this message translates to:
  /// **'Remove this study plan? Your subjects, materials, and progress logs will stay untouched.'**
  String get prepStudyPlanDeleteBody;

  /// Badge when progress is ahead of the ideal line
  ///
  /// In en, this message translates to:
  /// **'Ahead'**
  String get prepStudyPlanStatusAhead;

  /// Badge when progress is on track with the ideal line
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get prepStudyPlanStatusOnTrack;

  /// Badge when progress has fallen behind the ideal line
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get prepStudyPlanStatusBehind;

  /// Metric label for remaining study units
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get prepStudyPlanRemainingLabel;

  /// Metric label for remaining effective study days
  ///
  /// In en, this message translates to:
  /// **'Study days left'**
  String get prepStudyPlanDaysLeftLabel;

  /// Metric label for today's study unit target
  ///
  /// In en, this message translates to:
  /// **'Today\'s target'**
  String get prepStudyPlanTodayTargetLabel;

  /// Formatted count of study units
  ///
  /// In en, this message translates to:
  /// **'{formatted} units'**
  String prepStudyPlanUnitsCount(String formatted);

  /// Pluralized count of remaining study days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{{formatted} day} other{{formatted} days}}'**
  String prepStudyPlanDaysCount(int count, String formatted);

  /// Compact progress label inside Today's progress ring or summary
  ///
  /// In en, this message translates to:
  /// **'{done} / {target} today'**
  String prepStudyPlanTodayDoneOfTarget(String done, String target);

  /// Subtitle summarizing exam target date and finish buffer
  ///
  /// In en, this message translates to:
  /// **'Finishes {formattedDays}d before exam ({examDate})'**
  String prepStudyPlanBufferSummary(String formattedDays, String examDate);

  /// Status message shown when all active syllabus units are finished
  ///
  /// In en, this message translates to:
  /// **'Syllabus complete — today\'s target is 0.'**
  String get prepStudyPlanFinishedComplete;

  /// Automatic missed-day catch-up explanation message
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{You missed {formattedUnits} units, they are now spread over the next {formattedDays} day (+{formattedExtra}/day).} other{You missed {formattedUnits} units, they are now spread over the next {formattedDays} days (+{formattedExtra}/day).}}'**
  String prepStudyPlanMissedRedistributed(int days, String formattedUnits,
      String formattedDays, String formattedExtra);

  /// Notice when today is inside the finish buffer or past exam date with work remaining
  ///
  /// In en, this message translates to:
  /// **'Study window before the finish buffer has ended with {formattedUnits} units left.'**
  String prepStudyPlanPastTargetNotice(String formattedUnits);

  /// Warning shown when daily target exceeds max_daily_pace
  ///
  /// In en, this message translates to:
  /// **'Recalculated target ({formattedTarget}/day) exceeds your pace limit ({formattedLimit}/day).'**
  String prepStudyPlanPaceWarning(
      String formattedTarget, String formattedLimit);

  /// Pace recovery action converting one rest day into a study day
  ///
  /// In en, this message translates to:
  /// **'Turn a rest day into a study day'**
  String get prepStudyPlanActionConvertRest;

  /// Pace recovery action raising max_daily_pace
  ///
  /// In en, this message translates to:
  /// **'Raise pace limit'**
  String get prepStudyPlanActionRaisePace;

  /// Pace recovery action postponing a lower-priority material
  ///
  /// In en, this message translates to:
  /// **'Postpone lower-priority material'**
  String get prepStudyPlanActionPostponeMaterial;

  /// Dialog title when raising the daily pace limit
  ///
  /// In en, this message translates to:
  /// **'Raise Daily Pace Limit'**
  String get prepStudyPlanRaisePaceTitle;

  /// Dialog title when choosing a material to postpone from the plan
  ///
  /// In en, this message translates to:
  /// **'Postpone Material'**
  String get prepStudyPlanPostponeTitle;

  /// Explanation shown inside the postpone material dialog
  ///
  /// In en, this message translates to:
  /// **'Excluding a material removes its remaining units from this plan\'s daily target without deleting your study progress.'**
  String get prepStudyPlanPostponeSubtitle;

  /// Chip label showing a postponed material that can be restored
  ///
  /// In en, this message translates to:
  /// **'Postponed: {title}'**
  String prepStudyPlanPostponedChip(String title);

  /// Tooltip on postponed material chip delete/restore icon
  ///
  /// In en, this message translates to:
  /// **'Restore to plan'**
  String get prepStudyPlanRestoreTooltip;

  /// Tooltip on study plan edit icon button
  ///
  /// In en, this message translates to:
  /// **'Edit study plan'**
  String get prepStudyPlanEditTooltip;

  /// Tooltip on study plan delete icon button
  ///
  /// In en, this message translates to:
  /// **'Delete study plan'**
  String get prepStudyPlanDeleteTooltip;

  /// Validation error for negative finish buffer
  ///
  /// In en, this message translates to:
  /// **'Finish buffer must be 0 days or greater.'**
  String get prepStudyPlanValidationBuffer;

  /// Validation error for non-positive daily pace limit
  ///
  /// In en, this message translates to:
  /// **'Pace limit must be greater than 0.'**
  String get prepStudyPlanValidationPace;

  /// Validation error when exam date precedes start date
  ///
  /// In en, this message translates to:
  /// **'Exam date must be on or after the start date.'**
  String get prepStudyPlanValidationDates;

  /// Heading for Today's Target card on the Home Dashboard
  ///
  /// In en, this message translates to:
  /// **'Today\'s Target'**
  String get dashboardTodayTargetTitle;

  /// Empty state heading inside Dashboard Today's Target card
  ///
  /// In en, this message translates to:
  /// **'No study plan configured yet'**
  String get dashboardTodayTargetEmptyTitle;

  /// Empty state explanation inside Dashboard Today's Target card
  ///
  /// In en, this message translates to:
  /// **'Set an exam date to calculate daily targets and automatic missed-day redistribution.'**
  String get dashboardTodayTargetEmptyBody;

  /// CTA button in Dashboard Today's Target empty state
  ///
  /// In en, this message translates to:
  /// **'Set study plan'**
  String get dashboardTodayTargetEmptyAction;

  /// Button navigating from Dashboard Today's Target card to Prep
  ///
  /// In en, this message translates to:
  /// **'Open study plans'**
  String get dashboardTodayTargetManageAction;

  /// Summary count of configured study plans shown on Dashboard
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formatted} active plan} other{{formatted} active plans}}'**
  String dashboardTodayTargetPlansSummary(int count, String formatted);

  /// Tab label for Subjects & Study Plans inside Prep screen
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get prepTabSubjects;

  /// Tab label for Mock Tests inside Prep screen
  ///
  /// In en, this message translates to:
  /// **'Mock tests'**
  String get prepTabMockTests;

  /// Heading for the Mock tests tab inside Prep screen
  ///
  /// In en, this message translates to:
  /// **'Mock tests'**
  String get prepMockTestsTitle;

  /// Subtitle explaining the Mock tests tab
  ///
  /// In en, this message translates to:
  /// **'Track scores after negative marking, time taken, and weak topics across platforms.'**
  String get prepMockTestsSubtitle;

  /// Button label to open the add mock test dialog
  ///
  /// In en, this message translates to:
  /// **'Log mock test'**
  String get prepMockTestAddButton;

  /// Section title for mock tests inside Subject Detail view
  ///
  /// In en, this message translates to:
  /// **'Mock test performance'**
  String get prepMockTestSubjectSectionTitle;

  /// Count of mock tests shown for a subject or filtered list
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formatted} test logged} other{{formatted} tests logged}}'**
  String prepMockTestSubjectCount(int count, String formatted);

  /// Filter label for subject selection on Mock tests tab
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get prepMockFilterSubjectLabel;

  /// Dropdown option showing mock tests across all subjects
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get prepMockFilterAllSubjects;

  /// Filter label for date range presets on Mock tests tab
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get prepMockFilterDateLabel;

  /// Date range filter preset including all dates
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get prepMockFilterDateAll;

  /// Date range filter preset for the last 7 days
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get prepMockFilterDate7Days;

  /// Date range filter preset for the last 30 days
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get prepMockFilterDate30Days;

  /// Date range filter preset for the last 90 days
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get prepMockFilterDate90Days;

  /// Action button clearing active mock test filters
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get prepMockFilterClear;

  /// Stat card label for the latest mock test score
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get prepMockStatLatest;

  /// Stat card label for the highest mock test score
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get prepMockStatBest;

  /// Stat card label for average mock test score
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get prepMockStatAverage;

  /// Stat card label for score improvement
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get prepMockStatImprovement;

  /// Formatted percentage value for a mock test stat
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String prepMockStatPercentValue(String percent);

  /// Placeholder when a mock test statistic is not available yet
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get prepMockStatNotAvailable;

  /// Caption showing improvement is computed over the last N tests
  ///
  /// In en, this message translates to:
  /// **'Last {formatted} tests'**
  String prepMockStatImprovementLastFive(String formatted);

  /// Caption showing improvement is measured from first to latest test
  ///
  /// In en, this message translates to:
  /// **'First to latest'**
  String get prepMockStatImprovementFirstToLatest;

  /// Caption when fewer than two tests exist for improvement calculation
  ///
  /// In en, this message translates to:
  /// **'Log 2+ tests to compare'**
  String get prepMockStatImprovementNeedsTwo;

  /// Heading above the mock test score trend line chart
  ///
  /// In en, this message translates to:
  /// **'Score trend (%)'**
  String get prepMockTrendChartTitle;

  /// Legend/reference line label showing average percentage
  ///
  /// In en, this message translates to:
  /// **'Avg {percent}%'**
  String prepMockTrendAverageLineLabel(String percent);

  /// Hint shown instead of trend chart when there are no tests
  ///
  /// In en, this message translates to:
  /// **'Log your first mock test to plot your score trend and average reference line.'**
  String get prepMockTrendNeedsDataHint;

  /// Tooltip text when touching a point on the mock test trend chart
  ///
  /// In en, this message translates to:
  /// **'{title}\n{percent}% • {date}'**
  String prepMockTrendTooltip(String title, String percent, String date);

  /// Empty state heading when no mock tests exist
  ///
  /// In en, this message translates to:
  /// **'No mock tests logged yet'**
  String get prepMockEmptyTitle;

  /// Empty state body when no mock tests exist
  ///
  /// In en, this message translates to:
  /// **'Log model tests from guidebooks or online platforms to track net percentage and weak areas.'**
  String get prepMockEmptyBody;

  /// Empty state heading when active filters return no mock tests
  ///
  /// In en, this message translates to:
  /// **'No mock tests match these filters'**
  String get prepMockFilteredEmptyTitle;

  /// Empty state body when active filters return no mock tests
  ///
  /// In en, this message translates to:
  /// **'Try clearing the subject or date range filter, or log a new mock test.'**
  String get prepMockFilteredEmptyBody;

  /// Loading label shown while fetching mock tests
  ///
  /// In en, this message translates to:
  /// **'Loading mock tests...'**
  String get prepMockLoadingLabel;

  /// Error heading shown when mock tests fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load mock tests'**
  String get prepMockLoadErrorTitle;

  /// Score summary showing net marks out of total marks
  ///
  /// In en, this message translates to:
  /// **'{net} / {total}'**
  String prepMockScoreRatio(String net, String total);

  /// Badge showing negative marks deducted
  ///
  /// In en, this message translates to:
  /// **'-{marks} neg'**
  String prepMockNegativeMarksBadge(String marks);

  /// Badge showing time taken out of time limit in minutes
  ///
  /// In en, this message translates to:
  /// **'{taken} / {limit} min'**
  String prepMockDurationWithLimitBadge(String taken, String limit);

  /// Badge showing time taken in minutes
  ///
  /// In en, this message translates to:
  /// **'{taken} min'**
  String prepMockDurationBadge(String taken);

  /// Line showing weak topics noted on a mock test
  ///
  /// In en, this message translates to:
  /// **'Weak topics: {topics}'**
  String prepMockWeakTopicsLabel(String topics);

  /// Chip showing circular linked to a mock test
  ///
  /// In en, this message translates to:
  /// **'Circular: {title}'**
  String prepMockLinkedCircularLabel(String title);

  /// Chip showing material linked to a mock test
  ///
  /// In en, this message translates to:
  /// **'Material: {title}'**
  String prepMockLinkedMaterialLabel(String title);

  /// Chip showing topic linked to a mock test
  ///
  /// In en, this message translates to:
  /// **'Topic: {title}'**
  String prepMockLinkedTopicLabel(String title);

  /// Tooltip for editing a mock test
  ///
  /// In en, this message translates to:
  /// **'Edit mock test'**
  String get prepMockEditTooltip;

  /// Tooltip for deleting a mock test
  ///
  /// In en, this message translates to:
  /// **'Delete mock test'**
  String get prepMockDeleteTooltip;

  /// Dialog heading when creating a new mock test
  ///
  /// In en, this message translates to:
  /// **'Log mock test'**
  String get prepMockFormCreateTitle;

  /// Dialog heading when editing an existing mock test
  ///
  /// In en, this message translates to:
  /// **'Edit mock test'**
  String get prepMockFormEditTitle;

  /// Subject field label in mock test form
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get prepMockFormSubjectLabel;

  /// Test title field label in mock test form
  ///
  /// In en, this message translates to:
  /// **'Test title'**
  String get prepMockFormTitleLabel;

  /// Hint text for mock test title input
  ///
  /// In en, this message translates to:
  /// **'e.g., 46th BCS Model Test 04'**
  String get prepMockFormTitleHint;

  /// Source field label in mock test form
  ///
  /// In en, this message translates to:
  /// **'Source / Platform (optional)'**
  String get prepMockFormSourceLabel;

  /// Hint text for mock test source input
  ///
  /// In en, this message translates to:
  /// **'e.g., Live MCQ, Oracle Guide'**
  String get prepMockFormSourceHint;

  /// Row showing selected test date in mock test form
  ///
  /// In en, this message translates to:
  /// **'Date taken: {date}'**
  String prepMockFormTakenOnLabel(String date);

  /// Button opening date picker for test taken_on date
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get prepMockFormPickDate;

  /// Marks obtained numeric input label
  ///
  /// In en, this message translates to:
  /// **'Marks obtained'**
  String get prepMockFormMarksObtainedLabel;

  /// Total marks numeric input label
  ///
  /// In en, this message translates to:
  /// **'Total marks'**
  String get prepMockFormTotalMarksLabel;

  /// Negative marks numeric input label
  ///
  /// In en, this message translates to:
  /// **'Negative marks (optional)'**
  String get prepMockFormNegativeMarksLabel;

  /// Time taken in minutes input label
  ///
  /// In en, this message translates to:
  /// **'Time taken (min, optional)'**
  String get prepMockFormTimeTakenLabel;

  /// Time limit in minutes input label
  ///
  /// In en, this message translates to:
  /// **'Time limit (min, optional)'**
  String get prepMockFormTimeLimitLabel;

  /// Weak topics input label
  ///
  /// In en, this message translates to:
  /// **'Weak topics (optional)'**
  String get prepMockFormWeakTopicsLabel;

  /// Hint for weak topics input
  ///
  /// In en, this message translates to:
  /// **'e.g., Constitutional Amendments, Time & Work'**
  String get prepMockFormWeakTopicsHint;

  /// Notes input label in mock test form
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get prepMockFormNotesLabel;

  /// Optional circular dropdown label in mock test form
  ///
  /// In en, this message translates to:
  /// **'Linked circular (optional)'**
  String get prepMockFormCircularLabel;

  /// Optional material dropdown label in mock test form
  ///
  /// In en, this message translates to:
  /// **'Linked material (optional)'**
  String get prepMockFormMaterialLabel;

  /// Optional topic dropdown label in mock test form
  ///
  /// In en, this message translates to:
  /// **'Linked topic (optional)'**
  String get prepMockFormTopicLabel;

  /// Dropdown option representing no linked item
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get prepMockFormNoneOption;

  /// Primary submit button in mock test form dialog
  ///
  /// In en, this message translates to:
  /// **'Save mock test'**
  String get prepMockFormSaveAction;

  /// Validation error when no subject is selected
  ///
  /// In en, this message translates to:
  /// **'Select a subject for this mock test.'**
  String get prepMockValidationSubjectRequired;

  /// Validation error when mock test title is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a title for the mock test.'**
  String get prepMockValidationTitleRequired;

  /// Validation error when total marks is invalid or <= 0
  ///
  /// In en, this message translates to:
  /// **'Total marks must be greater than zero.'**
  String get prepMockValidationTotalPositive;

  /// Validation error when marks obtained is outside 0..total_marks
  ///
  /// In en, this message translates to:
  /// **'Marks obtained must be between 0 and total marks.'**
  String get prepMockValidationMarksRange;

  /// Validation error when negative marks is outside 0..total_marks
  ///
  /// In en, this message translates to:
  /// **'Negative marks must be between 0 and total marks.'**
  String get prepMockValidationNegativeMarks;

  /// Validation error when time taken or time limit is invalid
  ///
  /// In en, this message translates to:
  /// **'Time taken must be 0 or more, and time limit must be greater than zero.'**
  String get prepMockValidationDuration;

  /// Confirmation dialog heading before deleting a mock test
  ///
  /// In en, this message translates to:
  /// **'Delete mock test?'**
  String get prepMockDeleteTitle;

  /// Confirmation dialog body when deleting a mock test
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from your mock test history? This cannot be undone.'**
  String prepMockDeleteBody(String title);

  /// Destructive confirmation button label for deleting a mock test
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get prepMockDeleteConfirm;

  /// Tab label for Study Analytics inside Prep screen
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get prepTabAnalytics;

  /// Heading on the Study Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Study analytics'**
  String get prepAnalyticsTitle;

  /// Subtitle explaining Study Analytics metrics and charts
  ///
  /// In en, this message translates to:
  /// **'Track daily consistency, study streaks, weekly volume, and subject focus.'**
  String get prepAnalyticsSubtitle;

  /// Loading indicator text while computing analytics
  ///
  /// In en, this message translates to:
  /// **'Loading study analytics...'**
  String get prepAnalyticsLoadingLabel;

  /// Error card title when analytics data fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load study analytics'**
  String get prepAnalyticsLoadErrorTitle;

  /// Empty state heading when a new user has no logs yet
  ///
  /// In en, this message translates to:
  /// **'No study activity logged yet'**
  String get prepAnalyticsEmptyTitle;

  /// Empty state body explaining how to populate Study Analytics
  ///
  /// In en, this message translates to:
  /// **'Log units on your study materials or set a study plan to unlock streaks, charts, and your consistency score.'**
  String get prepAnalyticsEmptyBody;

  /// CTA button navigating from empty analytics back to Subjects
  ///
  /// In en, this message translates to:
  /// **'Open subjects'**
  String get prepAnalyticsEmptyAction;

  /// Filter label for the analytics day window selector
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get prepAnalyticsFilterRangeLabel;

  /// 7-day analytics range option
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get prepAnalyticsRange7Days;

  /// 30-day analytics range option
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get prepAnalyticsRange30Days;

  /// 90-day analytics range option
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get prepAnalyticsRange90Days;

  /// Filter label for subject filter on Study Analytics
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get prepAnalyticsFilterSubjectLabel;

  /// Default dropdown option covering all subjects in analytics
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get prepAnalyticsAllSubjects;

  /// Button clearing subject/range filter back to defaults
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get prepAnalyticsClearFilter;

  /// Metric card title for active consecutive study days
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get prepAnalyticsCurrentStreak;

  /// Metric card title for longest consecutive study days
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get prepAnalyticsLongestStreak;

  /// Metric card title for units completed in the current local week
  ///
  /// In en, this message translates to:
  /// **'Units this week'**
  String get prepAnalyticsUnitsThisWeek;

  /// Metric card title for days studied / days in range percentage
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get prepAnalyticsConsistency;

  /// Pluralized unit suffix attached to AnimatedCounter streak values
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{ day} other{ days}}'**
  String prepAnalyticsDaysSuffix(int count);

  /// Percent sign suffix attached to AnimatedCounter consistency values
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get prepAnalyticsPercentSuffix;

  /// Caption under Consistency card showing active out of total days
  ///
  /// In en, this message translates to:
  /// **'{active} / {total} active days'**
  String prepAnalyticsActiveDaysCaption(String active, String total);

  /// Caption under Units this week showing 7-day average
  ///
  /// In en, this message translates to:
  /// **'{avg}/day (7d avg)'**
  String prepAnalyticsAvgPerDayCaption(String avg);

  /// Highlight tile label for 7-day rolling daily unit average
  ///
  /// In en, this message translates to:
  /// **'7-day avg'**
  String get prepAnalyticsRolling7dLabel;

  /// Highlight tile label for 30-day rolling daily unit average
  ///
  /// In en, this message translates to:
  /// **'30-day avg'**
  String get prepAnalyticsRolling30dLabel;

  /// Formatted rolling average units per day
  ///
  /// In en, this message translates to:
  /// **'{avg} units/day'**
  String prepAnalyticsUnitsPerDayValue(String avg);

  /// Highlight tile label for highest-volume study day in range
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get prepAnalyticsBestDayLabel;

  /// Highlight tile label for lowest-volume day in range
  ///
  /// In en, this message translates to:
  /// **'Weakest day'**
  String get prepAnalyticsWeakestDayLabel;

  /// Formatted best or weakest day units paired with local date
  ///
  /// In en, this message translates to:
  /// **'{units} units • {date}'**
  String prepAnalyticsDaySummaryValue(String units, String date);

  /// Highlight label summarizing mock tests taken during date window
  ///
  /// In en, this message translates to:
  /// **'Mock tests in range'**
  String get prepAnalyticsMockOverviewLabel;

  /// Formatted count and average score of mock tests in window
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formattedCount} test • avg {avg}%} other{{formattedCount} tests • avg {avg}%}}'**
  String prepAnalyticsMockOverviewValue(
      int count, String formattedCount, String avg);

  /// Placeholder when no best/weakest day or mock data is available
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get prepAnalyticsNoDataDash;

  /// Alert headline when both today and yesterday finished under target
  ///
  /// In en, this message translates to:
  /// **'Today and yesterday were below your daily target'**
  String get prepAnalyticsAlertBothTitle;

  /// Alert headline when today has fewer units than daily target
  ///
  /// In en, this message translates to:
  /// **'Today is still below your daily target'**
  String get prepAnalyticsAlertTodayTitle;

  /// Alert headline when yesterday had fewer units than daily target
  ///
  /// In en, this message translates to:
  /// **'Yesterday finished below your daily target'**
  String get prepAnalyticsAlertYesterdayTitle;

  /// Details comparing today's and yesterday's logged units with daily target
  ///
  /// In en, this message translates to:
  /// **'Today: {today} / {target} units • Yesterday: {yesterday} / {target} units'**
  String prepAnalyticsAlertBody(String today, String yesterday, String target);

  /// Heading for the daily bar chart card
  ///
  /// In en, this message translates to:
  /// **'Daily study activity'**
  String get prepAnalyticsDailyChartTitle;

  /// Badge showing the study plan daily target reference line value
  ///
  /// In en, this message translates to:
  /// **'Target: {target}/day'**
  String prepAnalyticsDailyTargetLegend(String target);

  /// Tooltip shown when hovering or tapping a daily bar
  ///
  /// In en, this message translates to:
  /// **'{date}\n{units} units'**
  String prepAnalyticsDailyTooltip(String date, String units);

  /// Heading for the weekly totals bar chart card
  ///
  /// In en, this message translates to:
  /// **'Weekly totals'**
  String get prepAnalyticsWeeklyChartTitle;

  /// Tooltip shown when touching a weekly bar
  ///
  /// In en, this message translates to:
  /// **'{range}\n{units} units ({days} active)'**
  String prepAnalyticsWeeklyTooltip(String range, String units, String days);

  /// Short calendar range label for a week bucket
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String prepAnalyticsWeeklyRangeLabel(String start, String end);

  /// Heading for the subject breakdown chart and legend card
  ///
  /// In en, this message translates to:
  /// **'Where study time went'**
  String get prepAnalyticsSubjectChartTitle;

  /// Hint inside subject breakdown card when zero activity matches
  ///
  /// In en, this message translates to:
  /// **'Log study units or mock tests in this window to compare subjects.'**
  String get prepAnalyticsSubjectNoData;

  /// Legend label displaying subject units and percentage share
  ///
  /// In en, this message translates to:
  /// **'{units} units ({percent}%)'**
  String prepAnalyticsSubjectRowSubtitle(String units, String percent);

  /// Sub-caption on subject breakdown showing mock test stats in window
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formattedCount} mock • {avg}% avg} other{{formattedCount} mocks • {avg}% avg}}'**
  String prepAnalyticsSubjectMockHint(
      int count, String formattedCount, String avg);

  /// Heading above the rolling calendar heatmap of study days
  ///
  /// In en, this message translates to:
  /// **'Study days heatmap (last 90 days)'**
  String get prepAnalyticsHeatmapTitle;

  /// Tooltip label for an individual calendar heatmap day cell
  ///
  /// In en, this message translates to:
  /// **'{date}: {units} units'**
  String prepAnalyticsHeatmapTooltip(String date, String units);

  /// Heatmap intensity legend low label
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get prepAnalyticsHeatmapLess;

  /// Heatmap intensity legend high label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get prepAnalyticsHeatmapMore;

  /// Toggle chip switching subject detail view to all materials
  ///
  /// In en, this message translates to:
  /// **'All materials'**
  String get prepSubjectViewAllMaterials;

  /// Toggle chip switching subject detail view to the side-by-side books shelf
  ///
  /// In en, this message translates to:
  /// **'Books shelf ({count})'**
  String prepSubjectViewBooksShelf(String count);

  /// Action button on a book card opening the interactive 3D book progress view
  ///
  /// In en, this message translates to:
  /// **'Book view'**
  String get prepOpenBookView;

  /// Heading above the side-by-side grid of book covers for a subject
  ///
  /// In en, this message translates to:
  /// **'Books shelf'**
  String get prepBooksShelfTitle;

  /// Helper text displayed on the Books shelf screen
  ///
  /// In en, this message translates to:
  /// **'Tap any book to update your position with the bookmark or page field.'**
  String get prepBooksShelfSubtitle;

  /// Empty state headline on the Books shelf view when a subject has zero book materials
  ///
  /// In en, this message translates to:
  /// **'No books in {subject} yet'**
  String prepBooksShelfEmptyTitle(String subject);

  /// Empty state body on the Books shelf view
  ///
  /// In en, this message translates to:
  /// **'Add a study material with kind Book to arrange it on your shelf.'**
  String get prepBooksShelfEmptyBody;

  /// Button label inside the Books shelf empty state to add a book
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get prepAddBookButton;

  /// Leading label before the current page input field inside BookProgressView
  ///
  /// In en, this message translates to:
  /// **'I am at page'**
  String get bookProgressPositionPrefix;

  /// Trailing label after the current page input field inside BookProgressView
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String bookProgressPositionSuffix(String total);

  /// Submit button saving the entered page position inside BookProgressView
  ///
  /// In en, this message translates to:
  /// **'Save page'**
  String get bookProgressSavePosition;

  /// Completed and total units summary displayed with BookProgressView
  ///
  /// In en, this message translates to:
  /// **'{current} / {total} {unitLabel}'**
  String bookProgressUnitSummary(
      String current, String total, String unitLabel);

  /// Percentage readout rendered on a book progress badge
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String bookProgressPercentLabel(String percent);

  /// Last updated date label displayed cleanly on the book card
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String bookProgressUpdatedOn(String date);

  /// Caption guiding bookmark dragging and quick page entry
  ///
  /// In en, this message translates to:
  /// **'Drag the bookmark or enter your page number'**
  String get bookProgressDragHint;

  /// Accessibility label for the draggable book ribbon bookmark
  ///
  /// In en, this message translates to:
  /// **'Book position bookmark'**
  String get bookProgressBookmarkSemantics;

  /// Validation error shown when submitting an empty book page input
  ///
  /// In en, this message translates to:
  /// **'Enter a page number'**
  String get bookProgressErrorEmpty;

  /// Validation error shown when book page input is not a whole integer
  ///
  /// In en, this message translates to:
  /// **'Enter a whole page number'**
  String get bookProgressErrorWholeNumber;

  /// Validation error shown when book page input is below zero
  ///
  /// In en, this message translates to:
  /// **'Page number cannot be negative'**
  String get bookProgressErrorBelowZero;

  /// Validation error shown when entered page is greater than total pages
  ///
  /// In en, this message translates to:
  /// **'Page cannot exceed {total}'**
  String bookProgressErrorExceedsTotal(String total);

  /// Confirmation dialog title shown when entered page is below current position
  ///
  /// In en, this message translates to:
  /// **'Save position correction?'**
  String get bookProgressConfirmCorrectionTitle;

  /// Explanation shown when lowering the current page position to confirm saving a correction log
  ///
  /// In en, this message translates to:
  /// **'You are moving back from page {fromPage} to page {toPage} ({delta} {unitLabel}). This updates your book position without counting as studied units in your study plan or analytics.'**
  String bookProgressConfirmCorrectionBody(
      String fromPage, String toPage, String delta, String unitLabel);

  /// Primary confirm button label for saving a downward position correction
  ///
  /// In en, this message translates to:
  /// **'Save correction'**
  String get bookProgressConfirmCorrectionAction;

  /// Feedback banner shown after saving a downward book position correction
  ///
  /// In en, this message translates to:
  /// **'Updated position to {page} (correction)'**
  String bookProgressCorrectionSaved(String page);

  /// Feedback banner shown after saving a forward page jump as a study log
  ///
  /// In en, this message translates to:
  /// **'Logged +{delta} {unitLabel}'**
  String bookProgressStudySaved(String delta, String unitLabel);

  /// Action button inside book view opening full progress log history
  ///
  /// In en, this message translates to:
  /// **'Log history'**
  String get bookProgressHistoryButton;

  /// Badge identifying correction entries inside past progress logs
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get prepLogEntryTypeCorrectionBadge;

  /// Generic close button label for dialogs
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get prepCloseButton;

  /// Top-level Prep tab label for spaced-repetition revision queue
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get prepTabRevision;

  /// Headline on the Revision tab
  ///
  /// In en, this message translates to:
  /// **'Revision queue'**
  String get prepRevisionTitle;

  /// Subtitle on the Revision tab
  ///
  /// In en, this message translates to:
  /// **'Revisit flagged pages, tricky problems, and weak topics on a spaced schedule.'**
  String get prepRevisionSubtitle;

  /// Metric card label counting active items due today or overdue
  ///
  /// In en, this message translates to:
  /// **'Due & overdue'**
  String get prepRevisionDueCountStat;

  /// Metric card label counting items mastered after the full spacing ladder
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get prepRevisionMasteredStat;

  /// Primary CTA button on Revision screen to manually create a revision flag
  ///
  /// In en, this message translates to:
  /// **'Flag item'**
  String get prepRevisionFlagItemButton;

  /// Revision queue tab showing items scheduled due today
  ///
  /// In en, this message translates to:
  /// **'Due today ({count})'**
  String prepRevisionTabDueToday(String count);

  /// Revision queue tab showing items past due date
  ///
  /// In en, this message translates to:
  /// **'Overdue ({count})'**
  String prepRevisionTabOverdue(String count);

  /// Revision queue tab showing future scheduled items
  ///
  /// In en, this message translates to:
  /// **'Upcoming ({count})'**
  String prepRevisionTabUpcoming(String count);

  /// Revision queue tab showing mastered or dismissed items
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String prepRevisionTabDone(String count);

  /// Default option in subject filter on Revision queue
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get prepRevisionAllSubjects;

  /// Default option in material filter on Revision queue
  ///
  /// In en, this message translates to:
  /// **'All materials'**
  String get prepRevisionAllMaterials;

  /// Button clearing subject and material filters on Revision queue
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get prepRevisionClearFilters;

  /// Revision flag reason: tricky
  ///
  /// In en, this message translates to:
  /// **'Tricky'**
  String get prepRevisionReasonTricky;

  /// Revision flag reason: forgot
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get prepRevisionReasonForgot;

  /// Revision flag reason: important
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get prepRevisionReasonImportant;

  /// Revision flag reason: mistake
  ///
  /// In en, this message translates to:
  /// **'Mistake'**
  String get prepRevisionReasonMistake;

  /// Origin chip indicating flag came from a study progress log
  ///
  /// In en, this message translates to:
  /// **'From study log'**
  String get prepRevisionSourceLog;

  /// Origin chip indicating flag came from a mock test weak topic
  ///
  /// In en, this message translates to:
  /// **'From mock test'**
  String get prepRevisionSourceMockTest;

  /// Origin chip indicating manual revision flag
  ///
  /// In en, this message translates to:
  /// **'Manual flag'**
  String get prepRevisionSourceManual;

  /// Badge for mastered revision items
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get prepRevisionStatusMastered;

  /// Badge for dismissed revision items
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get prepRevisionStatusDismissed;

  /// Schedule label on items due strictly today
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get prepRevisionDueTodayLabel;

  /// Schedule label showing how many days overdue an item is
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formattedCount} day overdue} other{{formattedCount} days overdue}}'**
  String prepRevisionOverdueDaysLabel(int count, String formattedCount);

  /// Schedule label showing remaining days until upcoming review
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{In {formattedCount} day} other{In {formattedCount} days}}'**
  String prepRevisionDueInDaysLabel(int count, String formattedCount);

  /// Formatted scheduled date caption on a revision card
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String prepRevisionDueDateLabel(String date);

  /// Compact page number badge rendered on book/page revision cards
  ///
  /// In en, this message translates to:
  /// **'p. {page}'**
  String prepRevisionPageChip(String page);

  /// Completed spaced review count badge
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{New} =1{{formattedCount} review} other{{formattedCount} reviews}}'**
  String prepRevisionReviewCountChip(int count, String formattedCount);

  /// Review action advancing the spaced repetition interval along 3, 7, 14, 30 days
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get prepRevisionActionEasy;

  /// Short day suffix shown alongside Easy button indicating the next gap
  ///
  /// In en, this message translates to:
  /// **'+{days}d'**
  String prepRevisionActionEasyHint(String days);

  /// Hint shown beside Easy on the final 30-day step before becoming mastered
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get prepRevisionActionEasyMasteredHint;

  /// Review action resetting the revision gap back to 1 day
  ///
  /// In en, this message translates to:
  /// **'Still hard'**
  String get prepRevisionActionStillHard;

  /// Action deferring the due date by 1 day without changing review count
  ///
  /// In en, this message translates to:
  /// **'Snooze +1d'**
  String get prepRevisionActionSnooze;

  /// Action dismissing an item from the active queue into Done
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get prepRevisionActionDismiss;

  /// Tooltip for deleting a Done revision item
  ///
  /// In en, this message translates to:
  /// **'Delete revision mark'**
  String get prepRevisionDeleteTooltip;

  /// Action reverting the latest Easy, Still hard, Snooze, or Dismiss action
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get prepRevisionUndoButton;

  /// Tooltip closing the revision undo confirmation banner
  ///
  /// In en, this message translates to:
  /// **'Hide undo banner'**
  String get prepRevisionUndoDismissTooltip;

  /// Undo banner feedback after scheduling the next Easy interval
  ///
  /// In en, this message translates to:
  /// **'Marked \"{reference}\" as Easy — next review in {days} days.'**
  String prepRevisionFeedbackEasyNext(String reference, String days);

  /// Undo banner feedback when final Easy step promotes item to mastered
  ///
  /// In en, this message translates to:
  /// **'Mastered \"{reference}\"! Moved to Done.'**
  String prepRevisionFeedbackMastered(String reference);

  /// Undo banner feedback after Still hard reset
  ///
  /// In en, this message translates to:
  /// **'Marked \"{reference}\" as Still hard — reset to 1 day.'**
  String prepRevisionFeedbackStillHard(String reference);

  /// Undo banner feedback after snoozing an item
  ///
  /// In en, this message translates to:
  /// **'Snoozed \"{reference}\" by 1 day.'**
  String prepRevisionFeedbackSnoozed(String reference);

  /// Undo banner feedback after dismissing an item
  ///
  /// In en, this message translates to:
  /// **'Dismissed \"{reference}\" to Done.'**
  String prepRevisionFeedbackDismissed(String reference);

  /// Empty headline on Due today queue tab
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get prepRevisionEmptyDueTitle;

  /// Empty helper text on Due today queue tab
  ///
  /// In en, this message translates to:
  /// **'Flag tricky pages while logging study progress or check Overdue and Upcoming.'**
  String get prepRevisionEmptyDueBody;

  /// Empty headline on Overdue queue tab
  ///
  /// In en, this message translates to:
  /// **'No overdue revisions'**
  String get prepRevisionEmptyOverdueTitle;

  /// Empty helper text on Overdue queue tab
  ///
  /// In en, this message translates to:
  /// **'Every scheduled revision mark is up to date.'**
  String get prepRevisionEmptyOverdueBody;

  /// Empty headline on Upcoming queue tab
  ///
  /// In en, this message translates to:
  /// **'No upcoming revisions scheduled'**
  String get prepRevisionEmptyUpcomingTitle;

  /// Empty helper text on Upcoming queue tab
  ///
  /// In en, this message translates to:
  /// **'New flags are scheduled 1 day ahead, and Easy reviews space out along 3, 7, 14, and 30 days.'**
  String get prepRevisionEmptyUpcomingBody;

  /// Empty headline on Done queue tab
  ///
  /// In en, this message translates to:
  /// **'No completed items yet'**
  String get prepRevisionEmptyDoneTitle;

  /// Empty helper text on Done queue tab
  ///
  /// In en, this message translates to:
  /// **'Mastered and dismissed items are archived here.'**
  String get prepRevisionEmptyDoneBody;

  /// Empty helper text when queue filters hide all items
  ///
  /// In en, this message translates to:
  /// **'No revision items match the active subject and material filters.'**
  String get prepRevisionEmptyFilteredBody;

  /// Button label opening inline revision flag composer during logging
  ///
  /// In en, this message translates to:
  /// **'Mark for revision'**
  String get prepRevisionMarkAction;

  /// Banner shown immediately after saving progress to invite quick revision flagging
  ///
  /// In en, this message translates to:
  /// **'Progress saved! Flag any page or problem to revise later without leaving?'**
  String get prepRevisionPostSavePrompt;

  /// Badge showing how many revision flags were added inside the current logging session
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{formattedCount} flag added} other{{formattedCount} flags added}}'**
  String prepRevisionAddedCountChip(int count, String formattedCount);

  /// Text field label for revision item reference_label
  ///
  /// In en, this message translates to:
  /// **'Reference (page, problem, or topic)'**
  String get prepRevisionRefLabel;

  /// Text field placeholder for revision item reference_label
  ///
  /// In en, this message translates to:
  /// **'e.g. p. 128 or Problem 14'**
  String get prepRevisionRefHint;

  /// Validation error when reference_label is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a page, problem, or topic to revise.'**
  String get prepRevisionRefError;

  /// Optional numeric page field shown when flagging book/material items
  ///
  /// In en, this message translates to:
  /// **'Page # (optional)'**
  String get prepRevisionPageLabel;

  /// Hint text for optional page number input
  ///
  /// In en, this message translates to:
  /// **'128'**
  String get prepRevisionPageHint;

  /// Chip selector heading for RevisionReason
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get prepRevisionReasonLabel;

  /// Text field label for optional note on revision item
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get prepRevisionNoteLabel;

  /// Placeholder text for optional revision note
  ///
  /// In en, this message translates to:
  /// **'Sign mistake in derivation, review shortcut...'**
  String get prepRevisionNoteHint;

  /// Submit button adding a revision flag while keeping inline composer open
  ///
  /// In en, this message translates to:
  /// **'Add flag'**
  String get prepRevisionAddAnotherButton;

  /// Collapse button hiding the inline revision composer
  ///
  /// In en, this message translates to:
  /// **'Hide flagger'**
  String get prepRevisionDoneFlaggingButton;

  /// Tooltip on MaterialCard flag icon button
  ///
  /// In en, this message translates to:
  /// **'Flag for revision'**
  String get prepRevisionFlagMaterialTooltip;

  /// Dialog heading when creating a manual or mock-test revision item
  ///
  /// In en, this message translates to:
  /// **'Mark for revision'**
  String get prepRevisionDialogTitle;

  /// Subject dropdown label inside standalone revision dialog
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get prepRevisionSubjectLabel;

  /// Material dropdown label inside standalone revision dialog
  ///
  /// In en, this message translates to:
  /// **'Material (optional)'**
  String get prepRevisionMaterialOptionalLabel;

  /// Option representing no attached study material on a revision mark
  ///
  /// In en, this message translates to:
  /// **'Subject-wide / No specific material'**
  String get prepRevisionNoMaterialOption;

  /// Prompt above parsed weak topic chips in mock-test revision dialog
  ///
  /// In en, this message translates to:
  /// **'Tap a weak topic to prefill:'**
  String get prepRevisionWeakTopicsQuickFill;

  /// Quick action adding every parsed weak topic from a mock test at once
  ///
  /// In en, this message translates to:
  /// **'Add all ({count})'**
  String prepRevisionAddAllWeakTopics(String count);

  /// Action button next to mock test weak topics sending them to the Revision queue
  ///
  /// In en, this message translates to:
  /// **'Add to revision'**
  String get prepMockAddToRevisionButton;
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
