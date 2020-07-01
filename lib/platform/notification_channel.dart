import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_mood/db/db_helper.dart';
import 'package:simple_mood/db/tables/mood_table.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';

const _platform = const MethodChannel(NotificationChannel.CHANNEL);

void _callbackDispatcher() {
  // Setup internal state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // Listen for background events from the platform portion of the plugin.
  _platform.setMethodCallHandler(NotificationChannel._handleNativeCall);

  // Alert plugin that the callback handler is ready for events.
  _platform.invokeMethod(NotificationChannel.METHOD_DISPATCHER_INITIALIZED);
}

class NotificationChannel {
  static const CHANNEL = 'com.seakernel.simple_mood/notification';

  static const METHOD_SET_DAILY_NOTIFICATION = 'setDailyNotification';
  static const METHOD_DAILY_NOTIFICATION_RATED = 'dailyNotificationRated';
  static const METHOD_DISPATCHER_INITIALIZED = 'dispatcherInitialized';

  static const KEY_CALLBACK_DISPATCHER = 'callbackDispatcher';
  static const KEY_DAILY_NOTIFICATION_ON = 'dailyNotificationOn';
  static const KEY_DAILY_NOTIFICATION_TIME = 'dailyNotificationTime';
  static const KEY_DAILY_NOTIFICATION_TITLE = 'dailyNotificationTitle';
  static const KEY_DAILY_NOTIFICATION_RATING = 'dailyNotificationRating';

  static Future<dynamic> _handleNativeCall(MethodCall call) {
    switch (call.method) {
      case METHOD_DAILY_NOTIFICATION_RATED: return _addRating(call);
      default: throw ArgumentError.value(call.method, 'MethodCall with invalid method for NotificationChannel');
    }
  }

  static Future _addRating(MethodCall call) async {
    final rating = call.arguments[0] as int;
      // Can't get our repo through provider, so create the repo ourselves
    await MoodRepo(MoodTable(db: await DbHelper().getDatabase())).create(MoodRating.ratings.elementAt(rating));
    // TODO: could report back the weekly moods for another notification
  }

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
      await _platform.invokeMethod(METHOD_SET_DAILY_NOTIFICATION, <String, dynamic>{
        KEY_CALLBACK_DISPATCHER: _callbackDispatcherHandle(),
        KEY_DAILY_NOTIFICATION_ON: notificationOn,
        if (notificationTitle != null) KEY_DAILY_NOTIFICATION_TITLE: notificationTitle,
        if (nextTime != null) KEY_DAILY_NOTIFICATION_TIME: nextTime.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      Crashlytics.instance.recordFlutterError(FlutterErrorDetails(exception: e));
    }
  }

  static int _callbackDispatcherHandle() => PluginUtilities.getCallbackHandle(_callbackDispatcher).toRawHandle();
}
