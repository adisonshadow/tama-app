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
  bool _isFullscreen = false; // 新增：全屏状态
  OverlayEntry? _fullscreenOverlay; // 新增：全屏覆盖层

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.video.id != widget.video.id) {
      // 打印当前选择视频的所有API data item信息
      print('🔍 当前选择视频的所有API data item信息:');
      print('🔍 Video ID: ${widget.video.id}');
      print('🔍 Video Title: ${widget.video.title}');
      print('🔍 Video Content: ${widget.video.content}');
      print('🔍 Video URL: ${widget.video.videoUrl}');
      print('🔍 Thumbnail URL: ${widget.video.thumbnailUrl}');
      print('🔍 User ID: ${widget.video.userId}');
      print('🔍 Nickname: ${widget.video.nickname}');
      print('🔍 Avatar: ${widget.video.avatar}');
      print('🔍 Video Hash: ${widget.video.videoHash}');
      print('🔍 Cover URL: ${widget.video.coverUrl}');
      print('🔍 Cover Type: ${widget.video.coverType}');
      print('🔍 View Count: ${widget.video.viewCount}');
      print('🔍 Liked Count: ${widget.video.likedCount}');
      print('🔍 Starred Count: ${widget.video.starredCount}');
      print('🔍 Is Short: ${widget.video.isShort}');
      print('🔍 Is Liked: ${widget.video.isLiked}');
      print('🔍 Is Starred: ${widget.video.isStarred}');
      print('🔍 Is Following: ${widget.video.isFollowing}');
      print('🔍 Created At: ${widget.video.createdAt}');
      print('🔍 Tags: ${widget.video.tags}');
      print('🔍 视频数据打印完成');
      
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
    // 清理全屏覆盖层
    if (_fullscreenOverlay != null) {
      _fullscreenOverlay!.remove();
      _fullscreenOverlay = null;
    }
    
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
    // print('🔍 VideoPlayerWidget - Original URL: ${widget.video.videoUrl}');
    // print('🔍 VideoPlayerWidget - URL with token: $videoUrlWithToken');
    
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
      // print('🔍 VideoPlayerWidget - Opening video with controller...');
      _controller!.open(videoUrlWithToken);
      // print('🔍 VideoPlayerWidget - Video opened successfully');
      
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

  /// 进入全屏模式
  void _enterFullscreen() {
    print('🔍 进入全屏模式');
    setState(() {
      _isFullscreen = true;
    });
    
    // 创建全屏覆盖层
    _fullscreenOverlay = OverlayEntry(
      builder: (context) => _buildFullscreenOverlay(),
    );
    
    // 显示全屏覆盖层
    Overlay.of(context).insert(_fullscreenOverlay!);
    
    print('🔍 全屏状态: $_isFullscreen');
  }

  /// 退出全屏模式
  void _exitFullscreen() {
    print('🔍 退出全屏模式');
    
    // 移除全屏覆盖层
    if (_fullscreenOverlay != null) {
      _fullscreenOverlay!.remove();
      _fullscreenOverlay = null;
    }
    
    setState(() {
      _isFullscreen = false;
    });
    print('🔍 全屏状态: $_isFullscreen');
  }

  /// 构建全屏覆盖层
  Widget _buildFullscreenOverlay() {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // 全屏视频播放器 - 旋转90度并填充整个屏幕
          Center(
            child: Transform.rotate(
              angle: 90 * 3.14159 / 180, // 90度转换为弧度
              child: SizedBox(
                // 确保视频完全填充屏幕，不留黑边
                width: MediaQuery.of(context).size.height * 1.2, // 增加宽度避免黑边
                height: MediaQuery.of(context).size.width * 1.2,  // 增加高度避免黑边
                child: VideoView(
                  controller: _controller!,
                ),
              ),
            ),
          ),
          // 全屏关闭按钮
          _buildFullscreenCloseButton(),
        ],
      ),
    );
  }

  /// 计算横屏视频全屏按钮的位置
  Widget _buildFullscreenButton() {
    // 如果是短视频(is_short = 1)，不显示全屏按钮
    if (widget.video.isShort == 1) {
      print('🔍 短视频，不显示全屏按钮');
      return const SizedBox.shrink();
    }

    print('🔍 横屏视频，显示全屏按钮');
    // 获取屏幕尺寸
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 计算16:9视频在当前屏幕下的实际尺寸
    final videoAspectRatio = 16.0 / 9.0;
    double videoWidth, videoHeight;
    
    if (screenWidth / screenHeight > videoAspectRatio) {
      // 屏幕更宽，以高度为准
      videoHeight = screenHeight;
      videoWidth = screenHeight * videoAspectRatio;
    } else {
      // 屏幕更高，以宽度为准
      videoWidth = screenWidth;
      videoHeight = screenWidth / videoAspectRatio;
    }

    // 计算视频在屏幕中的位置
    final videoLeft = (screenWidth - videoWidth) / 2;
    final videoTop = (screenHeight - videoHeight) / 2;

    // 全屏按钮位置：在横屏视频下方，居中
    final buttonLeft = videoLeft + (videoWidth - 60) / 2; // 按钮宽度60
    final buttonTop = videoTop + videoHeight + 20; // 视频底部下方20px

    print('🔍 全屏按钮位置计算:');
    print('🔍 屏幕尺寸: ${screenWidth}x${screenHeight}');
    print('🔍 视频尺寸: ${videoWidth.toStringAsFixed(1)}x${videoHeight.toStringAsFixed(1)}');
    print('🔍 视频位置: (${videoLeft.toStringAsFixed(1)}, ${videoTop.toStringAsFixed(1)})');
    print('🔍 按钮位置: (${buttonLeft.toStringAsFixed(1)}, ${buttonTop.toStringAsFixed(1)})');

    return Positioned(
      left: buttonLeft,
      top: buttonTop,
      child: GestureDetector(
        onTap: () {
          print('🔍 全屏按钮被点击');
          _enterFullscreen();
        },
        behavior: HitTestBehavior.opaque, // 确保点击事件能够正确响应
        child: Container(
          width: 88,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3), // 改为30%半透明黑色背景
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1), // 保持白色边框
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), // 减少上下空白，增加左右空白
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  '全屏',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建全屏模式下的关闭按钮
  Widget _buildFullscreenCloseButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: GestureDetector(
        onTap: _exitFullscreen,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 VideoPlayerWidget build - 全屏状态: $_isFullscreen, isShort: ${widget.video.isShort}');
    
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

    // 全屏模式 - 现在使用OverlayEntry，这里不再需要
    // if (_isFullscreen) {
    //   print('🔍 渲染全屏模式');
    //   return Scaffold(
    //     backgroundColor: Colors.black,
    //     body: Stack(
    //       children: [
    //         // 全屏视频播放器 - 旋转90度
    //         Center(
    //           child: Transform.rotate(
    //             angle: 90 * 3.14159 / 180, // 90度转换为弧度
    //             child: SizedBox(
    //               width: MediaQuery.of(context).size.height, // 使用屏幕高度作为宽度
    //               height: MediaQuery.of(context).size.width,  // 使用屏幕宽度作为高度
    //               child: VideoView(
    //                 controller: _controller!,
    //               ),
    //             ),
    //           ),
    //         ),
    //         // 全屏关闭按钮
    //         _buildFullscreenCloseButton(),
    //       ],
    //     ),
    //   );
    // }

    print('🔍 渲染普通模式');
    // 普通模式
    return Stack(
      children: [
        // 视频播放器
        GestureDetector(
          onTap: () {
            _togglePlayPause();
            widget.onTap?.call(); // 调用外部回调
          },
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.video.isShort == 1 ? 9 / 16 : 16 / 9, // 根据is_short判断比例
              child: VideoView(
                controller: _controller!,
              ),
            ),
          ),
        ),
        // 播放/暂停按钮
        _buildPlayButton(),
        // 全屏按钮（仅横屏视频显示，放在最上层）
        _buildFullscreenButton(),
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
