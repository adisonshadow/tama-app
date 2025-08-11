import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../providers/video_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/video_feed_widget.dart';
import '../../../shared/utils/error_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().loadRandomRecommendedVideos(refresh: true);
    });
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            const Row(
              children: [
                Icon(
                  Icons.video_collection,
                  color: Colors.blue,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Tama2',
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
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return PopupMenuButton<String>(
                      icon: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: authProvider.user?.avatar != null 
                            ? NetworkImage(authProvider.user!.avatar!)
                            : null,
                        child: authProvider.user?.avatar == null 
                            ? const Icon(Icons.person, color: Colors.white, size: 20)
                            : null,
                      ),
                      onSelected: (value) async {
                        if (value == 'logout') {
                          await authProvider.logout();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('个人资料'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('设置'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 8),
                              Text('退出登录', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),

      ),
      body: Consumer<VideoProvider>(
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
            child: VideoFeedWidget(videos: videoProvider.videos),
          );
        },
      ),
    );
  }
}
