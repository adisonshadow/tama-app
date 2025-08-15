import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../providers/fan_provider.dart';
import '../../../shared/widgets/user_card.dart';
import '../../user_space/screens/user_space_screen.dart';

class FansScreen extends StatefulWidget {
  const FansScreen({super.key});

  @override
  State<FansScreen> createState() => _FansScreenState();
}

class _FansScreenState extends State<FansScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // print('🔍 FansScreen - initState 被调用');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print('🔍 FansScreen - addPostFrameCallback 被调用');
      final fanProvider = context.read<FanProvider>();
      // print('🔍 FansScreen - 获取到 FanProvider: ${fanProvider.runtimeType}');
      
      // print('🔍 FansScreen - 开始调用 loadMyFollowers');
      fanProvider.loadMyFollowers(refresh: true);
      
      // print('🔍 FansScreen - loadMyFollowers 调用完成');
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<FanProvider>(
      builder: (context, fanProvider, child) {
        // print('🔍 FansScreen - Consumer builder 被调用，fans数量: ${fanProvider.fans.length}');
        // print('🔍 FansScreen - isLoading: ${fanProvider.isLoading}, error: ${fanProvider.error}');
        
        if (fanProvider.isLoading && fanProvider.fans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (fanProvider.error != null && fanProvider.fans.isEmpty) {
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
                  fanProvider.error!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    fanProvider.loadMyFollowers(refresh: true);
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

        if (fanProvider.fans.isEmpty) {
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
                  '暂无粉丝',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '发布更多有趣的内容来吸引粉丝吧',
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
          onRefresh: () async {
            await fanProvider.refreshFans();
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            await fanProvider.loadMyFollowers(refresh: false);
            if (fanProvider.hasMore) {
              _refreshController.loadComplete();
            } else {
              _refreshController.loadNoData();
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
            itemCount: fanProvider.fans.length,
            itemBuilder: (context, index) {
              final fan = fanProvider.fans[index];
              return UserCard(
                userId: fan.id,
                nickname: fan.nickname,
                avatar: fan.avatar,
                bio: fan.bio,
                onFollowTap: () async {
                  // 处理关注状态变化
                  print('🔍 FansScreen - 关注状态变化，用户ID: ${fan.id}');
                  // 可以在这里添加额外的逻辑，比如刷新列表等
                },
                onCardTap: () {
                  // 打印调试信息
                  print('跳转到用户空间页面:');
                  print('  userId: ${fan.id}');
                  print('  nickname: ${fan.nickname}');
                  print('  avatar: ${fan.avatar}');
                  print('  bio: ${fan.bio}');
                  print('  spaceBg: ${fan.spaceBg}');
                  
                  // 跳转到用户空间页面
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserSpaceScreen(
                        userId: fan.id,
                        nickname: fan.nickname,
                        avatar: fan.avatar ?? 'default_avatar.png', // 提供默认头像
                        bio: fan.bio,
                        spaceBg: fan.spaceBg ?? '', // 使用实际的spaceBg
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
