package com.seakernel.simple_mood.notification

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.util.Log
import androidx.core.app.JobIntentService
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.plugin.common.*
import io.flutter.view.FlutterCallbackInformation

class NotificationService : JobIntentService() {

    companion object {
        private const val METHOD_DAILY_NOTIFICATION_RATED = "dailyNotificationRated"
        private const val METHOD_DISPATCHER_INITIALIZED = "dispatcherInitialized"

        private const val JOB_ID = 40404

        fun handleNotification(context: Context, intent: Intent) {
//            Log.d("SimpleMoodNative", "Notification clicked")
            enqueueWork(context, NotificationService::class.java, JOB_ID, intent)
        }
    }

    override fun onHandleWork(intent: Intent) {
        Handler(applicationContext.mainLooper).post {
            val channel = initDartIsolate()
            channel.setMethodCallHandler { call, _ ->
                when(call.method) {
                    METHOD_DISPATCHER_INITIALIZED -> {
                        NotificationPlugin.dismissDailyNotification(applicationContext)
                        sendRating(channel, intent)
                    }
                    else -> Log.d("SimpleMoodNative", "-=-=-=MethodCallHandler unsupported for ${call.method}")
                }
            }
        }
    }

    private fun initDartIsolate(): MethodChannel {
        val callbackHandle = NotificationPlugin.getDailyNotification(applicationContext)?.callbackHandle ?: 0L

        val path = FlutterInjector.instance().flutterLoader().findAppBundlePath()
        val executor: DartExecutor = FlutterEngine(applicationContext).dartExecutor
        val channel = MethodChannel(executor, NotificationPlugin.FLUTTER_CHANNEL)
        val dartCallback = DartCallback(
                applicationContext.assets,
                path,
                FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
        )
        executor.executeDartCallback(dartCallback)
        return channel
    }

    private fun sendRating(channel: MethodChannel, intent: Intent) {
        val rating = intent.getIntExtra(NotificationPlugin.EXTRA_RATING_DAILY, -1).toLong()
        val date = intent.getLongExtra(NotificationPlugin.EXTRA_DATE, System.currentTimeMillis())

//        Log.d("SimpleMood-Native", "Sending rating")
//        val d = Date(date)
//        val formatter = SimpleDateFormat("MMM dd yyyy HH:mma")
//        val time: String = formatter.format(d)
//        Log.d("SimpleMood-Native", "Invoking flutter with parameters: $rating --- $time")

        channel.invokeMethod(
                METHOD_DAILY_NOTIFICATION_RATED,
                longArrayOf(rating, date),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
//                        Log.d("SimpleMoodNative", "result after sending rating: $result")
                        val update = result as? String ?: return
                        // Hack to get the title updated without having to manually set the notification again
                        NotificationPlugin.updateDailyNotification(applicationContext, update)
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}

                    override fun notImplemented() {}
                }
        )
    }
}
