import 'package:flutter/foundation.dart';
import '../../home/models/video_model.dart';
import '../services/liked_service.dart';

class LikedProvider extends ChangeNotifier {
  List<VideoModel> _likedVideos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  List<VideoModel> get likedVideos => _likedVideos;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadMyLiked({bool refresh = false}) async {
    // print('🔍 LikedProvider - loadMyLiked 方法开始执行');
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _likedVideos.clear();
      }

      _setLoading(true);
      _clearError();

      // print('🔍 LikedProvider - 开始加载点赞文章，页码: $_currentPage');

      final response = await LikedService.getMyLiked(
        page: _currentPage,
        pageSize: 20,
      );

      // print('🔍 LikedProvider - API响应: $response');

      if (response['status'] == 'SUCCESS') {
        // 处理分页数据结构
        final dynamic data = response['data'];
        List<dynamic> videoData = [];
        
        // print('🔍 LikedProvider - 原始data: $data');
        // print('🔍 LikedProvider - data类型: ${data.runtimeType}');
        
        if (data is Map<String, dynamic>) {
          // 如果data是Map，尝试获取items字段或嵌套的data字段
          videoData = data['data'] ?? data['items'] ?? [];
          // print('🔍 LikedProvider - 从Map中提取的videoData: $videoData');
        } else if (data is List) {
          // 如果data直接是List
          videoData = data;
          // print('🔍 LikedProvider - data直接是List: $videoData');
        } else {
          // print('🔍 LikedProvider - 未知的点赞文章数据结构: ${data.runtimeType}');
          videoData = [];
        }
        
        // print('🔍 LikedProvider - 最终解析到的点赞文章数据: ${videoData.length} 条');
        
        if (videoData.isNotEmpty) {
          // print('🔍 LikedProvider - 第一条数据示例: ${videoData.first}');
        }
        
        final List<VideoModel> newVideos = videoData
            .map((json) {
              try {
                final video = VideoModel.fromJsonSafe(json);
                // print('🔍 LikedProvider - 成功解析视频: ${video.title}');
                return video;
              } catch (e) {
                print('❌ LikedProvider - 解析视频失败: $e');
                print('❌ LikedProvider - 失败的数据: $json');
                rethrow;
              }
            })
            .toList();

        if (refresh) {
          _likedVideos = newVideos;
        } else {
          _likedVideos.addAll(newVideos);
        }

        _currentPage++;
        _hasMore = newVideos.length >= 20;
        
        // print('🔍 LikedProvider - 加载完成，当前点赞文章总数: ${_likedVideos.length}');
      } else {
        print('❌ LikedProvider - API返回失败状态: ${response['message']}');
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      print('❌ LikedProvider - 加载点赞文章时发生错误: $e');
      _setError('网络错误：$e');
    } finally {
      _setLoading(false);
      // print('🔍 LikedProvider - 加载状态设置为false');
    }
  }

  Future<void> refreshLiked() async {
    await loadMyLiked(refresh: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    // 在Chrome中打印错误信息到控制台
    if (kIsWeb) {
      debugPrint('❌ LikedProvider Error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
