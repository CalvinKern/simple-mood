package com.seakernel.simple_mood.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


object NotificationPlugin {
    private const val KEY_DAILY_NOTIFICATION_ON = "dailyNotificationOn"
    private const val METHOD_SET_DAILY_NOTIFICATION = "setDailyNotification"

    private const val REQUEST_DAILY_NOTIFICATION = 0
    private const val NOTIFICATION_PREFS = "notificationPrefs"

    // TODO: Add weekly notification
    private enum class NotificationId { DAILY }
    private enum class ChannelId { DAILY_NOTIFICATION }

    const val FLUTTER_CHANNEL = "com.seakernel.simple_mood/notification"

    const val EXTRA_ID_NOTIFICATION = "dailyNotificationId"
    const val EXTRA_ID_CHANNEL = "dailyNotificationChannel"
    const val EXTRA_TITLE = "dailyNotificationTitle"
    const val EXTRA_RATING = "dailyNotificationRating"

    fun configure(context: Context, flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SET_DAILY_NOTIFICATION -> setDailyNotification(context, call)
            }
            result.success(null)
        }
    }

    private fun getAlarmManager(context: Context): AlarmManager {
        return context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }

    // SharedPreferences helpers

    private fun sharedPrefs(context: Context) = context.getSharedPreferences(NOTIFICATION_PREFS, Context.MODE_PRIVATE)

    private fun setDailyNotification(context: Context, notification: DailyNotification) {
        sharedPrefs(context).edit().apply {
            putString(METHOD_SET_DAILY_NOTIFICATION, notification.toJson())
        }.apply()
    }

    private fun clearDailyNotification(context: Context) {
        sharedPrefs(context).edit().apply {
            remove(METHOD_SET_DAILY_NOTIFICATION)
        }.apply()
    }

    fun getDailyNotification(context: Context) =
            DailyNotification.fromJson(sharedPrefs(context).getString(METHOD_SET_DAILY_NOTIFICATION, null))

    // Notification helpers

    /**
     * Creates a pending intent for starting an alarm or returns a pending intent that can be canceled
     *
     * @param title not required if creating an intent to cancel
     */
    private fun createDailyPendingIntent(context: Context, notificationId: NotificationId, channelId: ChannelId, title: String? = null): PendingIntent {
        val notificationIntent = Intent(context, ScheduledNotificationReceiver::class.java).apply {
            putExtra(EXTRA_ID_NOTIFICATION, notificationId.ordinal)
            putExtra(EXTRA_ID_CHANNEL, channelId.name)
            if (title != null) putExtra(EXTRA_TITLE, title)
        }
        return PendingIntent.getBroadcast(context, REQUEST_DAILY_NOTIFICATION, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun setDailyNotification(context: Context, call: MethodCall) {
        if (call.argument<Boolean>(KEY_DAILY_NOTIFICATION_ON) != true) return deleteDailyNotification(context)

        val notification = DailyNotification(call)

        setDailyNotification(context, notification)
        setupBootReceiver(context)

        val type = AlarmManager.RTC_WAKEUP
        val repeatInterval = AlarmManager.INTERVAL_DAY
        val intent = createDailyPendingIntent(context, NotificationId.DAILY, ChannelId.DAILY_NOTIFICATION, notification.title)

        getAlarmManager(context).setInexactRepeating(type, notification.time, repeatInterval, intent)
    }

    private fun deleteDailyNotification(context: Context) {
        clearDailyNotification(context)
        setupBootReceiver(context)

        val intent = createDailyPendingIntent(context, NotificationId.DAILY, ChannelId.DAILY_NOTIFICATION)
        getAlarmManager(context).cancel(intent)
    }

    private fun setupBootReceiver(context: Context) {
        val notificationsOn = getDailyNotification(context) != null
        val receiver = ComponentName(context, NotificationBootReceiver::class.java)
        context.packageManager.setComponentEnabledSetting(
                receiver,
                if (notificationsOn) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
        )
    }
}
