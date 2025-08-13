import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
    print('🔍 FollowingScreen - initState 被调用');
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 FollowingScreen - addPostFrameCallback 被调用');
      final followingProvider = context.read<FollowingProvider>();
      print('🔍 FollowingScreen - 获取到 FollowingProvider: ${followingProvider.runtimeType}');
      
      // 只加载当前激活tab的数据，避免loading状态冲突
      print('🔍 FollowingScreen - 开始调用 loadFollowingVideos');
      followingProvider.loadFollowingVideos(refresh: true);
      
      print('🔍 FollowingScreen - loadFollowingVideos 调用完成');
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
              tabs: const [
                Tab(text: '作品'),
                Tab(text: '用户'),
              ],
              onTap: (index) {
                print('🔍 FollowingScreen - Tab切换到索引: $index');
                // 切换tab时重置刷新控制器
                _videosRefreshController.resetNoData();
                _usersRefreshController.resetNoData();
                
                // 如果切换到用户tab，加载用户数据
                if (index == 1) {
                  final followingProvider = context.read<FollowingProvider>();
                  print('🔍 FollowingScreen - 切换到用户tab，开始加载用户数据');
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
          onVideoTap: (video) {
            // TODO: 处理视频点击，跳转到视频播放页面
            // print('点击视频: ${video.title}');
          },
        );
      },
    );
  }

  Widget _buildFollowingUsersTab() {
    print('🔍 FollowingScreen - _buildFollowingUsersTab 被调用');
    return Consumer<FollowingProvider>(
      builder: (context, followingProvider, child) {
        print('🔍 FollowingScreen - Consumer builder 被调用，follows数量: ${followingProvider.follows.length}');
        print('🔍 FollowingScreen - isLoading: ${followingProvider.isLoading}, error: ${followingProvider.error}');
        
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
                  child: const Text('重试'),
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
                  '暂无关注的用户',
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
          header: const WaterDropHeader(
            waterDropColor: Colors.blue,
            complete: Text('刷新完成', style: TextStyle(color: Colors.white)),
            failed: Text('刷新失败', style: TextStyle(color: Colors.white)),
          ),
          footer: CustomFooter(
            builder: (context, mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = const Text('继续上拉加载更多', style: TextStyle(color: Colors.grey));
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
          child: ListView.builder(
            itemCount: followingProvider.follows.length,
            itemBuilder: (context, index) {
              final follow = followingProvider.follows[index];
              return UserCard(
                userId: follow.id,
                nickname: follow.nickname,
                avatar: follow.avatar,
                bio: follow.bio,
                isFollowing: true, // 在关注列表中，默认都是已关注状态
                onFollowTap: () async {
                  // 处理取消关注
                  await followingProvider.unfollowUser(follow.id);
                },
                onCardTap: () {
                  // 打印调试信息
                  print('跳转到用户空间页面:');
                  print('  userId: ${follow.id}');
                  print('  nickname: ${follow.nickname}');
                  print('  avatar: ${follow.avatar}');
                  print('  bio: ${follow.bio}');
                  print('  spaceBg: ${follow.spaceBg}');
                  
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
