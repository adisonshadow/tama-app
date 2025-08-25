import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../../../shared/services/storage_service.dart';

class VideoProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasMore = true; // 始终为true，因为每次都是随机推荐
  String? _error;

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// 加载随机推荐文章
  /// 使用 GET /api/articles/random 接口
  /// 服务端会自动排除用户已看过的视频
  /// 每次调用都是随机推荐，无需分页
  Future<void> loadRandomArticles({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _videos.clear();
      }

      _setLoading(true);
      _clearError();

      print('🔍 VideoProvider - 加载随机推荐文章，刷新: $refresh');

      final response = await VideoService.getRandomVideos(
        pageSize: 20,
      );

      // 添加调试信息
      if (kIsWeb) {
        // debugPrint('🔍 Random Articles API Response: $response');
      }

      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        
        // 添加调试信息
        if (kIsWeb) {
          debugPrint('🔍 Random Articles Count: ${videoData.length}');
          if (videoData.isNotEmpty) {
            // debugPrint('🔍 First Article Data: ${videoData.first}');
          }
        }
        
        print('🔍 VideoProvider - API返回视频数量: ${videoData.length}');
        
        try {
          final List<VideoModel> newVideos = videoData
              .map((json) => VideoModel.fromJsonSafe(json))
              .toList();

          if (refresh) {
            _videos = newVideos;
            print('🔍 VideoProvider - 刷新模式，设置视频列表，数量: ${_videos.length}');
          } else {
            _videos.addAll(newVideos);
            print('🔍 VideoProvider - 追加模式，添加视频数量: ${newVideos.length}，总数量: ${_videos.length}');
          }
          
          // random接口每次都是随机推荐，始终有更多数据
          _hasMore = true;
          
          print('🔍 VideoProvider - 随机推荐模式，始终有更多数据: $_hasMore');
          
        } catch (parseError) {
          if (kIsWeb) {
            debugPrint('❌ VideoModel.fromJsonSafe failed: $parseError');
            if (videoData.isNotEmpty) {
              debugPrint('❌ First article data that caused error: ${videoData.first}');
            }
          }
          _setError('文章数据解析失败：$parseError');
        }
      } else {
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Load random articles API call failed: $e');
      }
      _setError('网络错误：$e');
    } finally {
      _setLoading(false);
    }
  }

  /// 加载推荐视频
  /// 使用 GET /api/articles/recommended2 接口
  /// 注意: 服务端会自动检查用户是否已经看过视频并排除已看过的视频
  Future<void> loadRecommendedVideos({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _videos.clear();
      }

      _setLoading(true);
      _clearError();

      final response = await VideoService.getRecommendedVideos(
        page: 1, // 推荐视频接口支持分页，但这里简化处理
        pageSize: 20,
      );

      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        final List<VideoModel> newVideos = videoData
            .map((json) => VideoModel.fromJsonSafe(json))
            .toList();

        if (refresh) {
          _videos = newVideos;
        } else {
          _videos.addAll(newVideos);
        }

        // 推荐视频接口支持分页，但这里简化处理
        _hasMore = newVideos.length >= 20;
      } else {
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      _setError('网络错误：$e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshVideos() async {
    await loadRandomArticles(refresh: true);
  }

  /// 手动加载更多视频
  /// 用于在用户播放到倒数第二条视频时自动触发
  /// 注意: random接口每次都是随机推荐，服务端自动排除已看过的视频
  Future<void> loadMoreVideos() async {
    if (!_hasMore || _isLoading) {
      print('🔍 VideoProvider - 无法加载更多视频，hasMore: $_hasMore, isLoading: $_isLoading');
      return;
    }
    
    print('🔍 VideoProvider - 手动加载更多视频');
    await loadRandomArticles(refresh: false);
  }

  /// 标记视频为已播放
  Future<void> markVideoAsPlayed(String videoId) async {
    await StorageService.addPlayedVideoId(videoId);
  }

  /// 切换视频点赞状态
  /// 接口: GET /api/my/toggleLikeArticle/{articleId}
  Future<bool> likeVideo(String videoId) async {
    try {
      final response = await VideoService.likeVideo(videoId);
      if (response['status'] == 'SUCCESS') {
        // 更新本地视频的点赞状态
        final videoIndex = _videos.indexWhere((video) => video.id == videoId);
        if (videoIndex != -1) {
          // TODO: 根据API返回结果更新点赞状态和数量
          // 当前只是通知UI刷新，实际状态更新需要根据API返回的数据
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Like video error: $e');
      return false;
    }
  }

  /// 切换视频收藏状态
  /// 接口: GET /api/my/toggleStarArticle/{articleId}
  Future<bool> starVideo(String videoId) async {
    try {
      final response = await VideoService.starVideo(videoId);
      if (response['status'] == 'SUCCESS') {
        // 更新本地视频的收藏状态
        final videoIndex = _videos.indexWhere((video) => video.id == videoId);
        if (videoIndex != -1) {
          // TODO: 根据API返回结果更新收藏状态和数量
          // 当前只是通知UI刷新，实际状态更新需要根据API返回的数据
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Star video error: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    // 在Chrome中打印错误信息到控制台
    if (kIsWeb) {
      debugPrint('❌ VideoProvider Error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
