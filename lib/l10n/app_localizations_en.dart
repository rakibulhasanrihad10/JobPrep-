// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JobPrep';

  @override
  String get dashboardTitle => 'JobPrep Dashboard';

  @override
  String get dashboardSubtitle =>
      'Job Circular Tracker & Exam Prep Foundations';

  @override
  String get themeSwitcherTitle => 'Theme Mode Switcher';

  @override
  String get themeSwitcherSubtitle =>
      'Choose an appearance mode (persisted with SharedPreferences)';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get lightTheme => 'Light Theme (Navy & Gold)';

  @override
  String get darkTheme => 'Dark Theme (Deep Navy & Gold)';

  @override
  String get languageSwitcherTitle => 'Language Switcher';

  @override
  String get languageSwitcherSubtitle =>
      'Choose an interface language (persisted with SharedPreferences)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা (Bangla)';

  @override
  String get tokensPreviewTitle => 'Design Tokens Preview';

  @override
  String get goldAccentButton => 'Gold Accent Button';

  @override
  String get outlinedButton => 'Outlined Button';

  @override
  String get statusSuccess => 'Success';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusDanger => 'Danger';

  @override
  String get formattersTitle => 'Locale Formatters & Plurals Preview';

  @override
  String sampleCurrency(String formattedAmount) {
    return 'Application Fee: $formattedAmount';
  }

  @override
  String sampleDate(String formattedDate) {
    return 'Exam Date: $formattedDate';
  }

  @override
  String pageProgress(String current, String total) {
    return 'Page $current of $total';
  }

  @override
  String booksCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books completed',
      one: '1 book completed',
      zero: 'No books completed yet',
    );
    return '$_temp0';
  }

  @override
  String deadlineDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days remaining until deadline',
      one: '1 day remaining until deadline',
      zero: 'Application deadline is today',
    );
    return '$_temp0';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCirculars => 'Circulars';

  @override
  String get navPrep => 'Prep';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navSettings => 'Settings';

  @override
  String get circularsTitle => 'Job Circulars';

  @override
  String get circularsSubtitle =>
      'Track active job circulars, deadlines, and requirements';

  @override
  String get prepTitle => 'Exam Preparation';

  @override
  String get prepSubtitle =>
      'Subject-wise syllabus, targets, and book tracking';

  @override
  String get calendarTitle => 'Exam Calendar';

  @override
  String get calendarSubtitle =>
      'Upcoming application deadlines and exam schedules';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'App preferences, appearance, and configurations';

  @override
  String navShortcutTooltip(String shortcut) {
    return 'Shortcut: $shortcut';
  }

  @override
  String navShortcutBadge(String digit) {
    return 'Alt+$digit';
  }

  @override
  String get authLoginRouteTitle => 'Sign In';

  @override
  String get authResetPasswordRouteTitle => 'Reset Password';

  @override
  String get authSignInTitle => 'Welcome back';

  @override
  String get authSignInSubtitle =>
      'Sign in to manage your job circulars and exam prep';

  @override
  String get authSignUpTitle => 'Create your account';

  @override
  String get authSignUpSubtitle =>
      'Start tracking circulars and study progress securely';

  @override
  String get authForgotPasswordTitle => 'Reset your password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email and we will send a password reset link';

  @override
  String get authResetPasswordTitle => 'Set a new password';

  @override
  String get authResetPasswordSubtitle =>
      'Choose a strong password of at least 8 characters';

  @override
  String get authEmailLabel => 'Email address';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authNewPasswordHint => 'At least 8 characters';

  @override
  String get authConfirmPasswordLabel => 'Confirm new password';

  @override
  String get authConfirmPasswordHint => 'Re-enter your new password';

  @override
  String get authPasswordMinLengthHelper => 'Must be at least 8 characters';

  @override
  String get authShowPasswordTooltip => 'Show password';

  @override
  String get authHidePasswordTooltip => 'Hide password';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authSendResetLinkButton => 'Send reset link';

  @override
  String get authUpdatePasswordButton => 'Update password';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authOrDivider => 'or';

  @override
  String get authForgotPasswordLink => 'Forgot password?';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account?';

  @override
  String get authAlreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get authSwitchToSignUp => 'Create account';

  @override
  String get authSwitchToSignIn => 'Sign in';

  @override
  String get authCheckEmailTitle => 'Check your email';

  @override
  String authCheckEmailMessage(String email) {
    return 'We sent a confirmation link to $email. Open the link in your inbox to confirm your account before signing in.';
  }

  @override
  String get authResetLinkSentTitle => 'Reset link sent';

  @override
  String authResetLinkSentMessage(String email) {
    return 'If an account exists for $email, we sent instructions to reset your password.';
  }

  @override
  String get authPasswordUpdatedTitle => 'Password updated';

  @override
  String get authPasswordUpdatedMessage =>
      'Your password has been updated successfully. You can now continue to your dashboard.';

  @override
  String get authContinueToDashboard => 'Continue to dashboard';

  @override
  String get authValidationEmailRequired => 'Please enter your email address.';

  @override
  String get authValidationEmailInvalid =>
      'Please enter a valid email address.';

  @override
  String get authValidationPasswordRequired => 'Please enter your password.';

  @override
  String get authValidationPasswordTooShort =>
      'Password must be at least 8 characters.';

  @override
  String get authValidationConfirmPasswordRequired =>
      'Please confirm your new password.';

  @override
  String get authValidationPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authErrorInvalidCredentials =>
      'Invalid email or password. Please check your details and try again.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Please confirm your email address before signing in. Check your inbox for the verification link.';

  @override
  String get authErrorAccountAlreadyExists =>
      'An account with this email already exists. Try signing in instead.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authErrorNetwork =>
      'Network error. Please check your internet connection and try again.';

  @override
  String get authErrorWeakPassword =>
      'Your password is too weak. Use at least 8 characters with letters and numbers.';

  @override
  String get authErrorUnknown =>
      'Something went wrong during authentication. Please try again.';

  @override
  String circularsCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount circulars',
      one: '$formattedCount circular',
      zero: 'No circulars',
    );
    return '$_temp0';
  }

  @override
  String get circularsSearchHint => 'Search by title or organization...';

  @override
  String get circularsClearSearchTooltip => 'Clear search';

  @override
  String get circularsFilterToggle => 'Filters';

  @override
  String get circularsClearFilters => 'Clear filters';

  @override
  String get circularsSortLabel => 'Sort by';

  @override
  String get circularsRefreshTooltip => 'Refresh circulars';

  @override
  String get circularsSortDeadline => 'Deadline (soonest)';

  @override
  String get circularsSortPriority => 'Priority (highest)';

  @override
  String get circularsSortCreated => 'Created date (newest)';

  @override
  String get circularsSortUpdated => 'Recently updated';

  @override
  String get circularsSortTitle => 'Title (A-Z)';

  @override
  String get circularsFilterSector => 'Sector';

  @override
  String get circularsFilterApplicationStatus => 'Application Status';

  @override
  String get circularsFilterPriority => 'Priority';

  @override
  String get circularsFilterWorkflowStatus => 'Workflow Status';

  @override
  String get circularsFilterDeadlineRange => 'Deadline Range';

  @override
  String get circularsDeadlineRangeAll => 'All deadlines';

  @override
  String get circularsDeadlineRangeUnder3OrOverdue => 'Under 3 days / Overdue';

  @override
  String get circularsDeadlineRange3To7Days => '3 to 7 days';

  @override
  String get circularsDeadlineRangeOver7Days => 'Above 7 days';

  @override
  String get circularsDeadlineRangeNext30Days => 'Next 30 days';

  @override
  String get circularsDeadlineFromLabel => 'From';

  @override
  String get circularsDeadlineToLabel => 'To';

  @override
  String get circularsClearDatesTooltip => 'Clear date range';

  @override
  String get circularsColumnTitle => 'Circular & Organization';

  @override
  String get circularsColumnSector => 'Sector';

  @override
  String get circularsColumnDeadline => 'Deadline';

  @override
  String get circularsColumnVacancies => 'Vacancies';

  @override
  String get circularsColumnStatus => 'Status';

  @override
  String circularsVacanciesCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount posts',
      one: '$formattedCount post',
      zero: 'No vacancies',
    );
    return '$_temp0';
  }

  @override
  String get circularsVacanciesUnspecified => 'Not specified';

  @override
  String get circularsOrganizationUnspecified => 'Organization not specified';

  @override
  String get circularsCountdownNoDeadline => 'No deadline';

  @override
  String get circularsCountdownToday => 'Due today';

  @override
  String circularsCountdownDaysLeft(int days, String formattedDays) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$formattedDays days left',
      one: '$formattedDays day left',
    );
    return '$_temp0';
  }

  @override
  String circularsCountdownOverdueDays(int days, String formattedDays) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$formattedDays days overdue',
      one: '$formattedDays day overdue',
      zero: 'Expired today',
    );
    return '$_temp0';
  }

  @override
  String get circularSectorGovernment => 'Government';

  @override
  String get circularSectorBcs => 'BCS';

  @override
  String get circularSectorBank => 'Bank';

  @override
  String get circularSectorAutonomous => 'Autonomous';

  @override
  String get circularSectorPrivate => 'Private';

  @override
  String get circularSectorNgo => 'NGO';

  @override
  String get circularSectorDefense => 'Defense';

  @override
  String get circularSectorOther => 'Other';

  @override
  String get circularAppStatusNotApplied => 'Not applied';

  @override
  String get circularAppStatusInProgress => 'In progress';

  @override
  String get circularAppStatusApplied => 'Applied';

  @override
  String get circularAppStatusFeePaid => 'Fee paid';

  @override
  String get circularAppStatusExempt => 'Fee exempt';

  @override
  String get circularAppStatusMissed => 'Missed';

  @override
  String get circularAppStatusNotApplicable => 'N/A';

  @override
  String get circularPriorityLow => 'Low';

  @override
  String get circularPriorityMedium => 'Medium';

  @override
  String get circularPriorityHigh => 'High';

  @override
  String get circularPriorityUrgent => 'Urgent';

  @override
  String get circularWorkflowSaved => 'Saved';

  @override
  String get circularWorkflowPreparing => 'Preparing';

  @override
  String get circularWorkflowApplied => 'Applied';

  @override
  String get circularWorkflowExamUpcoming => 'Exam upcoming';

  @override
  String get circularWorkflowResultAwaited => 'Result awaited';

  @override
  String get circularWorkflowArchived => 'Archived';

  @override
  String get circularsLoadingMessage => 'Loading job circulars...';

  @override
  String get circularsEmptyTitle => 'No job circulars yet';

  @override
  String get circularsEmptyMessage =>
      'Tracked job circulars will appear here once added.';

  @override
  String get circularsFilteredEmptyTitle => 'No matching circulars';

  @override
  String get circularsFilteredEmptyMessage =>
      'Try adjusting your search query or clearing active filters.';

  @override
  String get circularsErrorTitle => 'Unable to load circulars';

  @override
  String get circularsRetryButton => 'Retry';

  @override
  String get circularsErrorPermission =>
      'You do not have permission to view these circulars.';

  @override
  String get circularsErrorNetwork =>
      'Network error while loading circulars. Check your connection and try again.';

  @override
  String get circularsErrorUnknown =>
      'Something went wrong while loading circulars. Please try again.';
}
