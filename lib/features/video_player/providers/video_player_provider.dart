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
    
    // 跳转到初始视频位置
    if (_videos.isNotEmpty && initialIndex < _videos.length) {
      _pageController.jumpToPage(initialIndex);
    }
    
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
    if (_currentIndex < _videos.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousVideo() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void jumpToVideo(int index) {
    if (index >= 0 && index < _videos.length) {
      _pageController.jumpToPage(index);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
