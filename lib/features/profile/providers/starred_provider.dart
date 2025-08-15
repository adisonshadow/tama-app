import 'package:flutter/foundation.dart';
import '../../home/models/video_model.dart';
import '../services/starred_service.dart';

class StarredProvider extends ChangeNotifier {
  List<VideoModel> _starredVideos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  List<VideoModel> get starredVideos => _starredVideos;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadMyStarred({bool refresh = false}) async {
    // print('🔍 StarredProvider - loadMyStarred 方法开始执行');
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _starredVideos.clear();
      }

      _setLoading(true);
      _clearError();

      // print('🔍 StarredProvider - 开始加载收藏文章，页码: $_currentPage');

      final response = await StarredService.getMyStarred(
        page: _currentPage,
        pageSize: 20,
      );

      // print('🔍 StarredProvider - API响应: $response');

      if (response['status'] == 'SUCCESS') {
        // 处理分页数据结构
        final dynamic data = response['data'];
        List<dynamic> videoData = [];
        
        // print('🔍 StarredProvider - 原始data: $data');
        // print('🔍 StarredProvider - data类型: ${data.runtimeType}');
        
        if (data is Map<String, dynamic>) {
          // 如果data是Map，尝试获取items字段或嵌套的data字段
          videoData = data['data'] ?? data['items'] ?? [];
          // print('🔍 StarredProvider - 从Map中提取的videoData: $videoData');
        } else if (data is List) {
          // 如果data直接是List
          videoData = data;
          // print('🔍 StarredProvider - data直接是List: $videoData');
        } else {
          // print('🔍 StarredProvider - 未知的收藏文章数据结构: ${data.runtimeType}');
          videoData = [];
        }
        
        // print('🔍 StarredProvider - 最终解析到的收藏文章数据: ${videoData.length} 条');
        
        if (videoData.isNotEmpty) {
          // print('🔍 StarredProvider - 第一条数据示例: ${videoData.first}');
        }
        
        final List<VideoModel> newVideos = videoData
            .map((json) {
              try {
                final video = VideoModel.fromJsonSafe(json);
                // print('🔍 StarredProvider - 成功解析视频: ${video.title}');
                return video;
              } catch (e) {
                print('❌ StarredProvider - 解析视频失败: $e');
                print('❌ StarredProvider - 失败的数据: $json');
                rethrow;
              }
            })
            .toList();

        if (refresh) {
          _starredVideos = newVideos;
        } else {
          _starredVideos.addAll(newVideos);
        }

        _currentPage++;
        _hasMore = newVideos.length >= 20;
        
        // print('🔍 StarredProvider - 加载完成，当前收藏文章总数: ${_starredVideos.length}');
      } else {
        print('❌ StarredProvider - API返回失败状态: ${response['message']}');
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      print('❌ StarredProvider - 加载收藏文章时发生错误: $e');
      _setError('网络错误：$e');
    } finally {
      _setLoading(false);
      // print('🔍 StarredProvider - 加载状态设置为false');
    }
  }

  Future<void> refreshStarred() async {
    await loadMyStarred(refresh: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    // 在Chrome中打印错误信息到控制台
    if (kIsWeb) {
      debugPrint('❌ StarredProvider Error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
