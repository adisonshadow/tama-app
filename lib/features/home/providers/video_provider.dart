import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../../../shared/services/storage_service.dart';

class VideoProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadRandomRecommendedVideos({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _videos.clear();
      }

      _setLoading(true);
      _clearError();

      final response = await VideoService.getRandomVideos(
        limit: 20,
      );

      // 添加调试信息
      if (kIsWeb) {
        debugPrint('🔍 Random Videos API Response: $response');
      }

      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        
        // 添加调试信息
        if (kIsWeb) {
          debugPrint('🔍 Video Data Count: ${videoData.length}');
          if (videoData.isNotEmpty) {
            debugPrint('🔍 First Video Data: ${videoData.first}');
          }
        }
        
        try {
          final List<VideoModel> newVideos = videoData
              .map((json) => VideoModel.fromJsonSafe(json))
              .toList();

          if (refresh) {
            _videos = newVideos;
          } else {
            _videos.addAll(newVideos);
          }

          _currentPage++;
          _hasMore = newVideos.length >= 20;
        } catch (parseError) {
          if (kIsWeb) {
            debugPrint('❌ VideoModel.fromJsonSafe failed: $parseError');
            if (videoData.isNotEmpty) {
              debugPrint('❌ First video data that caused error: ${videoData.first}');
            }
          }
          _setError('视频数据解析失败：$parseError');
        }
      } else {
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Load random videos API call failed: $e');
      }
      _setError('网络错误：$e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRecommendedVideos({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _videos.clear();
      }

      _setLoading(true);
      _clearError();

      final response = await VideoService.getRecommendedVideos(
        page: _currentPage,
        limit: 20,
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

        _currentPage++;
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
    await loadRandomRecommendedVideos(refresh: true);
  }

  Future<void> loadMoreVideos() async {
    if (!_hasMore || _isLoading) return;
    await loadRandomRecommendedVideos(refresh: false);
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
