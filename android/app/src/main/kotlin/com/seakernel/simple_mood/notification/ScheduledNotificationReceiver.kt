package com.seakernel.simple_mood.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.seakernel.simple_mood.MainActivity
import com.seakernel.simple_mood.R

class ScheduledNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra(NotificationPlugin.EXTRA_ID_NOTIFICATION, 0) + 1 // Has to be 1 based
        val channelId = intent.getStringExtra(NotificationPlugin.EXTRA_ID_CHANNEL)!!
        val title = intent.getStringExtra(NotificationPlugin.EXTRA_TITLE)!!
        val notification: Notification = createNotification(context, channelId, notificationId, title)
        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }

    private fun createNotification(context: Context, channelId: String, notificationId: Int, title: String): Notification {
        setupNotificationChannel(context, channelId)

        val notificationLayout = RemoteViews("com.seakernel.simple_mood", R.layout.notification_layout).apply {
            setTextViewText(R.id.notification_title, title)
        }
        val notificationLayoutExpanded = RemoteViews("com.seakernel.simple_mood", R.layout.notification_expanded).apply {
            setTextViewText(R.id.notification_title, title)
            val imageIds = arrayOf(R.id.notification_very_dissatisfied, R.id.notification_dissatisfied, R.id.notification_plain, R.id.notification_satisfied, R.id.notification_very_satisfied)
            imageIds.forEach {
                val intent = Intent(context, ClickedNotificationReceiver::class.java).apply {
                    this.putExtra(ClickedNotificationReceiver.EXTRA_SELECTED, it)
                }
                // Use the imageId as the request code so they don't overwrite each other with the same code
                val pendingIntent = PendingIntent.getBroadcast(context, it, intent, PendingIntent.FLAG_UPDATE_CURRENT)
                setOnClickPendingIntent(it, pendingIntent)
            }
        }

        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(context, notificationId, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        val builder: NotificationCompat.Builder = NotificationCompat.Builder(context, channelId)
                .setContentTitle(title)
                .setSmallIcon(R.drawable.ic_notification)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(notificationLayout)
                .setCustomBigContentView(notificationLayoutExpanded)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
        return builder.build()
    }

    private fun setupNotificationChannel(context: Context, channelId: String) {
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