import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../services/follow_service.dart';
import '../../core/network/dio_client.dart';

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

class FollowButton extends StatefulWidget {
  final String userId;
  final FollowButtonMode mode;
  final VoidCallback? onFollowChanged;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;

  const FollowButton({
    super.key,
    required this.userId,
    this.mode = FollowButtonMode.button,
    this.onFollowChanged,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing = false;
  bool _isLoading = true;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFollowStatus();
  }

  Future<void> _initializeFollowStatus() async {
    if (_hasInitialized) return;
    
    try {
      final response = await FollowService.checkFollowStatus(widget.userId);
      if (mounted) {
        setState(() {
          if (DioClient.isApiSuccess(response)) {
            _isFollowing = response['data']['isFollowed'] ?? false;
          }
          _isLoading = false;
          _hasInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasInitialized = true;
        });
      }
    }
  }

  Future<void> _handleFollowTap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await FollowService.toggleFollow(widget.userId);
      
      if (mounted) {
        if (DioClient.isApiSuccess(response)) {
          final newStatus = response['data']['isFollowed'] ?? false;
          setState(() {
            _isFollowing = newStatus;
            _isLoading = false;
          });
          
          // 显示成功消息
          _showToastMessage(
            newStatus 
              ? FlutterI18n.translate(context, 'common.follow_button.follow_success')
              : FlutterI18n.translate(context, 'common.follow_button.unfollow_success'),
            isSuccess: true,
          );
        } else {
          // 显示错误消息
          final errorMessage = DioClient.getApiErrorMessage(response);
          _showToastMessage(errorMessage);
          setState(() {
            _isLoading = false;
          });
        }
      }
          } catch (e) {
        if (mounted) {
          _showToastMessage(FlutterI18n.translate(context, 'common.follow_button.network_error'));
          setState(() {
            _isLoading = false;
          });
        }
      }
    
    // 调用回调
    widget.onFollowChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == FollowButtonMode.icon) {
      return GestureDetector(
        onTap: _isLoading ? null : _handleFollowTap,
        child: Container(
          width: widget.width ?? 32,
          height: widget.height ?? 32,
          decoration: BoxDecoration(
            color: _isFollowing ? const Color.fromARGB(255, 203, 203, 203) : Colors.red,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  _isFollowing ? Icons.check : Icons.add,
                  size: (widget.fontSize ?? 16) * 1.4,
                  color: _isFollowing ? const Color.fromARGB(255, 51, 51, 51) : Colors.white,
                ),
        ),
      );
    } else {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleFollowTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? const Color.fromARGB(239, 167, 167, 167) : Colors.red,
            foregroundColor: _isFollowing ? const Color.fromARGB(255, 74, 74, 74) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isFollowing ? Icons.check : Icons.add,
                      size: widget.fontSize ?? 24,
                      color: _isFollowing ? const Color.fromARGB(255, 66, 66, 66) : Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isFollowing 
                        ? FlutterI18n.translate(context, 'common.follow_button.following')
                        : FlutterI18n.translate(context, 'common.follow_button.follow'),
                      style: TextStyle(
                        fontSize: widget.fontSize ?? 18,
                        fontWeight: FontWeight.bold,
                        color: _isFollowing ? const Color.fromARGB(255, 66, 66, 66) : Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }
  }

  void _showToastMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
