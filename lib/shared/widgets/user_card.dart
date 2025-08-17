// 用户卡片组件

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_constants.dart';
import 'follow_button.dart';

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
                    nickname ?? FlutterI18n.translate(context, 'common.unknown_user'),
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
                      FlutterI18n.translate(context, 'common.user_card.lazy_user_bio'),
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
            FollowButton(
              userId: userId,
              mode: FollowButtonMode.button,
              width: 130,
              height: 32,
              fontSize: 14,
              borderRadius: 16,
              onFollowChanged: onFollowTap,
            ),
          ],
        ),
      ),
    );
  }
}
