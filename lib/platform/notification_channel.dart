import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_mood/db/db_helper.dart';
import 'package:simple_mood/db/tables/mood_table.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

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

  static const METHOD_DISPATCHER_INITIALIZED = 'dispatcherInitialized';
  static const METHOD_NOTIFICATION_DAILY_RATED = 'dailyNotificationRated';
  static const METHOD_SET_NOTIFICATION_DAILY = 'setDailyNotification';
  static const METHOD_SET_NOTIFICATION_WEEKLY = 'setWeeklyNotification';

  static const KEY_CALLBACK_DISPATCHER = 'callbackDispatcher';
  static const KEY_NOTIFICATION_TITLE = 'notificationTitle';
  static const KEY_NOTIFICATION_TIME = 'notificationTime';
  static const KEY_NOTIFICATION_RATING_DAILY = 'dailyNotificationRating';
  static const KEY_NOTIFICATION_ON = 'notificationOn';

  static Future<dynamic> _handleNativeCall(MethodCall call) {
    switch (call.method) {
      case METHOD_NOTIFICATION_DAILY_RATED: return _addRating(call);
      default: throw ArgumentError.value(call.method, 'MethodCall with invalid method for NotificationChannel');
    }
  }

  /// HACK returns the current string to use as the header for notifications
  static Future _addRating(MethodCall call) async {
    final args = call.arguments as List<Object>? ?? List.empty();
    final rating = args.length > 0 ? args[0] as int : -1;
    final time = args.length > 1 ? args[1] as int : DateTime.now().millisecondsSinceEpoch;

    // final x = DateTime.fromMillisecondsSinceEpoch(time);
    // print("SimpleMood: _addRating for time ${x.fullFormat()}");

    // Can't get our repo through provider, so create the repo ourselves
    await MoodRepo(MoodTable(db: await DbHelper().getDatabase()))
        .create(MoodRating.ratings.elementAt(rating), date: DateTime.fromMillisecondsSinceEpoch(time, isUtc: true));

    final title = AppLocalizations().dailyReminderNotificationTitle;
    return title;
  }

  /// Platform channel to set the daily notification
  ///
  /// [notificationOn] - true if the notification is on
  /// [skipToday] - Optional, true if today's notification should be skipped (start tomorrow). Used when entered manually in the app
  /// [time] - Required as non null if [notificationOn] is true, the time to have the notification appear
  static Future<void> setDailyNotification(bool notificationOn, {bool skipToday = false, TimeOfDay? time, String? notificationTitle}) async {
    assert((time != null && notificationTitle != null) || !notificationOn); // Time has to be present if notification is on

    final now = DateTime.now();
    DateTime? nextTime = time == null ? null : DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (nextTime != null && (now.isAfter(nextTime) || skipToday)) {
      nextTime = nextTime.add(Duration(days: 1));
    }

    try {
      await _platform.invokeMethod(METHOD_SET_NOTIFICATION_DAILY, <String, dynamic>{
        KEY_CALLBACK_DISPATCHER: _callbackDispatcherHandle(),
        KEY_NOTIFICATION_ON: notificationOn,
        if (notificationTitle != null) KEY_NOTIFICATION_TITLE: notificationTitle,
        if (nextTime != null) KEY_NOTIFICATION_TIME: nextTime.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      FirebaseCrashlytics.instance.recordFlutterError(FlutterErrorDetails(exception: e));
    }
  }

  /// Platform channel to set the weekly notification
  ///
  /// [notificationOn] - true if the notification is on
  /// [time] - Required as non null if [notificationOn] is true, the time to have the notification appear
  static Future<void> setWeeklyNotification(bool notificationOn, {TimeOfDay? time, String? notificationTitle}) async {
    assert((time != null && notificationTitle != null) || !notificationOn); // Time has to be present if notification is on

    final now = DateTime.now().add(Duration(days: 7)).toStartOfWeek();
    DateTime? nextTime = time == null ? null : DateTime(now.year, now.month, now.day, time.hour, time.minute);

    try {
      await _platform.invokeMethod(METHOD_SET_NOTIFICATION_WEEKLY, <String, dynamic>{
        KEY_CALLBACK_DISPATCHER: _callbackDispatcherHandle(),
        KEY_NOTIFICATION_ON: notificationOn,
        if (notificationTitle != null) KEY_NOTIFICATION_TITLE: notificationTitle,
        if (nextTime != null) KEY_NOTIFICATION_TIME: nextTime.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      FirebaseCrashlytics.instance.recordFlutterError(FlutterErrorDetails(exception: e));
    }
  }

  static int _callbackDispatcherHandle() => PluginUtilities.getCallbackHandle(_callbackDispatcher)!.toRawHandle();
}
