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
}
