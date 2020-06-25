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
    private const val SHARED_PREFS = "notificationPrefs"
    private const val REQUEST_DAILY_NOTIFICATION = 0

    private const val KEY_DAILY_NOTIFICATION_ON = "dailyNotificationOn"
    private const val KEY_DAILY_NOTIFICATION_TIME = "dailyNotificationTime"
    private const val KEY_DAILY_NOTIFICATION_TITLE = "dailyNotificationTitle"
    private const val KEY_CALLBACK_DISPATCHER = "callbackDispatcher"

    private enum class NotificationId { DAILY }
    private enum class ChannelId { DAILY_NOTIFICATION }

    const val CHANNEL = "com.seakernel.simple_mood/notification"

    const val METHOD_SET_DAILY_NOTIFICATION = "setDailyNotification"
    const val METHOD_DAILY_NOTIFICATION_RATED = "dailyNotificationRated"
    const val METHOD_DISPATCHER_INITIALIZED = "dispatcherInitialized"

    const val EXTRA_ID_NOTIFICATION = "dailyNotificationId"
    const val EXTRA_ID_CHANNEL = "dailyNotificationChannel"
    const val EXTRA_TITLE = "dailyNotificationTitle"
    const val EXTRA_RATING = "dailyNotificationRating"

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

    fun getCallbackHandle(context: Context): Long =
            context.getSharedPreferences(SHARED_PREFS, Context.MODE_PRIVATE).getLong(KEY_CALLBACK_DISPATCHER, 0)

    fun setCallbackHandle(context: Context, callbackHandle: Long) =
            context.getSharedPreferences(SHARED_PREFS, Context.MODE_PRIVATE).edit().putLong(KEY_CALLBACK_DISPATCHER, callbackHandle).commit()

    /**
     * Creates a pending intent for starting an alarm or returns a pending intent that can be canceled
     *
     * @param title not required if creating an intent to cancel
     * @param callbackHandle not required if creating an intent to cancel
     */
    private fun createDailyPendingIntent(context: Context, notificationId: NotificationId, channelId: ChannelId, title: String?, callbackHandle: Long?): PendingIntent {
        if (callbackHandle != null) setCallbackHandle(context, callbackHandle)
        val notificationIntent = Intent(context, ScheduledNotificationReceiver::class.java).apply {
            putExtra(EXTRA_ID_NOTIFICATION, notificationId.ordinal)
            putExtra(EXTRA_ID_CHANNEL, channelId.name)
            if (title != null) putExtra(EXTRA_TITLE, title)
        }
        return PendingIntent.getBroadcast(context, REQUEST_DAILY_NOTIFICATION, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun setDailyNotification(context: Context, call: MethodCall) {
        val notificationOn = call.argument<Boolean>(KEY_DAILY_NOTIFICATION_ON)!!
        if (!notificationOn) return deleteDailyNotification(context)

        val startTime = call.argument<Long>(KEY_DAILY_NOTIFICATION_TIME)!!
        val title = call.argument<String>(KEY_DAILY_NOTIFICATION_TITLE)!!
        val callbackHandle = call.argument<Long>(KEY_CALLBACK_DISPATCHER)!!

        val repeatInterval = 24 * 60 * 60 * 1000.toLong() // 24.hours.toLongMilliseconds()

        // Get faster alerts while developing
        val type = if (BuildConfig.DEBUG) AlarmManager.RTC_WAKEUP else AlarmManager.RTC
        val intent = createDailyPendingIntent(context, NotificationId.DAILY, ChannelId.DAILY_NOTIFICATION, title, callbackHandle)
        getAlarmManager(context).setRepeating(type, startTime, repeatInterval, intent)
    }

    private fun deleteDailyNotification(context: Context) {
        val intent = createDailyPendingIntent(context, NotificationId.DAILY, ChannelId.DAILY_NOTIFICATION, null, null)
        getAlarmManager(context).cancel(intent)
    }
}