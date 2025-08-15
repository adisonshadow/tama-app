import 'package:flutter/material.dart';

import '../models/video_model.dart';
import 'video_item_widget.dart';

class VideoFeedWidget extends StatefulWidget {
  final List<VideoModel> videos;
  final Function(String?)? onVideoChanged; // 添加回调参数

  const VideoFeedWidget({
    super.key,
    required this.videos,
    this.onVideoChanged,
  });

  @override
  State<VideoFeedWidget> createState() => _VideoFeedWidgetState();
}

class _VideoFeedWidgetState extends State<VideoFeedWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无推荐内容',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '下拉刷新试试看',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        // 调用回调，传递当前视频的封面URL
        if (widget.onVideoChanged != null) {
          final currentVideo = widget.videos[index];
          // 使用新的getCoverByRecord方法，支持resize参数
          final coverUrl = currentVideo.getCoverByRecord('w=360&h=202'); // 使用web项目中的默认尺寸
          // print('🔍 VideoFeedWidget - 视频切换，封面URL: $coverUrl'); // 添加调试信息
          if (coverUrl.isNotEmpty) {
            widget.onVideoChanged!(coverUrl);
          }
        }
      },
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        final isActive = index == _currentIndex;
        
        return VideoItemWidget(
          video: video,
          isActive: isActive,
        );
      },
    );
  }
}
