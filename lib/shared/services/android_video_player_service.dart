import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class AndroidVideoPlayerService {
  static const MethodChannel _channel = MethodChannel('com.tama2.app/video_player');
  
  static AndroidVideoPlayerService? _instance;
  factory AndroidVideoPlayerService() => _instance ??= AndroidVideoPlayerService._internal();
  AndroidVideoPlayerService._internal();
  
  /// 初始化播放器
  Future<bool> initializePlayer() async {
    try {
      final result = await _channel.invokeMethod('initializePlayer');
      developer.log('Android video player initialized: $result', name: 'AndroidVideoPlayer');
      return true;
    } catch (e) {
      developer.log('Failed to initialize Android video player: $e', name: 'AndroidVideoPlayer');
      return false;
    }
  }
  
  /// 播放视频
  Future<bool> playVideo(String url) async {
    try {
      final result = await _channel.invokeMethod('playVideo', {'url': url});
      developer.log('Android video started playing: $result', name: 'AndroidVideoPlayer');
      return true;
    } catch (e) {
      developer.log('Failed to play video on Android: $e', name: 'AndroidVideoPlayer');
      return false;
    }
  }
  
  /// 暂停视频
  Future<bool> pauseVideo() async {
    try {
      final result = await _channel.invokeMethod('pauseVideo');
      developer.log('Android video paused: $result', name: 'AndroidVideoPlayer');
      return true;
    } catch (e) {
      developer.log('Failed to pause video on Android: $e', name: 'AndroidVideoPlayer');
      return false;
    }
  }
  
  /// 停止视频
  Future<bool> stopVideo() async {
    try {
      final result = await _channel.invokeMethod('stopVideo');
      developer.log('Android video stopped: $result', name: 'AndroidVideoPlayer');
      return true;
    } catch (e) {
      developer.log('Failed to stop video on Android: $e', name: 'AndroidVideoPlayer');
      return false;
    }
  }
  
  /// 释放播放器资源
  Future<bool> disposePlayer() async {
    try {
      final result = await _channel.invokeMethod('disposePlayer');
      developer.log('Android video player disposed: $result', name: 'AndroidVideoPlayer');
      return true;
    } catch (e) {
      developer.log('Failed to dispose Android video player: $e', name: 'AndroidVideoPlayer');
      return false;
    }
  }
  
  /// 获取支持的编解码器信息
  Future<Map<String, dynamic>?> getSupportedCodecs() async {
    try {
      final result = await _channel.invokeMethod('getSupportedCodecs');
      developer.log('Got supported codecs: $result', name: 'AndroidVideoPlayer');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      developer.log('Failed to get supported codecs: $e', name: 'AndroidVideoPlayer');
      return null;
    }
  }
  
  /// 检查是否支持特定视频格式
  Future<bool> isVideoFormatSupported(String mimeType) async {
    try {
      final codecs = await getSupportedCodecs();
      if (codecs != null && codecs.containsKey('videoDecoders')) {
        final videoDecoders = List<String>.from(codecs['videoDecoders']);
        return videoDecoders.any((decoder) => decoder.startsWith(mimeType));
      }
      return false;
    } catch (e) {
      developer.log('Failed to check video format support: $e', name: 'AndroidVideoPlayer');
      return false;
    }
  }
  
  /// 检查是否有软件解码器可用
  Future<bool> hasSoftwareDecoder() async {
    try {
      final codecs = await getSupportedCodecs();
      if (codecs != null && codecs.containsKey('videoDecoders')) {
        final videoDecoders = List<String>.from(codecs['videoDecoders']);
        return videoDecoders.any((decoder) => 
          decoder.contains('google') || 
          decoder.contains('sw') || 
          decoder.contains('soft') ||
          decoder.contains('ffmpeg')
        );
      }
      return false;
    } catch (e) {
      developer.log('Failed to check software decoder availability: $e', name: 'AndroidVideoPlayer');
      return false;
    }
  }
}
