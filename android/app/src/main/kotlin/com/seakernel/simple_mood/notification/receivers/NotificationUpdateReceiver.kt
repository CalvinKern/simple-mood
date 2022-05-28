package com.seakernel.simple_mood.notification.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.seakernel.simple_mood.notification.NotificationPlugin

class NotificationUpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent?.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        NotificationPlugin.resetAlarms(context)
        // TODO: Check for new updates by calling to reinitialize from dart
    }
}