// 视频网格组件

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../features/home/models/video_model.dart';
import '../../features/video_player/screens/video_player_screen.dart';
import 'video_card.dart';

class VideoGridWidget extends StatelessWidget {
  final List<VideoModel> videos;
  final RefreshController refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final Function(VideoModel)? onVideoTap;
  final bool hasMore;
  final bool isLoading;

  const VideoGridWidget({
    super.key,
    required this.videos,
    required this.refreshController,
    this.onRefresh,
    this.onLoading,
    this.onVideoTap,
    this.hasMore = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              FlutterI18n.translate(context, 'video_grid.no_content'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: onRefresh,
      onLoading: onLoading,
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
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2, // 固定2列
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          // print('🔍 VideoGridWidget - 构建视频卡片: index=$index, videoId=${video.id}, userId=${video.userId}');
          
          return VideoCard(
            video: video,
            onTap: () {
              // print('🔍 VideoGridWidget - 视频被点击: index=$index, videoId=${video.id}, userId=${video.userId}');
              // print('🔍 VideoGridWidget - onVideoTap回调: ${onVideoTap != null ? "存在" : "不存在"}');
              
              // 如果有自定义的onVideoTap回调，使用它
              if (onVideoTap != null) {
                // print('🔍 VideoGridWidget - 使用自定义onVideoTap回调');
                onVideoTap!(video);
              } else {
                // 默认行为：跳转到视频播放页面
                // print('🔍 VideoGridWidget - 使用默认跳转行为');
                // print('🔍 VideoGridWidget - 准备跳转到VideoPlayerScreen');
                // print('🔍 VideoGridWidget - 参数: userId=${video.userId}, videosCount=${videos.length}, initialVideoIndex=$index');
                
                try {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        userId: video.userId,
                        videos: videos,
                        initialVideoIndex: index,
                      ),
                    ),
                  );
                  // print('🔍 VideoGridWidget - 跳转成功');
                } catch (e) {
                  print('❌ VideoGridWidget - 跳转失败: $e');
                }
              }
            },
          );
        },
      ),
    );
  }
}
