package com.example.ustropralki

import android.R
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews

import io.flutter.app.FlutterActivity
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
//import com.google.firebase.messaging.FirebaseMessagingService

class Application : FlutterApplication() , PluginRegistrantCallback {

    override fun onCreate() {
        super.onCreate();
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    override fun registerWith( registry: PluginRegistry) {
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry)
    }

    fun createNotification(view: View?) {
        val contentView = RemoteViews(packageName, R.layout.custom_notification_layout)
        val mNotificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val mBuilder: NotificationCompat.Builder = Builder(this@MainActivity, default_notification_channel_id)
        mBuilder.setContent(contentView)
        mBuilder.setSmallIcon(R.drawable.ic_launcher_foreground)
        mBuilder.setAutoCancel(true)
        mBuilder.setVisibility(NotificationCompat.VISIBILITY_SECRET)
        val VIBRATE_PATTERN = longArrayOf(0, 500)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val notificationChannel = NotificationChannel(NOTIFICATION_CHANNEL_ID, "NOTIFICATION_CHANNEL_NAME", importance)
            notificationChannel.lightColor = R.color.colorAccent
            notificationChannel.vibrationPattern = VIBRATE_PATTERN
            notificationChannel.enableVibration(true)
            mBuilder.setChannelId(NOTIFICATION_CHANNEL_ID)
            assert(mNotificationManager != null)
            mNotificationManager.createNotificationChannel(notificationChannel)
        }
        assert(mNotificationManager != null)
        mNotificationManager.notify(System.currentTimeMillis().toInt(), mBuilder.build())
    }
}