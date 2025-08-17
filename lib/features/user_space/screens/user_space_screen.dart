import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
// import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/video_card.dart';

import '../../../shared/widgets/follow_button.dart';
import '../providers/user_space_provider.dart';
import '../../video_player/screens/video_player_screen.dart';

class UserSpaceScreen extends StatefulWidget {
  final String userId;
  final String nickname;
  final String avatar;
  final String? bio;
  final String? spaceBg;

  const UserSpaceScreen({
    super.key,
    required this.userId,
    required this.nickname,
    required this.avatar,
    this.bio,
    this.spaceBg,
  });

  @override
  State<UserSpaceScreen> createState() => _UserSpaceScreenState();
}

class _UserSpaceScreenState extends State<UserSpaceScreen> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    
    // 添加调试信息
    // if (kIsWeb) {
    //   debugPrint('🔍 UserSpaceScreen initState');
    //   debugPrint('🔍 userId: ${widget.userId}');
    //   debugPrint('🔍 nickname: ${widget.nickname}');
    //   debugPrint('🔍 avatar: ${widget.avatar}');
    //   debugPrint('🔍 bio: ${widget.bio}');
    //   debugPrint('🔍 spaceBg: ${widget.spaceBg}');
    // }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserSpaceProvider(),
      child: Consumer<UserSpaceProvider>(
        builder: (context, userSpaceProvider, child) {
          // 初始化数据
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (userSpaceProvider.videos.isEmpty && !userSpaceProvider.isLoading) {
              userSpaceProvider.loadUserVideos(widget.userId, refresh: true);
            }
          });
          
          return Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              children: [
                // 行1: 用户信息头部（带背景图片）
                _buildUserHeader(),
                
                // 行2: 作品列表
                Expanded(
                  child: _buildVideosList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (widget.spaceBg != null && widget.spaceBg!.isNotEmpty) {
      return Image.network(
        '${AppConstants.baseUrl}/api/media/img/${widget.spaceBg}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('网络背景图片加载失败: $error，使用本地默认背景');
          return _buildLocalBackgroundImage();
        },
      );
    } else {
      return _buildLocalBackgroundImage();
    }
  }

  Widget _buildLocalBackgroundImage() {
    return Image.asset(
      'assets/images/space_bg.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('本地背景图片加载失败: $error，使用纯色背景');
        return Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(
              Icons.image,
              color: Colors.grey,
              size: 64,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHeader() {
    return Container(
      height: 240,
      padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
      child: Stack(
        children: [
          // 背景图片 - 只在这个容器内显示
          Positioned.fill(
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(16), // 添加圆角
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: _buildBackgroundImage(),
            ),
          ),
          
          // 返回按钮 - 提高层级，确保可点击
          Positioned(
            top: 20,
            left: 20,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  print('返回按钮被点击');
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          
          // 关注按钮 - 在返回按钮右侧
          Positioned(
            top: 20,
            right: 20,
            child: FollowButton(
              userId: widget.userId,
              mode: FollowButtonMode.button,
              width: 160,
              height: 40,
              // fontSize: 16,
              onFollowChanged: () {
                print('关注状态已改变');
              },
            ),
          ),
          
          // 用户信息 - 修复布局约束问题
          Positioned(
            bottom: 20,
            left: 20,
            right: 20, // 添加右边界，提供宽度约束
            child: Row(
              children: [
                // 用户头像
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: widget.avatar.isNotEmpty
                        ? Image.network(
                            '${AppConstants.baseUrl}/api/image/${widget.avatar}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ 头像加载失败: $error');
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // 用户昵称和bio - 使用Flexible而不是Expanded
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.nickname.isNotEmpty ? widget.nickname : FlutterI18n.translate(context, 'common.unknown_user'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.bio != null && widget.bio!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.bio!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          FlutterI18n.translate(context, 'user_space.lazy_user_bio'),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildVideosList() {
    return Consumer<UserSpaceProvider>(
      builder: (context, userSpaceProvider, child) {
        if (userSpaceProvider.isLoading && userSpaceProvider.videos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (userSpaceProvider.error != null && userSpaceProvider.videos.isEmpty) {
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
                  userSpaceProvider.error!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    userSpaceProvider.loadUserVideos(widget.userId, refresh: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(FlutterI18n.translate(context, 'common.retry')),
                ),
              ],
            ),
          );
        }

        if (userSpaceProvider.videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  FlutterI18n.translate(context, 'user_space.no_videos'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
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
            await userSpaceProvider.refreshUserVideos(widget.userId);
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            await userSpaceProvider.loadUserVideos(widget.userId, refresh: false);
            if (userSpaceProvider.hasMore) {
              _refreshController.loadComplete();
            } else {
              _refreshController.loadNoData();
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
          child: MasonryGridView.count(
            // 使用 MasonryGridView 实现瀑布流布局，每个网格项高度完全自适应
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2, // 固定2列
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            itemCount: userSpaceProvider.videos.length,
            itemBuilder: (context, index) {
              final video = userSpaceProvider.videos[index];
              return VideoCard(
                video: video,
                showUserInfo: false, // 不显示用户信息
                
                onTap: () {
                  // 跳转到视频播放页面
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        userId: widget.userId,
                        videos: userSpaceProvider.videos,
                        initialVideoIndex: index,
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
