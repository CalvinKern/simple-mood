import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_mood/platform/notification_channel.dart';
import 'repo_helper.dart';

class PrefsRepo extends Repo {
  static const KEY_DAILY_REMINDER_HOUR = 'DAILY_REMINDER_HOUR';
  static const KEY_DAILY_REMINDER_MINUTE = 'DAILY_REMINDER_MINUTE';
  static const KEY_WEEKLY_REMINDER_HOUR = 'WEEKLY_REMINDER_HOUR';
  static const KEY_WEEKLY_REMINDER_MINUTE = 'WEEKLY_REMINDER_MINUTE';
  final SharedPreferences? prefs;

  PrefsRepo({this.prefs});

  @override
  ChangeNotifierProxyProvider<SharedPreferences, PrefsRepo?> getProvider() =>
      ChangeNotifierProxyProvider<SharedPreferences, PrefsRepo?>(
        create: (_) => null,
        update: (_, prefs, __) => PrefsRepo(prefs: prefs),
      );

  @override
  bool readyToLoad() => prefs != null;

  ///
  /// Pref methods
  ///

  TimeOfDay? getDailyReminderTime() {
    final hour = prefs!.getInt(KEY_DAILY_REMINDER_HOUR);
    final minute = prefs!.getInt(KEY_DAILY_REMINDER_MINUTE);
    return (hour == null || minute == null) ? null : TimeOfDay(hour: hour, minute: minute);
  }

  TimeOfDay? getWeeklyReminderTime() {
    final hour = prefs!.getInt(KEY_WEEKLY_REMINDER_HOUR);
    final minute = prefs!.getInt(KEY_WEEKLY_REMINDER_MINUTE);
    return (hour == null || minute == null) ? null : TimeOfDay(hour: hour, minute: minute);
  }

  Future setDailyReminder({required String title, required bool notificationOn, required bool hasRatedToday}) async {
    if (!notificationOn) {
      await prefs!.remove(KEY_DAILY_REMINDER_HOUR);
      await prefs!.remove(KEY_DAILY_REMINDER_MINUTE);
    }

    if (notificationOn && (prefs!.getInt(KEY_DAILY_REMINDER_HOUR) == null || prefs!.getInt(KEY_DAILY_REMINDER_MINUTE) == null)) {
      // Set the time if one wasn't previously set (and rely on [setDailyReminderTime] to call [notifyListeners])
      await setDailyReminderTime(title, TimeOfDay.now(), hasRatedToday);
    } else {
      _setDailyNotification(notificationOn: notificationOn, time: getDailyReminderTime(), title: title, skipToday: hasRatedToday);
      notifyListeners();
    }
  }

  Future setWeeklyReminder({required String title, required bool notificationOn}) async {
    if (!notificationOn) {
      await prefs!.remove(KEY_WEEKLY_REMINDER_HOUR);
      await prefs!.remove(KEY_WEEKLY_REMINDER_MINUTE);
    }

    if (notificationOn && (prefs!.getInt(KEY_WEEKLY_REMINDER_HOUR) == null || prefs!.getInt(KEY_WEEKLY_REMINDER_MINUTE) == null)) {
      // Set the time if one wasn't previously set (and rely on [setDailyReminderTime] to call [notifyListeners])
      await setWeeklyReminderTime(title, TimeOfDay.now());
    } else {
      _setWeeklyNotification(notificationOn: notificationOn, time: getDailyReminderTime(), title: title);
      notifyListeners();
    }
  }

  Future setDailyReminderTime(String title, TimeOfDay time, bool hasRatedToday) async {
    await prefs!.setInt(KEY_DAILY_REMINDER_HOUR, time.hour);
    await prefs!.setInt(KEY_DAILY_REMINDER_MINUTE, time.minute);

    _setDailyNotification(notificationOn: true, time: time, title: title, skipToday: hasRatedToday);
    notifyListeners();
  }

  Future setWeeklyReminderTime(String title, TimeOfDay time) async {
    await prefs!.setInt(KEY_WEEKLY_REMINDER_HOUR, time.hour);
    await prefs!.setInt(KEY_WEEKLY_REMINDER_MINUTE, time.minute);

    _setWeeklyNotification(notificationOn: true, time: time, title: title);
    notifyListeners();
  }

  Future delayTodayReminder(String title) async {
    final reminderTime = getDailyReminderTime();
    if (reminderTime == null) return;

    final now = TimeOfDay.now();
    if (reminderTime.hour < now.hour || (reminderTime.hour == now.hour && reminderTime.minute < now.minute)) return;
    _setDailyNotification(notificationOn: true, time: reminderTime, skipToday: true, title: title);
  }

  Future _setDailyNotification({
    required bool notificationOn,
    required TimeOfDay? time,
    required String title,
    bool skipToday = false,
  }) =>
      NotificationChannel.setDailyNotification(
        notificationOn,
        skipToday: skipToday,
        time: time,
        notificationTitle: title,
      );

  Future _setWeeklyNotification({
    required bool notificationOn,
    required TimeOfDay? time,
    required String title,
  }) =>
      NotificationChannel.setWeeklyNotification(
        notificationOn,
        time: time,
        notificationTitle: title,
      );
}
