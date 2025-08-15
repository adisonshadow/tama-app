import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../services/comment_rate_limiter.dart';

class CommentSheet extends StatefulWidget {
  final String videoId;
  final double currentTime; // 当前视频播放时间

  const CommentSheet({
    super.key,
    required this.videoId,
    required this.currentTime,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final CommentService _commentService = CommentService();
  final CommentRateLimiter _rateLimiter = CommentRateLimiter();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _showEmojiPicker = false;
  String? _errorMessage;
  
  // 临时用户ID（实际应用中应该从用户服务获取）
  final String _currentUserId = '999';

  @override
  void initState() {
    super.initState();
    _loadComments();
    
    // 延迟一帧后自动聚焦输入框，确保UI完全构建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _commentFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  /// 加载评论列表
  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // print('🔍 开始加载评论，videoId: ${widget.videoId}');
      final comments = await _commentService.getComments(widget.videoId);
      // print('🔍 成功获取评论数量: ${comments.length}');
      
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 加载评论失败: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (kIsWeb) {
        debugPrint('❌ 加载评论失败: $e');
      }
    }
  }

  /// 发布评论
  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    // 检查评论频率限制
    if (!_rateLimiter.canComment(_currentUserId)) {
      final nextTime = _rateLimiter.getNextCommentTime(_currentUserId);
      final remainingTime = nextTime?.difference(DateTime.now());
      
      String message = '评论过于频繁，请稍后再试';
      if (remainingTime != null) {
        final minutes = remainingTime.inMinutes;
        final seconds = remainingTime.inSeconds % 60;
        if (minutes > 0) {
          message = '评论过于频繁，请$minutes分$seconds秒后再试';
        } else {
          message = '评论过于频繁，请$seconds秒后再试';
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _commentService.createComment(
        content,
        widget.currentTime,
        widget.videoId,
      );

      if (success) {
        // 记录评论成功
        _rateLimiter.recordComment(_currentUserId);
        
        _commentController.clear();
        _commentFocusNode.unfocus();
        
        // 显示成功提示（顶部显示）
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('评论发布成功！'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 100,
                right: 20,
                left: 20,
              ),
            ),
          );
          
          // 重新加载评论列表
          if (mounted) {
            await _loadComments();
          }
        }
        
        if (mounted && kIsWeb) {
          // debugPrint('🔍 评论发布成功');
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 发布评论失败: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布评论失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// 格式化时间
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MM-dd HH:mm').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 格式化视频时间
  String _formatVideoTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 获取表情列表
  List<String> _getEmojiList() {
    return [
      '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
      '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
      '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
      '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏',
      '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣',
      '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠',
      '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨',
      '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥',
    ];
  }

  /// 插入表情到输入框
  void _insertEmoji(String emoji) {
    final text = _commentController.text;
    final selection = _commentController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );
    _commentController.text = newText;
    _commentController.selection = TextSelection.collapsed(
      offset: selection.start + emoji.length,
    );
    
    // 重新获取焦点
    _commentFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2 / 3,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 第一行：拖拽指示器和关闭按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 拖拽指示器
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // 关闭按钮
                // IconButton(
                //   onPressed: () => Navigator.of(context).pop(),
                //   icon: const Icon(Icons.close, size: 24),
                //   style: IconButton.styleFrom(
                //     backgroundColor: Colors.grey[100],
                //     foregroundColor: const Color.fromARGB(255, 96, 96, 96),
                //     shape: const CircleBorder(),
                //   ),
                // ),
              ],
            ),
          ),

          // 第二行：评论数量
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_comments.length}条评论',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 第三行：评论列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadComments,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : _comments.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无评论，快来发表第一条评论吧！',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return _buildCommentItem(comment);
                            },
                          ),
          ),

          // 表情选择器
          if (_showEmojiPicker)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '选择表情',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(221, 91, 91, 91),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = false;
                          });
                        },
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: const Color.fromARGB(255, 96, 96, 96),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _getEmojiList().length,
                      itemBuilder: (context, index) {
                        final emoji = _getEmojiList()[index];
                        return GestureDetector(
                          onTap: () {
                            _insertEmoji(emoji);
                            // 自动关闭表情面板
                            setState(() {
                              _showEmojiPicker = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // 底部：发布评论区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                // 用户头像
                // CircleAvatar(
                //   radius: 20,
                //   backgroundColor: Colors.grey[200],
                //   child: const Icon(Icons.person, color: Colors.grey),
                // ),
                // const SizedBox(width: 12),
                
                // 表情按钮
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                  icon: Icon(
                    _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                    color: _showEmojiPicker ? Colors.blue : Colors.grey[600],
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _showEmojiPicker ? Colors.blue[50] : Colors.transparent,
                    shape: const CircleBorder(),
                  ),
                ),
                
                // 评论输入框
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      maxHeight: 120,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: '说点什么...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 发送按钮
                GestureDetector(
                  onTap: _isSubmitting ? null : _submitComment,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isSubmitting ? Colors.grey : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
                

              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建评论项
  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户头像
          CircleAvatar(
            radius: 20,
            backgroundImage: comment.avatar != null
                ? NetworkImage('http://localhost:5200/api/media/img/${comment.avatar}')
                : null,
            child: comment.avatar == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // 评论内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户昵称
                Text(
                  comment.nickname,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // 评论内容
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 发布时间和视频时间
                Row(
                  children: [
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatVideoTime(comment.start),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
