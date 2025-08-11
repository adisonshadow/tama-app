import 'package:flutter/foundation.dart';
import '../models/follow_model.dart';
import '../services/following_service.dart';
import '../../home/models/video_model.dart';

class FollowingProvider extends ChangeNotifier {
  List<FollowModel> _follows = [];
  List<VideoModel> _followingVideos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  List<FollowModel> get follows => _follows;
  List<VideoModel> get followingVideos => _followingVideos;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadMyFollows({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _follows.clear();
      }

      _setLoading(true);
      _clearError();

      final response = await FollowingService.getMyFollows(
        page: _currentPage,
        limit: 20,
      );

      if (response['status'] == 'SUCCESS') {
        final List<dynamic> followData = response['data'] ?? [];
        final List<FollowModel> newFollows = followData
            .map((json) => FollowModel.fromJson(json))
            .toList();

        if (refresh) {
          _follows = newFollows;
        } else {
          _follows.addAll(newFollows);
        }

        _currentPage++;
        _hasMore = newFollows.length >= 20;
      } else {
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      _setError('网络错误：$e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFollowingVideos({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _followingVideos.clear();
      }

      _setLoading(true);
      _clearError();

      final response = await FollowingService.getFollowingArticles(
        page: _currentPage,
        limit: 20,
      );

      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        final List<VideoModel> newVideos = videoData
            .map((json) => VideoModel.fromJson(json))
            .toList();

        if (refresh) {
          _followingVideos = newVideos;
        } else {
          _followingVideos.addAll(newVideos);
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

  Future<bool> followUser(String userId) async {
    try {
      final response = await FollowingService.followUser(userId);
      if (response['status'] == 'SUCCESS') {
        // 重新加载关注列表
        await loadMyFollows(refresh: true);
        return true;
      }
      return false;
    } catch (e) {
      print('Follow user error: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      final response = await FollowingService.unfollowUser(userId);
      if (response['status'] == 'SUCCESS') {
        // 从本地列表中移除
        _follows.removeWhere((follow) => follow.id == userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Unfollow user error: $e');
      return false;
    }
  }

  Future<void> refreshFollows() async {
    await loadMyFollows(refresh: true);
  }

  Future<void> refreshFollowingVideos() async {
    await loadFollowingVideos(refresh: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    // 在Chrome中打印错误信息到控制台
    if (kIsWeb) {
      debugPrint('❌ FollowingProvider Error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
