import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:video_view/video_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'dart:io' show Platform;

import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../../../shared/services/video_token_manager.dart';
import '../../../shared/services/android_video_player_service.dart';

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
  VlcPlayerController? _vlcController;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _hasMarkedAsPlayed = false;
  bool _isPlaying = false;
  bool _useAndroidPlayer = false; // 是否使用Android原生播放器
  bool _useVlcPlayer = false; // 是否使用VLC播放器
  final AndroidVideoPlayerService _androidPlayerService = AndroidVideoPlayerService();

  OverlayEntry? _fullscreenOverlay; // 全屏覆盖层

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
      // print('🔍 当前选择视频的所有API data item信息:');
      // print('🔍 Video ID: ${widget.video.id}');
      // print('🔍 Video Title: ${widget.video.title}');
      // print('🔍 Video Content: ${widget.video.content}');
      // print('🔍 Video URL: ${widget.video.videoUrl}');
      // print('🔍 Thumbnail URL: ${widget.video.thumbnailUrl}');
      // print('🔍 User ID: ${widget.video.userId}');
      // print('🔍 Nickname: ${widget.video.nickname}');
      // print('🔍 Avatar: ${widget.video.avatar}');
      // print('🔍 Video Hash: ${widget.video.videoHash}');
      // print('🔍 Cover URL: ${widget.video.coverUrl}');
      // print('🔍 Cover Type: ${widget.video.coverType}');
      // print('🔍 View Count: ${widget.video.viewCount}');
      // print('🔍 Liked Count: ${widget.video.likedCount}');
      // print('🔍 Starred Count: ${widget.video.starredCount}');
      // print('🔍 Is Short: ${widget.video.isShort}');
      // print('🔍 Is Liked: ${widget.video.isLiked}');
      // print('🔍 Is Starred: ${widget.video.isStarred}');
      // print('🔍 Is Following: ${widget.video.isFollowing}');
      // print('🔍 Created At: ${widget.video.createdAt}');
      // print('🔍 Tags: ${widget.video.tags}');
      // print('🔍 视频数据打印完成');
      
      // 安全地释放之前的播放器
      _safeDisposeController();
      _initializeVideo();
      _hasMarkedAsPlayed = false;
    }
    
    if (oldWidget.isActive != widget.isActive) {
      _handleActiveStateChange();
    }
  }
  
  /// 安全地释放播放器控制器
  void _safeDisposeController() {
    try {
      // 先暂停播放
      if (_useVlcPlayer && _vlcController != null) {
        try {
          _vlcController!.pause();
        } catch (e) {
          print('Error pausing VLC controller: $e');
        }
      }
      
      // 等待一小段时间让OpenGL上下文稳定
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _disposeController();
        }
      });
    } catch (e) {
      print('Error in safe dispose: $e');
      // 如果出错，强制清理
      _disposeController();
    }
  }

  @override
  void dispose() {
    // 先退出全屏模式
    if (_fullscreenOverlay != null) {
      try {
        _fullscreenOverlay!.remove();
      } catch (e) {
        print('Error removing fullscreen overlay: $e');
      }
      _fullscreenOverlay = null;
    }
    
    // 安全地释放播放器
    _safeDisposeController();
    
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
    
    // 检查是否是m3u8视频（video hash没有.mp4/.ogg等后缀）
    final isM3u8Video = !widget.video.videoHash!.contains('.') || 
                        !['.mp4', '.ogg', '.avi', '.mov', '.mkv', '.wmv', '.flv'].any(
                          (ext) => widget.video.videoHash!.toLowerCase().endsWith(ext)
                        );
    
    if (isM3u8Video) {
      // 对于m3u8视频，优先尝试VLC播放器
      try {
        await _initializeVlcPlayer(videoUrlWithToken);
        return;
      } catch (e) {
        print('VLC player failed for m3u8 video, trying other options: $e');
      }
    }
    
    try {
      // 首先尝试使用Flutter视频播放器
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
          _useAndroidPlayer = false;
          _useVlcPlayer = false;
        });
        
        if (widget.isActive) {
          _controller!.play();
        }
      }
    } catch (e) {
      print('Flutter video player failed, trying Android native player: $e');
      
      // 如果Flutter播放器失败，尝试使用Android原生播放器
      if (Platform.isAndroid) {
        try {
          await _initializeAndroidPlayer(videoUrlWithToken);
        } catch (androidError) {
          print('Android native player also failed: $androidError');
          
          // 如果Android播放器也失败，最后尝试VLC播放器
          try {
            await _initializeVlcPlayer(videoUrlWithToken);
          } catch (vlcError) {
            print('All video players failed: $vlcError');
            setState(() {
              _hasError = true;
            });
          }
        }
      } else {
        setState(() {
          _hasError = true;
        });
      }
    }
  }
  
  /// 初始化Android原生视频播放器
  Future<void> _initializeAndroidPlayer(String videoUrl) async {
    try {
      // 初始化Android播放器
      final success = await _androidPlayerService.initializePlayer();
      if (success) {
        // 检查是否有软件解码器可用
        final hasSoftwareDecoder = await _androidPlayerService.hasSoftwareDecoder();
        print('Android player initialized, software decoder available: $hasSoftwareDecoder');
        
        setState(() {
          _isInitialized = true;
          _hasError = false;
          _useAndroidPlayer = true;
        });
        
        if (widget.isActive) {
          await _androidPlayerService.playVideo(videoUrl);
        }
      } else {
        throw Exception('Failed to initialize Android player');
      }
    } catch (e) {
      print('Android player initialization error: $e');
      throw e;
    }
  }

  /// 初始化VLC播放器
  Future<void> _initializeVlcPlayer(String videoUrl) async {
    try {
      // 先释放之前的VLC控制器
      if (_vlcController != null) {
        try {
          _vlcController!.dispose();
        } catch (e) {
          print('Error disposing previous VLC controller: $e');
        }
        _vlcController = null;
      }
      
      _vlcController = VlcPlayerController.network(
        videoUrl,
        hwAcc: HwAcc.full, // 启用硬件加速
        autoPlay: widget.isActive,
      );
      
      // 监听播放状态
      _vlcController!.addListener(() {
        if (mounted) {
          try {
            final isPlaying = _vlcController!.value.isPlaying;
            if (_isPlaying != isPlaying) {
              setState(() {
                _isPlaying = isPlaying;
              });
              
              // 检查是否开始播放
              if (!_hasMarkedAsPlayed && isPlaying) {
                _markVideoAsPlayed();
              }
            }
          } catch (e) {
            print('Error in VLC listener: $e');
          }
        }
      });
      
      setState(() {
        _isInitialized = true;
        _hasError = false;
        _useAndroidPlayer = false;
        _useVlcPlayer = true;
      });
      
      print('VLC player initialized successfully for m3u8 video');
      
    } catch (e) {
      print('VLC player initialization error: $e');
      throw e;
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
    if (_useVlcPlayer) {
      // VLC播放器的状态管理
      if (widget.isActive) {
        _vlcController?.play();
      } else {
        _vlcController?.pause();
      }
    } else if (_useAndroidPlayer) {
      // Android播放器的状态管理
      if (widget.isActive) {
        _androidPlayerService.playVideo(widget.video.videoUrl);
      } else {
        _androidPlayerService.pauseVideo();
      }
    } else if (_controller != null && _isInitialized) {
      // Flutter播放器的状态管理
      if (widget.isActive) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  void _togglePlayPause() {
    if (_useVlcPlayer) {
      // VLC播放器的播放/暂停切换
      if (_isPlaying) {
        _vlcController?.pause();
      } else {
        _vlcController?.play();
      }
    } else if (_useAndroidPlayer) {
      // Android播放器的播放/暂停切换
      if (_isPlaying) {
        _androidPlayerService.pauseVideo();
      } else {
        _androidPlayerService.playVideo(widget.video.videoUrl);
      }
    } else if (_controller != null && _isInitialized) {
      // Flutter播放器的播放/暂停切换
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
    if (_useVlcPlayer) {
      _vlcController?.play();
    } else if (_useAndroidPlayer) {
      _androidPlayerService.playVideo(widget.video.videoUrl);
    } else if (_controller != null && _isInitialized) {
      _controller!.play();
    }
  }

  /// 外部调用的暂停方法
  void pause() {
    if (_useVlcPlayer) {
      _vlcController?.pause();
    } else if (_useAndroidPlayer) {
      _androidPlayerService.pauseVideo();
    } else if (_controller != null && _isInitialized) {
      _controller!.pause();
    }
  }

  void _disposeController() {
    if (_useVlcPlayer) {
      try {
        if (_vlcController != null) {
          _vlcController!.dispose();
          _vlcController = null;
        }
      } catch (e) {
        print('Error disposing VLC controller: $e');
        _vlcController = null;
      }
    } else if (_useAndroidPlayer) {
      _androidPlayerService.disposePlayer();
    } else {
      _controller?.dispose();
    }
    _controller = null;
    _isInitialized = false;
    _hasError = false;
    _isPlaying = false;
    _useAndroidPlayer = false;
    _useVlcPlayer = false;
  }

  /// 进入全屏模式
  void _enterFullscreen() {
    // print('🔍 进入全屏模式');
    setState(() {
      // 全屏状态已通过 OverlayEntry 管理
    });
    
    // 创建全屏覆盖层
    _fullscreenOverlay = OverlayEntry(
      builder: (context) => _buildFullscreenOverlay(),
    );
    
    // 显示全屏覆盖层
    Overlay.of(context).insert(_fullscreenOverlay!);
  }

  /// 退出全屏模式
  void _exitFullscreen() {
    // print('�� 退出全屏模式');
    
    try {
      // 移除全屏覆盖层
      if (_fullscreenOverlay != null) {
        _fullscreenOverlay!.remove();
        _fullscreenOverlay = null;
      }
      
      // 强制重建UI
      if (mounted) {
        setState(() {
          // 确保UI状态正确更新
        });
      }
    } catch (e) {
      print('Error exiting fullscreen: $e');
      // 如果移除失败，强制清理
      _fullscreenOverlay = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 构建全屏覆盖层
  Widget _buildFullscreenOverlay() {
    return Material(
      color: Colors.black,
      child: WillPopScope(
        onWillPop: () async {
          _exitFullscreen();
          return false; // 阻止默认的返回行为
        },
        child: Stack(
          children: [
            // 全屏视频播放器 - 90度旋转
            Center(
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90度转换为弧度
                child: SizedBox(
                  // 确保视频完全填充屏幕，不留黑边
                  width: MediaQuery.of(context).size.height * 1.2, // 增加宽度避免黑边
                  height: MediaQuery.of(context).size.width * 1.2,  // 增加高度避免黑边
                  child: _useVlcPlayer
                      ? _buildVlcFullscreenPlayer()
                      : _useAndroidPlayer
                          ? _buildAndroidFullscreenPlayer()
                          : VideoView(
                              controller: _controller!,
                            ),
                ),
              ),
            ),
            // 全屏关闭按钮
            _buildFullscreenCloseButton(),
          ],
        ),
      ),
    );
  }
  
  /// 构建VLC播放器的全屏界面
  Widget _buildVlcFullscreenPlayer() {
    return VlcPlayer(
      controller: _vlcController!,
      aspectRatio: 16 / 9, // 全屏时使用16:9比例
    );
  }
  
  /// 构建Android播放器的全屏界面
  Widget _buildAndroidFullscreenPlayer() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'Android Native Player - Fullscreen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 计算横屏视频全屏按钮的位置
  Widget _buildFullscreenButton() {
    // 如果是短视频(is_short = 1)，不显示全屏按钮
    if (widget.video.isShort == 1) {
      // print('🔍 短视频，不显示全屏按钮');
      return const SizedBox.shrink();
    }

    // print('🔍 横屏视频，显示全屏按钮');
    // 获取屏幕尺寸
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 计算16:9视频在当前屏幕下的实际尺寸
    const videoAspectRatio = 16.0 / 9.0;
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
    final buttonLeft = videoLeft + (videoWidth - 120) / 2; // 按按钮宽度 计算
    final buttonTop = videoTop + videoHeight + 20; // 视频底部下方20px

    // print('🔍 全屏按钮位置计算:');
    // print('🔍 屏幕尺寸: $screenWidth x $screenHeight');
    // print('🔍 视频尺寸: ${videoWidth.toStringAsFixed(1)} x ${videoHeight.toStringAsFixed(1)}');
    // print('🔍 视频位置: (${videoLeft.toStringAsFixed(1)}, ${videoTop.toStringAsFixed(1)})');
    // print('🔍 按钮位置: (${buttonLeft.toStringAsFixed(1)}, ${buttonTop.toStringAsFixed(1)})');

    return Positioned(
      left: buttonLeft,
      top: buttonTop,
      child: GestureDetector(
        onTap: () {
          // print('🔍 全屏按钮被点击');
          _enterFullscreen();
        },
        behavior: HitTestBehavior.opaque, // 确保点击事件能够正确响应
        child: Container(
          width: 120,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3), // 改为30%半透明黑色背景
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1), // 保持白色边框
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // 减少上下空白，增加左右空白
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  FlutterI18n.translate(context, 'home.player.fullscreen'),
                  style: const TextStyle(
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
        onTap: () {
          print('🔍 全屏关闭按钮被点击');
          _exitFullscreen();
        },
        behavior: HitTestBehavior.opaque,
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
    if (_hasError || widget.video.videoUrl.isEmpty) {
      return _buildThumbnailView();
    }

    if (!_isInitialized) {
      return Stack(
        children: [
          _buildThumbnailView(),
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ],
      );
    }

    // 根据播放器类型选择不同的UI
    if (_useVlcPlayer) {
      return _buildVlcPlayerUI();
    } else if (_useAndroidPlayer) {
      return _buildAndroidPlayerUI();
    } else {
      return _buildFlutterPlayerUI();
    }
  }
  
  /// 构建VLC播放器的UI
  Widget _buildVlcPlayerUI() {
    // 安全检查VLC控制器
    if (_vlcController == null) {
      return _buildThumbnailView();
    }
    
    return Stack(
      children: [
        // VLC播放器
        GestureDetector(
          onTap: () {
            _togglePlayPause();
            widget.onTap?.call();
          },
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.video.isShort == 1 ? 9 / 16 : 16 / 9,
              child: VlcPlayer(
                controller: _vlcController!,
                aspectRatio: widget.video.isShort == 1 ? 9 / 16 : 16 / 9,
              ),
            ),
          ),
        ),
        // 加载指示器
        if (!_isPlaying && _isInitialized)
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
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
  
  /// 构建Android播放器的UI
  Widget _buildAndroidPlayerUI() {
    return Stack(
      children: [
        // Android播放器容器
        GestureDetector(
          onTap: () {
            _togglePlayPause();
            widget.onTap?.call();
          },
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.video.isShort == 1 ? 9 / 16 : 16 / 9,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 60,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Android Native Player',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 加载指示器
        if (!_isPlaying && _isInitialized)
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
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
  
  /// 构建Flutter播放器的UI
  Widget _buildFlutterPlayerUI() {
    if (_controller == null) {
      return _buildThumbnailView();
    }
    
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
        // 加载指示器
        if (!_isPlaying && _isInitialized)
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
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
    // 检查是否应该显示播放按钮
    bool shouldShowPlayButton = false;
    
    if (_useAndroidPlayer) {
      // Android播放器：当没有播放时显示播放按钮
      shouldShowPlayButton = !_isPlaying;
    } else if (_controller != null) {
      // Flutter播放器：当没有播放时显示播放按钮
      shouldShowPlayButton = !_isPlaying;
    }
    
    if (!shouldShowPlayButton) {
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
            FlutterI18n.translate(context, 'home.player.video_unavailable'),
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
