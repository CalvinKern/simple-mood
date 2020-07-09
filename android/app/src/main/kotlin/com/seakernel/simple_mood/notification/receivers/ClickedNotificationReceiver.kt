package com.seakernel.simple_mood.notification.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.seakernel.simple_mood.notification.NotificationService

class ClickedNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) =
            NotificationService.handleNotification(context, intent)
}
