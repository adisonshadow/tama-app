import 'package:flutter/material.dart';
import 'package:video_view/video_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../../../shared/services/video_token_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final bool isActive;
  final VoidCallback? onTap; // 添加点击回调

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
    this.onTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _hasMarkedAsPlayed = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.video.id != widget.video.id) {
      _disposeController();
      _initializeVideo();
      _hasMarkedAsPlayed = false;
    }
    
    if (oldWidget.isActive != widget.isActive) {
      _handleActiveStateChange();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _initializeVideo() async {
    if (widget.video.videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    try {
      await _initializeVideoWithToken();
    } catch (e) {
      print('Video controller creation error: $e');
      setState(() {
        _hasError = true;
      });
    }
  }
  
  /// 使用token初始化视频播放器
  Future<void> _initializeVideoWithToken() async {
    final tokenManager = VideoTokenManager();
    
    // 获取带token的视频URL
    final videoUrlWithToken = await tokenManager.addTokenToUrl(widget.video.videoUrl);
    
    // 添加调试日志
    print('🔍 VideoPlayerWidget - Original URL: ${widget.video.videoUrl}');
    print('🔍 VideoPlayerWidget - URL with token: $videoUrlWithToken');
    
    try {
      _controller = VideoController();
      
      // 监听播放状态变化
      _controller!.playbackState.addListener(() {
        if (mounted) {
          final isPlaying = _controller!.playbackState.value == VideoControllerPlaybackState.playing;
          if (_isPlaying != isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
            
            // 检查是否开始播放
            if (!_hasMarkedAsPlayed && isPlaying) {
              _markVideoAsPlayed();
            }
          }
        }
      });
      
      // 加载视频
      print('🔍 VideoPlayerWidget - Opening video with controller...');
      _controller!.open(videoUrlWithToken);
      print('🔍 VideoPlayerWidget - Video opened successfully');
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        
        if (widget.isActive) {
          _controller!.play();
        }
      }
    } catch (e) {
      print('Video initialization error: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  void _markVideoAsPlayed() {
    if (!_hasMarkedAsPlayed) {
      _hasMarkedAsPlayed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final videoProvider = context.read<VideoProvider>();
          videoProvider.markVideoAsPlayed(widget.video.id);
        }
      });
    }
  }

  void _handleActiveStateChange() {
    if (_controller != null && _isInitialized) {
      if (widget.isActive) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  /// 外部调用的播放/暂停方法
  void togglePlayPause() {
    _togglePlayPause();
  }

  /// 外部调用的播放方法
  void play() {
    if (_controller != null && _isInitialized) {
      _controller!.play();
    }
  }

  /// 外部调用的暂停方法
  void pause() {
    if (_controller != null && _isInitialized) {
      _controller!.pause();
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
    _isPlaying = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || widget.video.videoUrl.isEmpty) {
      return _buildThumbnailView();
    }

    if (!_isInitialized || _controller == null) {
      return Stack(
        children: [
          _buildThumbnailView(),
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ],
      );
    }

    return Stack(
      children: [
        // 视频播放器
        Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: VideoView(
              controller: _controller!,
            ),
          ),
        ),
        // 播放/暂停按钮
        _buildPlayButton(),
        // 添加一个透明的点击区域来处理点击事件
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _togglePlayPause();
              widget.onTap?.call(); // 调用外部回调
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    if (_controller == null || (_controller != null && _isPlaying)) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildThumbnailView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: widget.video.thumbnailUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.video.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              errorWidget: (context, url, error) => _buildErrorWidget(),
            )
          : _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            widget.video.title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '视频暂时无法播放',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
