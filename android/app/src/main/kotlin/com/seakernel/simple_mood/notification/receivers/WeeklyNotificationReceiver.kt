package com.seakernel.simple_mood.notification.receivers

import android.app.Notification
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.seakernel.simple_mood.MainActivity
import com.seakernel.simple_mood.R
import com.seakernel.simple_mood.notification.NotificationPlugin

class WeeklyNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra(NotificationPlugin.EXTRA_ID_NOTIFICATION, 0)
        val channelId = intent.getStringExtra(NotificationPlugin.EXTRA_ID_CHANNEL)!!
        val title = NotificationPlugin.getWeeklyNotification(context)!!.title!!
        val notification: Notification = createNotification(context, channelId, notificationId, title)
        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }

    private fun createNotification(context: Context, channelId: String, notificationId: Int, title: String): Notification {
        NotificationPlugin.setupNotificationChannel(context, channelId)

        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(context, notificationId, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        val builder: NotificationCompat.Builder = NotificationCompat.Builder(context, channelId)
                .setContentTitle(title)
                .setSmallIcon(R.drawable.ic_notification)
                .setStyle(NotificationCompat.BigTextStyle().setBigContentTitle(title))
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
        return builder.build()
    }
}
