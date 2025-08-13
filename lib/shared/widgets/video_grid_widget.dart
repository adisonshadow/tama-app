// 视频网格组件

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../features/home/models/video_model.dart';
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无内容',
              style: TextStyle(
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
      child: MasonryGridView.count(
        // 使用 MasonryGridView 实现瀑布流布局，每个网格项高度完全自适应
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2, // 固定2列
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return VideoCard(
            video: video,
            onTap: () => onVideoTap?.call(video),
          );
        },
      ),
    );
  }
}
