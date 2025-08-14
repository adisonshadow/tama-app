import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

import '../../home/models/video_model.dart';
import '../services/user_space_service.dart';

class UserSpaceProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadUserVideos(String userId, {bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _videos.clear();
      }

      _setLoading(true);
      _clearError();

      final response = await UserSpaceService.getUserVideos(
        userId: userId,
        page: _currentPage,
        limit: 20,
      );

      if (response['status'] == 'SUCCESS') {
        final dynamic data = response['data'];
        List<dynamic> videoData = [];
        
        if (data is Map<String, dynamic>) {
          videoData = data['items'] ?? data['data'] ?? [];
        } else if (data is List) {
          videoData = data;
        } else {
          videoData = [];
        }
        
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

  Future<void> refreshUserVideos(String userId) async {
    await loadUserVideos(userId, refresh: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    if (kIsWeb) {
      debugPrint('❌ UserSpaceProvider Error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
