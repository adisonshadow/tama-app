import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';

import '../../../shared/widgets/follow_button.dart';
import '../models/video_model.dart';

class VideoActionButtons extends StatefulWidget {
  final VideoModel video;
  final VoidCallback onLike;
  final VoidCallback onStar;
  final VoidCallback onShare;
  final VoidCallback onComment;
  final VoidCallback? onAvatarTap; // 新增：头像点击回调

  const VideoActionButtons({
    super.key,
    required this.video,
    required this.onLike,
    required this.onStar,
    required this.onShare,
    required this.onComment,
    this.onAvatarTap, // 新增：头像点击回调
  });

  @override
  State<VideoActionButtons> createState() => _VideoActionButtonsState();
}

class _VideoActionButtonsState extends State<VideoActionButtons>
    with TickerProviderStateMixin {
  bool _isLiked = false;
  bool _isStarred = false;
  bool _isLiking = false;
  bool _isStarring = false;
  
  late AnimationController _likeAnimationController;
  late AnimationController _starAnimationController;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 初始化状态
    _isLiked = widget.video.isLiked ?? false;
    _isStarred = widget.video.isStarred ?? false;
    
    // 打印调试信息
    if (kIsWeb) {
      debugPrint('🔍 VideoActionButtons - Video ID: ${widget.video.id}');
      debugPrint('🔍 VideoActionButtons - Is Liked: ${widget.video.isLiked}');
      debugPrint('🔍 VideoActionButtons - Is Starred: ${widget.video.isStarred}');
      debugPrint('🔍 VideoActionButtons - Liked Count: ${widget.video.likedCount}');
      debugPrint('🔍 VideoActionButtons - Starred Count: ${widget.video.starredCount}');
    }
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _starAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 作者头像
        _buildAuthorAvatar(),
        
        const SizedBox(height: 15),
        
        // 点赞按钮
        _buildActionButton(
          icon: AnimatedBuilder(
            animation: _likeAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_likeAnimationController.value * 0.3),
                child: Icon(
                  Icons.favorite,
                  color: _isLiked ? Colors.red : Colors.white,
                  size: 38,
                ),
              );
            },
          ),
          count: _formatCount(widget.video.likedCount),
          onTap: _handleLike,
          isLoading: _isLiking,
        ),
        
        const SizedBox(height: 15),
        
        // 评论按钮
        _buildActionButton(
          icon: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 38,
          ),
          count: '评论',
          onTap: widget.onComment,
        ),
        
        const SizedBox(height: 15),
        
        // 收藏按钮
        _buildActionButton(
          icon: AnimatedBuilder(
            animation: _starAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_starAnimationController.value * 0.3),
                child: Icon(
                  Icons.star,
                  color: _isStarred ? Colors.yellow : Colors.white,
                  size: 38,
                ),
              );
            },
          ),
          count: _formatCount(widget.video.starredCount),
          onTap: _handleStar,
          isLoading: _isStarring,
        ),
        
        const SizedBox(height: 15),
        
        // 分享按钮
        _buildActionButton(
          icon: const Icon(
            Icons.share,
            color: Colors.white,
            size: 38,
          ),
          count: '分享',
          onTap: widget.onShare,
        ),

        const SizedBox(height: 15),
        
      ],
    );
  }

  Widget _buildAuthorAvatar() {
    return GestureDetector(
      onTap: widget.onAvatarTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        // 增加容器高度，让关注按钮能够完全显示
        height: 100, // 头像68 + 关注按钮26，减去重叠的13，所以需要 81 + 8 + 8 = 97
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 头像
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 31,
                backgroundColor: Colors.grey[800],
                backgroundImage: widget.video.avatar != null
                    ? CachedNetworkImageProvider('${AppConstants.baseUrl}/api/media/img/${widget.video.avatar}?w=68&h=68')
                    : null,
                child: widget.video.avatar == null
                    ? const Icon(Icons.person, color: Colors.white, size: 24)
                    : null,
              ),
            ),
            // 关注按钮 - 在头像下方，上半部分与头像重叠50%
            Positioned(
              bottom: 0,
              child: FollowButton(
                userId: widget.video.userId,
                mode: FollowButtonMode.icon, // 使用圆形图标模式
                width: 26,
                height: 26,
                fontSize: 10,
                onFollowChanged: () {
                  print('关注状态已改变: ${widget.video.nickname}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String count,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // 去掉圆形背景，直接显示图标
            isLoading
                ? const SpinKitPulse(
                    color: Colors.white,
                    size: 38,
                  )
                : icon,
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLike() async {
    if (_isLiking) return;
    
    setState(() {
      _isLiking = true;
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    }
    
    try {
      widget.onLike();
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  void _handleStar() async {
    if (_isStarring) return;
    
    setState(() {
      _isStarring = true;
      _isStarred = !_isStarred;
    });
    
    if (_isStarred) {
      _starAnimationController.forward().then((_) {
        _starAnimationController.reverse();
      });
    }
    
    try {
      widget.onStar();
    } finally {
      if (mounted) {
        setState(() {
          _isStarring = false;
        });
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
