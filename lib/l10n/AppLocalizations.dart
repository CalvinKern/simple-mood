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

  String get appName => "Simple Mood";

  String get addTodaysMood => Intl.message('Add Today\'s Mood');
  String get moodChart => Intl.message('Mood Chart');
  String get moodCount => Intl.message('Mood Count');
  String get noMoods => Intl.message('No Moods\nTry adding a new one!');
}
