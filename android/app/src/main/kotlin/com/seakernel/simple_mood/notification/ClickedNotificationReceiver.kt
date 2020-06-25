package com.seakernel.simple_mood.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ClickedNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) =
            NotificationService.handleNotification(context, intent)
}
