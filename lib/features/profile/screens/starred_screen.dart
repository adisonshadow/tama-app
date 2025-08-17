import 'package:flutter/material.dart';
// import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../providers/starred_provider.dart';
import '../../../shared/widgets/video_grid_widget.dart';

class StarredScreen extends StatefulWidget {
  const StarredScreen({super.key});

  @override
  State<StarredScreen> createState() => _StarredScreenState();
}

class _StarredScreenState extends State<StarredScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // print('🔍 StarredScreen - initState 被调用');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print('🔍 StarredScreen - addPostFrameCallback 被调用');
      final starredProvider = context.read<StarredProvider>();
      // print('🔍 StarredScreen - 获取到 StarredProvider: ${starredProvider.runtimeType}');
      
      // print('🔍 StarredScreen - 开始调用 loadMyStarred');
      starredProvider.loadMyStarred(refresh: true);
      
      // print('🔍 StarredScreen - loadMyStarred 调用完成');
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
    
    return Consumer<StarredProvider>(
      builder: (context, starredProvider, child) {
        // print('🔍 StarredScreen - Consumer builder 被调用，starredVideos数量: ${starredProvider.starredVideos.length}');
        // print('🔍 StarredScreen - isLoading: ${starredProvider.isLoading}, error: ${starredProvider.error}');
        
        if (starredProvider.isLoading && starredProvider.starredVideos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (starredProvider.error != null && starredProvider.starredVideos.isEmpty) {
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
                  starredProvider.error!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    starredProvider.loadMyStarred(refresh: true);
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

        if (starredProvider.starredVideos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_outline,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无收藏的文章',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '去收藏一些有趣的文章吧',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // print('🔍 StarredScreen - 准备构建VideoGridWidget');
        // print('🔍 StarredScreen - 视频数量: ${starredProvider.starredVideos.length}');
        
        return VideoGridWidget(
          videos: starredProvider.starredVideos,
          refreshController: _refreshController,
          onRefresh: () async {
            await starredProvider.refreshStarred();
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            await starredProvider.loadMyStarred(refresh: false);
            if (starredProvider.hasMore) {
              _refreshController.loadComplete();
            } else {
              _refreshController.loadNoData();
            }
          },
          hasMore: starredProvider.hasMore,
          isLoading: starredProvider.isLoading,
          // 不传递onVideoTap，让VideoGridWidget使用默认的跳转行为
        );
      },
    );
  }
}
