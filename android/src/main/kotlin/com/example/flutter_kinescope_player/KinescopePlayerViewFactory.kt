package com.example.flutter_kinescope_player

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.kinescope.sdk.view.KinescopePlayerView
import io.kinescope.sdk.player.KinescopeVideoPlayer
import io.kinescope.sdk.player.KinescopePlayerOptions
import android.app.Activity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.content.pm.ActivityInfo
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import android.os.Handler
import android.os.Looper
import androidx.media3.common.Player
import com.example.flutter_kinescope_player.PlayerControl
import io.flutter.plugin.common.EventChannel

class KinescopePlayerViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private const val TAG = "KinescopePlayerFactory"
        private var nextViewId = 1
        private val players = mutableMapOf<Int, KinescopeVideoPlayer>()
        val playerViews = mutableMapOf<Int, KinescopePlayerView>()
        var activity: Activity? = null
        private var fullscreenContainer: FrameLayout? = null
        private var fullscreenPlayerView: KinescopePlayerView? = null
        private val fullscreenStates = mutableMapOf<Int, Boolean>()
        private var eventChannel: MethodChannel? = null
        private val originalParents = mutableMapOf<Int, Pair<FrameLayout, Int>>()
        private val wasPlayingStates = mutableMapOf<Int, Boolean>()
        private val progressUpdateHandlers = mutableMapOf<Int, Handler>()
        private val playerControls = mutableMapOf<Int, PlayerControl>()
        private var eventSink: EventChannel.EventSink? = null

        fun createViewId(): Int {
            return nextViewId++
        }

        fun initializePlayer(viewId: Int, config: Map<String, Any>?, result: MethodChannel.Result) {
            Log.d(TAG, "Initializing player for viewId: $viewId")
            Log.d(TAG, "Available players before init: ${players.keys}")

            val player = players[viewId]
            if (player != null) {
                try {
                    // Применяем конфигурацию к плееру
                    config?.let { cfg ->
                        // Применяем настройки из конфигурации
                        Log.d(TAG, "Applying config: $cfg")

                        // Применяем настройки UI
                        val showFullscreenButton = cfg["showFullscreenButton"] as? Boolean
                        if (showFullscreenButton != null) {
                            player.setShowFullscreen(showFullscreenButton)
                        }

                        val showOptionsButton = cfg["showOptionsButton"] as? Boolean
                        if (showOptionsButton != null) {
                            player.setShowOptions(showOptionsButton)
                        }

                        val showSubtitlesButton = cfg["showSubtitlesButton"] as? Boolean
                        if (showSubtitlesButton != null) {
                            player.setShowSubtitles(showSubtitlesButton)
                        }

                        // Применяем DRM токен если есть
                        val drmToken = cfg["drmToken"] as? Map<String, Any>
                        if (drmToken != null) {
                            val licenseUrl = drmToken["licenseUrl"] as? String
                            val token = drmToken["token"] as? String

                            if (licenseUrl != null && token != null) {
                                Log.d(TAG, "Applying DRM token: licenseUrl=$licenseUrl")
                                // Здесь нужно будет применить DRM токен к плееру
                                // Это зависит от реализации KinescopeVideoPlayer
                            }
                        }
                    }

                    Log.d(TAG, "Player found for viewId: $viewId, initialization successful")
                    try {
                        result.success(mapOf("success" to true))
                    } catch (e: Exception) {
                        Log.e(TAG, "Error sending init success result", e)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Exception during player initialization", e)
                    try {
                        result.error("INIT_ERROR", e.message, null)
                    } catch (ex: Exception) {
                        Log.e(TAG, "Error sending init exception result", ex)
                    }
                }
            } else {
                Log.e(TAG, "Player not found for viewId: $viewId during initialization")
                try {
                    result.error("PLAYER_NOT_FOUND", "Player not found for viewId: $viewId", null)
                } catch (e: Exception) {
                    Log.e(TAG, "Error sending init player not found result", e)
                }
            }
        }

        fun loadVideo(
            viewId: Int,
            videoId: String,
            result: MethodChannel.Result,
            config: Map<String, Any>? = null
        ) {
            Log.d(TAG, "Loading video: $videoId for viewId: $viewId")
            Log.d(TAG, "Available players: ${players.keys}")

            val player = players[viewId]
            if (player != null) {
                Log.d(TAG, "Player found, attempting to load video")
                try {
                    player.loadVideo(videoId, onSuccess = { video ->
                        Log.d(
                            TAG,
                            "Video loaded successfully: " + (video?.title ?: "Unknown title")
                        )

                        // Скрываем название после загрузки видео через titleView и authorView
                        try {
                            val playerView = playerViews[viewId]
                            if (playerView != null) {
                                val titleViewField =
                                    playerView.javaClass.getDeclaredField("titleView")
                                titleViewField.isAccessible = true
                                val titleView =
                                    titleViewField.get(playerView) as? android.widget.TextView

                                if (titleView != null) {
                                    titleView.visibility = android.view.View.GONE
                                    Log.d(TAG, "Successfully hid titleView after video load")
                                } else {
                                    Log.d(TAG, "titleView not found or is null after video load")
                                }

                                // Также скрываем authorView (подзаголовок)
                                try {
                                    val authorViewField =
                                        playerView.javaClass.getDeclaredField("authorView")
                                    authorViewField.isAccessible = true
                                    val authorView =
                                        authorViewField.get(playerView) as? android.widget.TextView

                                    if (authorView != null) {
                                        authorView.visibility = android.view.View.GONE
                                        Log.d(TAG, "Successfully hid authorView after video load")
                                    } else {
                                        Log.d(
                                            TAG,
                                            "authorView not found or is null after video load"
                                        )
                                    }
                                } catch (e: Exception) {
                                    Log.d(
                                        TAG,
                                        "Could not hide authorView after video load: ${e.message}"
                                    )
                                }
                            }
                        } catch (e: Exception) {
                            Log.d(TAG, "Could not hide titleView after video load: ${e.message}")
                        }
                        var startTime = 0
                        config?.get("startTime")?.let {
                            startTime = when (it) {
                                is Int -> it
                                is Double -> it.toInt()
                                is Float -> it.toInt()
                                else -> 0
                            }
                        }
                        if (startTime > 0) {
                            val exoPlayer = player.exoPlayer
                            if (exoPlayer != null) {
                                val listener = object : Player.Listener {
                                    override fun onPlaybackStateChanged(state: Int) {
                                        if (state == Player.STATE_READY) {
                                            val control = playerControls[viewId]
                                            control?.seekTo(startTime * 1000)
                                            exoPlayer.removeListener(this)
                                        }
                                    }
                                }
                                exoPlayer.addListener(listener)
                            }
                        }
                        try {
                            if (video?.isLive == true) {
                                playerViews[viewId]?.setLiveState()
                                val startDate = video.live?.startsAt
                                if (!startDate.isNullOrEmpty()) {
                                    playerViews[viewId]?.showLiveStartDate(startDate)
                                }
                            }
                            result.success(
                                mapOf(
                                    "success" to true,
                                    "title" to video?.title,
                                    "duration" to video?.duration,
                                    "isLive" to (video?.isLive ?: false),
                                    "liveStartDate" to (video?.live?.startsAt ?: "")
                                )
                            )
                        } catch (e: Exception) {
                            Log.e(TAG, "Error sending success result", e)
                        }
                    }, onFailed = { error ->
                        Log.e(
                            TAG, "Failed to load video: " + (error?.message ?: "Unknown error")
                        )
                        try {
                            result.error(
                                "LOAD_ERROR", error?.message ?: "Failed to load video", null
                            )
                        } catch (e: Exception) {
                            Log.e(TAG, "Error sending error result", e)
                        }
                    })
                    Log.d(TAG, "loadVideo method called successfully")

                    // Создаём PlayerControl для этого плеера, если ещё не создан
                    if (!playerControls.containsKey(viewId) && player.exoPlayer != null) {
                        playerControls[viewId] = PlayerControl(player.exoPlayer!!)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Exception while loading video", e)
                    try {
                        result.error("LOAD_ERROR", e.message, null)
                    } catch (ex: Exception) {
                        Log.e(TAG, "Error sending exception result", ex)
                    }
                }
            } else {
                Log.e(TAG, "Player not found for viewId: $viewId")
                try {
                    result.error("PLAYER_NOT_FOUND", "Player not found for viewId: $viewId", null)
                } catch (e: Exception) {
                    Log.e(TAG, "Error sending player not found result", e)
                }
            }
        }

        fun play(viewId: Int, result: MethodChannel.Result) {
            Log.d(TAG, "Playing video for viewId: $viewId")
            val control = playerControls[viewId]
            if (control != null) {
                try {
                    control.start()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "Exception while playing", e)
                    result.error("PLAY_EXCEPTION", e.message, null)
                }
            } else {
                result.error(
                    "PLAYER_NOT_FOUND",
                    "PlayerControl not found for viewId: $viewId",
                    null
                )
            }
        }

        fun pause(viewId: Int, result: MethodChannel.Result) {
            Log.d(TAG, "Pausing video for viewId: $viewId")
            val control = playerControls[viewId]
            if (control != null) {
                try {
                    control.pause()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "Exception while pausing", e)
                    result.error("PAUSE_EXCEPTION", e.message, null)
                }
            } else {
                result.error(
                    "PLAYER_NOT_FOUND",
                    "PlayerControl not found for viewId: $viewId",
                    null
                )
            }
        }

        fun seekTo(viewId: Int, position: Int, result: MethodChannel.Result) {
            Log.d(
                TAG,
                "[FLUTTER_PLUGIN] SEEKTO: viewId=$viewId, position=$position, players.keys=${players.keys}"
            )
            val control = playerControls[viewId]
            if (control != null) {
                try {
                    Log.d(TAG, "[FLUTTER_PLUGIN] REAL SEEK: toMillis=${position * 1000}")
                    control.seekTo(position * 1000)
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "[FLUTTER_PLUGIN] Exception while seeking", e)
                    result.error("SEEK_EXCEPTION", e.message, null)
                }
            } else {
                result.error(
                    "PLAYER_NOT_FOUND",
                    "PlayerControl not found for viewId: $viewId",
                    null
                )
            }
        }

        fun setFullscreen(viewId: Int, fullscreen: Boolean, result: MethodChannel.Result) {
            Log.d(TAG, "setFullscreen called for viewId=$viewId, fullscreen=$fullscreen")
            val playerView = playerViews[viewId]
            val player = players[viewId]
            val act = activity
            if (playerView != null && player != null && act != null) {
                if (fullscreen) {
                    // Всегда сохраняем состояние воспроизведения
                    wasPlayingStates[viewId] = player.exoPlayer?.isPlaying == true
                    act.window.setFlags(
                        WindowManager.LayoutParams.FLAG_FULLSCREEN,
                        WindowManager.LayoutParams.FLAG_FULLSCREEN
                    )
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                        act.window.decorView.systemUiVisibility =
                            (View.SYSTEM_UI_FLAG_FULLSCREEN or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)
                    } else {
                        act.window.decorView.systemUiVisibility =
                            (View.SYSTEM_UI_FLAG_FULLSCREEN or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)
                    }
                    act.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
                    if (fullscreenContainer == null) {
                        fullscreenContainer = FrameLayout(act)
                        fullscreenContainer!!.layoutParams = FrameLayout.LayoutParams(
                            FrameLayout.LayoutParams.MATCH_PARENT,
                            FrameLayout.LayoutParams.MATCH_PARENT
                        )
                        (act.window.decorView as? FrameLayout)?.addView(fullscreenContainer)
                    }
                    if (!originalParents.containsKey(viewId)) {
                        val parent = playerView.parent as? FrameLayout
                        val index = parent?.indexOfChild(playerView) ?: -1
                        if (parent != null && index >= 0) {
                            originalParents[viewId] = Pair(parent, index)
                        }
                    }
                    (playerView.parent as? FrameLayout)?.removeView(playerView)
                    fullscreenContainer!!.addView(
                        playerView, FrameLayout.LayoutParams(
                            FrameLayout.LayoutParams.MATCH_PARENT,
                            FrameLayout.LayoutParams.MATCH_PARENT
                        )
                    )
                    playerView.setIsFullscreen(true)
                    fullscreenStates[viewId] = true
                    Log.d(TAG, "Entered fullscreen for viewId=$viewId")
                    // Восстанавливаем воспроизведение, если было playing
                    if (wasPlayingStates[viewId] == true) {
                        val exoPlayer = player.exoPlayer
                        if (exoPlayer != null) {
                            // 1. Слушатель первого кадра
                            val listener = object : Player.Listener {
                                override fun onRenderedFirstFrame() {
                                    exoPlayer.play()
                                    exoPlayer.removeListener(this)
                                }
                            }
                            exoPlayer.addListener(listener)
                            // 2. Несколько попыток play() через Handler
                            val handler = Handler(Looper.getMainLooper())
                            val playAttempts = listOf(75L, 225L, 450L)
                            for (delay in playAttempts) {
                                handler.postDelayed({
                                    try {
                                        exoPlayer.play()
                                    } catch (e: Exception) {
                                        Log.w(TAG, "Exception in delayed play(): ${e.message}")
                                    }
                                }, delay)
                            }
                        }
                    }
                } else {
                    act.window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
                    act.window.decorView.systemUiVisibility =
                        (View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
                    act.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
                    fullscreenContainer?.removeView(playerView)
                    val original = originalParents[viewId]
                    if (original != null) {
                        val (parent, index) = original
                        if (index >= 0 && index <= parent.childCount) {
                            parent.addView(playerView, index)
                        } else {
                            parent.addView(playerView)
                        }
                    }
                    playerView.setIsFullscreen(false)
                    (act.window.decorView as? FrameLayout)?.removeView(fullscreenContainer)
                    fullscreenContainer = null
                    fullscreenStates[viewId] = false
                    // Восстанавливаем состояние воспроизведения
                    if (wasPlayingStates[viewId] == true) {
                        Handler(Looper.getMainLooper()).postDelayed({
                            player.play()
                        }, 200)
                    }
                    Log.d(TAG, "Exited fullscreen for viewId=$viewId")
                }
                result.success(null)
            } else {
                Log.e(
                    TAG,
                    "PLAYER_VIEW_NOT_FOUND: Player view or activity not found for viewId: $viewId"
                )
                result.error(
                    "PLAYER_VIEW_NOT_FOUND",
                    "Player view or activity not found for viewId: $viewId",
                    null
                )
            }
        }

        fun dispose(viewId: Int, result: MethodChannel.Result) {
            Log.d(TAG, "Disposing player for viewId: $viewId")
            val player = players[viewId]
            if (player != null) {
                try {
                    // Останавливаем воспроизведение
                    player.pause()
                    // Если у плеера есть метод release, вызываем его
                    try {
                        val releaseMethod = player.javaClass.getMethod("release")
                        releaseMethod.invoke(player)
                        Log.d(TAG, "Called player.release() for viewId: $viewId")
                    } catch (e: NoSuchMethodException) {
                        Log.d(TAG, "No release() method on player for viewId: $viewId")
                    }
                    Log.d(TAG, "Clearing player reference for viewId: $viewId")
                } catch (e: Exception) {
                    Log.w(TAG, "Exception while disposing player", e)
                }
                players.remove(viewId)
            }

            val playerView = playerViews[viewId]
            if (playerView != null) {
                playerViews.remove(viewId)
            }
            // Останавливаем обновление прогресса
            progressUpdateHandlers[viewId]?.removeCallbacksAndMessages(null)
            progressUpdateHandlers.remove(viewId)

            result.success(null)
        }


        fun setEventChannel(channel: MethodChannel?) {
            eventChannel = channel
        }

        private fun toggleFullscreen(viewId: Int) {
            val isFullscreen = fullscreenStates[viewId] ?: false
            val newState = !isFullscreen
            // Отправляем событие во Flutter
            sendFullscreenEvent(newState)
            Log.d(TAG, "toggleFullscreen called for viewId=$viewId, isFullscreen=$isFullscreen")
            setFullscreen(viewId, newState, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Log.d(TAG, "setFullscreen success for viewId=$viewId, newState=$newState")
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e(TAG, "setFullscreen error: $errorCode $errorMessage")
                }

                override fun notImplemented() {
                    Log.e(TAG, "setFullscreen not implemented")
                }
            })
        }

        private fun applyBottomInset(view: View) {
            ViewCompat.setOnApplyWindowInsetsListener(view) { v, insets ->
                val systemInsets = insets.getInsets(WindowInsetsCompat.Type.systemBars())
                v.setPadding(
                    v.paddingLeft,
                    v.paddingTop,
                    v.paddingRight,
                    systemInsets.bottom // только нижний отступ
                )
                insets
            }
        }

        private fun sendPlaybackRateChanged(viewId: Int, rate: Float) {
            eventSink?.success(
                mapOf(
                    "method" to "onChangePlaybackRate",
                    "args" to mapOf(
                        "viewId" to viewId,
                        "rate" to rate
                    )
                )
            )
        }

        private fun sendStatusChanged(viewId: Int, status: String) {
            eventSink?.success(
                mapOf(
                    "method" to "onChangeStatus",
                    "args" to mapOf(
                        "viewId" to viewId,
                        "status" to status
                    )
                )
            )
        }

        private fun sendProgressUpdate(viewId: Int, percent: Double) {
            eventSink?.success(
                mapOf(
                    "method" to "onProgressUpdate",
                    "args" to mapOf(
                        "viewId" to viewId,
                        "progressPercent" to percent
                    )
                )
            )
        }

        fun stop(viewId: Int, result: MethodChannel.Result) {
            Log.d(TAG, "Stopping video for viewId: $viewId")
            val player = players[viewId]
            if (player != null) {
                try {
                    player.stop()
                    result.success(null)
                } catch (e: Exception) {
                    Log.e(TAG, "Exception while stopping", e)
                    result.error("STOP_EXCEPTION", e.message, null)
                }
            } else {
                result.error("PLAYER_NOT_FOUND", "Player not found for viewId: $viewId", null)
            }
        }

        fun getPlaybackRate(viewId: Int, result: MethodChannel.Result) {
            Log.d(TAG, "Getting playback rate for viewId: $viewId")
            val player = players[viewId]
            if (player != null) {
                try {
                    val rate = player.exoPlayer?.playbackParameters?.speed ?: 1.0f
                    result.success(rate)
                } catch (e: Exception) {
                    Log.e(TAG, "Exception while getting playback rate", e)
                    result.error("GET_PLAYBACK_RATE_EXCEPTION", e.message, null)
                }
            } else {
                result.error("PLAYER_NOT_FOUND", "Player not found for viewId: $viewId", null)
            }
        }

        fun forceReleaseAllPlayers() {
            val keys = players.keys.toMutableList()
            for (viewId in keys) {
                dispose(viewId, object : MethodChannel.Result {
                    override fun success(result: Any?) {}
                    override fun error(
                        errorCode: String, errorMessage: String?, errorDetails: Any?
                    ) {
                        Log.e(TAG, "Error during dispose: $errorCode - $errorMessage")
                    }

                    override fun notImplemented() {}
                })
            }
            players.clear()
            playerViews.clear()
            progressUpdateHandlers.clear()
            playerControls.clear()
            fullscreenStates.clear()
            originalParents.clear()
            wasPlayingStates.clear()
            fullscreenContainer = null
            fullscreenPlayerView = null
        }

        private fun playerOptionsForViewId(viewId: Int): Map<String, Any>? {
            val playerView = playerViews[viewId]
            val player = players[viewId]
            return try {
                val tag = playerView?.tag
                if (tag is Map<*, *>) {
                    @Suppress("UNCHECKED_CAST")
                    tag as? Map<String, Any>
                } else null
            } catch (e: Exception) {
                null
            }
        }

        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }

        fun sendFullscreenEvent(isFullscreen: Boolean) {
            eventSink?.success(
                mapOf(
                    "method" to "onTapFullscreen",
                    "args" to mapOf("isFullscreen" to isFullscreen)
                )
            )
        }

        fun getCurrentPosition(viewId: Int, result: MethodChannel.Result) {
            val player = players[viewId]
            if (player != null) {
                try {
                    val posMs = player.exoPlayer?.currentPosition ?: 0L
                    result.success((posMs / 1000).toInt())
                } catch (e: Exception) {
                    result.error("GET_CURRENT_POSITION_EXCEPTION", e.message, null)
                }
            } else {
                result.error("PLAYER_NOT_FOUND", "Player not found for viewId: $viewId", null)
            }
        }

        fun getDuration(viewId: Int, result: MethodChannel.Result) {
            Log.d(TAG, "Getting duration for viewId: $viewId")
            val control = playerControls[viewId]
            if (control != null) {
                try {
                    val durationMs = control.getDuration()
                    result.success((durationMs / 1000).toInt())
                } catch (e: Exception) {
                    Log.e(TAG, "Exception while getting duration", e)
                    result.error("GET_DURATION_EXCEPTION", e.message, null)
                }
            } else {
                result.error(
                    "PLAYER_NOT_FOUND",
                    "PlayerControl not found for viewId: $viewId",
                    null
                )
            }
        }
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(TAG, "Creating platform view for viewId: $viewId")
        Log.d(TAG, "Creation params: $args")
        // Останавливаем и удаляем все старые плееры перед созданием нового
        forceReleaseAllPlayers()
        val creationParams = args as? Map<String?, Any?>

        var useCustomFullscreen = false
        creationParams?.let { params ->
            val config = params["config"] as? Map<String, Any>
            config?.let { cfg ->
                useCustomFullscreen = cfg["useCustomFullscreen"] as? Boolean ?: false
                // Если явно указан isLive, сразу включаем live-режим
                val isLive = cfg["isLive"] as? Boolean ?: false
                if (isLive) {
                    playerViews[viewId]?.setLiveState()
                }
            }
        }

        try {
            // Создаем KinescopePlayerView с правильным конструктором
            val playerView = KinescopePlayerView(context, null)
            Log.d(TAG, "KinescopePlayerView created successfully")

            // Простое скрытие названия через titleView и authorView
            try {
                val titleViewField = playerView.javaClass.getDeclaredField("titleView")
                titleViewField.isAccessible = true
                val titleView = titleViewField.get(playerView) as? android.widget.TextView

                if (titleView != null) {
                    titleView.visibility = android.view.View.GONE
                    Log.d(TAG, "Successfully hid titleView")
                } else {
                    Log.d(TAG, "titleView not found or is null")
                }

                // Также скрываем authorView (подзаголовок)
                try {
                    val authorViewField = playerView.javaClass.getDeclaredField("authorView")
                    authorViewField.isAccessible = true
                    val authorView = authorViewField.get(playerView) as? android.widget.TextView

                    if (authorView != null) {
                        authorView.visibility = android.view.View.GONE
                        Log.d(TAG, "Successfully hid authorView")
                    } else {
                        Log.d(TAG, "authorView not found or is null")
                    }
                } catch (e: Exception) {
                    Log.d(TAG, "Could not hide authorView: ${e.message}")
                }
            } catch (e: Exception) {
                Log.d(TAG, "Could not hide titleView: ${e.message}")
            }

            // Создаем KinescopeVideoPlayer с опциями
            val playerOptions = KinescopePlayerOptions()

            // Применяем конфигурацию из creationParams
            creationParams?.let { params ->
                val config = params["config"] as? Map<String, Any>
                config?.let { cfg ->
                    // Применяем referer
                    val referer = cfg["referer"] as? String
                    if (referer != null) {
                        playerOptions.referer = referer
                        Log.d(TAG, "Setting referer in player options: $referer")
                    }

                    // Применяем настройки UI
                    val showFullscreenButton = cfg["showFullscreenButton"] as? Boolean
                    if (showFullscreenButton != null) {
                        playerOptions.showFullscreenButton = showFullscreenButton
                    }

                    val showOptionsButton = cfg["showOptionsButton"] as? Boolean
                    if (showOptionsButton != null) {
                        playerOptions.showOptionsButton = showOptionsButton
                    }

                    val showSubtitlesButton = cfg["showSubtitlesButton"] as? Boolean
                    if (showSubtitlesButton != null) {
                        playerOptions.showSubtitlesButton = showSubtitlesButton
                    }

                    val showSeekBar = cfg["showSeekBar"] as? Boolean
                    if (showSeekBar != null) {
                        playerOptions.showSeekBar = showSeekBar
                    }

                    val showDuration = cfg["showDuration"] as? Boolean
                    if (showDuration != null) {
                        playerOptions.showDuration = showDuration
                    }

                    val showAttachments = cfg["showAttachments"] as? Boolean
                    if (showAttachments != null) {
                        playerOptions.showAttachments = showAttachments
                    }
                }
            }

            val player = KinescopeVideoPlayer(context, playerOptions)

            Log.d(TAG, "KinescopeVideoPlayer created successfully")

            // Устанавливаем плеер в view
            playerView.setPlayer(player)
            Log.d(TAG, "Player set to view successfully")

            // Подписка на событие полноэкранного режима через единый callback
            playerView.onFullscreenButtonCallback = {
                Log.d(
                    TAG,
                    "onFullscreenButtonCallback triggered for playerView, viewId=$viewId"
                )
                if (useCustomFullscreen) {
                    Log.d(
                        TAG,
                        "Попытка отправить onTapFullscreen в Flutter, eventChannel=$eventChannel, viewId=$viewId, isFullscreen=${!(fullscreenStates[viewId] ?: false)}"
                    )
                    sendFullscreenEvent(!(fullscreenStates[viewId] ?: false))
                    fullscreenStates[viewId] = !(fullscreenStates[viewId] ?: false);
                } else {
                    toggleFullscreen(viewId)
                }
            }

            // Подписка на события ExoPlayer
            player.exoPlayer?.addListener(object : Player.Listener {
                override fun onPlaybackStateChanged(state: Int) {
                    val status = when (state) {
                        Player.STATE_IDLE -> "idle"
                        Player.STATE_BUFFERING -> "buffering"
                        Player.STATE_READY -> if (player.exoPlayer?.playWhenReady == true) "playing" else "paused"
                        Player.STATE_ENDED -> "ended"
                        else -> "unknown"
                    }
                    Log.d(TAG, "Player state changed to: $status (state=$state, playWhenReady=${player.exoPlayer?.playWhenReady})")
                    
                    // Логируем дополнительную информацию для buffering
                    if (state == Player.STATE_BUFFERING) {
                        player.exoPlayer?.let { exo ->
                            Log.d(TAG, "Buffering info: currentPosition=${exo.currentPosition}, duration=${exo.duration}, bufferedPosition=${exo.bufferedPosition}")
                        }
                    }
                    
                    sendStatusChanged(viewId, status)
                }

                override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) {
                    val reasonStr = when (reason) {
                        Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST -> "USER_REQUEST"
                        Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_FOCUS_LOSS -> "AUDIO_FOCUS_LOSS"
                        Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_BECOMING_NOISY -> "AUDIO_BECOMING_NOISY"
                        Player.PLAY_WHEN_READY_CHANGE_REASON_REMOTE -> "REMOTE"
                        else -> "UNKNOWN($reason)"
                    }
                    Log.d(TAG, "⚡ playWhenReady changed to: $playWhenReady, reason: $reasonStr, state: ${player.exoPlayer?.playbackState}")
                    
                    val state = player.exoPlayer?.playbackState
                    val status = if (playWhenReady && state == Player.STATE_READY) "playing"
                    else if (!playWhenReady && state == Player.STATE_READY) "paused"
                    else null
                    if (status != null) sendStatusChanged(viewId, status)
                }

                override fun onPlayerError(error: androidx.media3.common.PlaybackException) {
                    Log.e(
                        TAG,
                        "ExoPlayer error: ${error.message}, errorCode: ${error.errorCode}"
                    )
                    when (error.errorCode) {
                        androidx.media3.common.PlaybackException.ERROR_CODE_DRM_SCHEME_UNSUPPORTED -> {
                            Log.e(
                                TAG,
                                "DRM UNSUPPORTED: Widevine может быть недоступен на устройстве или DRM metadata некорректны"
                            )
                        }

                        androidx.media3.common.PlaybackException.ERROR_CODE_DRM_LICENSE_ACQUISITION_FAILED -> {
                            Log.e(
                                TAG,
                                "DRM LICENSE FAILED: Проблема с получением лицензии - проверьте токен и referer"
                            )
                        }

                        androidx.media3.common.PlaybackException.ERROR_CODE_DRM_PROVISIONING_FAILED -> {
                            Log.e(
                                TAG,
                                "DRM PROVISIONING FAILED: Проблема с получением сертификата"
                            )
                        }
                    }

                    // Выводим полную информацию об ошибке
                    val cause = error.cause
                    if (cause != null) {
                        Log.e(
                            TAG,
                            "Error cause: ${cause.javaClass.simpleName}: ${cause.message}"
                        )
                    }
                }

                override fun onEvents(player: Player, events: Player.Events) {
                    if (events.contains(Player.EVENT_PLAYBACK_PARAMETERS_CHANGED)) {
                        val rate = player.playbackParameters.speed
                        sendPlaybackRateChanged(viewId, rate)
                    }
                }
            })

            // Запуск периодического обновления прогресса
            val handler = Handler(Looper.getMainLooper())
            val progressRunnable = object : Runnable {
                override fun run() {
                    val exoPlayer = player.exoPlayer
                    if (exoPlayer != null && exoPlayer.duration > 0) {
                        val position = exoPlayer.currentPosition
                        val duration = exoPlayer.duration
                        val percent =
                            (position.toDouble() / duration * 100).coerceIn(0.0, 100.0)
                        sendProgressUpdate(viewId, percent)
                    }
                    handler.postDelayed(this, 1000)
                }
            }
            handler.post(progressRunnable)
            progressUpdateHandlers[viewId] = handler

            // Сохраняем ссылки СРАЗУ при создании
            players[viewId] = player
            playerViews[viewId] = playerView
            Log.d(TAG, "Player and view saved for viewId: $viewId")
            Log.d(TAG, "Current players map: ${players.keys}")

            return object : PlatformView {
                override fun getView(): KinescopePlayerView {
                    Log.d(TAG, "getView() called for viewId: $viewId")
                    return playerView
                }

                override fun dispose() {
                    Log.d(TAG, "Disposing platform view for viewId: $viewId")
                    dispose(viewId, object : MethodChannel.Result {
                        override fun success(result: Any?) {}
                        override fun error(
                            errorCode: String, errorMessage: String?, errorDetails: Any?
                        ) {
                            Log.e(TAG, "Error during dispose: $errorCode - $errorMessage")
                        }

                        override fun notImplemented() {}
                    })
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception while creating platform view", e)
            throw e
        }
    }
}