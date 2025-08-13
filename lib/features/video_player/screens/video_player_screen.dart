import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../home/models/video_model.dart';
import '../../home/widgets/video_playback_component.dart';
import '../providers/video_player_provider.dart';
import '../../user_space/screens/user_space_screen.dart';

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
  @override
  void initState() {
    super.initState();
    
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部Bar
            _buildTopBar(),
            
            // 视频播放区域
            Expanded(
              child: _buildVideoPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
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
              // TODO: 实现搜索功能
              if (kIsWeb) {
                debugPrint('🔍 搜索按钮被点击');
              }
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
          onPageChanged: provider.onPageChanged,
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
