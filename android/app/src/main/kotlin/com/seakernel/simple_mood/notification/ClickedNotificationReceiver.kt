package com.seakernel.simple_mood.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.seakernel.simple_mood.R

class ClickedNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {

        val selected = getRatingFromId(intent?.getIntExtra(EXTRA_SELECTED, -1) ?: -1)
        println("clickedNotificationReceiver: $selected")
        // TODO: Start a service? to Call method channel to let flutter update database with selected rating
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

    companion object {
        const val EXTRA_SELECTED = "selected"
    }
}
