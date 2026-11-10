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
