import 'dart:async';
import 'storage_service.dart';
import 'media_service.dart';

class VideoTokenManager {
  static final VideoTokenManager _instance = VideoTokenManager._internal();
  factory VideoTokenManager() => _instance;
  VideoTokenManager._internal();
  
  String? _cachedToken;
  DateTime? _tokenExpiry;
  
  /// 获取视频播放token
  /// 如果缓存中没有token或者token已过期，则从服务器获取新的token
  Future<String> getVideoToken() async {
    // 检查内存中的token是否有效
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }
    
    // 检查本地存储中的token
    final storedToken = await StorageService.getVideoToken();
    if (storedToken != null) {
      _cachedToken = storedToken;
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1)); // 假设token有效期为1小时
      return storedToken;
    }
    
    // 从服务器获取新的token
    return await _fetchNewToken();
  }
  
  /// 获取新的视频播放token并缓存
  Future<String> _fetchNewToken() async {
    try {
      final response = await MediaService.generateVideoToken();
      
      if (response['status'] == 'SUCCESS' && response['data'] != null) {
        final tokenData = response['data'];
        final token = tokenData['token'] as String;
        
        // 缓存token
        _cachedToken = token;
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1)); // 假设token有效期为1小时
        
        // 保存到本地存储
        await StorageService.saveVideoToken(token);
        
        return token;
      } else {
        throw Exception('Failed to generate video token: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching video token: $e');
    }
  }
  
  /// 清除缓存的token
  void clearToken() {
    _cachedToken = null;
    _tokenExpiry = null;
    StorageService.clearVideoToken();
  }
  
  /// 更新token（当token失效时调用）
  Future<String> refreshVideoToken() async {
    // 清除当前token
    clearToken();
    
    // 获取新的token
    return await _fetchNewToken();
  }
  
  /// 为视频URL添加token参数
  Future<String> addTokenToUrl(String videoUrl) async {
    final token = await getVideoToken();
    
    // 检查URL是否包含#.m3u8，如果有，需要特殊处理
    String baseUrl;
    String fragment = '';
    
    if (videoUrl.contains('#.m3u8')) {
      // 分离基础URL和#.m3u8片段
      final parts = videoUrl.split('#.m3u8');
      baseUrl = parts[0];
      fragment = '#.m3u8';
    } else {
      baseUrl = videoUrl;
    }
    
    // 添加token参数
    final separator = baseUrl.contains('?') ? '&' : '?';
    final finalUrl = '$baseUrl${separator}token=$token$fragment';
    
    // 添加调试日志
    print('🔍 VideoTokenManager - Original URL: $videoUrl');
    print('🔍 VideoTokenManager - Base URL: $baseUrl');
    print('🔍 VideoTokenManager - Fragment: $fragment');
    print('🔍 VideoTokenManager - Token: $token');
    print('🔍 VideoTokenManager - Final URL: $finalUrl');
    
    return finalUrl;
  }
}