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

  @override
  String get prepSubjectsSectionTitle => 'Subjects';

  @override
  String get prepOverallProgressLabel => 'Overall progress';

  @override
  String prepSubjectCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount subjects',
      one: '1 subject',
      zero: 'No subjects',
    );
    return '$_temp0';
  }

  @override
  String prepMaterialCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount materials',
      one: '1 material',
      zero: 'No materials',
    );
    return '$_temp0';
  }

  @override
  String get prepAddSubjectButton => 'Add subject';

  @override
  String get prepAddMaterialButton => 'Add material';

  @override
  String get prepRefreshTooltip => 'Refresh subjects and materials';

  @override
  String get prepLoadError => 'Could not load preparation subjects right now.';

  @override
  String get prepSelectSubjectPrompt =>
      'Select a subject from the list to view and manage its study materials.';

  @override
  String get prepEmptySubjectsTitle => 'No subjects yet';

  @override
  String get prepEmptySubjectsBody =>
      'Create subjects for your target career or exam track, then add books, courses, notes, or question banks inside each.';

  @override
  String prepEmptyMaterialsTitle(String subjectName) {
    return 'No materials in $subjectName';
  }

  @override
  String get prepEmptyMaterialsBody =>
      'Add books, lecture sheets, video courses, or mock tests with any unit label you prefer.';

  @override
  String get prepBackToSubjects => 'Back to subjects';

  @override
  String get prepCreateSubjectTitle => 'New subject';

  @override
  String get prepEditSubjectTitle => 'Edit subject';

  @override
  String get prepSubjectNameLabel => 'Subject name';

  @override
  String get prepSubjectNameHint =>
      'e.g. English Grammar, Anatomy, Data Structures';

  @override
  String get prepSubjectNameRequired => 'Subject name is required.';

  @override
  String get prepExamTypeLabel => 'Exam or career track';

  @override
  String get prepExamTypeHint => 'Type any track or pick a suggestion below';

  @override
  String get prepExamTypeRequired => 'Exam or career track is required.';

  @override
  String get prepExamTrackGeneral => 'General';

  @override
  String get prepExamTrackBcs => 'BCS';

  @override
  String get prepExamTrackBank => 'Bank';

  @override
  String get prepExamTrackGovt => 'Govt Job';

  @override
  String get prepExamTrackMedical => 'Medical';

  @override
  String get prepExamTrackEngineering => 'Engineering';

  @override
  String get prepExamTrackIelts => 'IELTS';

  @override
  String get prepSubjectColorLabel => 'Color';

  @override
  String get prepColorGold => 'Gold';

  @override
  String get prepColorInfo => 'Sky Blue';

  @override
  String get prepColorSuccess => 'Emerald';

  @override
  String get prepColorWarning => 'Amber';

  @override
  String get prepColorDanger => 'Coral Red';

  @override
  String get prepColorAccentSecondary => 'Violet';

  @override
  String get prepSubjectIconLabel => 'Icon';

  @override
  String get prepIconMenuBook => 'Book';

  @override
  String get prepIconCalculate => 'Math';

  @override
  String get prepIconLanguage => 'Language';

  @override
  String get prepIconPublic => 'Global / GK';

  @override
  String get prepIconScience => 'Science';

  @override
  String get prepIconComputer => 'Computing';

  @override
  String get prepIconAccountBalance => 'Finance / Law';

  @override
  String get prepIconPsychology => 'Aptitude';

  @override
  String get prepIconGavel => 'Constitution';

  @override
  String get prepIconQuiz => 'Quiz / Mock';

  @override
  String get prepSaveButton => 'Save';

  @override
  String get prepCancelButton => 'Cancel';

  @override
  String get prepEditAction => 'Edit';

  @override
  String get prepDeleteAction => 'Delete';

  @override
  String get prepMoveUpTooltip => 'Move subject up';

  @override
  String get prepMoveDownTooltip => 'Move subject down';

  @override
  String get prepDragReorderTooltip => 'Drag to reorder';

  @override
  String get prepCreateMaterialTitle => 'New material';

  @override
  String get prepEditMaterialTitle => 'Edit material';

  @override
  String get prepMaterialTitleLabel => 'Material title';

  @override
  String get prepMaterialTitleHint =>
      'e.g. Official Guide, Clinical Handbook, System Design';

  @override
  String get prepMaterialTitleRequired => 'Material title is required.';

  @override
  String get prepMaterialKindLabel => 'Type';

  @override
  String get prepMaterialKindBook => 'Book';

  @override
  String get prepMaterialKindVideoCourse => 'Video course';

  @override
  String get prepMaterialKindLectureSheet => 'Lecture sheet';

  @override
  String get prepMaterialKindQuestionBank => 'Question bank';

  @override
  String get prepMaterialKindNotes => 'Notes';

  @override
  String get prepMaterialKindMockTest => 'Mock test';

  @override
  String get prepMaterialKindOther => 'Other';

  @override
  String get prepUnitLabelFieldLabel => 'Unit label';

  @override
  String get prepUnitLabelHint => 'e.g. pages, lectures, chapters, sets';

  @override
  String get prepUnitLabelRequired => 'Unit label is required.';

  @override
  String get prepUnitPresetPages => 'pages';

  @override
  String get prepUnitPresetChapters => 'chapters';

  @override
  String get prepUnitPresetLectures => 'lectures';

  @override
  String get prepUnitPresetVideos => 'videos';

  @override
  String get prepUnitPresetQuestions => 'questions';

  @override
  String get prepUnitPresetTests => 'tests';

  @override
  String get prepTotalUnitsLabel => 'Total units';

  @override
  String get prepTotalUnitsHint => 'e.g. 300';

  @override
  String get prepTotalUnitsInvalid =>
      'Enter a whole number greater than or equal to 0.';

  @override
  String prepMaterialProgressSummary(
      String completed, String total, String unitLabel) {
    return '$completed / $total $unitLabel';
  }

  @override
  String prepPercentComplete(String percent) {
    return '$percent% complete';
  }

  @override
  String get prepCoverSectionLabel => 'Cover image (optional)';

  @override
  String get prepCoverModeNone => 'None';

  @override
  String get prepCoverModeUpload => 'Upload photo';

  @override
  String get prepCoverModeUrl => 'Paste link';

  @override
  String get prepCoverPickButton => 'Choose JPG, PNG or WEBP';

  @override
  String get prepCoverReplaceButton => 'Replace photo';

  @override
  String get prepCoverRemoveButton => 'Remove cover';

  @override
  String prepCoverResizedNote(String formattedWidth) {
    return 'Resized to $formattedWidth px wide for upload.';
  }

  @override
  String get prepCoverUrlLabel => 'Image URL';

  @override
  String get prepCoverUrlHint => 'https://example.com/cover.jpg';

  @override
  String get prepCoverPlaceholderHint =>
      'Without a cover image, a glass initial badge is displayed automatically.';

  @override
  String get prepCoverErrorUnsupportedType =>
      'Only JPG, PNG, and WEBP images are supported.';

  @override
  String get prepCoverErrorEmptyFile => 'The selected cover image is empty.';

  @override
  String prepCoverErrorTooLarge(String maxSize) {
    return 'Cover image exceeds the $maxSize limit.';
  }

  @override
  String prepCoverErrorRawTooLarge(String maxSize) {
    return 'Image is too large to process (max $maxSize).';
  }

  @override
  String get prepCoverErrorInvalidUrl =>
      'Enter a valid http:// or https:// image URL.';

  @override
  String get prepCoverUploadProgress => 'Resizing and uploading cover...';

  @override
  String prepDeleteSubjectTitle(String subjectName) {
    return 'Delete \"$subjectName\"?';
  }

  @override
  String get prepDeleteSubjectBody =>
      'This will remove the subject and all materials inside it.';

  @override
  String prepDeleteSubjectProgressWarning(String formattedUnits) {
    return 'Warning: this subject has logged progress ($formattedUnits completed units across materials). Deleting it will permanently remove that progress.';
  }

  @override
  String prepDeleteMaterialTitle(String materialTitle) {
    return 'Delete \"$materialTitle\"?';
  }

  @override
  String get prepDeleteMaterialBody =>
      'Are you sure you want to remove this material from the subject?';

  @override
  String prepDeleteMaterialProgressWarning(String formattedCompleted,
      String formattedTotal, String unitLabel, String percent) {
    return 'Warning: you have already logged $formattedCompleted of $formattedTotal $unitLabel ($percent% complete). Deleting this material will also remove its logged progress.';
  }

  @override
  String get prepDeleteConfirmButton => 'Delete';

  @override
  String get prepErrorPermission =>
      'You do not have permission to update this preparation item.';

  @override
  String get prepErrorNetwork =>
      'Network issue while saving. Please try again.';

  @override
  String get prepErrorNotFound => 'That preparation item could not be found.';

  @override
  String get prepErrorUnknown =>
      'Something went wrong while updating preparation data.';

  @override
  String prepOverallUnitsSummary(
      String formattedCompleted, String formattedTotal) {
    return '$formattedCompleted / $formattedTotal total units';
  }

  @override
  String prepQuickLogPlus(String formattedAmount) {
    return '+$formattedAmount';
  }

  @override
  String get prepLogButton => 'Log';

  @override
  String get prepLogDialogTitle => 'Log progress';

  @override
  String get prepCustomUnitsLabel => 'Units completed';

  @override
  String get prepCustomUnitsHint => 'e.g. 25';

  @override
  String get prepCustomUnitsInvalid => 'Enter a whole number greater than 0.';

  @override
  String get prepLogDateLabel => 'Date';

  @override
  String get prepLogNoteLabel => 'Note (optional)';

  @override
  String get prepLogNoteHint => 'e.g. Chapters 1-3, revision set';

  @override
  String get prepLogSaveButton => 'Save log';

  @override
  String get prepLogUpdateButton => 'Update log';

  @override
  String get prepLogCancelEditButton => 'Cancel edit';

  @override
  String get prepEditingLogBanner => 'Editing existing log entry';

  @override
  String get prepPastLogsTitle => 'Past study logs';

  @override
  String get prepNoPastLogs => 'No study logs recorded for this material yet.';

  @override
  String prepLogUnitsSummary(String formattedUnits, String unitLabel) {
    return '+$formattedUnits $unitLabel';
  }

  @override
  String get prepTemplatesTitle => 'Start quickly with a template';

  @override
  String get prepTemplatesSubtitle =>
      'Apply a preset study plan you can freely customize, reorder, or delete anytime.';

  @override
  String get prepApplyTemplateButton => 'Apply template';

  @override
  String get prepTemplatesOpenButton => 'Templates';

  @override
  String get prepTemplatesDialogTitle => 'Study Templates';

  @override
  String get prepTemplatesSystemSection => 'Starter packs';

  @override
  String get prepTemplatesPersonalSection => 'Your personal templates';

  @override
  String get prepTemplatesPersonalEmpty =>
      'Save your current subjects as a personal template so you can reuse or share your plan anytime.';

  @override
  String get prepTemplateSystemBadge => 'Starter pack';

  @override
  String get prepTemplatePersonalBadge => 'Personal';

  @override
  String get prepTemplateAppliedBadge => 'Applied';

  @override
  String get prepTemplateCustomizeButton => 'Edit units';

  @override
  String get prepTemplateApplyAgainButton => 'Re-apply';

  @override
  String prepTemplateApplyConfirmTitle(String title) {
    return 'Customize & apply \"$title\"';
  }

  @override
  String get prepTemplateApplyConfirmSubtitle =>
      'Adjust unit counts below before copying into your own prep subjects. Everything remains fully editable afterward.';

  @override
  String get prepTemplateConfirmApplyAction => 'Copy to my prep plan';

  @override
  String prepTemplateAppliedSnackbar(int subjectCount, String formattedSubjects,
      int materialCount, String formattedMaterials, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      subjectCount,
      locale: localeName,
      other: '$formattedSubjects subjects',
      one: '1 subject',
      zero: '0 subjects',
    );
    String _temp1 = intl.Intl.pluralLogic(
      materialCount,
      locale: localeName,
      other: '$formattedMaterials materials',
      one: '1 material',
      zero: '0 materials',
    );
    return 'Copied $_temp0 and $_temp1 from \"$title\".';
  }

  @override
  String prepTemplateAlreadyAppliedSnackbar(String title) {
    return 'All subjects and materials from \"$title\" are already in your plan (no duplicates created).';
  }

  @override
  String get prepSaveAsTemplateButton => 'Save as template';

  @override
  String get prepSaveTemplateDialogTitle => 'Save personal template';

  @override
  String get prepSaveTemplateTitleLabel => 'Template name';

  @override
  String get prepSaveTemplateTitleHint => 'e.g. 48th BCS Core Plan';

  @override
  String get prepSaveTemplateTitleRequired => 'Please enter a template name.';

  @override
  String get prepSaveTemplateDescLabel => 'Description (optional)';

  @override
  String get prepSaveTemplateDescHint =>
      'Short summary of subjects and target role';

  @override
  String get prepSaveTemplateExamLabel => 'Career or exam track';

  @override
  String prepSaveTemplatePreviewSummary(
      String formattedSubjects, String formattedMaterials) {
    return 'Copies $formattedSubjects subjects and $formattedMaterials materials into this reusable template';
  }

  @override
  String get prepSaveTemplateSaveAction => 'Save template';

  @override
  String prepSaveTemplateSavedSnackbar(String title) {
    return 'Saved personal template \"$title\".';
  }

  @override
  String get prepDeleteTemplateTitle => 'Delete personal template?';

  @override
  String prepDeleteTemplateMessage(String title) {
    return 'Delete \"$title\"? Any subjects and materials already copied into your prep dashboard stay untouched.';
  }

  @override
  String prepDeleteTemplateDeletedSnackbar(String title) {
    return 'Deleted personal template \"$title\".';
  }

  @override
  String get prepTemplateUnitsInvalid =>
      'Enter zero or a positive whole number.';

  @override
  String get prepSeededGovJobTitle => 'Government Job';

  @override
  String get prepSeededGovJobSubtitle =>
      'Bengali, English, General Knowledge, Mathematics, Analytical Reasoning, and Computer with customizable materials.';

  @override
  String get prepSeededSweTitle => 'Software Engineer';

  @override
  String get prepSeededSweSubtitle =>
      'Data Structures & Algorithms, Database Systems, OOP, Web Development, and Software Quality Assurance.';

  @override
  String get dashboardHomeSubtitle =>
      'Your job circulars, upcoming dates, and study momentum at a glance.';

  @override
  String get dashboardRefreshTooltip => 'Refresh dashboard';

  @override
  String get dashboardLoadError => 'Could not load dashboard summary.';

  @override
  String get dashboardWelcomeTitle => 'Welcome to JobPrep';

  @override
  String get dashboardWelcomeBody =>
      'Track job circulars, checklists, exam dates, and study progress in one calm workspace.';

  @override
  String get dashboardWelcomeAddCircular => 'Add first circular';

  @override
  String get dashboardWelcomeSetupPrep => 'Set up study plan';

  @override
  String get dashboardMetricDeadlinesWeek => 'Deadlines this week';

  @override
  String get dashboardMetricInbox => 'Inbox items';

  @override
  String get dashboardMetricExams14Days => 'Exams in 14 days';

  @override
  String get dashboardMetricSubmitted => 'Applications submitted';

  @override
  String get dashboardMetricOverallPrep => 'Overall prep';

  @override
  String get dashboardContinueStudyingTitle => 'Continue studying';

  @override
  String get dashboardContinueStudyingAction => 'Continue studying';

  @override
  String dashboardContinueStudyingLastLogged(
      String formattedUnits, String unitLabel, String formattedDate) {
    return '+$formattedUnits $unitLabel on $formattedDate';
  }

  @override
  String dashboardMaterialProgressLine(String formattedCompleted,
      String formattedTotal, String unitLabel, String percent) {
    return '$formattedCompleted / $formattedTotal $unitLabel ($percent%)';
  }

  @override
  String get dashboardContinueStudyingEmptyTitle => 'No study logs yet';

  @override
  String get dashboardContinueStudyingEmptyBody =>
      'Log a study session in Prep and jump straight back into your book or course from here.';

  @override
  String get dashboardContinueStudyingEmptyAction => 'Open Prep';

  @override
  String get dashboardUpcomingDeadlinesTitle => 'Upcoming deadlines';

  @override
  String get dashboardUpcomingDeadlinesEmptyTitle => 'No upcoming deadlines';

  @override
  String get dashboardUpcomingDeadlinesEmptyBody =>
      'Saved circulars with future deadlines will appear here with color-coded countdowns.';

  @override
  String get dashboardViewAllAction => 'View all';

  @override
  String get dashboardUpcomingExamsTitle => 'Upcoming exams';

  @override
  String get dashboardUpcomingExamsEmptyTitle => 'No upcoming exams scheduled';

  @override
  String get dashboardUpcomingExamsEmptyBody =>
      'Add Preliminary, Written, or Viva dates on a circular to keep track of upcoming sittings here.';

  @override
  String get dashboardOpenCalendarAction => 'Open calendar';

  @override
  String get dashboardExamToday => 'Today';

  @override
  String dashboardExamInDays(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $formattedCount days',
      one: 'In 1 day',
    );
    return '$_temp0';
  }

  @override
  String get settingsRemindersTitle => 'Email Reminders';

  @override
  String get settingsRemindersSubtitle =>
      'Receive daily alerts for circular deadlines and exam dates 7, 3, and 1 days ahead.';

  @override
  String get settingsRemindersToggleLabel => 'Enable daily email reminders';

  @override
  String get settingsRemindersToggleHintEnabled =>
      'Reminders are sent once per milestone using your saved account email.';

  @override
  String get settingsRemindersToggleHintDisabled =>
      'Email reminders are paused. Turn them on anytime without losing saved circulars.';

  @override
  String get settingsRemindersLanguageTitle => 'Reminder email language';

  @override
  String get settingsRemindersLanguageSubtitle =>
      'Choose which language daily reminder emails are written in.';

  @override
  String get settingsRemindersSaveError =>
      'Could not save reminder settings. Please try again.';

  @override
  String get settingsRemindersLoadError => 'Could not load reminder settings.';

  @override
  String get settingsRemindersOfflineHint =>
      'Connect Supabase to persist email reminder preferences across devices.';

  @override
  String get vaultTitle => 'Portal Vault';

  @override
  String get vaultSubtitle =>
      'Protect saved application portal logins with your local vault passphrase.';

  @override
  String get vaultStatusLocked => 'Locked';

  @override
  String get vaultStatusUnlocked => 'Unlocked';

  @override
  String get vaultSetupButton => 'Set up vault';

  @override
  String get vaultUnlockButton => 'Unlock vault';

  @override
  String get vaultLockButton => 'Lock vault';

  @override
  String get vaultSetupDialogTitle => 'Create Vault Passphrase';

  @override
  String get vaultSetupDialogBody =>
      'Choose a strong passphrase to encrypt your portal passwords on this device.';

  @override
  String get vaultUnrecoverableWarning =>
      'Important: A forgotten passphrase cannot be recovered or reset. Any saved passwords cannot be decrypted without it.';

  @override
  String get vaultAcknowledgeWarningLabel =>
      'I understand that a forgotten passphrase cannot be recovered.';

  @override
  String get vaultAcknowledgeRequiredError =>
      'Please confirm that you understand the recovery warning.';

  @override
  String get vaultPassphraseLabel => 'Vault passphrase';

  @override
  String get vaultPassphraseConfirmLabel => 'Confirm passphrase';

  @override
  String get vaultPassphraseTooShortError => 'Enter at least 8 characters.';

  @override
  String get vaultPassphraseMismatchError => 'Passphrases do not match.';

  @override
  String get vaultCreateAndUnlockAction => 'Create & unlock';

  @override
  String get vaultUnlockDialogTitle => 'Unlock Portal Vault';

  @override
  String get vaultUnlockDialogBody =>
      'Enter your vault passphrase to view, copy, and manage saved portal accounts.';

  @override
  String get vaultWrongPassphraseError =>
      'Incorrect vault passphrase. Please try again.';

  @override
  String get vaultAutoLockNote =>
      'Auto-locks after inactivity and whenever you sign out.';

  @override
  String get vaultPortalLockedHint =>
      'Portal logins are hidden while the vault is locked.';

  @override
  String get portalSectionTitle => 'Portal Login';

  @override
  String get portalAddAccountButton => 'Add account';

  @override
  String get portalEmptyState =>
      'No portal accounts saved for this circular yet.';

  @override
  String get portalAddDialogTitle => 'Add Portal Account';

  @override
  String get portalEditDialogTitle => 'Edit Portal Account';

  @override
  String get portalUrlLabel => 'Portal URL (optional)';

  @override
  String get portalUsernameLabel => 'User ID / Username';

  @override
  String get portalUsernameRequiredError => 'User ID is required.';

  @override
  String get portalPasswordLabel => 'Password';

  @override
  String get portalPasswordRequiredError => 'Password is required.';

  @override
  String get portalNotesLabel => 'Notes (optional)';

  @override
  String get portalCopyUserIdAction => 'Copy ID';

  @override
  String get portalCopyPasswordAction => 'Copy password';

  @override
  String get portalOpenUrlAction => 'Open portal';

  @override
  String get portalRevealPasswordTooltip => 'Show password';

  @override
  String get portalHidePasswordTooltip => 'Hide password';

  @override
  String portalCopiedClipboardNotice(String formattedSeconds) {
    return 'Copied to clipboard — clears in ${formattedSeconds}s.';
  }

  @override
  String get portalDeleteConfirmTitle => 'Delete portal account?';

  @override
  String portalDeleteConfirmMessage(String username) {
    return 'Remove saved portal login \"$username\" from this circular?';
  }

  @override
  String get portalSaveError =>
      'Could not save portal account. Please try again.';

  @override
  String get portalLoadError => 'Could not load portal accounts.';

  @override
  String get prepStudyPlanSectionTitle => 'Study Plans';

  @override
  String get prepStudyPlanAddButton => 'Set study plan';

  @override
  String get prepStudyPlanCreateTitle => 'Create Study Plan';

  @override
  String get prepStudyPlanEditTitle => 'Edit Study Plan';

  @override
  String get prepStudyPlanScopeLabel => 'Plan scope';

  @override
  String get prepStudyPlanAllSubjectsLabel => 'All subjects (combined)';

  @override
  String get prepStudyPlanCircularLabel => 'Linked exam circular (optional)';

  @override
  String get prepStudyPlanNoCircularOption => 'No circular link (custom date)';

  @override
  String get prepStudyPlanExamStageLabel => 'Circular exam stage (optional)';

  @override
  String get prepStudyPlanStartDateLabel => 'Start date';

  @override
  String prepStudyPlanStartDateValue(String formattedDate) {
    return 'Start date: $formattedDate';
  }

  @override
  String get prepStudyPlanTargetDateLabel => 'Exam date';

  @override
  String prepStudyPlanTargetDateValue(String formattedDate) {
    return 'Exam date: $formattedDate';
  }

  @override
  String get prepStudyPlanBufferDaysLabel => 'Finish buffer (days before exam)';

  @override
  String get prepStudyPlanRestDaysLabel => 'Rest days per week';

  @override
  String get prepStudyPlanMaxPaceLabel =>
      'Max daily pace limit (units/day, optional)';

  @override
  String get prepStudyPlanMaxPaceHint => 'Leave blank for no pace cap';

  @override
  String get prepStudyPlanSaveButton => 'Save plan';

  @override
  String get prepStudyPlanDeleteTitle => 'Delete study plan?';

  @override
  String get prepStudyPlanDeleteBody =>
      'Remove this study plan? Your subjects, materials, and progress logs will stay untouched.';

  @override
  String get prepStudyPlanStatusAhead => 'Ahead';

  @override
  String get prepStudyPlanStatusOnTrack => 'On track';

  @override
  String get prepStudyPlanStatusBehind => 'Behind';

  @override
  String get prepStudyPlanRemainingLabel => 'Remaining';

  @override
  String get prepStudyPlanDaysLeftLabel => 'Study days left';

  @override
  String get prepStudyPlanTodayTargetLabel => 'Today\'s target';

  @override
  String prepStudyPlanUnitsCount(String formatted) {
    return '$formatted units';
  }

  @override
  String prepStudyPlanDaysCount(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted days',
      one: '$formatted day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String prepStudyPlanTodayDoneOfTarget(String done, String target) {
    return '$done / $target today';
  }

  @override
  String prepStudyPlanBufferSummary(String formattedDays, String examDate) {
    return 'Finishes ${formattedDays}d before exam ($examDate)';
  }

  @override
  String get prepStudyPlanFinishedComplete =>
      'Syllabus complete — today\'s target is 0.';

  @override
  String prepStudyPlanMissedRedistributed(int days, String formattedUnits,
      String formattedDays, String formattedExtra) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'You missed $formattedUnits units, they are now spread over the next $formattedDays days (+$formattedExtra/day).',
      one:
          'You missed $formattedUnits units, they are now spread over the next $formattedDays day (+$formattedExtra/day).',
    );
    return '$_temp0';
  }

  @override
  String prepStudyPlanPastTargetNotice(String formattedUnits) {
    return 'Study window before the finish buffer has ended with $formattedUnits units left.';
  }

  @override
  String prepStudyPlanPaceWarning(
      String formattedTarget, String formattedLimit) {
    return 'Recalculated target ($formattedTarget/day) exceeds your pace limit ($formattedLimit/day).';
  }

  @override
  String get prepStudyPlanActionConvertRest =>
      'Turn a rest day into a study day';

  @override
  String get prepStudyPlanActionRaisePace => 'Raise pace limit';

  @override
  String get prepStudyPlanActionPostponeMaterial =>
      'Postpone lower-priority material';

  @override
  String get prepStudyPlanRaisePaceTitle => 'Raise Daily Pace Limit';

  @override
  String get prepStudyPlanPostponeTitle => 'Postpone Material';

  @override
  String get prepStudyPlanPostponeSubtitle =>
      'Excluding a material removes its remaining units from this plan\'s daily target without deleting your study progress.';

  @override
  String prepStudyPlanPostponedChip(String title) {
    return 'Postponed: $title';
  }

  @override
  String get prepStudyPlanRestoreTooltip => 'Restore to plan';

  @override
  String get prepStudyPlanEditTooltip => 'Edit study plan';

  @override
  String get prepStudyPlanDeleteTooltip => 'Delete study plan';

  @override
  String get prepStudyPlanValidationBuffer =>
      'Finish buffer must be 0 days or greater.';

  @override
  String get prepStudyPlanValidationPace =>
      'Pace limit must be greater than 0.';

  @override
  String get prepStudyPlanValidationDates =>
      'Exam date must be on or after the start date.';

  @override
  String get dashboardTodayTargetTitle => 'Today\'s Target';

  @override
  String get dashboardTodayTargetEmptyTitle => 'No study plan configured yet';

  @override
  String get dashboardTodayTargetEmptyBody =>
      'Set an exam date to calculate daily targets and automatic missed-day redistribution.';

  @override
  String get dashboardTodayTargetEmptyAction => 'Set study plan';

  @override
  String get dashboardTodayTargetManageAction => 'Open study plans';

  @override
  String dashboardTodayTargetPlansSummary(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted active plans',
      one: '$formatted active plan',
    );
    return '$_temp0';
  }

  @override
  String get prepTabSubjects => 'Subjects';

  @override
  String get prepTabMockTests => 'Mock tests';

  @override
  String get prepMockTestsTitle => 'Mock tests';

  @override
  String get prepMockTestsSubtitle =>
      'Track scores after negative marking, time taken, and weak topics across platforms.';

  @override
  String get prepMockTestAddButton => 'Log mock test';

  @override
  String get prepMockTestSubjectSectionTitle => 'Mock test performance';

  @override
  String prepMockTestSubjectCount(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formatted tests logged',
      one: '$formatted test logged',
    );
    return '$_temp0';
  }

  @override
  String get prepMockFilterSubjectLabel => 'Subject';

  @override
  String get prepMockFilterAllSubjects => 'All subjects';

  @override
  String get prepMockFilterDateLabel => 'Date range';

  @override
  String get prepMockFilterDateAll => 'All time';

  @override
  String get prepMockFilterDate7Days => 'Last 7 days';

  @override
  String get prepMockFilterDate30Days => 'Last 30 days';

  @override
  String get prepMockFilterDate90Days => 'Last 90 days';

  @override
  String get prepMockFilterClear => 'Clear filters';

  @override
  String get prepMockStatLatest => 'Latest';

  @override
  String get prepMockStatBest => 'Best';

  @override
  String get prepMockStatAverage => 'Average';

  @override
  String get prepMockStatImprovement => 'Improvement';

  @override
  String prepMockStatPercentValue(String percent) {
    return '$percent%';
  }

  @override
  String get prepMockStatNotAvailable => '—';

  @override
  String prepMockStatImprovementLastFive(String formatted) {
    return 'Last $formatted tests';
  }

  @override
  String get prepMockStatImprovementFirstToLatest => 'First to latest';

  @override
  String get prepMockStatImprovementNeedsTwo => 'Log 2+ tests to compare';

  @override
  String get prepMockTrendChartTitle => 'Score trend (%)';

  @override
  String prepMockTrendAverageLineLabel(String percent) {
    return 'Avg $percent%';
  }

  @override
  String get prepMockTrendNeedsDataHint =>
      'Log your first mock test to plot your score trend and average reference line.';

  @override
  String prepMockTrendTooltip(String title, String percent, String date) {
    return '$title\n$percent% • $date';
  }

  @override
  String get prepMockEmptyTitle => 'No mock tests logged yet';

  @override
  String get prepMockEmptyBody =>
      'Log model tests from guidebooks or online platforms to track net percentage and weak areas.';

  @override
  String get prepMockFilteredEmptyTitle => 'No mock tests match these filters';

  @override
  String get prepMockFilteredEmptyBody =>
      'Try clearing the subject or date range filter, or log a new mock test.';

  @override
  String get prepMockLoadingLabel => 'Loading mock tests...';

  @override
  String get prepMockLoadErrorTitle => 'Could not load mock tests';

  @override
  String prepMockScoreRatio(String net, String total) {
    return '$net / $total';
  }

  @override
  String prepMockNegativeMarksBadge(String marks) {
    return '-$marks neg';
  }

  @override
  String prepMockDurationWithLimitBadge(String taken, String limit) {
    return '$taken / $limit min';
  }

  @override
  String prepMockDurationBadge(String taken) {
    return '$taken min';
  }

  @override
  String prepMockWeakTopicsLabel(String topics) {
    return 'Weak topics: $topics';
  }

  @override
  String prepMockLinkedCircularLabel(String title) {
    return 'Circular: $title';
  }

  @override
  String prepMockLinkedMaterialLabel(String title) {
    return 'Material: $title';
  }

  @override
  String prepMockLinkedTopicLabel(String title) {
    return 'Topic: $title';
  }

  @override
  String get prepMockEditTooltip => 'Edit mock test';

  @override
  String get prepMockDeleteTooltip => 'Delete mock test';

  @override
  String get prepMockFormCreateTitle => 'Log mock test';

  @override
  String get prepMockFormEditTitle => 'Edit mock test';

  @override
  String get prepMockFormSubjectLabel => 'Subject';

  @override
  String get prepMockFormTitleLabel => 'Test title';

  @override
  String get prepMockFormTitleHint => 'e.g., 46th BCS Model Test 04';

  @override
  String get prepMockFormSourceLabel => 'Source / Platform (optional)';

  @override
  String get prepMockFormSourceHint => 'e.g., Live MCQ, Oracle Guide';

  @override
  String prepMockFormTakenOnLabel(String date) {
    return 'Date taken: $date';
  }

  @override
  String get prepMockFormPickDate => 'Change date';

  @override
  String get prepMockFormMarksObtainedLabel => 'Marks obtained';

  @override
  String get prepMockFormTotalMarksLabel => 'Total marks';

  @override
  String get prepMockFormNegativeMarksLabel => 'Negative marks (optional)';

  @override
  String get prepMockFormTimeTakenLabel => 'Time taken (min, optional)';

  @override
  String get prepMockFormTimeLimitLabel => 'Time limit (min, optional)';

  @override
  String get prepMockFormWeakTopicsLabel => 'Weak topics (optional)';

  @override
  String get prepMockFormWeakTopicsHint =>
      'e.g., Constitutional Amendments, Time & Work';

  @override
  String get prepMockFormNotesLabel => 'Notes (optional)';

  @override
  String get prepMockFormCircularLabel => 'Linked circular (optional)';

  @override
  String get prepMockFormMaterialLabel => 'Linked material (optional)';

  @override
  String get prepMockFormTopicLabel => 'Linked topic (optional)';

  @override
  String get prepMockFormNoneOption => 'None';

  @override
  String get prepMockFormSaveAction => 'Save mock test';

  @override
  String get prepMockValidationSubjectRequired =>
      'Select a subject for this mock test.';

  @override
  String get prepMockValidationTitleRequired =>
      'Enter a title for the mock test.';

  @override
  String get prepMockValidationTotalPositive =>
      'Total marks must be greater than zero.';

  @override
  String get prepMockValidationMarksRange =>
      'Marks obtained must be between 0 and total marks.';

  @override
  String get prepMockValidationNegativeMarks =>
      'Negative marks must be between 0 and total marks.';

  @override
  String get prepMockValidationDuration =>
      'Time taken must be 0 or more, and time limit must be greater than zero.';

  @override
  String get prepMockDeleteTitle => 'Delete mock test?';

  @override
  String prepMockDeleteBody(String title) {
    return 'Remove \"$title\" from your mock test history? This cannot be undone.';
  }

  @override
  String get prepMockDeleteConfirm => 'Delete';

  @override
  String get prepTabAnalytics => 'Analytics';

  @override
  String get prepAnalyticsTitle => 'Study analytics';

  @override
  String get prepAnalyticsSubtitle =>
      'Track daily consistency, study streaks, weekly volume, and subject focus.';

  @override
  String get prepAnalyticsLoadingLabel => 'Loading study analytics...';

  @override
  String get prepAnalyticsLoadErrorTitle => 'Could not load study analytics';

  @override
  String get prepAnalyticsEmptyTitle => 'No study activity logged yet';

  @override
  String get prepAnalyticsEmptyBody =>
      'Log units on your study materials or set a study plan to unlock streaks, charts, and your consistency score.';

  @override
  String get prepAnalyticsEmptyAction => 'Open subjects';

  @override
  String get prepAnalyticsFilterRangeLabel => 'Date range';

  @override
  String get prepAnalyticsRange7Days => '7 days';

  @override
  String get prepAnalyticsRange30Days => '30 days';

  @override
  String get prepAnalyticsRange90Days => '90 days';

  @override
  String get prepAnalyticsFilterSubjectLabel => 'Subject';

  @override
  String get prepAnalyticsAllSubjects => 'All subjects';

  @override
  String get prepAnalyticsClearFilter => 'Clear filter';

  @override
  String get prepAnalyticsCurrentStreak => 'Current streak';

  @override
  String get prepAnalyticsLongestStreak => 'Longest streak';

  @override
  String get prepAnalyticsUnitsThisWeek => 'Units this week';

  @override
  String get prepAnalyticsConsistency => 'Consistency';

  @override
  String prepAnalyticsDaysSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' days',
      one: ' day',
    );
    return '$_temp0';
  }

  @override
  String get prepAnalyticsPercentSuffix => '%';

  @override
  String prepAnalyticsActiveDaysCaption(String active, String total) {
    return '$active / $total active days';
  }

  @override
  String prepAnalyticsAvgPerDayCaption(String avg) {
    return '$avg/day (7d avg)';
  }

  @override
  String get prepAnalyticsRolling7dLabel => '7-day avg';

  @override
  String get prepAnalyticsRolling30dLabel => '30-day avg';

  @override
  String prepAnalyticsUnitsPerDayValue(String avg) {
    return '$avg units/day';
  }

  @override
  String get prepAnalyticsBestDayLabel => 'Best day';

  @override
  String get prepAnalyticsWeakestDayLabel => 'Weakest day';

  @override
  String prepAnalyticsDaySummaryValue(String units, String date) {
    return '$units units • $date';
  }

  @override
  String get prepAnalyticsMockOverviewLabel => 'Mock tests in range';

  @override
  String prepAnalyticsMockOverviewValue(
      int count, String formattedCount, String avg) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount tests • avg $avg%',
      one: '$formattedCount test • avg $avg%',
    );
    return '$_temp0';
  }

  @override
  String get prepAnalyticsNoDataDash => '—';

  @override
  String get prepAnalyticsAlertBothTitle =>
      'Today and yesterday were below your daily target';

  @override
  String get prepAnalyticsAlertTodayTitle =>
      'Today is still below your daily target';

  @override
  String get prepAnalyticsAlertYesterdayTitle =>
      'Yesterday finished below your daily target';

  @override
  String prepAnalyticsAlertBody(String today, String yesterday, String target) {
    return 'Today: $today / $target units • Yesterday: $yesterday / $target units';
  }

  @override
  String get prepAnalyticsDailyChartTitle => 'Daily study activity';

  @override
  String prepAnalyticsDailyTargetLegend(String target) {
    return 'Target: $target/day';
  }

  @override
  String prepAnalyticsDailyTooltip(String date, String units) {
    return '$date\n$units units';
  }

  @override
  String get prepAnalyticsWeeklyChartTitle => 'Weekly totals';

  @override
  String prepAnalyticsWeeklyTooltip(String range, String units, String days) {
    return '$range\n$units units ($days active)';
  }

  @override
  String prepAnalyticsWeeklyRangeLabel(String start, String end) {
    return '$start – $end';
  }

  @override
  String get prepAnalyticsSubjectChartTitle => 'Where study time went';

  @override
  String get prepAnalyticsSubjectNoData =>
      'Log study units or mock tests in this window to compare subjects.';

  @override
  String prepAnalyticsSubjectRowSubtitle(String units, String percent) {
    return '$units units ($percent%)';
  }

  @override
  String prepAnalyticsSubjectMockHint(
      int count, String formattedCount, String avg) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount mocks • $avg% avg',
      one: '$formattedCount mock • $avg% avg',
    );
    return '$_temp0';
  }

  @override
  String get prepAnalyticsHeatmapTitle => 'Study days heatmap (last 90 days)';

  @override
  String prepAnalyticsHeatmapTooltip(String date, String units) {
    return '$date: $units units';
  }

  @override
  String get prepAnalyticsHeatmapLess => 'Less';

  @override
  String get prepAnalyticsHeatmapMore => 'More';

  @override
  String get prepSubjectViewAllMaterials => 'All materials';

  @override
  String prepSubjectViewBooksShelf(String count) {
    return 'Books shelf ($count)';
  }

  @override
  String get prepOpenBookView => 'Book view';

  @override
  String get prepBooksShelfTitle => 'Books shelf';

  @override
  String get prepBooksShelfSubtitle =>
      'Tap any book to update your position with the bookmark or page field.';

  @override
  String prepBooksShelfEmptyTitle(String subject) {
    return 'No books in $subject yet';
  }

  @override
  String get prepBooksShelfEmptyBody =>
      'Add a study material with kind Book to arrange it on your shelf.';

  @override
  String get prepAddBookButton => 'Add book';

  @override
  String get bookProgressPositionPrefix => 'I am at page';

  @override
  String bookProgressPositionSuffix(String total) {
    return 'of $total';
  }

  @override
  String get bookProgressSavePosition => 'Save page';

  @override
  String bookProgressUnitSummary(
      String current, String total, String unitLabel) {
    return '$current / $total $unitLabel';
  }

  @override
  String bookProgressPercentLabel(String percent) {
    return '$percent%';
  }

  @override
  String bookProgressUpdatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String get bookProgressDragHint =>
      'Drag the bookmark or enter your page number';

  @override
  String get bookProgressBookmarkSemantics => 'Book position bookmark';

  @override
  String get bookProgressErrorEmpty => 'Enter a page number';

  @override
  String get bookProgressErrorWholeNumber => 'Enter a whole page number';

  @override
  String get bookProgressErrorBelowZero => 'Page number cannot be negative';

  @override
  String bookProgressErrorExceedsTotal(String total) {
    return 'Page cannot exceed $total';
  }

  @override
  String get bookProgressConfirmCorrectionTitle => 'Save position correction?';

  @override
  String bookProgressConfirmCorrectionBody(
      String fromPage, String toPage, String delta, String unitLabel) {
    return 'You are moving back from page $fromPage to page $toPage ($delta $unitLabel). This updates your book position without counting as studied units in your study plan or analytics.';
  }

  @override
  String get bookProgressConfirmCorrectionAction => 'Save correction';

  @override
  String bookProgressCorrectionSaved(String page) {
    return 'Updated position to $page (correction)';
  }

  @override
  String bookProgressStudySaved(String delta, String unitLabel) {
    return 'Logged +$delta $unitLabel';
  }

  @override
  String get bookProgressHistoryButton => 'Log history';

  @override
  String get prepLogEntryTypeCorrectionBadge => 'Correction';

  @override
  String get prepCloseButton => 'Close';

  @override
  String get prepTabRevision => 'Revision';

  @override
  String get prepRevisionTitle => 'Revision queue';

  @override
  String get prepRevisionSubtitle =>
      'Revisit flagged pages, tricky problems, and weak topics on a spaced schedule.';

  @override
  String get prepRevisionDueCountStat => 'Due & overdue';

  @override
  String get prepRevisionMasteredStat => 'Mastered';

  @override
  String get prepRevisionFlagItemButton => 'Flag item';

  @override
  String prepRevisionTabDueToday(String count) {
    return 'Due today ($count)';
  }

  @override
  String prepRevisionTabOverdue(String count) {
    return 'Overdue ($count)';
  }

  @override
  String prepRevisionTabUpcoming(String count) {
    return 'Upcoming ($count)';
  }

  @override
  String prepRevisionTabDone(String count) {
    return 'Done ($count)';
  }

  @override
  String get prepRevisionAllSubjects => 'All subjects';

  @override
  String get prepRevisionAllMaterials => 'All materials';

  @override
  String get prepRevisionClearFilters => 'Clear filters';

  @override
  String get prepRevisionReasonTricky => 'Tricky';

  @override
  String get prepRevisionReasonForgot => 'Forgot';

  @override
  String get prepRevisionReasonImportant => 'Important';

  @override
  String get prepRevisionReasonMistake => 'Mistake';

  @override
  String get prepRevisionSourceLog => 'From study log';

  @override
  String get prepRevisionSourceMockTest => 'From mock test';

  @override
  String get prepRevisionSourceManual => 'Manual flag';

  @override
  String get prepRevisionStatusMastered => 'Mastered';

  @override
  String get prepRevisionStatusDismissed => 'Dismissed';

  @override
  String get prepRevisionDueTodayLabel => 'Due today';

  @override
  String prepRevisionOverdueDaysLabel(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount days overdue',
      one: '$formattedCount day overdue',
    );
    return '$_temp0';
  }

  @override
  String prepRevisionDueInDaysLabel(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $formattedCount days',
      one: 'In $formattedCount day',
    );
    return '$_temp0';
  }

  @override
  String prepRevisionDueDateLabel(String date) {
    return 'Due $date';
  }

  @override
  String prepRevisionPageChip(String page) {
    return 'p. $page';
  }

  @override
  String prepRevisionReviewCountChip(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount reviews',
      one: '$formattedCount review',
      zero: 'New',
    );
    return '$_temp0';
  }

  @override
  String get prepRevisionActionEasy => 'Easy';

  @override
  String prepRevisionActionEasyHint(String days) {
    return '+${days}d';
  }

  @override
  String get prepRevisionActionEasyMasteredHint => 'Master';

  @override
  String get prepRevisionActionStillHard => 'Still hard';

  @override
  String get prepRevisionActionSnooze => 'Snooze +1d';

  @override
  String get prepRevisionActionDismiss => 'Dismiss';

  @override
  String get prepRevisionDeleteTooltip => 'Delete revision mark';

  @override
  String get prepRevisionUndoButton => 'Undo';

  @override
  String get prepRevisionUndoDismissTooltip => 'Hide undo banner';

  @override
  String prepRevisionFeedbackEasyNext(String reference, String days) {
    return 'Marked \"$reference\" as Easy — next review in $days days.';
  }

  @override
  String prepRevisionFeedbackMastered(String reference) {
    return 'Mastered \"$reference\"! Moved to Done.';
  }

  @override
  String prepRevisionFeedbackStillHard(String reference) {
    return 'Marked \"$reference\" as Still hard — reset to 1 day.';
  }

  @override
  String prepRevisionFeedbackSnoozed(String reference) {
    return 'Snoozed \"$reference\" by 1 day.';
  }

  @override
  String prepRevisionFeedbackDismissed(String reference) {
    return 'Dismissed \"$reference\" to Done.';
  }

  @override
  String get prepRevisionEmptyDueTitle => 'Nothing due today';

  @override
  String get prepRevisionEmptyDueBody =>
      'Flag tricky pages while logging study progress or check Overdue and Upcoming.';

  @override
  String get prepRevisionEmptyOverdueTitle => 'No overdue revisions';

  @override
  String get prepRevisionEmptyOverdueBody =>
      'Every scheduled revision mark is up to date.';

  @override
  String get prepRevisionEmptyUpcomingTitle =>
      'No upcoming revisions scheduled';

  @override
  String get prepRevisionEmptyUpcomingBody =>
      'New flags are scheduled 1 day ahead, and Easy reviews space out along 3, 7, 14, and 30 days.';

  @override
  String get prepRevisionEmptyDoneTitle => 'No completed items yet';

  @override
  String get prepRevisionEmptyDoneBody =>
      'Mastered and dismissed items are archived here.';

  @override
  String get prepRevisionEmptyFilteredBody =>
      'No revision items match the active subject and material filters.';

  @override
  String get prepRevisionMarkAction => 'Mark for revision';

  @override
  String get prepRevisionPostSavePrompt =>
      'Progress saved! Flag any page or problem to revise later without leaving?';

  @override
  String prepRevisionAddedCountChip(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCount flags added',
      one: '$formattedCount flag added',
    );
    return '$_temp0';
  }

  @override
  String get prepRevisionRefLabel => 'Reference (page, problem, or topic)';

  @override
  String get prepRevisionRefHint => 'e.g. p. 128 or Problem 14';

  @override
  String get prepRevisionRefError =>
      'Enter a page, problem, or topic to revise.';

  @override
  String get prepRevisionPageLabel => 'Page # (optional)';

  @override
  String get prepRevisionPageHint => '128';

  @override
  String get prepRevisionReasonLabel => 'Reason';

  @override
  String get prepRevisionNoteLabel => 'Note (optional)';

  @override
  String get prepRevisionNoteHint =>
      'Sign mistake in derivation, review shortcut...';

  @override
  String get prepRevisionAddAnotherButton => 'Add flag';

  @override
  String get prepRevisionDoneFlaggingButton => 'Hide flagger';

  @override
  String get prepRevisionFlagMaterialTooltip => 'Flag for revision';

  @override
  String get prepRevisionDialogTitle => 'Mark for revision';

  @override
  String get prepRevisionSubjectLabel => 'Subject';

  @override
  String get prepRevisionMaterialOptionalLabel => 'Material (optional)';

  @override
  String get prepRevisionNoMaterialOption =>
      'Subject-wide / No specific material';

  @override
  String get prepRevisionWeakTopicsQuickFill => 'Tap a weak topic to prefill:';

  @override
  String prepRevisionAddAllWeakTopics(String count) {
    return 'Add all ($count)';
  }

  @override
  String get prepMockAddToRevisionButton => 'Add to revision';

  @override
  String get prepTabTimer => 'Timer';

  @override
  String get prepTimerTitle => 'Study Timer';

  @override
  String get prepTimerSubtitle =>
      'Track Focus rounds and stopwatch sessions driven by timestamps';

  @override
  String get prepTimerModeFocus => 'Focus';

  @override
  String get prepTimerModeStopwatch => 'Stopwatch';

  @override
  String get prepTimerModeManual => 'Manual';

  @override
  String get prepTimerManualEntryButton => 'Log manual time';

  @override
  String get prepTimerSoundLabel => 'Sound alert';

  @override
  String get prepTimerSettingsButton => 'Pomodoro lengths';

  @override
  String prepTimerPhaseFocus(String round) {
    return 'Focus round $round';
  }

  @override
  String get prepTimerPhaseShortBreak => 'Short break';

  @override
  String get prepTimerPhaseLongBreak => 'Long break';

  @override
  String get prepTimerStatusRunning => 'Running';

  @override
  String get prepTimerStatusPaused => 'Paused';

  @override
  String get prepTimerStatusReady => 'Ready';

  @override
  String prepTimerElapsedSummary(String duration) {
    return 'Studied: $duration';
  }

  @override
  String prepTimerConfigSummary(
      String focus, String shortBreak, String longBreak) {
    return '${focus}m focus • ${shortBreak}m short • ${longBreak}m long';
  }

  @override
  String get prepTimerSubjectRequired => 'Pick a subject to start studying';

  @override
  String get prepTimerStartButton => 'Start';

  @override
  String get prepTimerPauseButton => 'Pause';

  @override
  String get prepTimerResumeButton => 'Resume';

  @override
  String get prepTimerFinishButton => 'Finish';

  @override
  String get prepTimerDiscardButton => 'Discard';

  @override
  String get prepTimerDiscardConfirmTitle => 'Discard active session?';

  @override
  String get prepTimerDiscardConfirmBody =>
      'This open timer session has not been saved and will be removed permanently.';

  @override
  String get prepTimerOpenFullButton => 'Open';

  @override
  String prepTimerAlertFocusDone(String round) {
    return 'Focus round $round complete!';
  }

  @override
  String prepTimerAlertBreakDone(String round) {
    return 'Break finished! Ready for round $round?';
  }

  @override
  String prepTimerStartShortBreak(String minutes) {
    return 'Start ${minutes}m short break';
  }

  @override
  String prepTimerStartLongBreak(String minutes) {
    return 'Start ${minutes}m long break';
  }

  @override
  String prepTimerStartNextRound(String round) {
    return 'Start round $round';
  }

  @override
  String get prepTimerDismissAlert => 'Dismiss';

  @override
  String get prepTimerConfigDialogTitle => 'Pomodoro lengths';

  @override
  String get prepTimerConfigFocusLabel => 'Focus length (minutes)';

  @override
  String get prepTimerConfigShortBreakLabel => 'Short break (minutes)';

  @override
  String get prepTimerConfigLongBreakLabel =>
      'Long break after 4 rounds (minutes)';

  @override
  String get prepTimerConfigPositiveError => 'Enter at least 1 minute';

  @override
  String get prepTimerFinishDialogTitle => 'Save study session';

  @override
  String get prepTimerFinishDurationLabel => 'Studied time';

  @override
  String get prepTimerFinishNoteLabel => 'Session note (optional)';

  @override
  String get prepTimerFinishNoteHint => 'Chapters solved, formulas reviewed...';

  @override
  String prepTimerFinishUnitsLabel(String material) {
    return 'Units done in $material (optional)';
  }

  @override
  String get prepTimerFinishUnitsHint => 'e.g. 20';

  @override
  String get prepTimerFinishUnitsError =>
      'Enter a positive whole number or leave blank';

  @override
  String get prepTimerFinishFlagRevisionCheck =>
      'Mark an item for revision after saving';

  @override
  String get prepTimerFinishSaveButton => 'Save session';

  @override
  String get prepTimerFinishSavedHeading => 'Session saved!';

  @override
  String get prepTimerFinishDoneButton => 'Done';

  @override
  String get prepTimerManualDialogTitle => 'Log manual study session';

  @override
  String get prepTimerEditDialogTitle => 'Edit study session';

  @override
  String get prepTimerStartDateLabel => 'Date';

  @override
  String get prepTimerStartTimeLabel => 'Start time';

  @override
  String get prepTimerHoursLabel => 'Hours';

  @override
  String get prepTimerMinutesLabel => 'Minutes';

  @override
  String get prepTimerDurationPositiveError =>
      'Enter at least 1 minute of study time';

  @override
  String get prepTimerHistoryTitle => 'Recent study sessions';

  @override
  String get prepTimerHistoryEmpty =>
      'No saved study sessions yet. Start Focus or Stopwatch above, or log study time from elsewhere.';

  @override
  String get prepTimerEditTooltip => 'Edit session';

  @override
  String get prepTimerDeleteTooltip => 'Delete session';

  @override
  String get prepTimerDeleteConfirmTitle => 'Delete study session?';

  @override
  String get prepTimerDeleteConfirmBody =>
      'This session and its study hours will be removed from your history and analytics.';

  @override
  String prepTimerTabFocus(String clock) {
    return '$clock • Focus — JobPrep';
  }

  @override
  String prepTimerTabBreak(String clock) {
    return '$clock • Break — JobPrep';
  }

  @override
  String prepTimerTabStopwatch(String clock) {
    return '$clock • Stopwatch — JobPrep';
  }

  @override
  String prepTimerTabPaused(String clock) {
    return 'Paused $clock — JobPrep';
  }

  @override
  String get prepAnalyticsHoursThisWeek => 'Hours this week';

  @override
  String get prepAnalyticsHoursSuffix => 'h';

  @override
  String prepAnalyticsHoursInRangeCaption(String hours) {
    return '${hours}h in window';
  }

  @override
  String get prepAnalyticsDailyHoursTitle => 'Hours studied per day';

  @override
  String get prepAnalyticsDailyHoursSubtitle =>
      'Days with a 10+ min session or unit log count toward streaks';

  @override
  String get prepAnalyticsSubjectHoursTitle => 'Hours studied by subject';

  @override
  String get prepAnalyticsSubjectHoursEmpty =>
      'Complete a study timer session or add manual hours to compare time across subjects.';

  @override
  String prepAnalyticsHeatmapTimeTooltip(
      String date, String units, String hours) {
    return '$date: $units units, ${hours}h';
  }

  @override
  String prepTimerStartDateValue(String date) {
    return 'Date: $date';
  }

  @override
  String prepTimerStartTimeValue(String time) {
    return 'Start time: $time';
  }

  @override
  String prepAnalyticsHoursValue(String hours) {
    return '${hours}h';
  }

  @override
  String prepAnalyticsDailyHoursTooltip(String date, String hours) {
    return '$date: ${hours}h';
  }

  @override
  String prepAnalyticsSubjectHoursLegend(String subject, String hours) {
    return '$subject: ${hours}h';
  }
}
