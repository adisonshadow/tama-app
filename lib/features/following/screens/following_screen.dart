import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../providers/following_provider.dart';
import '../../home/widgets/video_feed_widget.dart';
import '../widgets/following_users_widget.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final RefreshController _refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final followingProvider = context.read<FollowingProvider>();
      followingProvider.loadFollowingVideos(refresh: true);
      followingProvider.loadMyFollows(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final followingProvider = context.read<FollowingProvider>();
    if (_tabController.index == 0) {
      await followingProvider.refreshFollowingVideos();
    } else {
      await followingProvider.refreshFollows();
    }
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    final followingProvider = context.read<FollowingProvider>();
    if (_tabController.index == 0) {
      await followingProvider.loadFollowingVideos(refresh: false);
    } else {
      await followingProvider.loadMyFollows(refresh: false);
    }
    
    if (followingProvider.hasMore) {
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
        title: const Text(
          '关注',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '作品'),
            Tab(text: '用户'),
          ],
          onTap: (index) {
            // 切换tab时重置刷新控制器
            _refreshController.resetNoData();
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 关注的用户作品
          _buildFollowingVideosTab(),
          // 关注的用户列表
          _buildFollowingUsersTab(),
        ],
      ),
    );
  }

  Widget _buildFollowingVideosTab() {
    return Consumer<FollowingProvider>(
      builder: (context, followingProvider, child) {
        if (followingProvider.isLoading && followingProvider.followingVideos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (followingProvider.error != null && followingProvider.followingVideos.isEmpty) {
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
                  followingProvider.error!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    followingProvider.loadFollowingVideos(refresh: true);
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

        if (followingProvider.followingVideos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无关注用户的作品',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '去关注一些有趣的用户吧',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
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
          child: VideoFeedWidget(videos: followingProvider.followingVideos),
        );
      },
    );
  }

  Widget _buildFollowingUsersTab() {
    return Consumer<FollowingProvider>(
      builder: (context, followingProvider, child) {
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
          child: FollowingUsersWidget(follows: followingProvider.follows),
        );
      },
    );
  }
}
