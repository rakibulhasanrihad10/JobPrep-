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
