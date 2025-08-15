import 'package:flutter/material.dart';

class ErrorUtils {
  // 错误去重缓存，避免短时间内重复显示相同错误
  static final Map<String, DateTime> _errorCache = {};
  static const Duration _errorCacheTimeout = Duration(minutes: 5); // 5分钟内不重复显示相同错误
  
  // 网络错误计数，用于控制错误提示频率
  static int _networkErrorCount = 0;
  static const int _maxNetworkErrorsBeforeSilent = 3; // 超过3次网络错误后静默处理
  
  // 字体加载错误计数
  static int _fontErrorCount = 0;
  static const int _maxFontErrorsBeforeSilent = 2; // 超过2次字体错误后静默处理

  /// 显示错误提示（带去重机制）
  /// [context] 上下文
  /// [message] 错误消息
  /// [errorKey] 错误唯一标识，用于去重
  /// [backgroundColor] 背景颜色，默认为红色
  /// [duration] 显示时长，默认为10秒
  static void showError(
    BuildContext context,
    String message, {
    String? errorKey,
    Color backgroundColor = Colors.red,
    Duration duration = const Duration(seconds: 10),
  }) {
    // 生成错误键
    final key = errorKey ?? message;
    
    // 检查是否应该显示错误（去重机制）
    if (!_shouldShowError(key)) {
      return;
    }
    
    // 更新错误缓存
    _errorCache[key] = DateTime.now();
    
    // 打印错误信息到控制台（仅一次）
    debugPrint('❌ Error: $message');

    // 显示SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 显示网络错误（带频率控制）
  /// [context] 上下文
  /// [message] 错误消息
  /// [errorKey] 错误唯一标识
  static void showNetworkError(
    BuildContext context,
    String message, {
    String? errorKey,
  }) {
    _networkErrorCount++;
    
    // 如果网络错误次数过多，静默处理
    if (_networkErrorCount > _maxNetworkErrorsBeforeSilent) {
      debugPrint('🔇 网络错误过多，静默处理: $message');
      return;
    }
    
    // 显示网络错误提示
    showError(
      context,
      message,
      errorKey: errorKey ?? 'network_error_$message',
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 8),
    );
  }

  /// 显示字体加载错误（带频率控制）
  /// [context] 上下文
  /// [fontName] 字体名称
  static void showFontError(
    BuildContext context,
    String fontName,
  ) {
    _fontErrorCount++;
    
    // 如果字体错误次数过多，静默处理
    if (_fontErrorCount > _maxFontErrorsBeforeSilent) {
      debugPrint('🔇 字体加载错误过多，静默处理: $fontName');
      return;
    }
    
    // 显示字体错误提示
    showError(
      context,
      '字体加载失败: $fontName',
      errorKey: 'font_error_$fontName',
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 5),
    );
  }

  /// 重置网络错误计数
  static void resetNetworkErrorCount() {
    _networkErrorCount = 0;
  }

  /// 重置字体错误计数
  static void resetFontErrorCount() {
    _fontErrorCount = 0;
  }

  /// 清理过期的错误缓存
  static void _cleanupErrorCache() {
    final now = DateTime.now();
    _errorCache.removeWhere((key, timestamp) {
      return now.difference(timestamp) > _errorCacheTimeout;
    });
  }

  /// 判断是否应该显示错误（去重逻辑）
  static bool _shouldShowError(String errorKey) {
    _cleanupErrorCache();
    
    final lastErrorTime = _errorCache[errorKey];
    if (lastErrorTime == null) {
      return true; // 首次错误，显示
    }
    
    // 检查是否超过缓存时间
    final timeSinceLastError = DateTime.now().difference(lastErrorTime);
    return timeSinceLastError > _errorCacheTimeout;
  }

  /// 显示成功提示
  /// [context] 上下文
  /// [message] 成功消息
  /// [duration] 显示时长，默认为3秒
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // 打印成功信息到控制台
    debugPrint('✅ Success: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示警告提示
  /// [context] 上下文
  /// [message] 警告消息
  /// [duration] 显示时长，默认为5秒
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    // 打印警告信息到控制台
    debugPrint('⚠️ Warning: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 显示信息提示
  /// [context] 上下文
  /// [message] 信息消息
  /// [duration] 显示时长，默认为4秒
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    // 打印信息到控制台
    debugPrint('ℹ️ Info: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示网络状态提示
  /// [context] 上下文
  /// [isOnline] 是否在线
  static void showNetworkStatus(
    BuildContext context,
    bool isOnline,
  ) {
    if (isOnline) {
      // 网络恢复时重置错误计数
      resetNetworkErrorCount();
      resetFontErrorCount();
      
      showSuccess(
        context,
        '网络连接已恢复',
        duration: const Duration(seconds: 3),
      );
    } else {
      showWarning(
        context,
        '网络连接已断开，请检查网络设置',
        duration: const Duration(seconds: 8),
      );
    }
  }
}
