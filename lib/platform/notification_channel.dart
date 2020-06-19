import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationChannel {
  static const CHANNEL = 'com.seakernel.simple_mood/notification';

  static const METHOD_SET_DAILY_NOTIFICATION = 'setDailyNotification';

  static const KEY_DAILY_NOTIFICATION_ON = 'dailyNotificationOn';
  static const KEY_DAILY_NOTIFICATION_TIME = 'dailyNotificationTime';
  static const KEY_DAILY_NOTIFICATION_TITLE = 'dailyNotificationTitle';

  static const platform = const MethodChannel(CHANNEL);

  /// Platform channel to set the daily notification
  ///
  /// [notificationOn] - true if the notification is on
  /// [skipToday] - Optional, true if today's notification should be skipped (start tomorrow). Used when entered manually in the app
  /// [time] - Required as non null if [notificationOn] is true, the time to have the notification appear
  static Future<void> setDailyNotification(bool notificationOn, {bool skipToday, TimeOfDay time, String notificationTitle}) async {
    assert((time != null && notificationTitle != null) || !notificationOn); // Time has to be present if notification is on

    final now = DateTime.now();
    DateTime nextTime = time == null ? null : DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (nextTime != null && (now.isAfter(nextTime) || skipToday)) {
      nextTime = nextTime.add(Duration(days: 1));
    }
    
    try {
      await platform.invokeMethod(METHOD_SET_DAILY_NOTIFICATION, <String, dynamic>{
        KEY_DAILY_NOTIFICATION_ON: notificationOn,
        if (notificationTitle != null) KEY_DAILY_NOTIFICATION_TITLE: notificationTitle,
        if (nextTime != null) KEY_DAILY_NOTIFICATION_TIME: nextTime.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      Crashlytics.instance.recordFlutterError(FlutterErrorDetails(exception: e));
    }
  }
}
