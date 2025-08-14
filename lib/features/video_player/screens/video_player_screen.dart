import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../home/models/video_model.dart';
import '../../home/widgets/video_playback_component.dart';
import '../providers/video_player_provider.dart';
import '../../user_space/screens/user_space_screen.dart';
import '../../../shared/widgets/search_manager.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String userId;
  final List<VideoModel> videos;
  final int initialVideoIndex;

  const VideoPlayerScreen({
    super.key,
    required this.userId,
    required this.videos,
    this.initialVideoIndex = 0,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  String? _currentVideoCoverUrl;

  @override
  void initState() {
    super.initState();
    
    // 设置初始封面
    if (widget.videos.isNotEmpty) {
      final initialVideo = widget.videos[widget.initialVideoIndex];
      _currentVideoCoverUrl = initialVideo.getCoverByRecord('w=360&h=202');
    }
    
    // 添加调试信息
    if (kIsWeb) {
      debugPrint('🔍 VideoPlayerScreen initState');
      debugPrint('🔍 userId: ${widget.userId}');
      debugPrint('🔍 videos count: ${widget.videos.length}');
      debugPrint('🔍 initialVideoIndex: ${widget.initialVideoIndex}');
    }
    
    // 初始化视频播放Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VideoPlayerProvider>();
      if (kIsWeb) {
        debugPrint('🔍 初始化VideoPlayerProvider');
        debugPrint('🔍 Provider videos count before: ${provider.videos.length}');
      }
      provider.initializeVideos(widget.videos, widget.initialVideoIndex);
      if (kIsWeb) {
        debugPrint('🔍 Provider videos count after: ${provider.videos.length}');
      }
    });
  }

  void _onVideoChanged(String? coverUrl) {
    if (mounted) {
      setState(() {
        _currentVideoCoverUrl = coverUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, // 让body延伸到AppBar后面
      body: Stack(
        children: [
          // 第1层: 模糊背景层 - 从屏幕顶部到底部
          if (_currentVideoCoverUrl != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                children: [
                  // 模糊图片背景
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0), // 大模糊效果
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_currentVideoCoverUrl!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.3), // 添加半透明黑色遮罩
                            BlendMode.dstATop,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // 第2层: 视频播放区域（从top: 0开始）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildVideoPlayer(),
          ),
          
          // 第3层: 悬浮的顶部导航栏（最上层）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top), // 考虑状态栏高度
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          const Spacer(),
          
          // 搜索按钮
          GestureDetector(
            onTap: () {
              // 跳转到搜索页面
              SearchManager.showSearch(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.search,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Consumer<VideoPlayerProvider>(
      builder: (context, provider, child) {
        // 直接使用传入的videos数据，而不是Provider的状态
        final videos = widget.videos;
        
        if (videos.isEmpty) {
          return const Center(
            child: Text(
              '暂无视频',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return PageView.builder(
          controller: provider.pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            provider.onPageChanged(index);
            // 更新封面URL
            final currentVideo = videos[index];
            final coverUrl = currentVideo.getCoverByRecord('w=360&h=202');
            _onVideoChanged(coverUrl);
          },
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return VideoPlaybackComponent(
              video: video,
              isActive: index == provider.currentIndex,
              onAvatarTap: () {
                // 头像点击后跳转到用户Space
                if (kIsWeb) {
                  debugPrint('🔍 头像被点击，准备跳转到用户Space: ${video.userId}');
                }
                _navigateToUserSpace(video);
              },
              key: ValueKey(video.id),
            );
          },
        );
      },
    );
  }

  void _navigateToUserSpace(VideoModel video) {
    // 跳转到用户Space页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserSpaceScreen(
          userId: video.userId,
          nickname: video.nickname ?? '未知用户',
          avatar: video.avatar ?? '',
          bio: null, // 暂时不传递bio
          spaceBg: null, // 暂时不传递spaceBg
        ),
      ),
    );
  }
}
