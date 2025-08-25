import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/video_model.dart';
import '../providers/video_provider.dart';
import 'video_item_widget.dart';
import '../../video_player/providers/video_player_provider.dart'; // 导入自定义滚动物理效果

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
  bool _isAutoLoading = false; // 防止重复自动加载

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

  /// 检查是否需要自动加载更多视频
  /// 参考web端逻辑：当播放到倒数第二条视频时自动加载
  /// 注意: random接口每次都是随机推荐，服务端自动排除已看过的视频
  void _checkAutoLoadMore(int index) {
    final videoProvider = context.read<VideoProvider>();
    
    // 防止重复自动加载
    if (_isAutoLoading) {
      print('🔍 VideoFeedWidget - 正在自动加载中，跳过重复请求');
      return;
    }
    
    // 如果当前是倒数第二条视频，且还有更多数据，则自动加载
    // random接口每次都是随机推荐，始终有更多数据
    if (index >= widget.videos.length - 2 && 
        videoProvider.hasMore && 
        !videoProvider.isLoading) {
      
      print('🔍 VideoFeedWidget - 自动加载更多随机推荐文章，当前索引: $index, 总视频数: ${widget.videos.length}');
      
      _isAutoLoading = true;
      
      // 延迟一点时间再加载，避免过于频繁的请求
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          videoProvider.loadRandomArticles(refresh: false).then((_) {
            _isAutoLoading = false;
            print('🔍 VideoFeedWidget - 自动加载完成');
          }).catchError((error) {
            _isAutoLoading = false;
            print('❌ VideoFeedWidget - 自动加载失败: $error');
          });
        }
      });
    }
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

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          // 优化滑动体验
          pageSnapping: true, // 启用页面吸附
          scrollBehavior: const ScrollBehavior().copyWith(
            scrollbars: false, // 隐藏滚动条
          ),
          // 减少滑动距离，提高响应性 - 使用ClampingScrollPhysics减少滑动距离要求
          physics: const SensitivePageScrollPhysics(
            parent: BouncingScrollPhysics(), // 使用弹性滚动
          ),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            
            // 检查是否需要自动加载更多视频
            _checkAutoLoadMore(index);
            
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
        ),
        
        // 自动加载状态指示器
        if (_isAutoLoading)
          Positioned(
            bottom: 100,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '加载中...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
