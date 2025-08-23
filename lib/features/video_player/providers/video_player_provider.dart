import 'package:flutter/material.dart';
import '../../home/models/video_model.dart';

class VideoPlayerProvider extends ChangeNotifier {
  List<VideoModel> _videos = [];
  int _currentIndex = 0;
  late PageController _pageController;

  VideoPlayerProvider() {
    _pageController = PageController();
  }

  List<VideoModel> get videos => _videos;
  int get currentIndex => _currentIndex;
  PageController get pageController => _pageController;

  void initializeVideos(List<VideoModel> videos, int initialIndex) {
    _videos = videos;
    _currentIndex = initialIndex;
    
    // 使用 addPostFrameCallback 确保 PageView 完全构建后再跳转
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查 controller 是否仍然有效且已附加到 PageView
      if (_pageController.hasClients && _videos.isNotEmpty && initialIndex < _videos.length) {
        try {
          _pageController.jumpToPage(initialIndex);
        } catch (e) {
          debugPrint('❌ VideoPlayerProvider: 跳转页面失败: $e');
        }
      }
    });
    
    notifyListeners();
  }

  void onPageChanged(int index) {
    if (index != _currentIndex && index >= 0 && index < _videos.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  VideoModel? get currentVideo {
    if (_videos.isEmpty || _currentIndex < 0 || _currentIndex >= _videos.length) {
      return null;
    }
    return _videos[_currentIndex];
  }

  void nextVideo() {
    if (_pageController.hasClients && _currentIndex < _videos.length - 1) {
      try {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        debugPrint('❌ VideoPlayerProvider: nextVideo 失败: $e');
      }
    }
  }

  void previousVideo() {
    if (_pageController.hasClients && _currentIndex > 0) {
      try {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        debugPrint('❌ VideoPlayerProvider: previousVideo 失败: $e');
      }
    }
  }

  void jumpToVideo(int index) {
    if (_pageController.hasClients && index >= 0 && index < _videos.length) {
      try {
        _pageController.jumpToPage(index);
      } catch (e) {
        debugPrint('❌ VideoPlayerProvider: jumpToVideo 失败: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
