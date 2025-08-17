import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../providers/following_provider.dart';
import '../../../shared/widgets/video_grid_widget.dart';
import '../../../shared/widgets/user_card.dart';
import '../../user_space/screens/user_space_screen.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final RefreshController _videosRefreshController = RefreshController();
  final RefreshController _usersRefreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // print('🔍 FollowingScreen - initState 被调用');
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print('🔍 FollowingScreen - addPostFrameCallback 被调用');
      final followingProvider = context.read<FollowingProvider>();
      // print('🔍 FollowingScreen - 获取到 FollowingProvider: ${followingProvider.runtimeType}');
      
      // 只加载当前激活tab的数据，避免loading状态冲突
      // print('🔍 FollowingScreen - 开始调用 loadFollowingVideos');
      followingProvider.loadFollowingVideos(refresh: true);
      
      // print('🔍 FollowingScreen - loadFollowingVideos 调用完成');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videosRefreshController.dispose();
    _usersRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // 直接在body顶部放置TabBar
          Container(
            color: Colors.black,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: [
                Tab(text: FlutterI18n.translate(context, 'following.tabs.videos')),
                Tab(text: FlutterI18n.translate(context, 'following.tabs.users')),
              ],
              onTap: (index) {
                // print('🔍 FollowingScreen - Tab切换到索引: $index');
                // 切换tab时重置刷新控制器
                _videosRefreshController.resetNoData();
                _usersRefreshController.resetNoData();
                
                // 如果切换到用户tab，加载用户数据
                if (index == 1) {
                  final followingProvider = context.read<FollowingProvider>();
                  // print('🔍 FollowingScreen - 切换到用户tab，开始加载用户数据');
                  followingProvider.loadMyFollows(refresh: true);
                }
              },
            ),
          ),
          
          // TabBarView内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 关注的用户作品
                _buildFollowingVideosTab(),
                // 关注的用户列表
                _buildFollowingUsersTab(),
              ],
            ),
          ),
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
                  child: Text(FlutterI18n.translate(context, 'following.retry')),
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
                  FlutterI18n.translate(context, 'following.no_videos'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FlutterI18n.translate(context, 'following.no_videos_subtitle'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // print('🔍 FollowingScreen - 准备构建VideoGridWidget');
        // print('🔍 FollowingScreen - 视频数量: ${followingProvider.followingVideos.length}');
        
        return VideoGridWidget(
          videos: followingProvider.followingVideos,
          refreshController: _videosRefreshController,
          onRefresh: () async {
            await followingProvider.refreshFollowingVideos();
            _videosRefreshController.refreshCompleted();
          },
          onLoading: () async {
            await followingProvider.loadFollowingVideos(refresh: false);
            if (followingProvider.hasMore) {
              _videosRefreshController.loadComplete();
            } else {
              _videosRefreshController.loadNoData();
            }
          },
          hasMore: followingProvider.hasMore,
          isLoading: followingProvider.isLoading,
          // 不传递onVideoTap，让VideoGridWidget使用默认的跳转行为
        );
      },
    );
  }

  Widget _buildFollowingUsersTab() {
    // print('🔍 FollowingScreen - _buildFollowingUsersTab 被调用');
    return Consumer<FollowingProvider>(
      builder: (context, followingProvider, child) {
        // print('🔍 FollowingScreen - Consumer builder 被调用，follows数量: ${followingProvider.follows.length}');
        // print('🔍 FollowingScreen - isLoading: ${followingProvider.isLoading}, error: ${followingProvider.error}');
        
        if (followingProvider.isLoading && followingProvider.follows.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (followingProvider.error != null && followingProvider.follows.isEmpty) {
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    followingProvider.loadMyFollows(refresh: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(FlutterI18n.translate(context, 'following.retry')),
                ),
              ],
            ),
          );
        }

        if (followingProvider.follows.isEmpty) {
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
                  FlutterI18n.translate(context, 'following.no_users'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FlutterI18n.translate(context, 'following.no_users_subtitle'),
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
          controller: _usersRefreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () async {
            await followingProvider.refreshFollows();
            _usersRefreshController.refreshCompleted();
          },
          onLoading: () async {
            await followingProvider.loadMyFollows(refresh: false);
            if (followingProvider.hasMore) {
              _usersRefreshController.loadComplete();
            } else {
              _usersRefreshController.loadNoData();
            }
          },
          header: WaterDropHeader(
            waterDropColor: Colors.blue,
            complete: Text(FlutterI18n.translate(context, 'common.refresh.complete'), style: const TextStyle(color: Colors.white)),
            failed: Text(FlutterI18n.translate(context, 'common.refresh.failed'), style: const TextStyle(color: Colors.white)),
          ),
          footer: CustomFooter(
            builder: (context, mode) {
              Widget body;
                          if (mode == LoadStatus.idle) {
              body = Text(FlutterI18n.translate(context, 'common.refresh.pull_to_load_more'), style: const TextStyle(color: Colors.grey));
            } else if (mode == LoadStatus.loading) {
              body = const CircularProgressIndicator(color: Colors.blue);
            } else if (mode == LoadStatus.failed) {
              body = Text(FlutterI18n.translate(context, 'common.refresh.load_failed_retry'), style: const TextStyle(color: Colors.red));
            } else if (mode == LoadStatus.canLoading) {
              body = Text(FlutterI18n.translate(context, 'common.refresh.release_to_load_more'), style: const TextStyle(color: Colors.grey));
            } else {
              body = Text(FlutterI18n.translate(context, 'common.refresh.no_more_content'), style: const TextStyle(color: Colors.grey));
            }
              return SizedBox(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          child: ListView.builder(
            itemCount: followingProvider.follows.length,
            itemBuilder: (context, index) {
              final follow = followingProvider.follows[index];
              return UserCard(
                userId: follow.id,
                nickname: follow.nickname,
                avatar: follow.avatar,
                bio: follow.bio,
                onFollowTap: () async {
                  // 处理关注状态变化
                  // print('🔍 FollowingScreen - 关注状态变化，用户ID: ${follow.id}');
                  // 可以在这里添加额外的逻辑，比如刷新列表等
                },
                onCardTap: () {
                  // 打印调试信息
                  // print('跳转到用户空间页面:');
                  // print('  userId: ${follow.id}');
                  // print('  nickname: ${follow.nickname}');
                  // print('  avatar: ${follow.avatar}');
                  // print('  bio: ${follow.bio}');
                  // print('  spaceBg: ${follow.spaceBg}');
                  
                  // 跳转到用户空间页面
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserSpaceScreen(
                        userId: follow.id,
                        nickname: follow.nickname,
                        avatar: follow.avatar ?? 'default_avatar.png', // 提供默认头像
                        bio: follow.bio,
                        spaceBg: follow.spaceBg ?? '', // 使用实际的spaceBg
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
