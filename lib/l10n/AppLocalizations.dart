import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// The localization delegate for the app strings.
/// TODO: Needs to be finished linking in with intl_translations, leaving that until further in, but at least this
/// structure has been setup.
///
/// It also might be simplified, so holding off on getting everything setup until I need it:
/// https://github.com/flutter/flutter/issues/41437
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  // List of supported languages, currently only English
  final supportedLocales = const <Locale>[
    Locale('en'),
  ];

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    // TODO: Uncomment once intl_translation generation is happening
//    final String name =
//        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
//    final String localeName = Intl.canonicalizedLocale(name);
//    return initializeMessages(localeName).then((_) {
//      return AppLocalizations();
//    });
    return Future.value(AppLocalizations());
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

/// A class to contain all the localized strings.
class AppLocalizations {
  static const _AppLocalizationsDelegate delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // App Strings

  String get appName => 'Simple Mood';

  String get pageHome => 'Dashboard';

  String get pageCalendar => 'Calendar';

  String get pageSettings => 'Settings';

  String get ratingMiserable => 'Miserable';

  String get ratingUnhappy => 'Unhappy';

  String get ratingPlain => 'Plain';

  String get ratingHappy => 'Happy';

  String get ratingEcstatic => 'Ecstatic';

  String get ratingMissing => 'Missing';

  // Action Strings

  String get delete => 'Delete';

  // Dashboard Strings

  String get addTodaysMood => Intl.message('Add Today\'s Mood');

  String editMood(String date) => Intl.message(
        'Edit Mood for $date',
        name: 'editMood',
        args: [date],
      );

  String get timePeriod => Intl.message('Time Period:');

  String get oneWeek => Intl.message('1W');

  String get oneMonth => Intl.message('1M');

  String get threeMonths => Intl.message('3M');

  String get sixMonths => Intl.message('6M');

  String get oneYear => Intl.message('1Y');

  String get periodAll => Intl.message('All');

  String get moodChart => Intl.message('Mood Chart');

  String get moodCount => Intl.message('Mood Count');

  String get noMoods => Intl.message('No Moods\nTry adding a new one!');

  String get deleteMoodTitle => Intl.message('Delete Mood?');

  String deleteMoodBody(String date, String moodRating) => Intl.message(
        'Delete the entry from $date with mood: $moodRating',
        name: 'deleteMoodBody',
        args: [date, moodRating],
      );

  // Settings Strings
  String get setDailyReminderTitle => Intl.message('Daily reminder:');

  String get setDailyReminderDateTitle => Intl.message('Receive a notification daily at:');

  String get dailyReminderNotificationTitle => Intl.message('How\'s your day going?');
}
