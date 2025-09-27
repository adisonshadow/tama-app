import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../services/auth_state_manager.dart';

/// 通用错误处理组件
/// 根据错误类型显示不同的UI和操作
class AppErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final String? errorKey;
  final bool showRetryButton;

  const AppErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.errorKey,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // 检查是否是认证相关错误
    final isAuthError = AuthStateManager.isAuthError(errorMessage);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAuthError ? Icons.lock_outline : Icons.error_outline,
            size: 64,
            color: isAuthError ? Colors.orange : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            isAuthError 
              ? FlutterI18n.translate(context, 'common.auth_expired')
              : FlutterI18n.translate(context, 'common.error_occurred'),
            style: TextStyle(
              color: isAuthError ? Colors.orange : Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              color: isAuthError ? Colors.orange[700] : Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (isAuthError) ...[
            // 认证错误：显示登录按钮
            ElevatedButton(
              onPressed: () {
                // 重置认证状态
                AuthStateManager.resetAuthState();
                // 跳转到登录页
                context.go('/auth/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(FlutterI18n.translate(context, 'common.go_to_login')),
            ),
          ] else if (showRetryButton && onRetry != null) ...[
            // 其他错误：显示重试按钮
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(FlutterI18n.translate(context, 'common.retry')),
            ),
          ],
        ],
      ),
    );
  }
}
