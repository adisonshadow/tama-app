package com.tama2.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaCodec
import android.media.MediaCodecList
import android.util.Log
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tama2.app/video_player"
    private var exoPlayer: ExoPlayer? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 设置方法通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializePlayer" -> {
                    initializeExoPlayer()
                    result.success("Player initialized")
                }
                "playVideo" -> {
                    val videoUrl = call.argument<String>("url")
                    if (videoUrl != null) {
                        playVideo(videoUrl)
                        result.success("Video started playing")
                    } else {
                        result.error("INVALID_ARGUMENT", "Video URL is required", null)
                    }
                }
                "pauseVideo" -> {
                    pauseVideo()
                    result.success("Video paused")
                }
                "stopVideo" -> {
                    stopVideo()
                    result.success("Video stopped")
                }
                "disposePlayer" -> {
                    disposePlayer()
                    result.success("Player disposed")
                }
                "getSupportedCodecs" -> {
                    val codecs = getSupportedCodecs()
                    result.success(codecs)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun initializeExoPlayer() {
        try {
            // 使用默认的RenderersFactory，但启用解码器回退
            val renderersFactory = DefaultRenderersFactory(this).apply {
                setEnableDecoderFallback(true) // 启用解码器回退
            }
            
            exoPlayer = ExoPlayer.Builder(this)
                .setRenderersFactory(renderersFactory)
                .setMediaSourceFactory(DefaultMediaSourceFactory(this))
                .build()
                
            Log.d("MainActivity", "ExoPlayer initialized successfully with decoder fallback enabled")
            
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to initialize ExoPlayer: ${e.message}")
        }
    }
    
    private fun playVideo(videoUrl: String) {
        try {
            exoPlayer?.let { player ->
                val mediaItem = MediaItem.fromUri(videoUrl)
                player.setMediaItem(mediaItem)
                player.prepare()
                player.play()
                Log.d("MainActivity", "Started playing video: $videoUrl")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to play video: ${e.message}")
        }
    }
    
    private fun pauseVideo() {
        exoPlayer?.pause()
        Log.d("MainActivity", "Video paused")
    }
    
    private fun stopVideo() {
        exoPlayer?.stop()
        Log.d("MainActivity", "Video stopped")
    }
    
    private fun disposePlayer() {
        exoPlayer?.release()
        exoPlayer = null
        Log.d("MainActivity", "Player disposed")
    }
    
    private fun getSupportedCodecs(): Map<String, Any> {
        val codecInfo = mutableMapOf<String, Any>()
        
        try {
            // 获取所有可用的编解码器
            val codecList = MediaCodecList(MediaCodecList.REGULAR_CODECS)
            val codecNames = codecList.codecInfos
            
            val videoDecoders = mutableListOf<String>()
            val audioDecoders = mutableListOf<String>()
            
            for (codec in codecNames) {
                if (codec.isEncoder) continue
                
                for (type in codec.supportedTypes) {
                    when {
                        type.startsWith("video/") -> {
                            val codecName = codec.name
                            videoDecoders.add("$type ($codecName)")
                            
                            // 检查是否是软件解码器
                            if (codecName.contains("google") || codecName.contains("sw") || codecName.contains("soft")) {
                                Log.d("MainActivity", "Found software video decoder: $codecName for $type")
                            }
                        }
                        type.startsWith("audio/") -> {
                            val codecName = codec.name
                            audioDecoders.add("$type ($codecName)")
                        }
                    }
                }
            }
            
            codecInfo["videoDecoders"] = videoDecoders
            codecInfo["audioDecoders"] = audioDecoders
            codecInfo["totalVideoDecoders"] = videoDecoders.size
            codecInfo["totalAudioDecoders"] = audioDecoders.size
            
            Log.d("MainActivity", "Found ${videoDecoders.size} video decoders and ${audioDecoders.size} audio decoders")
            
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to get codec info: ${e.message}")
            codecInfo["error"] = e.message ?: "Unknown error"
        }
        
        return codecInfo
    }
    
    override fun onDestroy() {
        disposePlayer()
        super.onDestroy()
    }
}
