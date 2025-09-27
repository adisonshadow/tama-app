import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:ui';

import '../providers/video_provider.dart';
import '../widgets/video_feed_widget.dart';
import '../../../shared/widgets/search_manager.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/services/version_manager.dart';

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
    
    // 初始化时加载随机推荐文章
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().loadRandomArticles(refresh: true);
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
      final coverUrl = firstVideo.getCoverByRecord('w=90&h=160'); // 使用web项目中的默认尺寸
      // print('🔍 HomeScreen - 设置初始封面: $coverUrl'); // 添加调试信息
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
    // print('🔍 HomeScreen - 视频封面变化: $coverUrl'); // 添加调试信息
    setState(() {
      _currentVideoCoverUrl = coverUrl;
    });
  }

  /// 检查版本更新
  Future<void> _checkVersionUpdate() async {
    try {
      // 延迟检查，等待页面完全加载
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // 使用 try-catch 包装版本检查调用
        try {
          await VersionManager().checkVersionOnStartup(context);
        } catch (e) {
          print('启动时版本检查失败: $e');
          // 启动时版本检查失败不影响应用正常使用
        }
      }
    } catch (e) {
      print('版本检查延迟失败: $e');
    }
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
                  width: 26,
                  height: 26,
                ),
                // SizedBox(width: 8),
                // Consumer<LanguageProvider>(
                //   builder: (context, languageProvider, _) {
                //     return Text(
                //       FlutterI18n.translate(context, 'app.name'),
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontSize: 22,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
            
            // 右侧按钮
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    SearchManager.showSearch(context);
                  },
                  tooltip: FlutterI18n.translate(context, 'common.search.title'),
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
                            Colors.black.withValues(alpha: 0.27), // 添加半透明黑色遮罩
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
                    color: const Color.fromARGB(255, 1, 1, 1).withValues(alpha: 0.1), // 20%透明度的绿色
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
                return AppErrorWidget(
                  errorMessage: videoProvider.error!,
                  onRetry: () {
                    videoProvider.loadRandomArticles(refresh: true);
                  },
                );
              }

              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                header: Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    return WaterDropHeader(
                      waterDropColor: Colors.blue,
                      complete: Text(
                        FlutterI18n.translate(context, 'common.refresh.complete'),
                        style: const TextStyle(color: Colors.white)
                      ),
                      failed: Text(
                        FlutterI18n.translate(context, 'common.refresh.failed'),
                        style: const TextStyle(color: Colors.white)
                      ),
                    );
                  },
                ),
                footer: Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    return CustomFooter(
                      builder: (context, mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = Text(
                            FlutterI18n.translate(context, 'common.refresh.pull_to_load_more'),
                            style: const TextStyle(color: Colors.grey)
                          );
                        } else if (mode == LoadStatus.loading) {
                          body = const CircularProgressIndicator(color: Colors.blue);
                        } else if (mode == LoadStatus.failed) {
                          body = Text(
                            FlutterI18n.translate(context, 'common.refresh.load_failed_retry'),
                            style: const TextStyle(color: Colors.red)
                          );
                        } else if (mode == LoadStatus.canLoading) {
                          body = Text(
                            FlutterI18n.translate(context, 'common.refresh.release_to_load_more'),
                            style: const TextStyle(color: Colors.grey)
                          );
                        } else {
                          body = Text(
                            FlutterI18n.translate(context, 'common.refresh.no_more_content'),
                            style: const TextStyle(color: Colors.grey)
                          );
                        }
                        return SizedBox(
                          height: 55.0,
                          child: Center(child: body),
                        );
                      },
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
