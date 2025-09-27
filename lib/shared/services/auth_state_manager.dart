import 'dart:async';

/// 全局认证状态管理器
/// 用于处理token超时等认证相关状态
class AuthStateManager {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal();

  // 认证失效标志
  static bool _isAuthExpired = false;
  
  // 认证状态变化监听器
  static final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  
  /// 获取认证状态变化流
  static Stream<bool> get authStateStream => _authStateController.stream;
  
  /// 检查认证是否已失效
  static bool get isAuthExpired => _isAuthExpired;
  
  /// 设置认证失效状态
  static void setAuthExpired(bool expired) {
    if (_isAuthExpired != expired) {
      _isAuthExpired = expired;
      _authStateController.add(expired);
      print('🔐 认证状态变化: ${expired ? "已失效" : "已恢复"}');
    }
  }
  
  /// 重置认证状态
  static void resetAuthState() {
    setAuthExpired(false);
  }
  
  /// 检查是否是认证相关错误
  static bool isAuthError(String errorMessage) {
    return errorMessage.contains('身份验证失败') ||
           errorMessage.contains('请重新登录') ||
           errorMessage.contains('token') ||
           errorMessage.contains('401') ||
           errorMessage.contains('unauthorized');
  }
  
  /// 释放资源
  static void dispose() {
    _authStateController.close();
  }
}
