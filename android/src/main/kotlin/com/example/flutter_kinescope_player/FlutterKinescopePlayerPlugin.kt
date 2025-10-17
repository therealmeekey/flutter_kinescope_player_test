package com.example.flutter_kinescope_player

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.app.Activity
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel

/** FlutterKinescopePlayerPlugin */
class FlutterKinescopePlayerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the FlutterEngine and unregister it
    /// when the FlutterEngine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    //    private var drmHelper: KinescopeDrmHelper? = null
    private var context: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_kinescope_player")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_kinescope_player_events")
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                KinescopePlayerViewFactory.setEventSink(eventSink)
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
                KinescopePlayerViewFactory.setEventSink(null)
            }
        })

        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory("flutter_kinescope_player_view", KinescopePlayerViewFactory())
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        KinescopePlayerViewFactory.activity = activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        KinescopePlayerViewFactory.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        KinescopePlayerViewFactory.activity = activity
    }

    override fun onDetachedFromActivity() {
        activity = null
        KinescopePlayerViewFactory.activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initializePlayer" -> {
                val viewId = call.argument<Int>("viewId")
                val config = call.argument<Map<String, Any>>("config")

                if (viewId != null) {
                    KinescopePlayerViewFactory.initializePlayer(viewId, config, result)
                } else {
                    result.error("INVALID_ARGUMENTS", "viewId is required", null)
                }
            }

            "loadVideo" -> {
                val viewId = call.argument<Int>("viewId")
                val videoId = call.argument<String>("videoId")
                val config = call.argument<Map<String, Any>>("config")
                if (viewId != null && videoId != null) {
                    KinescopePlayerViewFactory.loadVideo(viewId, videoId, result, config)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId and videoId are required", null)
                }
            }

            "play" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    KinescopePlayerViewFactory.play(viewId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "pause" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    KinescopePlayerViewFactory.pause(viewId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "seekTo" -> {
                val viewId = call.argument<Int>("viewId")
                val position = call.argument<Int>("position")
                if (viewId != null && position != null) {
                    KinescopePlayerViewFactory.seekTo(viewId, position, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId and position are required", null)
                }
            }

            "setFullscreen" -> {
                val viewId = call.argument<Int>("viewId")
                val fullscreen = call.argument<Boolean>("fullscreen")
                if (viewId != null && fullscreen != null) {
                    KinescopePlayerViewFactory.setFullscreen(viewId, fullscreen, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId and fullscreen are required", null)
                }
            }

            "dispose" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    KinescopePlayerViewFactory.dispose(viewId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "stop" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    KinescopePlayerViewFactory.stop(viewId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "getPlaybackRate" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    KinescopePlayerViewFactory.getPlaybackRate(viewId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "getCurrentPosition" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    KinescopePlayerViewFactory.getCurrentPosition(viewId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "getDuration" -> {
                val viewId = call.argument<Int>("viewId")
                if (viewId != null) {
                    KinescopePlayerViewFactory.getDuration(viewId, result)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "setLiveState" -> {
                val viewId = call.argument<Int>("viewId")
                val isLive = call.argument<Boolean>("isLive") ?: false
                if (viewId != null) {
                    if (isLive) {
                        KinescopePlayerViewFactory.playerViews[viewId]?.setLiveState()
                    }
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId is required", null)
                }
            }

            "showLiveStartDate" -> {
                val viewId = call.argument<Int>("viewId")
                val startDate = call.argument<String>("startDate")
                if (viewId != null && startDate != null) {
                    KinescopePlayerViewFactory.playerViews[viewId]?.showLiveStartDate(startDate)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "viewId and startDate are required", null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        eventSink = null
        context = null
    }
} 