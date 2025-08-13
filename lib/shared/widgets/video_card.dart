import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../features/home/models/video_model.dart';
import '../../core/constants/app_constants.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showUserInfo;

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.width,
    this.height,
    this.showUserInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行1: 3:4比例的封面图片
            AspectRatio(
              aspectRatio: 3 / 4, // 强制3:4比例
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: video.getCoverByRecord('w=300&h=400'),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 行2: title + tag组合文字
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    if (video.title.isNotEmpty)
                      Expanded(
                        child: Text(
                          video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 3, // 最多显示3行
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    // 标签
                    if (video.tagList.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: video.tagList.take(3).map((tag) {
                          return Text(
                            '#$tag',
                            style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // 行3: 左边 作者头像（宽高16）、作者昵称 右边：点赞icon + 点赞数量
            Container(
              height: 40, // 固定高度，避免溢出
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Row(
                children: [
                  // 左边：作者头像 + 昵称（根据showUserInfo控制）
                  if (showUserInfo)
                    Expanded(
                      child: Row(
                        children: [
                          // 作者头像
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: video.avatar != null && video.avatar!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: '${AppConstants.baseUrl}/api/image/${video.avatar}',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[600],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[600],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[600],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 作者昵称
                          Expanded(
                            child: Text(
                              video.nickname ?? '未知用户',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // 当不显示用户信息时，添加一个空的Expanded来保持布局
                    const Expanded(child: SizedBox()),
                  
                  // 右边：点赞icon + 数量（始终显示）
                  Row(
                    children: [
                      Icon(
                        video.isLiked == true ? Icons.favorite : Icons.favorite_border,
                        color: video.isLiked == true ? Colors.red : Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${video.likedCount}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
