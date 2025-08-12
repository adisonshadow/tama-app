import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/video_model.dart';
import '../providers/video_provider.dart';
import 'video_player_widget.dart';
import 'video_action_buttons.dart';
import '../../../shared/utils/error_utils.dart';

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
  bool _showInfo = true;

  @override
  void initState() {
    super.initState();
    
    // 打印调试信息
    if (kIsWeb) {
      debugPrint('🔍 Video Item Widget - Video ID: ${widget.video.id}');
      debugPrint('🔍 Video Item Widget - Avatar: ${widget.video.avatar}');
      if (widget.video.avatar != null) {
        final avatarUrl = 'http://localhost:5200/api/media/img/${widget.video.avatar}';
        debugPrint('🔍 Video Item Widget - Full Avatar URL: $avatarUrl');
      }
    }
  }

  void _toggleInfo() {
    setState(() {
      _showInfo = !_showInfo;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // 改为透明背景，让模糊背景层显示
      child: Stack(
        children: [
          // 视频播放器
          Positioned.fill(
            child: VideoPlayerWidget(
              video: widget.video,
              isActive: widget.isActive,
              onTap: _toggleInfo, // 传递回调函数
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
                    // decoration: BoxDecoration(
                    //   gradient: LinearGradient(
                    //     begin: Alignment.topCenter,
                    //     end: Alignment.bottomCenter,
                    //     colors: [
                    //       Colors.transparent,
                    //       Colors.black.withValues(alpha: 0.7),
                    //       Colors.black.withValues(alpha: 0.9),
                    //     ],
                    //     stops: const [0.0, 0.5, 1.0],
                    //   ),
                    // ),
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
              onShare: _handleShare,
              onComment: _handleComment,
            ),
          ),
        ],
      ),
    );
  }

  void _showContentOffcanvas() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildContentOffcanvas(),
    );
  }

  Widget _buildContentOffcanvas() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.video.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const Divider(height: 1),
          
          // 内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 内容描述
                  if (widget.video.content.isNotEmpty) ...[
                    const Text(
                      '内容描述',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.video.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // 标签
                  if (widget.video.tagList.isNotEmpty) ...[
                    const Text(
                      '标签',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.video.tagList.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare() {
    // TODO: 实现分享功能
    ErrorUtils.showWarning(
      context,
      '分享功能暂未实现',
    );
  }

  void _handleComment() {
    // TODO: 实现评论功能
    ErrorUtils.showWarning(
      context,
      '评论功能暂未实现',
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
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
      return dateTimeStr;
    }
  }
}
