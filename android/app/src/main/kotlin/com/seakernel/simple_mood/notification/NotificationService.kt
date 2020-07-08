package com.seakernel.simple_mood.notification

import android.content.Context
import android.content.Intent
import android.os.Handler
import androidx.core.app.JobIntentService
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.plugin.common.*
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain

class NotificationService : JobIntentService() {

    companion object {
        private const val METHOD_DAILY_NOTIFICATION_RATED = "dailyNotificationRated"
        private const val METHOD_DISPATCHER_INITIALIZED = "dispatcherInitialized"

        private const val JOB_ID = 40404

        fun handleNotification(context: Context, intent: Intent) {
            enqueueWork(context, NotificationService::class.java, JOB_ID, intent)
        }
    }

    override fun onHandleWork(intent: Intent) {
        Handler(applicationContext.mainLooper).post {
            val channel = initDartIsolate()
            channel.setMethodCallHandler { call, _ ->
                if (call.method != METHOD_DISPATCHER_INITIALIZED) return@setMethodCallHandler

                sendRating(channel, intent)
                NotificationManagerCompat
                        .from(applicationContext)
                        .cancel(intent.getIntExtra(NotificationPlugin.EXTRA_ID_NOTIFICATION, 0))
            }
        }
    }

    private fun initDartIsolate(): MethodChannel {
        val callbackHandle = NotificationPlugin.getDailyNotification(applicationContext)?.callbackHandle ?: 0L

        val executor: DartExecutor = FlutterEngine(applicationContext).dartExecutor
        val channel = MethodChannel(executor, NotificationPlugin.FLUTTER_CHANNEL)
        val dartCallback = DartCallback(
                applicationContext.assets,
                FlutterMain.findAppBundlePath(),
                FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        )
        executor.executeDartCallback(dartCallback)
        return channel
    }

    private fun sendRating(channel: MethodChannel, intent: Intent) {
        channel.invokeMethod(
                METHOD_DAILY_NOTIFICATION_RATED,
                intArrayOf(intent.getIntExtra(NotificationPlugin.EXTRA_RATING_DAILY, -1))
        )
    }
}
