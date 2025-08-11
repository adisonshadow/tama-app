import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../models/follow_model.dart';
import '../providers/following_provider.dart';
import '../../../shared/utils/error_utils.dart';

class FollowingUsersWidget extends StatelessWidget {
  final List<FollowModel> follows;

  const FollowingUsersWidget({
    super.key,
    required this.follows,
  });

  @override
  Widget build(BuildContext context) {
    if (follows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              '还没有关注任何人',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去发现一些有趣的用户吧',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: follows.length,
      itemBuilder: (context, index) {
        final follow = follows[index];
        return _buildFollowUserItem(context, follow);
      },
    );
  }

  Widget _buildFollowUserItem(BuildContext context, FollowModel follow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 用户头像
          GestureDetector(
            onTap: () {
              // TODO: 跳转到用户页面
              ErrorUtils.showWarning(
                context,
                '用户页面功能暂未实现',
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[800],
              backgroundImage: follow.avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(follow.avatarUrl)
                  : null,
              child: follow.avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      follow.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (follow.isBaba == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                if (follow.bio != null && follow.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    follow.bio!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 8),
                
                Text(
                  '关注时间：${_formatTime(follow.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 取消关注按钮
          Consumer<FollowingProvider>(
            builder: (context, followingProvider, child) {
              return OutlinedButton(
                onPressed: () => _showUnfollowDialog(context, follow),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  '取消关注',
                  style: TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showUnfollowDialog(BuildContext context, FollowModel follow) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            '取消关注',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '确定要取消关注 ${follow.nickname} 吗？',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await context
                    .read<FollowingProvider>()
                    .unfollowUser(follow.id);
                
                if (success && context.mounted) {
                  ErrorUtils.showSuccess(
                    context,
                    '已取消关注 ${follow.nickname}',
                  );
                } else if (context.mounted) {
                  ErrorUtils.showError(
                    context,
                    '取消关注失败',
                  );
                }
              },
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
