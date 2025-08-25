import 'dart:async';
import 'storage_service.dart';
import 'media_service.dart';
import '../models/user_model.dart';
import '../../features/home/models/video_model.dart';

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
      final response = await MediaService.generateToken();
      
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
  
  /// 为视频URL添加token参数和userId参数（向后兼容版本）
  /// 参考前端JS代码的逻辑：if(logined && myInfo){ videoUrl = `${videoUrl}&article_id=${videoInfo.article_id}&userId=${myInfo.userId}`; }
  Future<String> addTokenToUrl(String videoUrl) async {
    return addTokenToUrlWithVideo(videoUrl, null);
  }
  
  /// 为视频URL添加token参数、userId参数和article_id参数
  /// 参考前端JS代码的逻辑：if(logined && myInfo){ videoUrl = `${videoUrl}&article_id=${videoInfo.article_id}&userId=${myInfo.userId}`; }
  Future<String> addTokenToUrlWithVideo(String videoUrl, VideoModel? video) async {
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
    String finalUrl = '$baseUrl${separator}token=$token';
    
    // 检查用户是否已登录，如果已登录则添加userId参数
    final user = await StorageService.getUser();
    if (user != null && user.userId.isNotEmpty) {
      finalUrl = '$finalUrl&userId=${user.userId}';
      
      // 如果有视频信息，添加article_id参数
      if (video != null && video.id.isNotEmpty) {
        finalUrl = '$finalUrl&articleId=${video.id}';
      }
    }
    
    // 添加#.m3u8片段
    finalUrl = '$finalUrl$fragment';
    
    // 添加调试日志 - 输出到控制台
    print('🔍 VideoTokenManager - Original URL: $videoUrl');
    print('🔍 VideoTokenManager - Base URL: $baseUrl');
    print('🔍 VideoTokenManager - Fragment: $fragment');
    print('🔍 VideoTokenManager - Token: $token');
    print('🔍 VideoTokenManager - User ID: ${user?.userId}');
    print('🔍 VideoTokenManager - Article ID: ${video?.id}');
    print('🔍 VideoTokenManager - Final URL: $finalUrl');
    
    return finalUrl;
  }
}