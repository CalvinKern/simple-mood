package com.seakernel.simple_mood.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.seakernel.simple_mood.BuildConfig
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*


object NotificationPlugin {
    private const val CHANNEL = "com.seakernel.simple_mood/notification"

    private const val METHOD_SET_DAILY_NOTIFICATION = "setDailyNotification"

    private const val REQUEST_DAILY_NOTIFICATION = 0

    private const val KEY_DAILY_NOTIFICATION_ON = "dailyNotificationOn"
    private const val KEY_DAILY_NOTIFICATION_HOUR = "dailyNotificationHour"
    private const val KEY_DAILY_NOTIFICATION_MINUTE = "dailyNotificationMinute"
    private const val KEY_DAILY_NOTIFICATION_SKIP_TODAY = "dailyNotificationSkipToday"
    private const val KEY_DAILY_NOTIFICATION_TITLE = "dailyNotificationTitle"

    private enum class NotificationId { DAILY }
    private enum class ChannelId { DAILY_NOTIFICATION }

    const val EXTRA_ID_NOTIFICATION = "dailyNotificationId"
    const val EXTRA_ID_CHANNEL = "dailyNotificationChannel"
    const val EXTRA_TITLE = "dailyNotificationTitle"

    fun configure(context: Context, flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SET_DAILY_NOTIFICATION -> setDailyNotification(context, call)
            }
            result.success(null)
        }
    }

    private fun getAlarmManager(context: Context): AlarmManager {
        return context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }

    private fun createDailyPendingIntent(context: Context, notificationId: NotificationId, channelId: ChannelId, title: String?): PendingIntent {
        val notificationIntent = Intent(context, ScheduledNotificationReceiver::class.java).apply {
            putExtra(EXTRA_ID_NOTIFICATION, notificationId.ordinal)
            putExtra(EXTRA_ID_CHANNEL, channelId.name)
            if (title != null) putExtra(EXTRA_TITLE, title)
        }
        return PendingIntent.getBroadcast(context, REQUEST_DAILY_NOTIFICATION, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun setDailyNotification(context: Context, call: MethodCall) {
        val notificationOn = call.argument<Boolean>(KEY_DAILY_NOTIFICATION_ON)!!
        if (!notificationOn) return deleteDailyNotification(context);

        val hour = call.argument<Int>(KEY_DAILY_NOTIFICATION_HOUR)!!
        val minute = call.argument<Int>(KEY_DAILY_NOTIFICATION_MINUTE)!!
        val skipToday = call.argument<Boolean>(KEY_DAILY_NOTIFICATION_SKIP_TODAY)!!
        val title = call.argument<String>(KEY_DAILY_NOTIFICATION_TITLE)!!

        val now = System.currentTimeMillis()
        val repeatInterval = 24 * 60 * 60 * 1000.toLong() // 24.hours.toLongMilliseconds()
        val startTime = Calendar.getInstance().run {
            timeInMillis = now
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (timeInMillis < now || skipToday) {
                timeInMillis + repeatInterval
            } else {
                timeInMillis
            }
        }

        // Get faster alerts while developing
        val type = if (BuildConfig.DEBUG) AlarmManager.RTC_WAKEUP else AlarmManager.RTC
        val intent = createDailyPendingIntent(context, NotificationId.DAILY, ChannelId.DAILY_NOTIFICATION, title)
        getAlarmManager(context).setRepeating(type, startTime, repeatInterval, intent)
    }

    private fun deleteDailyNotification(context: Context) {
        val intent = createDailyPendingIntent(context, NotificationId.DAILY, ChannelId.DAILY_NOTIFICATION, null)
        getAlarmManager(context).cancel(intent)
    }
}