import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// import '../../../core/constants/app_constants.dart';
import '../models/video_model.dart';
import 'video_playback_component.dart';
import '../../user_space/screens/user_space_screen.dart';

class VideoItemWidget extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoItemWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<VideoItemWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget> {
  @override
  void initState() {
    super.initState();
    
    // 打印调试信息
    if (kIsWeb) {
      // debugPrint('🔍 Video Item Widget - Video ID: ${widget.video.id}');
      // debugPrint('🔍 Video Item Widget - Avatar: ${widget.video.avatar}');
      if (widget.video.avatar != null) {
        // final avatarUrl = '${AppConstants.baseUrl}/api/media/img/${widget.video.avatar}';
        // debugPrint('🔍 Video Item Widget - Full Avatar URL: $avatarUrl');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: VideoPlaybackComponent(
        video: widget.video,
        isActive: widget.isActive,
        onTap: null,
        onAvatarTap: () {
          // 头像点击后跳转到用户Space
          if (kIsWeb) {
            debugPrint('🔍 头像被点击，准备跳转到用户Space: ${widget.video.userId}');
          }
          _navigateToUserSpace(widget.video);
        },
      ),
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
