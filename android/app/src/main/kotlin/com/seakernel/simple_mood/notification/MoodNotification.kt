package com.seakernel.simple_mood.notification

import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import java.io.Serializable

data class MoodNotification(val title: String?, val time: Long, val callbackHandle: Long) : Serializable {
    constructor(call: MethodCall) : this(
            call.argument<String>(FLUTTER_KEY_NOTIFICATION_TITLE),
            call.argument<Long>(FLUTTER_KEY_NOTIFICATION_TIME)!!,
            call.argument<Long>(FLUTTER_KEY_CALLBACK_DISPATCHER)!!
    )


    fun toJson(): String = Gson().toJson(this)

    companion object {
        private const val FLUTTER_KEY_NOTIFICATION_TIME = "notificationTime"
        private const val FLUTTER_KEY_NOTIFICATION_TITLE = "notificationTitle"
        private const val FLUTTER_KEY_CALLBACK_DISPATCHER = "callbackDispatcher"

        fun fromJson(json: String?): MoodNotification? {
            if (json == null) return null
            return Gson().fromJson(json, MoodNotification::class.java)
        }
    }
}