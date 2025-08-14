import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';
import '../services/message_service.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final RefreshController _refreshController = RefreshController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMessages(refresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// 加载消息列表
  Future<void> _loadMessages({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _messages.clear();
    }

    if (!_hasMore && !refresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await MessageService.getMessages(
        page: _currentPage,
        pageSize: 20,
      );
      
      if (response['status'] == 'SUCCESS') {
        final List<dynamic> messageData = response['data']['messages'] ?? [];
        final List<MessageModel> results = messageData
            .map((json) => MessageModel.fromJson(json))
            .toList();
        
        if (refresh) {
          _messages = results;
          _currentPage = 2;
        } else {
          _messages.addAll(results);
          _currentPage++;
        }
        
        // 判断是否还有更多数据
        _hasMore = response['data']['hasMore'] ?? false;
        
        print('🔍 消息加载完成 - 当前页: $_currentPage, 结果数量: ${results.length}, 是否有更多: $_hasMore');
        print('🔍 当前总消息数量: ${_messages.length}');
        
        setState(() {});
      } else {
        setState(() {
          _errorMessage = response['message'] ?? '加载失败';
          if (refresh) {
            _messages = [];
          }
        });
      }
    } catch (e) {
      print('🔍 加载消息失败: $e');
      setState(() {
        _errorMessage = '网络错误，请稍后重试';
        if (refresh) {
          _messages = [];
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 刷新消息
  Future<void> _onRefresh() async {
    await _loadMessages(refresh: true);
    _refreshController.refreshCompleted();
  }

  /// 加载更多消息
  Future<void> _onLoading() async {
    if (_hasMore) {
      await _loadMessages(refresh: false);
      if (_hasMore) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    } else {
      _refreshController.loadNoData();
    }
  }

  /// 格式化时间
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MM-dd').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '消息',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (_errorMessage.isNotEmpty && _messages.isEmpty) {
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
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadMessages(refresh: true),
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

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无消息',
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
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: _hasMore,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageItem(message);
        },
      ),
    );
  }

  /// 构建消息项
  Widget _buildMessageItem(MessageModel message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 左侧：头像
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: message.avatar != null && message.avatar!.isNotEmpty
                  ? Image.network(
                      'http://localhost:5200/api/media/img/${message.avatar}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[600],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[600],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 中间：昵称和消息内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称
                Text(
                  message.nickname,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // 消息内容
                Text(
                  message.message,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 右侧：时间
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
