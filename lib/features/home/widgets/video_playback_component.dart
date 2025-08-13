// 视频播放组件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';

import '../../../core/constants/app_constants.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../screens/tag_videos_screen.dart';
import 'video_player_widget.dart';
import 'video_action_buttons.dart';
import 'comment_sheet.dart';

class VideoPlaybackComponent extends StatefulWidget {
  final VideoModel video;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap; // 新增：头像点击回调

  const VideoPlaybackComponent({
    super.key,
    required this.video,
    required this.isActive,
    this.onTap,
    this.onAvatarTap, // 新增：头像点击回调
  });

  @override
  State<VideoPlaybackComponent> createState() => _VideoPlaybackComponentState();
}

class _VideoPlaybackComponentState extends State<VideoPlaybackComponent> {
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    
    // 打印调试信息
    if (kIsWeb) {
      debugPrint('🔍 Video Playback Component - Video ID: ${widget.video.id}');
      debugPrint('🔍 Video Playback Component - Avatar: ${widget.video.avatar}');
      if (widget.video.avatar != null) {
        final avatarUrl = '${AppConstants.baseUrl}/api/media/img/${widget.video.avatar}';
        debugPrint('🔍 Video Playback Component - Full Avatar URL: $avatarUrl');
      }
    }
  }

  void _toggleInfo() {
    setState(() {
      _showInfo = !_showInfo;
    });
  }

  void _showContentOffcanvas() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildContentOffcanvas(),
    );
  }

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CommentSheet(
        videoId: widget.video.id,
        currentTime: 0.0, // TODO: 获取当前视频播放时间
      ),
    );
  }

  Widget _buildContentOffcanvas() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          margin: const EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 标签
                      if (widget.video.tags != null && widget.video.tags!.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.video.tagList.map((tag) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TagVideosScreen(tagName: tag),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // 描述
                      if (widget.video.content.isNotEmpty) ...[
                        Text(
                          '描述',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.video.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 视频播放器
          Positioned.fill(
            child: VideoPlayerWidget(
              video: widget.video,
              isActive: widget.isActive,
              onTap: _toggleInfo,
            ),
          ),

          // 底部信息区域
          if (_showInfo)
            Positioned(
              left: 5,
              right: 100,
              bottom: 20,
              child: GestureDetector(
                onTap: _showContentOffcanvas,
                child: AnimatedOpacity(
                  opacity: _showInfo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 第一行：作者名和时间
                        Row(
                          children: [
                            Text(
                              '@${widget.video.nickname ?? '未知用户'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _formatTime(widget.video.createdAt),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 第二行：视频描述（标题+标签）
                        RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              // 视频标题
                              TextSpan(
                                text: widget.video.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // 标签
                              if (widget.video.tagList.isNotEmpty) ...[
                                const TextSpan(text: ' '),
                                ...widget.video.tagList.map((tag) => TextSpan(
                                  text: '#$tag ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 右侧操作按钮
          Positioned(
            right: 10,
            bottom: 20,
            child: VideoActionButtons(
              video: widget.video,
              onLike: () async {
                final result = await context.read<VideoProvider>().likeVideo(widget.video.id);
                if (result) {
                  setState(() {});
                }
              },
              onStar: () async {
                final result = await context.read<VideoProvider>().starVideo(widget.video.id);
                if (result) {
                  setState(() {});
                }
              },
              onShare: () {
                // TODO: 实现分享功能
                if (kIsWeb) {
                  debugPrint('🔍 分享按钮被点击');
                }
              },
              onComment: () {
                _showCommentSheet();
              },
              onAvatarTap: widget.onAvatarTap,
            ),
          ),
        ],
      ),
    );
  }
}
