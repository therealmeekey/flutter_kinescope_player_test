package com.example.flutter_kinescope_player

import androidx.media3.common.C
import androidx.media3.exoplayer.ExoPlayer
import kotlin.math.max
import kotlin.math.min

class PlayerControl(private val exoPlayer: ExoPlayer) {
    fun canPause() = true
    fun canSeekBackward() = true
    fun canSeekForward() = true
    fun getBufferPercentage() = exoPlayer.bufferedPercentage
    fun getCurrentPosition() =
        if (exoPlayer.duration == C.TIME_UNSET) 0 else exoPlayer.currentPosition.toInt()

    fun getDuration() = if (exoPlayer.duration == C.TIME_UNSET) 0 else exoPlayer.duration.toInt()
    fun isPlaying() = exoPlayer.isPlaying
    fun start() {
        exoPlayer.playWhenReady = true
    }

    fun pause() {
        exoPlayer.playWhenReady = false
    }

    fun seekTo(timeMillis: Int) {
        val seekPosition = if (exoPlayer.duration == C.TIME_UNSET) 0L
        else min(max(0, timeMillis), getDuration()).toLong()
        exoPlayer.seekTo(seekPosition)
    }
} 