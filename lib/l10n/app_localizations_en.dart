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
}
