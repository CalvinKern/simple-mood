package com.seakernel.simple_mood.notification

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationManagerCompat
import com.seakernel.simple_mood.notification.receivers.DailyNotificationReceiver
import com.seakernel.simple_mood.notification.receivers.NotificationBootReceiver
import com.seakernel.simple_mood.notification.receivers.WeeklyNotificationReceiver
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


object NotificationPlugin {
    private const val KEY_NOTIFICATION_ON = "notificationOn"
    private const val METHOD_SET_NOTIFICATION_DAILY = "setDailyNotification"
    private const val METHOD_SET_NOTIFICATION_WEEKLY = "setWeeklyNotification"

    private const val REQUEST_NOTIFICATION_DAILY = 0
    private const val REQUEST_NOTIFICATION_WEEKLY = 1
    private const val NOTIFICATION_PREFS = "notificationPrefs"

    private enum class NotificationId { DAILY, WEEKLY }
    private enum class ChannelId { DAILY_NOTIFICATION, WEEKLY_NOTIFICATION }
    private sealed class NotificationData(
            val notificationId: NotificationId,
            val channelId: ChannelId,
            val requestCode: Int,
            val prefsKey: String,
            val interval: Long,
            val cls: Class<*>
    ) {
        class Daily : NotificationData(notificationId = NotificationId.DAILY, channelId = ChannelId.DAILY_NOTIFICATION, requestCode = REQUEST_NOTIFICATION_DAILY, prefsKey = METHOD_SET_NOTIFICATION_DAILY, cls = DailyNotificationReceiver::class.java, interval = AlarmManager.INTERVAL_DAY)
        class Weekly : NotificationData(notificationId = NotificationId.WEEKLY, channelId = ChannelId.WEEKLY_NOTIFICATION, requestCode = REQUEST_NOTIFICATION_WEEKLY, prefsKey = METHOD_SET_NOTIFICATION_WEEKLY, cls = WeeklyNotificationReceiver::class.java, interval = AlarmManager.INTERVAL_DAY * 7)
    }

    const val FLUTTER_CHANNEL = "com.seakernel.simple_mood/notification"

    const val EXTRA_ID_NOTIFICATION = "notificationId"
    const val EXTRA_ID_CHANNEL = "notificationChannel"
    const val EXTRA_TITLE = "notificationTitle"
    const val EXTRA_RATING_DAILY = "dailyNotificationRating"

    fun configure(context: Context, flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLUTTER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SET_NOTIFICATION_DAILY -> handleNotification(context, call, NotificationData.Daily())
                METHOD_SET_NOTIFICATION_WEEKLY -> handleNotification(context, call, NotificationData.Weekly())
            }
            result.success(null)
        }
    }

    private fun handleNotification(context: Context, call: MethodCall, data: NotificationData) {
        val notification = MoodNotification(call)
        val intent = createPendingIntent(context, data, notification.title)
        if (call.argument<Boolean>(KEY_NOTIFICATION_ON) != true) return deleteNotification(context, data.prefsKey, intent)

        setNotification(context, data.prefsKey, notification)
        setupBootReceiver(context)
        setAlarm(context, notification, data.interval, intent)
    }

    // SharedPreferences helpers

    private fun sharedPrefs(context: Context) = context.getSharedPreferences(NOTIFICATION_PREFS, Context.MODE_PRIVATE)

    private fun setNotification(context: Context, key: String, notification: MoodNotification) {
        sharedPrefs(context).edit().apply {
            putString(key, notification.toJson())
        }.apply()
    }

    private fun clearNotification(context: Context, key: String) {
        sharedPrefs(context).edit().apply {
            remove(key)
        }.apply()
    }

    private fun getWeeklyNotification(context: Context) =
            MoodNotification.fromJson(sharedPrefs(context).getString(METHOD_SET_NOTIFICATION_WEEKLY, null))

    fun getDailyNotification(context: Context) =
            MoodNotification.fromJson(sharedPrefs(context).getString(METHOD_SET_NOTIFICATION_DAILY, null))

    fun delayDailyNotification(context: Context) {
        val data = NotificationData.Daily()
        val notification = getDailyNotification(context) ?: return
        setNotification(context, data.prefsKey, notification.copy(time = validateDate(notification.time, data.interval)))
    }

    // Notification helpers

    private fun getAlarmManager(context: Context): AlarmManager {
        return context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }

    /**
     * Creates a pending intent for starting an alarm or returns a pending intent that can be canceled
     */
    private fun createPendingIntent(context: Context, data: NotificationData, title: String?): PendingIntent {
        val notificationIntent = Intent(context, data.cls).apply {
            putExtra(EXTRA_ID_NOTIFICATION, data.notificationId.ordinal)
            putExtra(EXTRA_ID_CHANNEL, data.channelId.name)
            if (title != null) putExtra(EXTRA_TITLE, title)
        }
        return PendingIntent.getBroadcast(context, data.requestCode, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun deleteNotification(context: Context, prefsKey: String, intent: PendingIntent) {
        clearNotification(context, prefsKey)
        setupBootReceiver(context)

        getAlarmManager(context).cancel(intent)
    }

    private fun setupBootReceiver(context: Context) {
        val notificationsOn = getDailyNotification(context) != null || getWeeklyNotification(context) != null
        val receiver = ComponentName(context, NotificationBootReceiver::class.java)
        context.packageManager.setComponentEnabledSetting(
                receiver,
                if (notificationsOn) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
        )
    }

    private fun setAlarm(context: Context, notification: MoodNotification, interval: Long, intent: PendingIntent) {
        val type = AlarmManager.RTC_WAKEUP
        getAlarmManager(context).setInexactRepeating(type, notification.time, interval, intent)
    }

    private fun resetAlarm(context: Context, notification: MoodNotification, data: NotificationData) {
        val intent = createPendingIntent(context, data, notification.title)
        setAlarm(context, notification, data.interval, intent)
    }

    fun resetAlarms(context: Context) {
        getDailyNotification(context)?.let { resetAlarm(context, it, NotificationData.Daily()) }
        getWeeklyNotification(context)?.let { resetAlarm(context, it.copy(time = validateDate(it.time, NotificationData.Weekly().interval)), NotificationData.Weekly()) }
    }

    // Returns the given time at an interval past now, or the time if it's after now.
    // Used for weekly only, daily always gets set each time a rating happens, weekly only gets set once.
    private fun validateDate(time: Long, interval: Long): Long {
        val currentTime = System.currentTimeMillis()
        var start = time
        while (start < currentTime) {
            start += interval
        }
        return start
    }

    fun setupNotificationChannel(context: Context, channelId: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val importance = NotificationManager.IMPORTANCE_DEFAULT
        val channel = NotificationChannel(channelId, channelId, importance).apply {
            description = channelId
            enableVibration(true)
            setShowBadge(true)
        }

        NotificationManagerCompat.from(context).createNotificationChannel(channel)
    }
}
