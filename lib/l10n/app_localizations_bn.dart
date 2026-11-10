// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'জবপ্রেপ';

  @override
  String get dashboardTitle => 'জবপ্রেপ ড্যাশবোর্ড';

  @override
  String get dashboardSubtitle =>
      'চাকরির সার্কুলার ট্র্যাকার ও পরীক্ষার প্রস্তুতি';

  @override
  String get themeSwitcherTitle => 'থিম মোড পরিবর্তন';

  @override
  String get themeSwitcherSubtitle =>
      'একটি ডিসপ্লে মোড নির্বাচন করুন (মেমোরিতে সংরক্ষিত থাকবে)';

  @override
  String get systemTheme => 'সিস্টেম থিম';

  @override
  String get lightTheme => 'লাইট থিম (নেভি ও গোল্ড)';

  @override
  String get darkTheme => 'ডার্ক থিম (ডিপ নেভি ও গোল্ড)';

  @override
  String get languageSwitcherTitle => 'ভাষা পরিবর্তন';

  @override
  String get languageSwitcherSubtitle =>
      'ইন্টারফেস ভাষা নির্বাচন করুন (মেমোরিতে সংরক্ষিত থাকবে)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা (Bangla)';

  @override
  String get tokensPreviewTitle => 'ডিজাইন টোকেন প্রিভিউ';

  @override
  String get goldAccentButton => 'গোল্ড অ্যাকসেন্ট বাটন';

  @override
  String get outlinedButton => 'আউটলাইন বাটন';

  @override
  String get statusSuccess => 'সফল';

  @override
  String get statusWarning => 'সতর্কতা';

  @override
  String get statusDanger => 'বিপদ';

  @override
  String get formattersTitle => 'লোকেল ফরম্যাটার ও বহুবাচক প্রিভিউ';

  @override
  String sampleCurrency(String formattedAmount) {
    return 'আবেদন ফি: $formattedAmount';
  }

  @override
  String sampleDate(String formattedDate) {
    return 'পরীক্ষার তারিখ: $formattedDate';
  }

  @override
  String pageProgress(String current, String total) {
    return 'পৃষ্ঠা $current / $total';
  }

  @override
  String booksCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি বই সমাপ্ত হয়েছে',
      one: '১টি বই সমাপ্ত হয়েছে',
      zero: 'কোনো বই সমাপ্ত হয়নি',
    );
    return '$_temp0';
  }

  @override
  String deadlineDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'আবেদন শেষ হতে $days দিন বাকি',
      one: 'আবেদন শেষ হতে ১ দিন বাকি',
      zero: 'আবেদনের শেষ তারিখ আজ',
    );
    return '$_temp0';
  }

  @override
  String get navDashboard => 'ড্যাশবোর্ড';

  @override
  String get navCirculars => 'সার্কুলার';

  @override
  String get navPrep => 'প্রস্তুতি';

  @override
  String get navCalendar => 'ক্যালেন্ডার';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get circularsTitle => 'চাকরির সার্কুলার';

  @override
  String get circularsSubtitle =>
      'চলমান সার্কুলার, সময়সীমা ও প্রয়োজনীয় তথ্য ট্র্যাক করুন';

  @override
  String get prepTitle => 'পরীক্ষার প্রস্তুতি';

  @override
  String get prepSubtitle =>
      'বিষয়ভিত্তিক সিলেবাস, পড়ার লক্ষ্য ও বই ট্র্যাকিং';

  @override
  String get calendarTitle => 'পরীক্ষার ক্যালেন্ডার';

  @override
  String get calendarSubtitle => 'আসন্ন আবেদনের শেষ তারিখ ও পরীক্ষার সময়সূচি';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsSubtitle => 'অ্যাপের পছন্দসমূহ, উপস্থিতি ও কনফিগারেশন';

  @override
  String navShortcutTooltip(String shortcut) {
    return 'শর্টকাট: $shortcut';
  }

  @override
  String navShortcutBadge(String digit) {
    return 'Alt+$digit';
  }

  @override
  String get authLoginRouteTitle => 'সাইন ইন';

  @override
  String get authResetPasswordRouteTitle => 'পাসওয়ার্ড রিসেট';

  @override
  String get authSignInTitle => 'স্বাগতম';

  @override
  String get authSignInSubtitle =>
      'চাকরির সার্কুলার ও পরীক্ষার প্রস্তুতি পরিচালনা করতে সাইন ইন করুন';

  @override
  String get authSignUpTitle => 'নতুন অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authSignUpSubtitle =>
      'সার্কুলার ও পড়াশোনার অগ্রগতি নিরাপদে ট্র্যাক করুন';

  @override
  String get authForgotPasswordTitle => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get authForgotPasswordSubtitle =>
      'আপনার ইমেইল লিখুন, আমরা পাসওয়ার্ড রিসেট লিংক পাঠাব';

  @override
  String get authResetPasswordTitle => 'নতুন পাসওয়ার্ড সেট করুন';

  @override
  String get authResetPasswordSubtitle =>
      'কমপক্ষে ৮ অক্ষরের একটি শক্তিশালী পাসওয়ার্ড দিন';

  @override
  String get authEmailLabel => 'ইমেইল ঠিকানা';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get authPasswordHint => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get authNewPasswordLabel => 'নতুন পাসওয়ার্ড';

  @override
  String get authNewPasswordHint => 'কমপক্ষে ৮ অক্ষর';

  @override
  String get authConfirmPasswordLabel => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get authConfirmPasswordHint => 'নতুন পাসওয়ার্ডটি আবার লিখুন';

  @override
  String get authPasswordMinLengthHelper => 'কমপক্ষে ৮ অক্ষরের হতে হবে';

  @override
  String get authShowPasswordTooltip => 'পাসওয়ার্ড দেখুন';

  @override
  String get authHidePasswordTooltip => 'পাসওয়ার্ড লুকান';

  @override
  String get authSignInButton => 'সাইন ইন';

  @override
  String get authCreateAccountButton => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authSendResetLinkButton => 'রিসেট লিংক পাঠান';

  @override
  String get authUpdatePasswordButton => 'পাসওয়ার্ড আপডেট করুন';

  @override
  String get authContinueWithGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get authOrDivider => 'অথবা';

  @override
  String get authForgotPasswordLink => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get authBackToSignIn => 'সাইন ইনে ফিরে যান';

  @override
  String get authNoAccountPrompt => 'অ্যাকাউন্ট নেই?';

  @override
  String get authAlreadyHaveAccountPrompt => 'ইতিমধ্যেই অ্যাকাউন্ট আছে?';

  @override
  String get authSwitchToSignUp => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authSwitchToSignIn => 'সাইন ইন করুন';

  @override
  String get authCheckEmailTitle => 'আপনার ইমেইল চেক করুন';

  @override
  String authCheckEmailMessage(String email) {
    return 'আমরা $email ঠিকানায় একটি কনফার্মেশন লিংক পাঠিয়েছি। সাইন ইন করার আগে ইনবক্স থেকে অ্যাকাউন্টটি নিশ্চিত করুন।';
  }

  @override
  String get authResetLinkSentTitle => 'রিসেট লিংক পাঠানো হয়েছে';

  @override
  String authResetLinkSentMessage(String email) {
    return '$email ঠিকানায় কোনো অ্যাকাউন্ট থাকলে পাসওয়ার্ড রিসেট নির্দেশনা পাঠানো হয়েছে।';
  }

  @override
  String get authPasswordUpdatedTitle => 'পাসওয়ার্ড আপডেট হয়েছে';

  @override
  String get authPasswordUpdatedMessage =>
      'আপনার পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে। এখন ড্যাশবোর্ডে যেতে পারেন।';

  @override
  String get authContinueToDashboard => 'ড্যাশবোর্ডে যান';

  @override
  String get authValidationEmailRequired =>
      'অনুগ্রহ করে আপনার ইমেইল ঠিকানা লিখুন।';

  @override
  String get authValidationEmailInvalid =>
      'অনুগ্রহ করে একটি সঠিক ইমেইল ঠিকানা লিখুন।';

  @override
  String get authValidationPasswordRequired =>
      'অনুগ্রহ করে আপনার পাসওয়ার্ড লিখুন।';

  @override
  String get authValidationPasswordTooShort =>
      'পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।';

  @override
  String get authValidationConfirmPasswordRequired =>
      'অনুগ্রহ করে নতুন পাসওয়ার্ডটি নিশ্চিত করুন।';

  @override
  String get authValidationPasswordsDoNotMatch => 'পাসওয়ার্ড দুটি মিলছে না।';

  @override
  String get authErrorInvalidCredentials =>
      'ইমেইল বা পাসওয়ার্ড সঠিক নয়। তথ্য যাচাই করে আবার চেষ্টা করুন।';

  @override
  String get authErrorEmailNotConfirmed =>
      'সাইন ইন করার আগে আপনার ইমেইল নিশ্চিত করুন। ইনবক্সে পাঠানো ভেরিফিকেশন লিংক দেখুন।';

  @override
  String get authErrorAccountAlreadyExists =>
      'এই ইমেইল দিয়ে ইতিমধ্যেই অ্যাকাউন্ট রয়েছে। সাইন ইন করার চেষ্টা করুন।';

  @override
  String get authErrorTooManyRequests =>
      'অতিরিক্ত প্রচেষ্টা করা হয়েছে। কিছুক্ষণ অপেক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get authErrorNetwork =>
      'নেটওয়ার্ক ত্রুটি। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get authErrorWeakPassword =>
      'পাসওয়ার্ডটি দুর্বল। অক্ষর ও সংখ্যাসহ কমপক্ষে ৮ অক্ষরের পাসওয়ার্ড দিন।';

  @override
  String get authErrorUnknown =>
      'প্রমাণীকরণের সময় একটি ত্রুটি হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String circularsCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCountটি সার্কুলার',
      one: '$formattedCountটি সার্কুলার',
      zero: 'কোনো সার্কুলার নেই',
    );
    return '$_temp0';
  }

  @override
  String get circularsSearchHint => 'শিরোনাম বা প্রতিষ্ঠান দিয়ে খুঁজুন...';

  @override
  String get circularsClearSearchTooltip => 'অনুসন্ধান মুছুন';

  @override
  String get circularsFilterToggle => 'ফিল্টার';

  @override
  String get circularsClearFilters => 'ফিল্টার মুছুন';

  @override
  String get circularsSortLabel => 'সাজান';

  @override
  String get circularsRefreshTooltip => 'সার্কুলার রিফ্রেশ করুন';

  @override
  String get circularsSortDeadline => 'শেষ তারিখ (আগে)';

  @override
  String get circularsSortPriority => 'অগ্রাধিকার (সর্বোচ্চ)';

  @override
  String get circularsSortCreated => 'তৈরির তারিখ (নতুন)';

  @override
  String get circularsSortUpdated => 'সর্বশেষ আপডেট';

  @override
  String get circularsSortTitle => 'শিরোনাম (A-Z)';

  @override
  String get circularsFilterSector => 'খাত';

  @override
  String get circularsFilterApplicationStatus => 'আবেদনের অবস্থা';

  @override
  String get circularsFilterPriority => 'অগ্রাধিকার';

  @override
  String get circularsFilterWorkflowStatus => 'কার্যপ্রবাহ';

  @override
  String get circularsFilterDeadlineRange => 'সময়সীমা';

  @override
  String get circularsDeadlineRangeAll => 'সব সময়সীমা';

  @override
  String get circularsDeadlineRangeUnder3OrOverdue =>
      '৩ দিনের কম / মেয়াদোত্তীর্ণ';

  @override
  String get circularsDeadlineRange3To7Days => '৩ থেকে ৭ দিন';

  @override
  String get circularsDeadlineRangeOver7Days => '৭ দিনের বেশি';

  @override
  String get circularsDeadlineRangeNext30Days => 'আগামী ৩০ দিন';

  @override
  String get circularsDeadlineFromLabel => 'শুরু';

  @override
  String get circularsDeadlineToLabel => 'শেষ';

  @override
  String get circularsClearDatesTooltip => 'তারিখের পরিসর মুছুন';

  @override
  String get circularsColumnTitle => 'সার্কুলার ও প্রতিষ্ঠান';

  @override
  String get circularsColumnSector => 'খাত';

  @override
  String get circularsColumnDeadline => 'শেষ তারিখ';

  @override
  String get circularsColumnVacancies => 'শূন্যপদ';

  @override
  String get circularsColumnStatus => 'অবস্থা';

  @override
  String circularsVacanciesCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCountটি পদ',
      one: '$formattedCountটি পদ',
      zero: 'শূন্যপদ নেই',
    );
    return '$_temp0';
  }

  @override
  String get circularsVacanciesUnspecified => 'উল্লেখ নেই';

  @override
  String get circularsOrganizationUnspecified => 'প্রতিষ্ঠান উল্লেখ নেই';

  @override
  String get circularsCountdownNoDeadline => 'শেষ তারিখ নেই';

  @override
  String get circularsCountdownToday => 'আজই শেষ দিন';

  @override
  String circularsCountdownDaysLeft(int days, String formattedDays) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$formattedDays দিন বাকি',
      one: '$formattedDays দিন বাকি',
    );
    return '$_temp0';
  }

  @override
  String circularsCountdownOverdueDays(int days, String formattedDays) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$formattedDays দিন মেয়াদোত্তীর্ণ',
      one: '$formattedDays দিন মেয়াদোত্তীর্ণ',
      zero: 'আজ মেয়াদ শেষ',
    );
    return '$_temp0';
  }

  @override
  String get circularSectorGovernment => 'সরকারি';

  @override
  String get circularSectorBcs => 'বিসিএস';

  @override
  String get circularSectorBank => 'ব্যাংক';

  @override
  String get circularSectorAutonomous => 'স্বায়ত্তশাসিত';

  @override
  String get circularSectorPrivate => 'বেসরকারি';

  @override
  String get circularSectorNgo => 'এনজিও';

  @override
  String get circularSectorDefense => 'প্রতিরক্ষা';

  @override
  String get circularSectorOther => 'অন্যান্য';

  @override
  String get circularAppStatusNotApplied => 'আবেদন করা হয়নি';

  @override
  String get circularAppStatusInProgress => 'চলমান';

  @override
  String get circularAppStatusApplied => 'আবেদিত';

  @override
  String get circularAppStatusFeePaid => 'ফি পরিশোধিত';

  @override
  String get circularAppStatusExempt => 'ফি মওকুফ';

  @override
  String get circularAppStatusMissed => 'সময় শেষ';

  @override
  String get circularAppStatusNotApplicable => 'প্রযোজ্য নয়';

  @override
  String get circularPriorityLow => 'নিম্ন';

  @override
  String get circularPriorityMedium => 'মাঝারি';

  @override
  String get circularPriorityHigh => 'উচ্চ';

  @override
  String get circularPriorityUrgent => 'জরুরি';

  @override
  String get circularWorkflowSaved => 'সংরক্ষিত';

  @override
  String get circularWorkflowPreparing => 'প্রস্তুতি চলছে';

  @override
  String get circularWorkflowApplied => 'আবেদিত';

  @override
  String get circularWorkflowExamUpcoming => 'পরীক্ষা আসন্ন';

  @override
  String get circularWorkflowResultAwaited => 'ফলাফলের অপেক্ষায়';

  @override
  String get circularWorkflowArchived => 'আর্কাইভড';

  @override
  String get circularsLoadingMessage => 'চাকরির সার্কুলার লোড হচ্ছে...';

  @override
  String get circularsEmptyTitle => 'এখনো কোনো সার্কুলার নেই';

  @override
  String get circularsEmptyMessage =>
      'ট্র্যাক করা চাকরির সার্কুলারগুলো যোগ করার পর এখানে দেখা যাবে।';

  @override
  String get circularsFilteredEmptyTitle => 'মিল পাওয়া কোনো সার্কুলার নেই';

  @override
  String get circularsFilteredEmptyMessage =>
      'অনুসন্ধানের শব্দ পরিবর্তন করুন অথবা সক্রিয় ফিল্টারগুলো মুছুন।';

  @override
  String get circularsErrorTitle => 'সার্কুলার লোড করা যায়নি';

  @override
  String get circularsRetryButton => 'আবার চেষ্টা করুন';

  @override
  String get circularsErrorPermission =>
      'এই সার্কুলারগুলো দেখার অনুমতি আপনার নেই।';

  @override
  String get circularsErrorNetwork =>
      'সার্কুলার লোড করার সময় নেটওয়ার্ক ত্রুটি হয়েছে। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get circularsErrorUnknown =>
      'সার্কুলার লোড করতে একটি সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get circularsAddButton => 'সার্কুলার যোগ করুন';

  @override
  String get circularFormAddTitle => 'নতুন সার্কুলার যোগ করুন';

  @override
  String get circularFormAddSubtitle =>
      'চাকরির সার্কুলারের শেষ তারিখ, আবেদন ফি ও ট্র্যাকিং তথ্য সংরক্ষণ করুন।';

  @override
  String get circularFormEditTitle => 'সার্কুলার সম্পাদনা করুন';

  @override
  String get circularFormEditSubtitle =>
      'সার্কুলারের তথ্য, আবেদনের অবস্থা বা ব্যক্তিগত নোট হালনাগাদ করুন।';

  @override
  String get circularFormSaveButton => 'সার্কুলার সংরক্ষণ করুন';

  @override
  String get circularFormUpdateButton => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get circularFormCancelButton => 'বাতিল';

  @override
  String get circularFormNotFoundTitle => 'সার্কুলারটি পাওয়া যায়নি';

  @override
  String get circularFormNotFoundMessage =>
      'এই সার্কুলারটি মুছে ফেলা হয়ে থাকতে পারে অথবা আর পাওয়া যাচ্ছে না।';

  @override
  String get circularFormBackToList => 'সার্কুলার তালিকায় ফিরে যান';

  @override
  String get circularFormSectionBasics => 'মৌলিক তথ্য';

  @override
  String get circularFormSectionLinks => 'লিংকসমূহ';

  @override
  String get circularFormSectionDatesAndNumbers => 'তারিখ ও সংখ্যা';

  @override
  String get circularFormSectionStatus => 'অবস্থা';

  @override
  String get circularFormSectionText => 'নির্দেশনা ও নোট';

  @override
  String get circularFieldTitleLabel => 'সার্কুলারের শিরোনাম';

  @override
  String get circularFieldTitleHint => 'যেমন: ৪৭তম বিসিএস সাধারণ ক্যাডার';

  @override
  String get circularFieldSectorLabel => 'খাত';

  @override
  String get circularFieldOrgNameLabel => 'প্রতিষ্ঠানের নাম';

  @override
  String get circularFieldOrgNameHint => 'যেমন: বাংলাদেশ সরকারি কর্ম কমিশন';

  @override
  String get circularFieldOrgWebsiteLabel => 'প্রতিষ্ঠানের ওয়েবসাইট';

  @override
  String get circularFieldOrgWebsiteHint => 'https://example.gov.bd';

  @override
  String get circularFieldCircularUrlLabel => 'মূল সার্কুলারের লিংক';

  @override
  String get circularFieldCircularUrlHint => 'https://example.gov.bd/circular';

  @override
  String get circularFieldApplicationUrlLabel => 'আবেদন পোর্টালের লিংক';

  @override
  String get circularFieldApplicationUrlHint => 'https://apply.example.gov.bd';

  @override
  String get circularFieldDeadlineLabel => 'আবেদনের শেষ তারিখ';

  @override
  String get circularFieldDeadlineNone => 'শেষ তারিখ নির্বাচন করুন';

  @override
  String get circularFieldClearDeadlineTooltip => 'শেষ তারিখ মুছুন';

  @override
  String get circularFieldVacanciesLabel => 'শূন্যপদ সংখ্যা';

  @override
  String get circularFieldVacanciesHint => 'যেমন: ১৫০';

  @override
  String get circularFieldSalaryMinLabel => 'সর্বনিম্ন বেতন';

  @override
  String get circularFieldSalaryMinHint => 'যেমন: ২২০০০';

  @override
  String get circularFieldSalaryMaxLabel => 'সর্বোচ্চ বেতন';

  @override
  String get circularFieldSalaryMaxHint => 'যেমন: ৫৩০৬০';

  @override
  String get circularFieldSalaryNoteLabel => 'বেতন ও সুবিধার নোট';

  @override
  String get circularFieldSalaryNoteHint => 'যেমন: ৯ম গ্রেড জাতীয় বেতন স্কেল';

  @override
  String get circularFieldFeeLabel => 'আবেদন ফি';

  @override
  String get circularFieldFeeHint => 'যেমন: ২০০';

  @override
  String get circularFieldFeeNoteLabel => 'ফি সংক্রান্ত নোট';

  @override
  String get circularFieldFeeNoteHint =>
      'যেমন: টেলিটক বা বিকাশের মাধ্যমে পরিশোধযোগ্য';

  @override
  String get circularFieldAppStatusLabel => 'আবেদনের অবস্থা';

  @override
  String get circularFieldAdmitStatusLabel => 'প্রবেশপত্রের অবস্থা';

  @override
  String get circularFieldPriorityLabel => 'অগ্রাধিকার';

  @override
  String get circularFieldWorkflowStatusLabel => 'কার্যপ্রবাহ';

  @override
  String get circularFieldInstructionsLabel => 'নির্দেশনা';

  @override
  String get circularFieldInstructionsHint =>
      'যোগ্যতার শর্ত, প্রয়োজনীয় কাগজপত্র, ছবির মাপ...';

  @override
  String get circularFieldNotesLabel => 'ব্যক্তিগত নোট';

  @override
  String get circularFieldNotesHint =>
      'মনে রাখার বিষয়, প্রস্তুতির পরিকল্পনা...';

  @override
  String get circularFieldSyllabusLabel => 'সিলেবাস';

  @override
  String get circularFieldSyllabusHint =>
      'পরীক্ষার বিষয়, মানবণ্টন ও গুরুত্বপূর্ণ টপিক...';

  @override
  String get circularAdmitStatusNotAvailable => 'প্রকাশিত হয়নি';

  @override
  String get circularAdmitStatusAvailable => 'উপলব্ধ';

  @override
  String get circularAdmitStatusDownloaded => 'ডাউনলোড সম্পন্ন';

  @override
  String get circularAdmitStatusNotApplicable => 'প্রযোজ্য নয়';

  @override
  String get circularValidationTitleRequired =>
      'অনুগ্রহ করে সার্কুলারের শিরোনাম লিখুন।';

  @override
  String get circularValidationInvalidUrl =>
      'http:// বা https:// দিয়ে শুরু সঠিক লিংক লিখুন।';

  @override
  String get circularValidationInvalidInt =>
      'শূন্য বা তার বেশি সঠিক পূর্ণসংখ্যা লিখুন।';

  @override
  String get circularValidationInvalidNumber =>
      'শূন্য বা তার বেশি সঠিক সংখ্যা লিখুন।';

  @override
  String get circularValidationSalaryRange =>
      'সর্বোচ্চ বেতন সর্বনিম্ন বেতনের চেয়ে কম হতে পারবে না।';

  @override
  String circularDuplicateLinkWarning(String title) {
    return 'সতর্কতা: \"$title\" সার্কুলারে ইতিমধ্যেই এই লিংকটি ব্যবহার করা হয়েছে।';
  }

  @override
  String get circularFormErrorValidation =>
      'জমা দেওয়া তথ্য যাচাইকরণে ত্রুটি পাওয়া গেছে।';

  @override
  String get circularDiscardDialogTitle => 'অসংরক্ষিত পরিবর্তন বাতিল করবেন?';

  @override
  String get circularDiscardDialogMessage =>
      'এই সার্কুলারে অসংরক্ষিত পরিবর্তন রয়েছে। এখন ফিরে গেলে সেগুলো হারিয়ে যাবে।';

  @override
  String get circularDiscardKeepEditing => 'সম্পাদনা চালিয়ে যান';

  @override
  String get circularDiscardConfirm => 'পরিবর্তন বাতিল করুন';

  @override
  String get navInbox => 'ইনবক্স';

  @override
  String navInboxCountSemantic(String label, String formattedCount) {
    return '$label, $formattedCountটি অপেক্ষমাণ';
  }

  @override
  String get circularWorkflowInbox => 'ইনবক্স';

  @override
  String get quickCaptureButton => 'দ্রুত সংরক্ষণ';

  @override
  String quickCaptureShortcutTooltip(String shortcut) {
    return 'দ্রুত সংরক্ষণ ($shortcut)';
  }

  @override
  String get quickCaptureDialogTitle => 'দ্রুত সংরক্ষণ';

  @override
  String get quickCaptureDialogSubtitle =>
      'এখনই সার্কুলার লিংক রাখুন এবং পরে ইনবক্স থেকে বিস্তারিত পূরণ করুন।';

  @override
  String get quickCaptureLinkLabel => 'সার্কুলারের লিংক';

  @override
  String get quickCaptureLinkHint => 'https://...';

  @override
  String get quickCaptureLinkRequired => 'অনুগ্রহ করে সার্কুলারের লিংক লিখুন।';

  @override
  String get quickCaptureTitleLabel => 'শিরোনাম (ঐচ্ছিক)';

  @override
  String get quickCaptureTitleHint =>
      'ঐচ্ছিক — খালি রাখলে ওয়েবসাইটের নাম ব্যবহার হবে';

  @override
  String get quickCaptureDeadlineLabel => 'আবেদনের শেষ তারিখ (ঐচ্ছিক)';

  @override
  String get quickCaptureSaveAction => 'ইনবক্সে রাখুন';

  @override
  String get quickCaptureSavingAction => 'সংরক্ষণ হচ্ছে...';

  @override
  String quickCaptureSavedSnackbar(String title) {
    return '\"$title\" ইনবক্সে সংরক্ষিত হয়েছে।';
  }

  @override
  String get quickCaptureViewInboxAction => 'ইনবক্স দেখুন';

  @override
  String get inboxTitle => 'ইনবক্স';

  @override
  String inboxCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCountটি দ্রুত-সংরক্ষিত আইটেম অপেক্ষমাণ',
      one: '১টি দ্রুত-সংরক্ষিত আইটেম অপেক্ষমাণ',
      zero: 'অপেক্ষমাণ কোনো দ্রুত-সংরক্ষিত আইটেম নেই',
    );
    return '$_temp0';
  }

  @override
  String get inboxEmptyTitle => 'ইনবক্স সম্পূর্ণ খালি';

  @override
  String get inboxEmptyMessage =>
      'যেকোনো স্ক্রিন থেকে দ্রুত সংরক্ষণ ব্যবহার করুন (অথবা ওয়েবে Alt+Q চাপুন) পরে যাচাই করার জন্য সার্কুলার লিংক জমা রাখতে।';

  @override
  String inboxCapturedOn(String formattedDate) {
    return 'সংরক্ষিত $formattedDate';
  }

  @override
  String get inboxCompleteDetailsAction => 'বিস্তারিত পূরণ করুন';

  @override
  String get inboxSkipAction => 'এড়িয়ে যান';

  @override
  String get inboxDeleteAction => 'মুছে ফেলুন';

  @override
  String get inboxRefreshTooltip => 'ইনবক্স রিফ্রেশ করুন';

  @override
  String inboxActionSkipped(String title) {
    return '\"$title\" ইনবক্স থেকে সরানো হয়েছে।';
  }

  @override
  String inboxActionDeleted(String title) {
    return '\"$title\" মুছে ফেলা হয়েছে।';
  }

  @override
  String get circularDetailBackTooltip => 'সার্কুলার তালিকায় ফিরুন';

  @override
  String get circularDetailCloseTooltip => 'বিস্তারিত বন্ধ করুন';

  @override
  String get circularDetailEditAction => 'সম্পাদনা';

  @override
  String get circularDetailDeleteAction => 'মুছে ফেলুন';

  @override
  String get circularDetailDeleteTitle => 'সার্কুলারটি মুছে ফেলবেন?';

  @override
  String circularDetailDeleteMessage(String title) {
    return '\"$title\" এবং এর নির্ধারিত পরীক্ষার তারিখগুলো স্থায়ীভাবে মুছে ফেলা হবে।';
  }

  @override
  String get circularDetailQuickCaptureBadge => 'দ্রুত সংরক্ষিত';

  @override
  String get circularDetailLaunchFailed => 'এই লিংকটি এখন খোলা যাচ্ছে না।';

  @override
  String get circularDetailQuickActionsTitle => 'দ্রুত অবস্থা ও চেকলিস্ট';

  @override
  String get circularDetailChecklistTitle => 'আবেদন চেকলিস্ট';

  @override
  String circularDetailChecklistProgress(
      String formattedDone, String formattedTotal) {
    return '$formattedTotalটির মধ্যে $formattedDoneটি সম্পন্ন';
  }

  @override
  String get checklistPhoto => 'ছবি প্রস্তুত';

  @override
  String get checklistCertificates => 'সনদপত্র প্রস্তুত';

  @override
  String get checklistFeePaid => 'আবেদন ফি পরিশোধিত';

  @override
  String get checklistSubmitted => 'আবেদন জমা দেওয়া হয়েছে';

  @override
  String get checklistAdmitCardDownloaded => 'প্রবেশপত্র ডাউনলোড সম্পন্ন';

  @override
  String get circularDetailLinksTitle => 'অফিসিয়াল লিংক';

  @override
  String get circularDetailOpenCircularLink => 'মূল সার্কুলার লিংক';

  @override
  String get circularDetailOpenApplicationPortal => 'আবেদন পোর্টাল';

  @override
  String get circularDetailOpenOrgWebsite => 'প্রতিষ্ঠানের ওয়েবসাইট';

  @override
  String get circularDetailLinkMissing => 'দেওয়া হয়নি';

  @override
  String get circularDetailOverviewTitle => 'সারসংক্ষেপ ও বেতন-ভাতা';

  @override
  String get circularDetailFieldDeadline => 'আবেদনের শেষ সময়';

  @override
  String get circularDetailFieldVacancies => 'শূন্যপদ';

  @override
  String get circularDetailFieldSalary => 'বেতন সীমা';

  @override
  String get circularDetailFieldSalaryNote => 'বেতন নোট';

  @override
  String get circularDetailFieldFee => 'আবেদন ফি';

  @override
  String get circularDetailFieldFeeNote => 'ফি সংক্রান্ত নোট';

  @override
  String get circularDetailFieldCreated => 'যোগ করা হয়েছে';

  @override
  String get circularDetailFieldUpdated => 'সর্বশেষ হালনাগাদ';

  @override
  String get circularDetailNotProvided => 'উল্লেখ নেই';

  @override
  String circularDetailSalaryRange(String min, String max) {
    return '$min - $max';
  }

  @override
  String circularDetailSalaryFrom(String min) {
    return '$min থেকে';
  }

  @override
  String circularDetailSalaryUpTo(String max) {
    return 'সর্বোচ্চ $max';
  }

  @override
  String get circularDetailExamDatesTitle => 'পরীক্ষার তারিখ';

  @override
  String get examDateAddAction => 'পরীক্ষার তারিখ যোগ করুন';

  @override
  String get examDateUpcomingHeading => 'আসন্ন পরীক্ষাসমূহ';

  @override
  String get examDatePastHeading => 'অতীত পরীক্ষাসমূহ';

  @override
  String get examDateEmptyMessage =>
      'এখনো কোনো পরীক্ষার তারিখ যোগ করা হয়নি। প্রিলিমিনারি, লিখিত, মৌখিক বা ব্যবহারিক ধাপ এখানে ট্র্যাক করুন।';

  @override
  String get examDateStageLabel => 'পরীক্ষার ধাপ';

  @override
  String get examDateStagePreliminary => 'প্রিলিমিনারি';

  @override
  String get examDateStageWritten => 'লিখিত';

  @override
  String get examDateStageViva => 'মৌখিক (ভাইভা)';

  @override
  String get examDateStagePractical => 'ব্যবহারিক';

  @override
  String get examDateStageOther => 'অন্যান্য';

  @override
  String get examDateDateLabel => 'পরীক্ষার তারিখ ও সময়';

  @override
  String get examDatePickDateAction => 'তারিখ পরিবর্তন';

  @override
  String get examDatePickTimeAction => 'সময় পরিবর্তন';

  @override
  String get examDateVenueLabel => 'ভেন্যু / কেন্দ্র (ঐচ্ছিক)';

  @override
  String get examDateVenueHint => 'যেমন: ঢাকা কলেজ / বিপিএসসি সদর দপ্তর';

  @override
  String get examDateNotesLabel => 'নোট (ঐচ্ছিক)';

  @override
  String get examDateNotesHint =>
      'রিপোর্টিং সময়, আসন বিন্যাস, প্রয়োজনীয় কাগজপত্র...';

  @override
  String get examDateDialogAddTitle => 'পরীক্ষার তারিখ যোগ করুন';

  @override
  String get examDateDialogEditTitle => 'পরীক্ষার তারিখ সম্পাদনা';

  @override
  String get examDateEditTooltip => 'পরীক্ষার তারিখ সম্পাদনা করুন';

  @override
  String get examDateDeleteTooltip => 'পরীক্ষার তারিখ মুছে ফেলুন';

  @override
  String get circularDetailNotesTitle => 'নির্দেশনা, নোট ও সিলেবাস';

  @override
  String get circularFilesTitle => 'ফাইল ও সংযুক্তি';

  @override
  String circularFilesAllowedHelper(String maxSize) {
    return 'PDF, PNG, JPG, WEBP • সর্বোচ্চ $maxSize (বড় ছবি রিসাইজ করা হয়)';
  }

  @override
  String get circularFilesUploadButton => 'ফাইল আপলোড করুন';

  @override
  String circularFilesUploading(String fileName, String percent) {
    return '$fileName আপলোড হচ্ছে ($percent%)';
  }

  @override
  String get circularFilesEmpty =>
      'এখনো কোনো ফাইল যুক্ত নেই। সার্কুলারের PDF, প্রবেশপত্র বা ছবি আপলোড করুন।';

  @override
  String get circularFilesLoadError =>
      'এই মুহূর্তে সংযুক্ত ফাইলগুলো লোড করা যায়নি।';

  @override
  String get circularFilesRetry => 'আবার চেষ্টা করুন';

  @override
  String get circularFilesPreviewAction => 'প্রিভিউ';

  @override
  String get circularFilesDownloadAction => 'ডাউনলোড';

  @override
  String get circularFilesDeleteAction => 'মুছে ফেলুন';

  @override
  String get circularFilesPreviewTitle => 'ফাইল প্রিভিউ';

  @override
  String get circularFilesPreviewPdfMessage =>
      'PDF ফাইল আপনার ব্রাউজার বা পিডিএফ ভিউয়ারে অস্থায়ী স্বাক্ষরিত লিংকের মাধ্যমে খুলবে।';

  @override
  String get circularFilesOpenSignedLink => 'স্বাক্ষরিত লিংক খুলুন';

  @override
  String get circularFilesPreviewLoadError =>
      'এখানে প্রিভিউ দেখানো যায়নি। পরিবর্তে অস্থায়ী স্বাক্ষরিত লিংক খুলুন।';

  @override
  String get circularFilesCloseAction => 'বন্ধ করুন';

  @override
  String get circularFilesSignedUrlSecurityNote =>
      'অস্থায়ী স্বাক্ষরিত লিংকে সুরক্ষিত (কখনো পাবলিক নয়)।';

  @override
  String get circularFilesDeleteConfirmTitle => 'সংযুক্ত ফাইল মুছে ফেলবেন?';

  @override
  String circularFilesDeleteConfirmBody(String fileName) {
    return 'এই সার্কুলার থেকে \"$fileName\" স্থায়ীভাবে মুছে ফেলতে চান?';
  }

  @override
  String get circularFilesCancelAction => 'বাতিল';

  @override
  String get circularFilesConfirmDeleteAction => 'মুছে ফেলুন';

  @override
  String get circularFilesErrorUnsupportedType =>
      'শুধুমাত্র PDF, PNG, JPG, JPEG এবং WEBP ফাইল অনুমোদিত।';

  @override
  String get circularFilesErrorEmptyFile => 'নির্বাচিত ফাইলটি খালি।';

  @override
  String circularFilesErrorFileTooLarge(String maxSize) {
    return 'ফাইলটি $maxSize সীমা ছাড়িয়ে গেছে।';
  }

  @override
  String circularFilesErrorRawImageTooLarge(String maxSize) {
    return 'ছবিটি প্রসেস করার জন্য অতিরিক্ত বড় (সর্বোচ্চ $maxSize)।';
  }

  @override
  String get circularFilesErrorOpenLinkFailed =>
      'স্বাক্ষরিত ফাইলের লিংক খোলা যায়নি।';

  @override
  String circularFilesSizeBytes(String count) {
    return '$count বাইট';
  }

  @override
  String circularFilesSizeKb(String count) {
    return '$count কে.বি.';
  }

  @override
  String circularFilesSizeMb(String count) {
    return '$count মে.বা.';
  }

  @override
  String circularFilesCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCountটি ফাইল',
      one: '১টি ফাইল',
      zero: '০টি ফাইল',
    );
    return '$_temp0';
  }

  @override
  String get circularFilesTypePdf => 'PDF';

  @override
  String get circularFilesTypeImage => 'ছবি';

  @override
  String get calendarPreviousMonthTooltip => 'পূর্ববর্তী মাস';

  @override
  String get calendarNextMonthTooltip => 'পরবর্তী মাস';

  @override
  String get calendarTodayButton => 'আজ';

  @override
  String get calendarEventDeadline => 'আবেদনের শেষ দিন';

  @override
  String get calendarEventPreliminary => 'প্রিলিমিনারি';

  @override
  String get calendarEventWritten => 'লিখিত';

  @override
  String get calendarEventViva => 'মৌখিক (ভাইভা)';

  @override
  String get calendarEventPractical => 'ব্যবহারিক';

  @override
  String get calendarEventOther => 'অন্যান্য পরীক্ষা';

  @override
  String get calendarLegendTitle => 'রঙের সূচক';

  @override
  String calendarAgendaCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCountটি ইভেন্ট',
      one: '১টি ইভেন্ট',
      zero: 'কোনো ইভেন্ট নেই',
    );
    return '$_temp0';
  }

  @override
  String get calendarAgendaEmptyDay =>
      'এই তারিখে কোনো আবেদনের শেষ সময় বা পরীক্ষার তারিখ নেই।';

  @override
  String get calendarEmptyMonthHint =>
      'এই ক্যালেন্ডারে দেখতে আপনার সার্কুলারগুলোতে আবেদনের শেষ দিন বা পরীক্ষার তারিখ যোগ করুন।';

  @override
  String get calendarLoadError => 'এই মুহূর্তে আপনার সময়সূচি লোড করা যায়নি।';

  @override
  String get calendarRetry => 'আবার চেষ্টা করুন';

  @override
  String get calendarOpenCircularAction => 'সার্কুলার দেখুন';

  @override
  String calendarMoreEvents(String formattedCount) {
    return '+$formattedCount';
  }

  @override
  String calendarWeekStartsNote(String dayName) {
    return 'সপ্তাহ শুরু: $dayName';
  }

  @override
  String get prepSubjectsSectionTitle => 'বিষয়সমূহ';

  @override
  String get prepOverallProgressLabel => 'সামগ্রিক অগ্রগতি';

  @override
  String prepSubjectCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCountটি বিষয়',
      one: '১টি বিষয়',
      zero: 'কোনো বিষয় নেই',
    );
    return '$_temp0';
  }

  @override
  String prepMaterialCount(int count, String formattedCount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$formattedCountটি উপকরণ',
      one: '১টি উপকরণ',
      zero: 'কোনো উপকরণ নেই',
    );
    return '$_temp0';
  }

  @override
  String get prepAddSubjectButton => 'বিষয় যোগ করুন';

  @override
  String get prepAddMaterialButton => 'উপকরণ যোগ করুন';

  @override
  String get prepRefreshTooltip => 'বিষয় ও উপকরণ রিফ্রেশ করুন';

  @override
  String get prepLoadError =>
      'এই মুহূর্তে প্রস্তুতির বিষয়সমূহ লোড করা যায়নি।';

  @override
  String get prepSelectSubjectPrompt =>
      'পড়ার উপকরণ দেখতে ও পরিচালনা করতে তালিকা থেকে একটি বিষয় নির্বাচন করুন।';

  @override
  String get prepEmptySubjectsTitle => 'এখনো কোনো বিষয় নেই';

  @override
  String get prepEmptySubjectsBody =>
      'আপনার কাঙ্ক্ষিত ক্যারিয়ার বা পরীক্ষার জন্য বিষয় তৈরি করুন, এবং প্রতিটি বিষয়ের ভেতরে বই, কোর্স, নোট বা প্রশ্নব্যাংক যোগ করুন।';

  @override
  String prepEmptyMaterialsTitle(String subjectName) {
    return '$subjectName বিষয়ে কোনো উপকরণ নেই';
  }

  @override
  String get prepEmptyMaterialsBody =>
      'আপনার পছন্দমতো একক সহ বই, লেকচার শিট, ভিডিও কোর্স বা মক টেস্ট যোগ করুন।';

  @override
  String get prepBackToSubjects => 'বিষয় তালিকায় ফিরুন';

  @override
  String get prepCreateSubjectTitle => 'নতুন বিষয়';

  @override
  String get prepEditSubjectTitle => 'বিষয় সম্পাদনা';

  @override
  String get prepSubjectNameLabel => 'বিষয়ের নাম';

  @override
  String get prepSubjectNameHint =>
      'যেমন: ইংরেজি, সাধারণ জ্ঞান, ডেটা স্ট্রাকচার্স';

  @override
  String get prepSubjectNameRequired => 'বিষয়ের নাম আবশ্যক।';

  @override
  String get prepExamTypeLabel => 'পরীক্ষা বা ক্যারিয়ার ট্র্যাক';

  @override
  String get prepExamTypeHint => 'যেকোনো ট্র্যাক লিখুন বা নিচ থেকে বাছাই করুন';

  @override
  String get prepExamTypeRequired => 'পরীক্ষা বা ক্যারিয়ার ট্র্যাক আবশ্যক।';

  @override
  String get prepExamTrackGeneral => 'সাধারণ';

  @override
  String get prepExamTrackBcs => 'বিসিএস';

  @override
  String get prepExamTrackBank => 'ব্যাংক';

  @override
  String get prepExamTrackGovt => 'সরকারি চাকরি';

  @override
  String get prepExamTrackMedical => 'মেডিকেল';

  @override
  String get prepExamTrackEngineering => 'প্রকৌশল';

  @override
  String get prepExamTrackIelts => 'আইইএলটিএস';

  @override
  String get prepSubjectColorLabel => 'রঙ';

  @override
  String get prepColorGold => 'সোনালি';

  @override
  String get prepColorInfo => 'আকাশি';

  @override
  String get prepColorSuccess => 'সবুজ';

  @override
  String get prepColorWarning => 'হলদে-কমলা';

  @override
  String get prepColorDanger => 'লাল';

  @override
  String get prepColorAccentSecondary => 'বেগুনি';

  @override
  String get prepSubjectIconLabel => 'আইকন';

  @override
  String get prepIconMenuBook => 'বই';

  @override
  String get prepIconCalculate => 'গণিত';

  @override
  String get prepIconLanguage => 'ভাষা';

  @override
  String get prepIconPublic => 'বিশ্ব / সাধারণ জ্ঞান';

  @override
  String get prepIconScience => 'বিজ্ঞান';

  @override
  String get prepIconComputer => 'কম্পিউটার';

  @override
  String get prepIconAccountBalance => 'অর্থ / আইন';

  @override
  String get prepIconPsychology => 'মানসিক দক্ষতা';

  @override
  String get prepIconGavel => 'সংবিধান';

  @override
  String get prepIconQuiz => 'কুইজ / মক';

  @override
  String get prepSaveButton => 'সংরক্ষণ করুন';

  @override
  String get prepCancelButton => 'বাতিল করুন';

  @override
  String get prepEditAction => 'সম্পাদনা';

  @override
  String get prepDeleteAction => 'মুছে ফেলুন';

  @override
  String get prepMoveUpTooltip => 'বিষয়টি উপরে নিন';

  @override
  String get prepMoveDownTooltip => 'বিষয়টি নিচে নিন';

  @override
  String get prepDragReorderTooltip => 'সাজাতে টেনে আনুন';

  @override
  String get prepCreateMaterialTitle => 'নতুন উপকরণ';

  @override
  String get prepEditMaterialTitle => 'উপকরণ সম্পাদনা';

  @override
  String get prepMaterialTitleLabel => 'উপকরণের শিরোনাম';

  @override
  String get prepMaterialTitleHint => 'যেমন: বাংলা সাহিত্য, অফিশিয়াল গাইড';

  @override
  String get prepMaterialTitleRequired => 'উপকরণের শিরোনাম আবশ্যক।';

  @override
  String get prepMaterialKindLabel => 'ধরন';

  @override
  String get prepMaterialKindBook => 'বই';

  @override
  String get prepMaterialKindVideoCourse => 'ভিডিও কোর্স';

  @override
  String get prepMaterialKindLectureSheet => 'লেকচার শিট';

  @override
  String get prepMaterialKindQuestionBank => 'প্রশ্নব্যাংক';

  @override
  String get prepMaterialKindNotes => 'নোট';

  @override
  String get prepMaterialKindMockTest => 'মক টেস্ট';

  @override
  String get prepMaterialKindOther => 'অন্যান্য';

  @override
  String get prepUnitLabelFieldLabel => 'এককের নাম';

  @override
  String get prepUnitLabelHint => 'যেমন: পৃষ্ঠা, লেকচার, অধ্যায়';

  @override
  String get prepUnitLabelRequired => 'এককের নাম আবশ্যক।';

  @override
  String get prepUnitPresetPages => 'পৃষ্ঠা';

  @override
  String get prepUnitPresetChapters => 'অধ্যায়';

  @override
  String get prepUnitPresetLectures => 'লেকচার';

  @override
  String get prepUnitPresetVideos => 'ভিডিও';

  @override
  String get prepUnitPresetQuestions => 'প্রশ্ন';

  @override
  String get prepUnitPresetTests => 'টেস্ট';

  @override
  String get prepTotalUnitsLabel => 'মোট একক';

  @override
  String get prepTotalUnitsHint => 'যেমন: ৩০০';

  @override
  String get prepTotalUnitsInvalid => '০ বা তার বড় একটি পূর্ণসংখ্যা লিখুন।';

  @override
  String prepMaterialProgressSummary(
      String completed, String total, String unitLabel) {
    return '$completed / $total $unitLabel';
  }

  @override
  String prepPercentComplete(String percent) {
    return '$percent% সম্পন্ন';
  }

  @override
  String get prepCoverSectionLabel => 'কভার ছবি (ঐচ্ছিক)';

  @override
  String get prepCoverModeNone => 'নেই';

  @override
  String get prepCoverModeUpload => 'ছবি আপলোড';

  @override
  String get prepCoverModeUrl => 'লিংক দিন';

  @override
  String get prepCoverPickButton => 'JPG, PNG বা WEBP বাছাই করুন';

  @override
  String get prepCoverReplaceButton => 'ছবি পরিবর্তন করুন';

  @override
  String get prepCoverRemoveButton => 'কভার সরান';

  @override
  String prepCoverResizedNote(String formattedWidth) {
    return 'আপলোডের জন্য $formattedWidth পিক্সেল প্রস্থে রিসাইজ করা হয়েছে।';
  }

  @override
  String get prepCoverUrlLabel => 'ছবির লিংক';

  @override
  String get prepCoverUrlHint => 'https://example.com/cover.jpg';

  @override
  String get prepCoverPlaceholderHint =>
      'কভার ছবি না থাকলে স্বয়ংক্রিয়ভাবে গ্লাস অক্ষর ব্যাজ দেখানো হবে।';

  @override
  String get prepCoverErrorUnsupportedType =>
      'শুধুমাত্র JPG, PNG এবং WEBP ছবি সমর্থিত।';

  @override
  String get prepCoverErrorEmptyFile => 'নির্বাচিত কভার ছবিটি খালি।';

  @override
  String prepCoverErrorTooLarge(String maxSize) {
    return 'কভার ছবিটি $maxSize সীমা ছাড়িয়ে গেছে।';
  }

  @override
  String prepCoverErrorRawTooLarge(String maxSize) {
    return 'ছবিটি প্রসেস করার জন্য অতিরিক্ত বড় (সর্বোচ্চ $maxSize)।';
  }

  @override
  String get prepCoverErrorInvalidUrl =>
      'সঠিক http:// বা https:// ছবির লিংক লিখুন।';

  @override
  String get prepCoverUploadProgress => 'কভার রিসাইজ ও আপলোড হচ্ছে...';

  @override
  String prepDeleteSubjectTitle(String subjectName) {
    return '\"$subjectName\" মুছে ফেলবেন?';
  }

  @override
  String get prepDeleteSubjectBody =>
      'এতে এই বিষয়টি এবং এর ভেতরের সব উপকরণ মুছে যাবে।';

  @override
  String prepDeleteSubjectProgressWarning(String formattedUnits) {
    return 'সতর্কতা: এই বিষয়ে সংরক্ষিত অগ্রগতি রয়েছে (উপকরণগুলোতে $formattedUnits একক সম্পন্ন হয়েছে)। মুছে ফেললে সেই অগ্রগতি স্থায়ীভাবে হারিয়ে যাবে।';
  }

  @override
  String prepDeleteMaterialTitle(String materialTitle) {
    return '\"$materialTitle\" মুছে ফেলবেন?';
  }

  @override
  String get prepDeleteMaterialBody =>
      'আপনি কি নিশ্চিত যে এই উপকরণটি বিষয় থেকে মুছে ফেলতে চান?';

  @override
  String prepDeleteMaterialProgressWarning(String formattedCompleted,
      String formattedTotal, String unitLabel, String percent) {
    return 'সতর্কতা: আপনি ইতিমধ্যেই $formattedTotal $unitLabel-এর মধ্যে $formattedCompleted $unitLabel ($percent% সম্পন্ন) লগ করেছেন। উপকরণটি মুছে ফেললে এর অগ্রগতিও মুছে যাবে।';
  }

  @override
  String get prepDeleteConfirmButton => 'মুছে ফেলুন';

  @override
  String get prepErrorPermission =>
      'এই প্রস্তুতি আইটেম পরিবর্তন করার অনুমতি আপনার নেই।';

  @override
  String get prepErrorNetwork =>
      'সংরক্ষণের সময় নেটওয়ার্ক সমস্যা হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get prepErrorNotFound => 'প্রস্তুতির সেই আইটেমটি খুঁজে পাওয়া যায়নি।';

  @override
  String get prepErrorUnknown =>
      'প্রস্তুতির তথ্য হালনাগাদ করার সময় সমস্যা হয়েছে।';

  @override
  String prepOverallUnitsSummary(
      String formattedCompleted, String formattedTotal) {
    return '$formattedCompleted / $formattedTotal মোট একক';
  }

  @override
  String prepQuickLogPlus(String formattedAmount) {
    return '+$formattedAmount';
  }

  @override
  String get prepLogButton => 'লগ';

  @override
  String get prepLogDialogTitle => 'অগ্রগতি লগ করুন';

  @override
  String get prepCustomUnitsLabel => 'সম্পন্ন একক';

  @override
  String get prepCustomUnitsHint => 'যেমন: ২৫';

  @override
  String get prepCustomUnitsInvalid => '০-এর চেয়ে বড় একটি পূর্ণসংখ্যা লিখুন।';

  @override
  String get prepLogDateLabel => 'তারিখ';

  @override
  String get prepLogNoteLabel => 'নোট (ঐচ্ছিক)';

  @override
  String get prepLogNoteHint => 'যেমন: অধ্যায় ১-৩, রিভিশন';

  @override
  String get prepLogSaveButton => 'লগ সংরক্ষণ';

  @override
  String get prepLogUpdateButton => 'লগ হালনাগাদ';

  @override
  String get prepLogCancelEditButton => 'সম্পাদনা বাতিল';

  @override
  String get prepEditingLogBanner => 'পূর্ববর্তী লগ সম্পাদনা চলছে';

  @override
  String get prepPastLogsTitle => 'পূর্ববর্তী পাঠ লগসমূহ';

  @override
  String get prepNoPastLogs => 'এই উপকরণে এখনো কোনো পাঠ লগ করা হয়নি।';

  @override
  String prepLogUnitsSummary(String formattedUnits, String unitLabel) {
    return '+$formattedUnits $unitLabel';
  }

  @override
  String get prepTemplatesTitle => 'টেমপ্লেট দিয়ে দ্রুত শুরু করুন';

  @override
  String get prepTemplatesSubtitle =>
      'একটি প্রস্তুত পরিকল্পনা বেছে নিন; পরে যেকোনো সময় পরিবর্তন বা মুছে ফেলতে পারবেন।';

  @override
  String get prepApplyTemplateButton => 'টেমপ্লেট প্রয়োগ করুন';

  @override
  String get prepTemplatesOpenButton => 'টেমপ্লেটসমূহ';

  @override
  String get prepTemplatesDialogTitle => 'প্রস্তুতি টেমপ্লেটসমূহ';

  @override
  String get prepTemplatesSystemSection => 'স্টার্টার প্যাক';

  @override
  String get prepTemplatesPersonalSection => 'আপনার ব্যক্তিগত টেমপ্লেট';

  @override
  String get prepTemplatesPersonalEmpty =>
      'আপনার বর্তমান বিষয়গুলো একটি ব্যক্তিগত টেমপ্লেট হিসেবে সংরক্ষণ করুন যাতে যেকোনো সময় পুনরায় ব্যবহার করতে পারেন।';

  @override
  String get prepTemplateSystemBadge => 'স্টার্টার প্যাক';

  @override
  String get prepTemplatePersonalBadge => 'ব্যক্তিগত';

  @override
  String get prepTemplateAppliedBadge => 'প্রয়োগ করা হয়েছে';

  @override
  String get prepTemplateCustomizeButton => 'একক পরিবর্তন';

  @override
  String get prepTemplateApplyAgainButton => 'পুনরায় প্রয়োগ';

  @override
  String prepTemplateApplyConfirmTitle(String title) {
    return '\"$title\" কাস্টমাইজ ও প্রয়োগ করুন';
  }

  @override
  String get prepTemplateApplyConfirmSubtitle =>
      'আপনার প্রস্তুতি বিষয়ে কপি করার আগে নিচে একক সংখ্যা পরিবর্তন করতে পারেন। পরে যেকোনো সময় সবকিছু সম্পাদনা বা মুছে ফেলতে পারবেন।';

  @override
  String get prepTemplateConfirmApplyAction => 'আমার প্রস্তুতিতে কপি করুন';

  @override
  String prepTemplateAppliedSnackbar(int subjectCount, String formattedSubjects,
      int materialCount, String formattedMaterials, String title) {
    return '\"$title\" থেকে $formattedSubjectsটি বিষয় এবং $formattedMaterialsটি উপকরণ যোগ করা হয়েছে।';
  }

  @override
  String prepTemplateAlreadyAppliedSnackbar(String title) {
    return '\"$title\" টেমপ্লেটের সব বিষয় ও উপকরণ ইতিমধ্যেই আপনার পরিকল্পনায় রয়েছে (কোনো ডুপ্লিকেট তৈরি হয়নি)।';
  }

  @override
  String get prepSaveAsTemplateButton => 'টেমপ্লেট হিসেবে সংরক্ষণ';

  @override
  String get prepSaveTemplateDialogTitle => 'ব্যক্তিগত টেমপ্লেট সংরক্ষণ';

  @override
  String get prepSaveTemplateTitleLabel => 'টেমপ্লেটের নাম';

  @override
  String get prepSaveTemplateTitleHint => 'যেমন: ৪৮তম বিসিএস মূল পরিকল্পনা';

  @override
  String get prepSaveTemplateTitleRequired =>
      'অনুগ্রহ করে টেমপ্লেটের একটি নাম লিখুন।';

  @override
  String get prepSaveTemplateDescLabel => 'বিবরণ (ঐচ্ছিক)';

  @override
  String get prepSaveTemplateDescHint =>
      'বিষয় এবং লক্ষ্য চাকরি সম্পর্কে সংক্ষিপ্ত নোট';

  @override
  String get prepSaveTemplateExamLabel => 'ক্যারিয়ার বা পরীক্ষার ধরন';

  @override
  String prepSaveTemplatePreviewSummary(
      String formattedSubjects, String formattedMaterials) {
    return '$formattedSubjectsটি বিষয় এবং $formattedMaterialsটি উপকরণ এই টেমপ্লেটে সংরক্ষণ করা হবে';
  }

  @override
  String get prepSaveTemplateSaveAction => 'টেমপ্লেট সংরক্ষণ করুন';

  @override
  String prepSaveTemplateSavedSnackbar(String title) {
    return 'ব্যক্তিগত টেমপ্লেট \"$title\" সংরক্ষণ করা হয়েছে।';
  }

  @override
  String get prepDeleteTemplateTitle => 'ব্যক্তিগত টেমপ্লেট মুছবেন?';

  @override
  String prepDeleteTemplateMessage(String title) {
    return '\"$title\" মুছে ফেলতে চান? আপনার ড্যাশবোর্ডে ইতিমধ্যে কপি করা বিষয় ও উপকরণ অপরিবর্তিত থাকবে।';
  }

  @override
  String prepDeleteTemplateDeletedSnackbar(String title) {
    return 'ব্যক্তিগত টেমপ্লেট \"$title\" মুছে ফেলা হয়েছে।';
  }

  @override
  String get prepTemplateUnitsInvalid => '০ বা তার বড় পূর্ণসংখ্যা লিখুন।';

  @override
  String get prepSeededGovJobTitle => 'সরকারি চাকরি';

  @override
  String get prepSeededGovJobSubtitle =>
      'বাংলা, ইংরেজি, সাধারণ জ্ঞান, গণিত, বিশ্লেষণাত্মক যুক্তি ও কম্পিউটার — পরিবর্তনযোগ্য স্টার্টার উপকরণসহ।';

  @override
  String get prepSeededSweTitle => 'সফটওয়্যার ইঞ্জিনিয়ার';

  @override
  String get prepSeededSweSubtitle =>
      'ডেটা স্ট্রাকচার ও অ্যালগরিদম, ডেটাবেস সিস্টেম, ওওপি, ওয়েব ডেভেলপমেন্ট এবং সফটওয়্যার কোয়ালিটি অ্যাসুরেন্স।';
}
