import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../../shared/services/search_service.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../home/models/video_model.dart';
import '../../../shared/widgets/video_card.dart';
import '../../video_player/screens/video_player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final RefreshController _refreshController = RefreshController();
  
  List<VideoModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      // 移除自动搜索，让用户手动触发
      // _performSearch(refresh: true);
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
          _currentPage = 2; // 重置后从第2页开始
        } else {
          _searchResults.addAll(results);
          _currentPage++;
        }
        
        // 判断是否还有更多数据
        _hasMore = results.length >= 20;
        
        // print('🔍 搜索完成 - 当前页: $_currentPage, 结果数量: ${results.length}, 是否有更多: $_hasMore');
        // print('🔍 当前总结果数量: ${_searchResults.length}');
        
        setState(() {
          _hasSearched = true;
          // 确保在 setState 中更新 _hasMore，这样 UI 才能正确刷新
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(FlutterI18n.translate(context, 'common.search.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: FlutterI18n.translate(context, 'common.search.placeholder'),
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white, size: 28),
                  onPressed: () => _performSearch(refresh: true),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(17),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              FlutterI18n.translate(context, 'search.start_search'),
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              FlutterI18n.translate(context, 'search.start_search_subtitle'),
              style: const TextStyle(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isSearching && _searchResults.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (_errorMessage.isNotEmpty && _searchResults.isEmpty) {
      return AppErrorWidget(
        errorMessage: _errorMessage,
        onRetry: () => _performSearch(refresh: true),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          FlutterI18n.translate(context, 'common.search.no_results'),
          style: const TextStyle(color: Colors.white54, fontSize: 18),
        ),
      );
    }

            return SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: _hasMore, // 根据是否有更多数据决定是否启用上拉
          onRefresh: () async {
            await _performSearch(refresh: true);
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            // print('🔍 开始上拉加载更多，当前页: $_currentPage, 是否有更多: $_hasMore');
            
            // 如果没有更多数据，直接显示"没有更多内容了"
            if (!_hasMore) {
              // print('🔍 没有更多数据，直接调用 loadNoData');
              _refreshController.loadNoData();
              return;
            }
            
            await _performSearch(refresh: false);
            // print('🔍 加载完成，当前页: $_currentPage, 是否有更多: $_hasMore');
            // print('🔍 决定调用: ${_hasMore ? "loadComplete" : "loadNoData"}');
            
            if (_hasMore) {
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
              // 强制获取最新的 _hasMore 值
              final hasMore = _hasMore;
              // print('🔍 CustomFooter 状态: $mode, _hasMore: $hasMore');
              
              Widget body;
              if (mode == LoadStatus.idle) {
                if (hasMore) {
                  body = Text(FlutterI18n.translate(context, 'common.refresh.pull_to_load_more'), style: const TextStyle(color: Colors.grey));
                } else {
                  body = Text(FlutterI18n.translate(context, 'common.refresh.no_more_content'), style: const TextStyle(color: Colors.grey));
                }
              } else if (mode == LoadStatus.loading) {
                body = const CircularProgressIndicator(color: Colors.blue);
              } else if (mode == LoadStatus.failed) {
                body = Text(FlutterI18n.translate(context, 'common.refresh.load_failed_retry'), style: const TextStyle(color: Colors.red));
              } else if (mode == LoadStatus.canLoading) {
                body = Text(FlutterI18n.translate(context, 'common.refresh.release_to_load_more'), style: const TextStyle(color: Colors.grey));
              } else if (mode == LoadStatus.noMore) {
                body = Text(FlutterI18n.translate(context, 'common.refresh.no_more_content'), style: const TextStyle(color: Colors.grey));
              } else {
                body = Text(FlutterI18n.translate(context, 'common.refresh.no_more_content'), style: const TextStyle(color: Colors.grey));
              }
              final textData = body is Text ? body.data : '其他组件';
              print('🔍 CustomFooter 构建: mode=$mode, hasMore=$hasMore, 显示文本: $textData');
              return Container(
                height: 55.0,
                color: Colors.red.withValues(alpha: 0.1), // 添加背景色以便调试
                child: Center(child: body),
              );
            },
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: _searchResults.length + (_hasMore ? 0 : 1), // 如果没有更多数据，添加一个额外的 item
              itemBuilder: (context, index) {
                                 // 如果是最后一个 item 且没有更多数据，显示"没有更多内容了"
                 if (!_hasMore && index == _searchResults.length) {
                   return SizedBox(
                     height: 55.0,
                     child: Center(
                       child: Text(
                         FlutterI18n.translate(context, 'common.refresh.no_more_content'),
                         style: const TextStyle(color: Colors.grey),
                       ),
                     ),
                   );
                 }
                
                // 显示视频卡片
                final video = _searchResults[index];
                return VideoCard(
                  video: video,
                  aspect: 16/9,
                  onTap: () async {
                    try {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            userId: video.userId,
                            videos: _searchResults,
                            initialVideoIndex: index,
                          ),
                        ),
                      );
                    } catch (e) {
                      print('导航错误: $e');
                    }
                  },
                );
              },
            ),
          ),
        );
  }
}
