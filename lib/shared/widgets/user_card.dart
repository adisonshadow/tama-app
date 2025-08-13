// 用户卡片组件

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_constants.dart';

class UserCard extends StatelessWidget {
  final String userId;
  final String? nickname;
  final String? avatar;
  final String? bio;
  final bool isFollowing;
  final VoidCallback? onFollowTap;
  final VoidCallback? onCardTap;

  const UserCard({
    super.key,
    required this.userId,
    this.nickname,
    this.avatar,
    this.bio,
    this.isFollowing = false,
    this.onFollowTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 左侧：用户头像
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
                child: avatar != null && avatar!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: '${AppConstants.baseUrl}/api/image/$avatar',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[600],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[600],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
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
            
            // 中间：用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 昵称
                  Text(
                    nickname ?? '未知用户',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Bio（允许null）
                  if (bio != null && bio!.isNotEmpty)
                    Text(
                      bio!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      '这个人很懒，还没有写简介',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 右侧：关注按钮
            GestureDetector(
              onTap: onFollowTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isFollowing 
                      ? Colors.grey.withValues(alpha: 0.2) // 已关注：灰色背景 20%透明度
                      : Colors.red, // 未关注：红色背景
                  borderRadius: BorderRadius.circular(20),
                  border: isFollowing 
                      ? Border.all(color: Colors.grey[400]!, width: 1)
                      : null,
                ),
                child: Text(
                  isFollowing ? '已关注' : '关注',
                  style: TextStyle(
                    color: isFollowing ? Colors.grey[400] : Colors.white, // 已关注：灰色文字，未关注：白色文字
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
