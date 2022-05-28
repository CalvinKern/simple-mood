package com.seakernel.simple_mood.notification.receivers

import android.app.Notification
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.seakernel.simple_mood.R
import com.seakernel.simple_mood.notification.NotificationPlugin
import java.text.SimpleDateFormat
import java.util.*

class DailyNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra(NotificationPlugin.EXTRA_ID_NOTIFICATION, 0)
        val channelId = intent.getStringExtra(NotificationPlugin.EXTRA_ID_CHANNEL)!!
        val dailyNotification = NotificationPlugin.delayDailyNotification(context)
        val time = dailyNotification?.time ?: System.currentTimeMillis()
        val title = dailyNotification?.title ?: "How's your day going?"
        val notification: Notification = createNotification(context, channelId, notificationId, title, time)

//        Log.d("SimpleMoodNative", "Alarm wake up to show notification: $title")
        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }

    private fun createNotification(context: Context, channelId: String, notificationId: Int, title: String, time: Long): Notification {
        NotificationPlugin.setupNotificationChannel(context, channelId)

        val notificationLayout = RemoteViews("com.seakernel.simple_mood", R.layout.notification_layout).apply {
            setTextViewText(R.id.notification_title, title)
        }
        val notificationLayoutExpanded = expandedRemoteViews(context, notificationId, title, time)

        val builder: NotificationCompat.Builder = NotificationCompat.Builder(context, channelId)
                .setContentTitle(title)
                .setSmallIcon(R.drawable.ic_notification)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(notificationLayout)
                .setCustomBigContentView(notificationLayoutExpanded)
                .setAutoCancel(true)
        return builder.build()
    }

    private fun expandedRemoteViews(context: Context, notificationId: Int, title: String, time: Long): RemoteViews {
        val expanded = RemoteViews("com.seakernel.simple_mood", R.layout.notification_expanded)
        expanded.setTextViewText(R.id.notification_title, title)

        arrayOf(R.id.notification_very_dissatisfied, R.id.notification_dissatisfied, R.id.notification_plain, R.id.notification_satisfied, R.id.notification_very_satisfied).forEach { imageId ->
            val intent = Intent(context, ClickedNotificationReceiver::class.java).apply {
                putExtra(NotificationPlugin.EXTRA_RATING_DAILY, getRatingFromId(imageId))
                putExtra(NotificationPlugin.EXTRA_ID_NOTIFICATION, notificationId)
                putExtra(NotificationPlugin.EXTRA_DATE, time)
            }
            // Use the imageId as the request code so they don't overwrite each other with the same code
            val pendingIntent = PendingIntent.getBroadcast(context, imageId, intent, PendingIntent.FLAG_UPDATE_CURRENT)
            expanded.setOnClickPendingIntent(imageId, pendingIntent)
        }

        return expanded
    }

    private fun getRatingFromId(imageId: Int): Int {
        return when (imageId) {
            R.id.notification_very_dissatisfied -> 0
            R.id.notification_dissatisfied -> 1
            R.id.notification_plain -> 2
            R.id.notification_satisfied -> 3
            R.id.notification_very_satisfied -> 4
            else -> throw IllegalArgumentException("Invalid image id ($imageId) when trying to determine rating")
        }
    }
}
