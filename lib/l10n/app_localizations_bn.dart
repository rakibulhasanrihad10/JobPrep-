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
}
