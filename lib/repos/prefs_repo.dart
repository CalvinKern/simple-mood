import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repo_helper.dart';

class PrefsRepo extends Repo {
  static const KEY_DAILY_REMINDER_SET = 'DAILY_REMINDER_SET';
  static const KEY_DAILY_REMINDER_HOUR = 'DAILY_REMINDER_HOUR';
  static const KEY_DAILY_REMINDER_MINUTE = 'DAILY_REMINDER_MINUTE';
  final SharedPreferences prefs;

  PrefsRepo({this.prefs});

  @override
  ChangeNotifierProxyProvider<SharedPreferences, PrefsRepo> getProvider() =>
      ChangeNotifierProxyProvider<SharedPreferences, PrefsRepo>(
        create: (_) => null,
        update: (_, prefs, __) => PrefsRepo(prefs: prefs),
      );

  @override
  bool readyToLoad() => prefs != null;

  ///
  /// Pref methods
  ///

  bool getDailyReminderSet() => prefs.getBool(KEY_DAILY_REMINDER_SET);

  Future setDailyReminder(bool set) async {
    await prefs.setBool(KEY_DAILY_REMINDER_SET, set);
    if (set && (prefs.getInt(KEY_DAILY_REMINDER_HOUR) == null || prefs.getInt(KEY_DAILY_REMINDER_MINUTE) == null)) {
      // Set the time if one wasn't previously set (and rely on [setDailyReminderTime] to call [notifyListeners])
      await setDailyReminderTime(TimeOfDay.now());
    } else {
      notifyListeners();
    }
  }

  TimeOfDay getDailyReminderTime() => TimeOfDay(
      hour: prefs.getInt(KEY_DAILY_REMINDER_HOUR),
      minute: prefs.getInt(KEY_DAILY_REMINDER_MINUTE),
    );

  Future setDailyReminderTime(TimeOfDay time) async {
    await prefs.setInt(KEY_DAILY_REMINDER_HOUR, time.hour);
    await prefs.setInt(KEY_DAILY_REMINDER_MINUTE, time.minute);
    notifyListeners();
  }
}
