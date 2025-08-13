import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:ui';

import '../providers/video_provider.dart';
import '../widgets/video_feed_widget.dart';
import '../../../shared/utils/error_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();
  String? _currentVideoCoverUrl;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('🔍 HomeScreen - initState 开始');
    print('🔍 HomeScreen - _currentVideoCoverUrl 初始值: $_currentVideoCoverUrl');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 HomeScreen - addPostFrameCallback 执行');
      context.read<VideoProvider>().loadRandomRecommendedVideos(refresh: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听视频列表变化，设置初始封面
    final videoProvider = context.read<VideoProvider>();
    if (videoProvider.videos.isNotEmpty && _currentVideoCoverUrl == null) {
      final firstVideo = videoProvider.videos.first;
      // 使用新的getCoverByRecord方法，支持resize参数
      final coverUrl = firstVideo.getCoverByRecord('w=360&h=202'); // 使用web项目中的默认尺寸
      print('🔍 HomeScreen - 设置初始封面: $coverUrl'); // 添加调试信息
      if (coverUrl.isNotEmpty) {
        setState(() {
          _currentVideoCoverUrl = coverUrl;
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<VideoProvider>().refreshVideos();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    if (!mounted) return;
    await context.read<VideoProvider>().loadMoreVideos();
    if (!mounted) return;
    final provider = context.read<VideoProvider>();
    if (provider.hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  void _onVideoChanged(String? coverUrl) {
    print('🔍 HomeScreen - 视频封面变化: $coverUrl'); // 添加调试信息
    setState(() {
      _currentVideoCoverUrl = coverUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, // 让body延伸到AppBar后面
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 透明背景
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            const Row(
              children: [
                Image(
                  image: AssetImage('assets/images/logo.png'),
                  width: 28,
                  height: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'TAMALOOK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // 右侧按钮
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // TODO: 实现搜索功能
                    ErrorUtils.showWarning(
                      context,
                      '搜索功能暂未开放',
                    );
                  },
                ),
                // Consumer<AuthProvider>(
                //   builder: (context, authProvider, child) {
                //     return PopupMenuButton<String>(
                //       icon: CircleAvatar(
                //         radius: 16,
                //         backgroundColor: Colors.grey[800],
                //         backgroundImage: authProvider.user?.avatar != null 
                //             ? NetworkImage(authProvider.user!.avatar!)
                //             : null,
                //         child: authProvider.user?.avatar == null 
                //             ? const Icon(Icons.person, color: Colors.white, size: 20)
                //             : null,
                //       ),
                //       onSelected: (value) async {
                //         if (value == 'logout') {
                //           await authProvider.logout();
                //         }
                //       },
                //       itemBuilder: (context) => const [
                //         PopupMenuItem(
                //           value: 'profile',
                //           child: Row(
                //             children: [
                //               Icon(Icons.person, color: Colors.grey),
                //               SizedBox(width: 8),
                //               Text('个人资料'),
                //             ],
                //           ),
                //         ),
                //         PopupMenuItem(
                //           value: 'settings',
                //           child: Row(
                //             children: [
                //               Icon(Icons.settings, color: Colors.grey),
                //               SizedBox(width: 8),
                //               Text('设置'),
                //             ],
                //           ),
                //         ),
                //         PopupMenuItem(
                //           value: 'logout',
                //           child: Row(
                //             children: [
                //               Icon(Icons.logout, color: Colors.red),
                //               SizedBox(width: 8),
                //               Text('退出登录', style: TextStyle(color: Colors.red)),
                //             ],
                //           ),
                //         ),
                //       ],
                //     );
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 第1层: 红色调试背景层 (最底层) - 已注释，保留以备将来使用
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: Container(
          //     width: double.infinity,
          //     height: double.infinity,
          //     color: Colors.red.withValues(alpha: 0.3), // 30%透明度的红色
          //   ),
          // ),
          
          // 模糊背景层 - 从屏幕顶部到tabbar（第二层）
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
                  // 半透明绿色调试层 - 用于观察模糊背景作用范围
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.green.withValues(alpha: 0.2), // 20%透明度的绿色
                  ),
                ],
              ),
            ),
          
          // 主内容区域（最上层，但确保不覆盖调试层）
          Consumer<VideoProvider>(
            builder: (context, videoProvider, child) {
              if (videoProvider.isLoading && videoProvider.videos.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              }

              if (videoProvider.error != null && videoProvider.videos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        videoProvider.error!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          videoProvider.loadRandomRecommendedVideos(refresh: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                header: const WaterDropHeader(
                  waterDropColor: Colors.blue,
                  complete: Text('刷新完成', style: TextStyle(color: Colors.white)),
                  failed: Text('刷新失败', style: TextStyle(color: Colors.white)),
                ),
                footer: CustomFooter(
                  builder: (context, mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = const Text('上拉加载更多', style: TextStyle(color: Colors.grey));
                            } else if (mode == LoadStatus.loading) {
                              body = const CircularProgressIndicator(color: Colors.blue);
                            } else if (mode == LoadStatus.failed) {
                              body = const Text('加载失败，点击重试', style: TextStyle(color: Colors.red));
                            } else if (mode == LoadStatus.canLoading) {
                              body = const Text('松开加载更多', style: TextStyle(color: Colors.grey));
                            } else {
                              body = const Text('没有更多内容了', style: TextStyle(color: Colors.grey));
                            }
                            return SizedBox(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                ),
                child: VideoFeedWidget(
                  videos: videoProvider.videos,
                  onVideoChanged: _onVideoChanged,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
