import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:ui';

import '../services/search_service.dart';
import '../../features/home/models/video_model.dart';
import '../../features/video_player/screens/video_player_screen.dart';
import 'video_card.dart';

class SearchOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const SearchOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final RefreshController _refreshController = RefreshController();
  
  List<VideoModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  
  @override
  void initState() {
    super.initState();
    // 设置默认搜索关键词
    _searchController.text = '温泉';
    
    // 自动聚焦到搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _performSearch({bool refresh = false}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _searchResults.clear();
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final response = await SearchService.searchArticles(
        query: query,
        page: _currentPage,
        pageSize: 20,
      );
      
      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        final List<VideoModel> results = videoData
            .map((json) => VideoModel.fromJsonSafe(json))
            .toList();
        
        if (refresh) {
          _searchResults = results;
        } else {
          _searchResults.addAll(results);
        }
        
        _currentPage++;
        _hasMore = results.length >= 20;
        
        setState(() {
          _hasSearched = true;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? '搜索失败';
          if (refresh) {
            _searchResults = [];
          }
          _hasSearched = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络错误：$e';
        if (refresh) {
          _searchResults = [];
        }
        _hasSearched = true;
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchSubmitted(String value) {
    _performSearch(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(199, 31, 31, 31),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 第一行：标题和关闭按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '搜索',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),
                
                // 第二行：搜索输入框和搜索按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                          decoration: InputDecoration(
                            hintText: '输入关键词搜索视频...',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            suffixIcon: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: _onSearchSubmitted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white, size: 28),
                          onPressed: _isSearching ? null : _performSearch,
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 搜索结果区域
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return const Center(
        child: Text(
          '输入关键词开始搜索',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 20,
          ),
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '搜索中...',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[300],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white54,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              '没有找到相关视频',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '请尝试其他关键词',
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () async {
          await _performSearch(refresh: true);
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await _performSearch(refresh: false);
          if (_hasMore) {
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
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final video = _searchResults[index];
            return VideoCard(
              video: video,
              aspect: 16/9,
              onTap: () async {
                try {
                  // 跳转到视频播放页面
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        userId: video.userId,
                        videos: _searchResults,
                        initialVideoIndex: index,
                      ),
                    ),
                  );
                  
                  // 关闭搜索覆盖层
                  widget.onClose();
                } catch (e) {
                  print('❌ 导航错误: $e');
                  // 如果导航失败，至少关闭搜索覆盖层
                  widget.onClose();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
