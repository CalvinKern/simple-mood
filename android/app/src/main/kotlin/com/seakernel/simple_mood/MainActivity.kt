package com.seakernel.simple_mood

import com.seakernel.simple_mood.notification.NotificationPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NotificationPlugin.configure(applicationContext, flutterEngine)
    }
}
