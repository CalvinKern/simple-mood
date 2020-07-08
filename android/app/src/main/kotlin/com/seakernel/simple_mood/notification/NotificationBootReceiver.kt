package com.seakernel.simple_mood.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent?.action != Intent.ACTION_BOOT_COMPLETED) return
        NotificationPlugin.setDailyAlarm(context)
    }
}
