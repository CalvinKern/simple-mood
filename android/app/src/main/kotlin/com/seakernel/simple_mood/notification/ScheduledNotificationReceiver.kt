package com.seakernel.simple_mood.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.seakernel.simple_mood.R

class ScheduledNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra(NotificationPlugin.EXTRA_ID_NOTIFICATION, 0) + 1 // Has to be 1 based
        val channelId = intent.getStringExtra(NotificationPlugin.EXTRA_ID_CHANNEL)!!
        val title = intent.getStringExtra(NotificationPlugin.EXTRA_TITLE)!!
        val notification: Notification = createNotification(context, channelId, title)
        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }

    private fun createNotification(context: Context, channelId: String, title: String): Notification {
        setupNotificationChannel(context, channelId)
//        val intent = Intent(context, getMainActivityClass(context))
//        intent.action = SELECT_NOTIFICATION
//        intent.putExtra(PAYLOAD, notificationDetails.payload)
//        val pendingIntent: PendingIntent = PendingIntent.getActivity(context, notificationDetails.id, intent, PendingIntent.FLAG_UPDATE_CURRENT)
//        val defaultStyleInformation: DefaultStyleInformation = notificationDetails.styleInformation as DefaultStyleInformation
        val builder: NotificationCompat.Builder = NotificationCompat.Builder(context, channelId)
                .setContentTitle(title)
                .setSmallIcon(R.drawable.ic_notification)
//                .setAutoCancel(BooleanUtils.getValue(notificationDetails.autoCancel))
//                .setContentIntent(pendingIntent)
//        setStyle(context, notificationDetails, builder)
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