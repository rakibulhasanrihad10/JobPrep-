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

  @override
  String get circularsAddButton => 'Add circular';

  @override
  String get circularFormAddTitle => 'Add Job Circular';

  @override
  String get circularFormAddSubtitle =>
      'Save deadlines, fees, links, and status details for a job circular.';

  @override
  String get circularFormEditTitle => 'Edit Job Circular';

  @override
  String get circularFormEditSubtitle =>
      'Update circular details, tracking status, or personal notes.';

  @override
  String get circularFormSaveButton => 'Save circular';

  @override
  String get circularFormUpdateButton => 'Save changes';

  @override
  String get circularFormCancelButton => 'Cancel';

  @override
  String get circularFormNotFoundTitle => 'Circular not found';

  @override
  String get circularFormNotFoundMessage =>
      'This job circular may have been deleted or is no longer available.';

  @override
  String get circularFormBackToList => 'Back to circulars';

  @override
  String get circularFormSectionBasics => 'Basics';

  @override
  String get circularFormSectionLinks => 'Links';

  @override
  String get circularFormSectionDatesAndNumbers => 'Dates & Numbers';

  @override
  String get circularFormSectionStatus => 'Status';

  @override
  String get circularFormSectionText => 'Instructions & Notes';

  @override
  String get circularFieldTitleLabel => 'Circular title';

  @override
  String get circularFieldTitleHint => 'e.g. 47th BCS General Cadre';

  @override
  String get circularFieldSectorLabel => 'Sector';

  @override
  String get circularFieldOrgNameLabel => 'Organization name';

  @override
  String get circularFieldOrgNameHint =>
      'e.g. Bangladesh Public Service Commission';

  @override
  String get circularFieldOrgWebsiteLabel => 'Organization website';

  @override
  String get circularFieldOrgWebsiteHint => 'https://example.gov.bd';

  @override
  String get circularFieldCircularUrlLabel => 'Original circular link';

  @override
  String get circularFieldCircularUrlHint => 'https://example.gov.bd/circular';

  @override
  String get circularFieldApplicationUrlLabel => 'Application portal link';

  @override
  String get circularFieldApplicationUrlHint => 'https://apply.example.gov.bd';

  @override
  String get circularFieldDeadlineLabel => 'Application deadline';

  @override
  String get circularFieldDeadlineNone => 'Select deadline date';

  @override
  String get circularFieldClearDeadlineTooltip => 'Clear deadline';

  @override
  String get circularFieldVacanciesLabel => 'Vacancies';

  @override
  String get circularFieldVacanciesHint => 'e.g. 150';

  @override
  String get circularFieldSalaryMinLabel => 'Minimum salary';

  @override
  String get circularFieldSalaryMinHint => 'e.g. 22000';

  @override
  String get circularFieldSalaryMaxLabel => 'Maximum salary';

  @override
  String get circularFieldSalaryMaxHint => 'e.g. 53060';

  @override
  String get circularFieldSalaryNoteLabel => 'Salary & benefits note';

  @override
  String get circularFieldSalaryNoteHint => 'e.g. Grade 9 National Pay Scale';

  @override
  String get circularFieldFeeLabel => 'Application fee';

  @override
  String get circularFieldFeeHint => 'e.g. 200';

  @override
  String get circularFieldFeeNoteLabel => 'Fee note';

  @override
  String get circularFieldFeeNoteHint => 'e.g. Payable via Teletalk / bKash';

  @override
  String get circularFieldAppStatusLabel => 'Application status';

  @override
  String get circularFieldAdmitStatusLabel => 'Admit card status';

  @override
  String get circularFieldPriorityLabel => 'Priority';

  @override
  String get circularFieldWorkflowStatusLabel => 'Workflow status';

  @override
  String get circularFieldInstructionsLabel => 'Instructions';

  @override
  String get circularFieldInstructionsHint =>
      'Eligibility criteria, required documents, photo dimensions...';

  @override
  String get circularFieldNotesLabel => 'Personal notes';

  @override
  String get circularFieldNotesHint =>
      'Reminders, preparation ideas, tracking notes...';

  @override
  String get circularFieldSyllabusLabel => 'Syllabus';

  @override
  String get circularFieldSyllabusHint =>
      'Exam subjects, mark distribution, key topics...';

  @override
  String get circularAdmitStatusNotAvailable => 'Not available';

  @override
  String get circularAdmitStatusAvailable => 'Available';

  @override
  String get circularAdmitStatusDownloaded => 'Downloaded';

  @override
  String get circularAdmitStatusNotApplicable => 'N/A';

  @override
  String get circularValidationTitleRequired =>
      'Please enter a circular title.';

  @override
  String get circularValidationInvalidUrl =>
      'Enter a valid URL starting with http:// or https://.';

  @override
  String get circularValidationInvalidInt =>
      'Enter a whole number (0 or greater).';

  @override
  String get circularValidationInvalidNumber =>
      'Enter a valid number (0 or greater).';

  @override
  String get circularValidationSalaryRange =>
      'Maximum salary cannot be lower than minimum salary.';

  @override
  String circularDuplicateLinkWarning(String title) {
    return 'Warning: \"$title\" already uses this circular link.';
  }

  @override
  String get circularFormErrorValidation =>
      'Submitted circular details failed validation checks.';

  @override
  String get circularDiscardDialogTitle => 'Discard unsaved changes?';

  @override
  String get circularDiscardDialogMessage =>
      'You have unsaved changes on this circular. Leaving now will discard them.';

  @override
  String get circularDiscardKeepEditing => 'Keep editing';

  @override
  String get circularDiscardConfirm => 'Discard changes';

  @override
  String get navInbox => 'Inbox';

  @override
  String navInboxCountSemantic(String label, String formattedCount) {
    return '$label, $formattedCount waiting';
  }

  @override
  String get circularWorkflowInbox => 'Inbox';

  @override
  String get quickCaptureButton => 'Quick capture';

  @override
  String quickCaptureShortcutTooltip(String shortcut) {
    return 'Quick capture ($shortcut)';
  }

  @override
  String get quickCaptureDialogTitle => 'Quick capture';

  @override
  String get quickCaptureDialogSubtitle =>
      'Paste a circular link now and fill in the rest later from your Inbox.';

  @override
  String get quickCaptureLinkLabel => 'Circular link';

  @override
  String get quickCaptureLinkHint => 'https://...';

  @override
  String get quickCaptureLinkRequired => 'Please enter the circular link.';

  @override
  String get quickCaptureTitleLabel => 'Title (optional)';

  @override
  String get quickCaptureTitleHint =>
      'Optional — uses website name if left blank';

  @override
  String get quickCaptureDeadlineLabel => 'Deadline (optional)';

  @override
  String get quickCaptureSaveAction => 'Save to Inbox';

  @override
  String get quickCaptureSavingAction => 'Saving...';

  @override
  String quickCaptureSavedSnackbar(String title) {
    return 'Saved \"$title\" to Inbox.';
  }

  @override
  String get quickCaptureViewInboxAction => 'View Inbox';

  @override
  String get inboxTitle => 'Inbox';

  @override
  String inboxCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount quick-captured items waiting',
      one: '1 quick-captured item waiting',
      zero: 'No quick-captured items waiting',
    );
    return '$_temp0';
  }

  @override
  String get inboxEmptyTitle => 'Your Inbox is clear';

  @override
  String get inboxEmptyMessage =>
      'Use Quick capture (or press Alt+Q on web) from any screen to drop a circular link here for later triage.';

  @override
  String inboxCapturedOn(String formattedDate) {
    return 'Captured $formattedDate';
  }

  @override
  String get inboxCompleteDetailsAction => 'Complete details';

  @override
  String get inboxSkipAction => 'Skip';

  @override
  String get inboxDeleteAction => 'Delete';

  @override
  String get inboxRefreshTooltip => 'Refresh inbox';

  @override
  String inboxActionSkipped(String title) {
    return 'Moved \"$title\" out of Inbox.';
  }

  @override
  String inboxActionDeleted(String title) {
    return 'Deleted \"$title\".';
  }

  @override
  String get circularDetailBackTooltip => 'Back to circulars';

  @override
  String get circularDetailCloseTooltip => 'Close details';

  @override
  String get circularDetailEditAction => 'Edit';

  @override
  String get circularDetailDeleteAction => 'Delete';

  @override
  String get circularDetailDeleteTitle => 'Delete this circular?';

  @override
  String circularDetailDeleteMessage(String title) {
    return '\"$title\" and any scheduled exam dates will be removed permanently.';
  }

  @override
  String get circularDetailQuickCaptureBadge => 'Quick captured';

  @override
  String get circularDetailLaunchFailed =>
      'Unable to open this link right now.';

  @override
  String get circularDetailQuickActionsTitle => 'Quick status & checklist';

  @override
  String get circularDetailChecklistTitle => 'Application checklist';

  @override
  String circularDetailChecklistProgress(
      String formattedDone, String formattedTotal) {
    return '$formattedDone of $formattedTotal done';
  }

  @override
  String get checklistPhoto => 'Photo prepared';

  @override
  String get checklistCertificates => 'Certificates ready';

  @override
  String get checklistFeePaid => 'Fee paid';

  @override
  String get checklistSubmitted => 'Submitted';

  @override
  String get checklistAdmitCardDownloaded => 'Admit card downloaded';

  @override
  String get circularDetailLinksTitle => 'Official links';

  @override
  String get circularDetailOpenCircularLink => 'Original circular link';

  @override
  String get circularDetailOpenApplicationPortal => 'Application portal';

  @override
  String get circularDetailOpenOrgWebsite => 'Organization website';

  @override
  String get circularDetailLinkMissing => 'Not provided';

  @override
  String get circularDetailOverviewTitle => 'Overview & compensation';

  @override
  String get circularDetailFieldDeadline => 'Deadline';

  @override
  String get circularDetailFieldVacancies => 'Vacancies';

  @override
  String get circularDetailFieldSalary => 'Salary range';

  @override
  String get circularDetailFieldSalaryNote => 'Salary note';

  @override
  String get circularDetailFieldFee => 'Application fee';

  @override
  String get circularDetailFieldFeeNote => 'Fee note';

  @override
  String get circularDetailFieldCreated => 'Added on';

  @override
  String get circularDetailFieldUpdated => 'Last updated';

  @override
  String get circularDetailNotProvided => 'Not specified';

  @override
  String circularDetailSalaryRange(String min, String max) {
    return '$min - $max';
  }

  @override
  String circularDetailSalaryFrom(String min) {
    return 'From $min';
  }

  @override
  String circularDetailSalaryUpTo(String max) {
    return 'Up to $max';
  }

  @override
  String get circularDetailExamDatesTitle => 'Exam dates';

  @override
  String get examDateAddAction => 'Add exam date';

  @override
  String get examDateUpcomingHeading => 'Upcoming exams';

  @override
  String get examDatePastHeading => 'Past exams';

  @override
  String get examDateEmptyMessage =>
      'No exam dates added yet. Track preliminary, written, viva, or practical stages here.';

  @override
  String get examDateStageLabel => 'Exam stage';

  @override
  String get examDateStagePreliminary => 'Preliminary';

  @override
  String get examDateStageWritten => 'Written';

  @override
  String get examDateStageViva => 'Viva';

  @override
  String get examDateStagePractical => 'Practical';

  @override
  String get examDateStageOther => 'Other';

  @override
  String get examDateDateLabel => 'Exam date & time';

  @override
  String get examDatePickDateAction => 'Change date';

  @override
  String get examDatePickTimeAction => 'Change time';

  @override
  String get examDateVenueLabel => 'Venue (optional)';

  @override
  String get examDateVenueHint => 'e.g. Dhaka College / BPSC HQ';

  @override
  String get examDateNotesLabel => 'Notes (optional)';

  @override
  String get examDateNotesHint => 'Reporting time, seat plan, documents...';

  @override
  String get examDateDialogAddTitle => 'Add exam date';

  @override
  String get examDateDialogEditTitle => 'Edit exam date';

  @override
  String get examDateEditTooltip => 'Edit exam date';

  @override
  String get examDateDeleteTooltip => 'Delete exam date';

  @override
  String get circularDetailNotesTitle => 'Instructions, notes & syllabus';

  @override
  String get circularFilesTitle => 'Files & attachments';

  @override
  String circularFilesAllowedHelper(String maxSize) {
    return 'PDF, PNG, JPG, WEBP • Max $maxSize (large images are resized)';
  }

  @override
  String get circularFilesUploadButton => 'Upload file';

  @override
  String circularFilesUploading(String fileName, String percent) {
    return 'Uploading $fileName ($percent%)';
  }

  @override
  String get circularFilesEmpty =>
      'No files attached yet. Upload a circular PDF, admit card, or image.';

  @override
  String get circularFilesLoadError => 'Could not load attachments right now.';

  @override
  String get circularFilesRetry => 'Retry';

  @override
  String get circularFilesPreviewAction => 'Preview';

  @override
  String get circularFilesDownloadAction => 'Download';

  @override
  String get circularFilesDeleteAction => 'Delete';

  @override
  String get circularFilesPreviewTitle => 'File preview';

  @override
  String get circularFilesPreviewPdfMessage =>
      'PDF files open with a temporary signed link in your browser or PDF viewer.';

  @override
  String get circularFilesOpenSignedLink => 'Open signed link';

  @override
  String get circularFilesPreviewLoadError =>
      'Could not display preview inline. Open the temporary signed link instead.';

  @override
  String get circularFilesCloseAction => 'Close';

  @override
  String get circularFilesSignedUrlSecurityNote =>
      'Protected with a temporary signed URL (never public).';

  @override
  String get circularFilesDeleteConfirmTitle => 'Delete attachment?';

  @override
  String circularFilesDeleteConfirmBody(String fileName) {
    return 'Remove \"$fileName\" permanently from this circular?';
  }

  @override
  String get circularFilesCancelAction => 'Cancel';

  @override
  String get circularFilesConfirmDeleteAction => 'Delete';

  @override
  String get circularFilesErrorUnsupportedType =>
      'Only PDF, PNG, JPG, JPEG, and WEBP files are supported.';

  @override
  String get circularFilesErrorEmptyFile => 'The selected file is empty.';

  @override
  String circularFilesErrorFileTooLarge(String maxSize) {
    return 'File exceeds the $maxSize limit.';
  }

  @override
  String circularFilesErrorRawImageTooLarge(String maxSize) {
    return 'Image is too large to process (max $maxSize).';
  }

  @override
  String get circularFilesErrorOpenLinkFailed =>
      'Could not open the signed file link.';

  @override
  String circularFilesSizeBytes(String count) {
    return '$count B';
  }

  @override
  String circularFilesSizeKb(String count) {
    return '$count KB';
  }

  @override
  String circularFilesSizeMb(String count) {
    return '$count MB';
  }

  @override
  String circularFilesCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount files',
      one: '1 file',
      zero: '0 files',
    );
    return '$_temp0';
  }

  @override
  String get circularFilesTypePdf => 'PDF';

  @override
  String get circularFilesTypeImage => 'Image';

  @override
  String get calendarPreviousMonthTooltip => 'Previous month';

  @override
  String get calendarNextMonthTooltip => 'Next month';

  @override
  String get calendarTodayButton => 'Today';

  @override
  String get calendarEventDeadline => 'Deadline';

  @override
  String get calendarEventPreliminary => 'Preliminary';

  @override
  String get calendarEventWritten => 'Written';

  @override
  String get calendarEventViva => 'Viva';

  @override
  String get calendarEventPractical => 'Practical';

  @override
  String get calendarEventOther => 'Other exam';

  @override
  String get calendarLegendTitle => 'Color legend';

  @override
  String calendarAgendaCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get calendarAgendaEmptyDay =>
      'No deadlines or exam dates on this day.';

  @override
  String get calendarEmptyMonthHint =>
      'Add deadlines or exam dates to your circulars to track them on this calendar.';

  @override
  String get calendarLoadError => 'Could not load your schedule right now.';

  @override
  String get calendarRetry => 'Retry';

  @override
  String get calendarOpenCircularAction => 'Open circular';

  @override
  String calendarMoreEvents(String formattedCount) {
    return '+$formattedCount';
  }

  @override
  String calendarWeekStartsNote(String dayName) {
    return 'Week starts on $dayName';
  }
}
