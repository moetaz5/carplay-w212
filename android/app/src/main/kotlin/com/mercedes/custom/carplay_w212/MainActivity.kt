package com.mercedes.custom.carplay_w212

import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Bundle
import android.view.Display
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val DISPLAY_CHANNEL = "com.mercedes.custom/display"
    private val DISPLAY_EVENTS = "com.mercedes.custom/display_events"
    private var eventSink: EventChannel.EventSink? = null
    private var displayManager: DisplayManager? = null

    private val displayListener = object : DisplayManager.DisplayListener {
        override fun onDisplayAdded(displayId: Int) {
            checkAndNotifyDisplays()
        }

        override fun onDisplayRemoved(displayId: Int) {
            checkAndNotifyDisplays()
        }

        override fun onDisplayChanged(displayId: Int) {
            checkAndNotifyDisplays()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        displayManager = getSystemService(Context.DISPLAY_SERVICE) as? DisplayManager
        displayManager?.registerDisplayListener(displayListener, null)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DISPLAY_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isExternalDisplayConnected") {
                val displays = displayManager?.displays ?: arrayOf()
                result.success(displays.size > 1)
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, DISPLAY_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    checkAndNotifyDisplays()
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private fun checkAndNotifyDisplays() {
        val displays = displayManager?.displays ?: arrayOf()
        val isExternalConnected = displays.size > 1
        runOnUiThread {
            eventSink?.success(isExternalConnected)
        }
    }

    override fun onDestroy() {
        displayManager?.unregisterDisplayListener(displayListener)
        super.onDestroy()
    }
}
