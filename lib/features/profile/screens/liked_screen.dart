import 'package:flutter/material.dart';
// import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../providers/liked_provider.dart';
import '../../../shared/widgets/video_grid_widget.dart';

class LikedScreen extends StatefulWidget {
  const LikedScreen({super.key});

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // print('🔍 LikedScreen - initState 被调用');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print('🔍 LikedScreen - addPostFrameCallback 被调用');
      final likedProvider = context.read<LikedProvider>();
      // print('🔍 LikedScreen - 获取到 LikedProvider: ${likedProvider.runtimeType}');
      
      // print('🔍 LikedScreen - 开始调用 loadMyLiked');
      likedProvider.loadMyLiked(refresh: true);
      
      // print('🔍 LikedScreen - loadMyLiked 调用完成');
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
    
    return Consumer<LikedProvider>(
      builder: (context, likedProvider, child) {
        // print('🔍 LikedScreen - Consumer builder 被调用，likedVideos数量: ${likedProvider.likedVideos.length}');
        // print('🔍 LikedScreen - isLoading: ${likedProvider.isLoading}, error: ${likedProvider.error}');
        
        if (likedProvider.isLoading && likedProvider.likedVideos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (likedProvider.error != null && likedProvider.likedVideos.isEmpty) {
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
                  likedProvider.error!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    likedProvider.loadMyLiked(refresh: true);
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

        if (likedProvider.likedVideos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无点赞的文章',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '去点赞一些有趣的文章吧',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // print('🔍 LikedScreen - 准备构建VideoGridWidget');
        // print('🔍 LikedScreen - 视频数量: ${likedProvider.likedVideos.length}');
        
        return VideoGridWidget(
          videos: likedProvider.likedVideos,
          refreshController: _refreshController,
          onRefresh: () async {
            await likedProvider.refreshLiked();
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            await likedProvider.loadMyLiked(refresh: false);
            if (likedProvider.hasMore) {
              _refreshController.loadComplete();
            } else {
              _refreshController.loadNoData();
            }
          },
          hasMore: likedProvider.hasMore,
          isLoading: likedProvider.isLoading,
          // 不传递onVideoTap，让VideoGridWidget使用默认的跳转行为
        );
      },
    );
  }
}
