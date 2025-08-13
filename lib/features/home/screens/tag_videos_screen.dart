import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// import '../../../core/constants/app_constants.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../../../shared/widgets/video_card.dart';
import '../../../shared/widgets/search_manager.dart';
// import '../../../shared/widgets/main_navigation.dart';

class TagVideosScreen extends StatefulWidget {
  final String tagName;

  const TagVideosScreen({
    super.key,
    required this.tagName,
  });

  @override
  State<TagVideosScreen> createState() => _TagVideosScreenState();
}

class _TagVideosScreenState extends State<TagVideosScreen> {
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTagVideos();
    
    // 添加滚动监听，实现分页加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreVideos();
      }
    }
  }

  Future<void> _loadTagVideos({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        if (refresh) {
          _currentPage = 1;
          _hasMore = true;
          _videos.clear();
        }
      });

      final response = await VideoService.getVideosByTag(
        tagName: widget.tagName,
        page: _currentPage,
        pageSize: 20,
      );

      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        final List<VideoModel> newVideos = videoData
            .map((json) => VideoModel.fromJsonSafe(json))
            .toList();

        if (refresh) {
          _videos = newVideos;
        } else {
          _videos.addAll(newVideos);
        }

        _currentPage++;
        _hasMore = newVideos.length >= 20;
      } else {
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      _setError('网络错误：$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreVideos() async {
    await _loadTagVideos(refresh: false);
  }

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  Future<void> _refresh() async {
    await _loadTagVideos(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopBar(),
            
            // 内容区域
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
          
          const SizedBox(width: 16),
          
          // 中间：Tag 名称
          Expanded(
            child: Text(
              '#${widget.tagName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 右侧：搜索按钮
          GestureDetector(
            onTap: () {
              SearchManager.showSearch(context);
            },
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
                Icons.search,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError && _videos.isEmpty) {
      return _buildErrorView();
    }

    if (_videos.isEmpty && !_isLoading) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Colors.white,
      backgroundColor: Colors.black,
      child: MasonryGridView.count(
        // 使用 MasonryGridView 实现瀑布流布局，每个网格项高度完全自适应
        // crossAxisCount: 2 - 固定2列，每列宽度自适应
        // 这样 VideoCard 就能根据内容自适应高度，真正实现高度自适应
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2, // 固定2列
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        itemCount: _videos.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _videos.length) {
            // 加载更多指示器
            return _buildLoadingMoreIndicator();
          }
          
          final video = _videos[index];
          return VideoCard(
            video: video,
            onTap: () {
              // TODO: 跳转到视频播放页面
              if (kIsWeb) {
                debugPrint('🔍 视频被点击: ${video.id}');
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withValues(alpha: 0.7),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tag_outlined,
            color: Colors.white.withValues(alpha: 0.7),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无视频',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '该标签下还没有视频内容',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
