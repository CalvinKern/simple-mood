package com.seakernel.simple_mood.notification.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.seakernel.simple_mood.notification.NotificationPlugin

class NotificationBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent?.action != Intent.ACTION_BOOT_COMPLETED) return
        NotificationPlugin.resetAlarms(context)
    }
}
