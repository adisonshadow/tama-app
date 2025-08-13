import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/follow_provider.dart';

/// 关注按钮组件，支持两种显示模式
/// 
/// 使用示例：
/// 
/// 1. 圆形图标模式（用于头像下方）：
/// ```dart
/// FollowButton(
///   userId: 'user123',
///   mode: FollowButtonMode.icon,
///   width: 26,
///   height: 26,
/// )
/// ```
/// 
/// 2. 完整按钮模式（用于用户空间页面）：
/// ```dart
/// FollowButton(
///   userId: 'user123',
///   mode: FollowButtonMode.button,
///   width: double.infinity,
///   height: 48,
/// )
/// ```
enum FollowButtonMode {
  icon,    // 圆形图标模式（用于头像下方）
  button,  // 完整按钮模式（用于用户空间页面）
}

class FollowButton extends StatelessWidget {
  final String userId;
  final FollowButtonMode mode;
  final double? width;
  final double? height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? followingColor;
  final Color? unfollowingColor;
  final Color? textColor;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    super.key,
    required this.userId,
    this.mode = FollowButtonMode.button,
    this.width,
    this.height = 48,
    this.fontSize = 16,
    this.padding,
    this.borderRadius,
    this.followingColor,
    this.unfollowingColor,
    this.textColor,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowProvider>(
      builder: (context, followProvider, child) {
        final isFollowing = followProvider.isFollowing(userId);
        final isLoading = followProvider.isLoading(userId);

        if (mode == FollowButtonMode.icon) {
          // 圆形图标模式
          return GestureDetector(
            onTap: isLoading ? null : () async {
              final success = await followProvider.toggleFollow(userId);
              if (success && onFollowChanged != null) {
                onFollowChanged!();
              }
            },
            child: Container(
              width: width ?? 26,
              height: height ?? 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFollowing 
                    ? (followingColor ?? const Color.fromARGB(255, 203, 203, 203))
                    : (unfollowingColor ?? Colors.red),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFollowing ? const Color.fromARGB(255, 51, 51, 51) : Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        isFollowing ? Icons.check : Icons.add,
                        size: (fontSize ?? 16) * 1.4, // 图标大小相对于按钮尺寸
                        color: isFollowing ? const Color.fromARGB(255, 51, 51, 51) : Colors.white,
                      ),
              ),
            ),
          );
        } else {
          // 完整按钮模式
          return SizedBox(
            width: width ?? double.infinity,
            height: height,
            child: ElevatedButton(
              onPressed: isLoading ? null : () async {
                final success = await followProvider.toggleFollow(userId);
                if (success && onFollowChanged != null) {
                  onFollowChanged!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing 
                    ? (followingColor ?? Colors.grey.withValues(alpha: 0.2))
                    : (unfollowingColor ?? Colors.red),
                foregroundColor: textColor ?? Colors.white,
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFollowing ? Icons.check : Icons.add,
                          size: fontSize ?? 16,
                          color: isFollowing ? Colors.grey[700] : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFollowing ? '已关注' : '关注',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: isFollowing ? Colors.grey[700] : Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }
      },
    );
  }
}
