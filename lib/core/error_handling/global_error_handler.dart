import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../shared/utils/error_utils.dart';
import '../../shared/utils/font_error_handler.dart';
import '../../shared/services/network_service.dart';
import 'font_error_interceptor.dart';
import 'web_error_suppressor.dart';

class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  // 错误计数
  static int _errorCount = 0;
  static const int _maxErrorsBeforeSilent = 10;
  
  // 错误缓存，避免重复显示相同错误
  static final Map<String, DateTime> _errorCache = {};
  static const Duration _errorCacheTimeout = Duration(minutes: 3);
  
  // 是否已初始化
  bool _isInitialized = false;

  /// 初始化全局错误处理
  void initialize() {
    if (_isInitialized) return;
    
    // 设置Flutter错误处理
    FlutterError.onError = _handleFlutterError;
    
    // 设置未捕获异常处理
    PlatformDispatcher.instance.onError = _handlePlatformError;
    
    // 初始化网络服务
    NetworkService().initialize();
    
    // 初始化字体错误拦截器
    FontErrorInterceptor().initialize();
    
    // 初始化Web错误抑制器
    WebErrorSuppressor().initialize();
    
    _isInitialized = true;
    debugPrint('🔧 全局错误处理器已初始化');
  }

  /// 处理Flutter框架错误
  void _handleFlutterError(FlutterErrorDetails details) {
    _incrementErrorCount();
    
    // 检查是否应该静默处理
    if (_shouldSilentHandle()) {
      debugPrint('🔇 错误过多，静默处理Flutter错误');
      return;
    }
    
    // 记录错误
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('❌ Flutter Error Stack: ${details.stack}');
    
    // 检查是否是字体相关错误
    if (_isFontError(details.exception.toString())) {
      _handleFontError(details);
      return;
    }
    
    // 检查是否是网络相关错误
    if (_isNetworkError(details.exception.toString())) {
      _handleNetworkError(details);
      return;
    }
    
    // 其他错误，记录但不显示用户提示
    _cacheError('flutter_error_${details.exception.hashCode}');
  }

  /// 处理平台错误
  bool _handlePlatformError(Object error, StackTrace stack) {
    _incrementErrorCount();
    
    // 检查是否应该静默处理
    if (_shouldSilentHandle()) {
      debugPrint('🔇 错误过多，静默处理平台错误');
      return true; // 返回true表示错误已处理
    }
    
    // 记录错误
    debugPrint('❌ Platform Error: $error');
    debugPrint('❌ Platform Error Stack: $stack');
    
    // 检查是否是字体相关错误
    if (_isFontError(error.toString())) {
      _handlePlatformFontError(error);
      return true;
    }
    
    // 检查是否是网络相关错误
    if (_isNetworkError(error.toString())) {
      _handlePlatformNetworkError(error);
      return true;
    }
    
    // 其他错误，记录但不显示用户提示
    _cacheError('platform_error_${error.hashCode}');
    
    return true; // 返回true表示错误已处理
  }

  /// 处理字体相关错误
  void _handleFontError(FlutterErrorDetails details) {
    final errorString = details.exception.toString();
    
    // 在Web环境中使用错误抑制器
    if (kIsWeb) {
      WebErrorSuppressor().handleFontError(errorString);
    } else {
      // 使用字体错误拦截器处理
      FontErrorInterceptor().handleFontError(errorString);
    }
    
    _cacheError('font_error_${details.exception.hashCode}');
  }

  /// 处理平台字体错误
  void _handlePlatformFontError(Object error) {
    final errorString = error.toString();
    
    // 在Web环境中使用错误抑制器
    if (kIsWeb) {
      WebErrorSuppressor().handleFontError(errorString);
    } else {
      // 使用字体错误拦截器处理
      FontErrorInterceptor().handleFontError(errorString);
    }
    
    _cacheError('platform_font_error_${error.hashCode}');
  }

  /// 处理网络相关错误
  void _handleNetworkError(FlutterErrorDetails details) {
    _cacheError('network_error_${details.exception.hashCode}');
    
    // 网络错误由网络服务处理，这里只记录
    debugPrint('🌐 网络错误已记录: ${details.exception}');
  }

  /// 处理平台网络错误
  void _handlePlatformNetworkError(Object error) {
    _cacheError('platform_network_error_${error.hashCode}');
    
    // 网络错误由网络服务处理，这里只记录
    debugPrint('🌐 平台网络错误已记录: $error');
  }

  /// 检查是否是字体相关错误
  bool _isFontError(String errorString) {
    return errorString.contains('Failed to load font') ||
           errorString.contains('font') ||
           errorString.contains('Font') ||
           errorString.contains('woff2') ||
           errorString.contains('gstatic.com');
  }

  /// 检查是否是网络相关错误
  bool _isNetworkError(String errorString) {
    return errorString.contains('Failed to fetch') ||
           errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('HTTP');
  }



  /// 增加错误计数
  void _incrementErrorCount() {
    _errorCount++;
    
    // 如果错误过多，清理缓存
    if (_errorCount > _maxErrorsBeforeSilent) {
      _cleanupErrorCache();
    }
  }

  /// 检查是否应该静默处理
  bool _shouldSilentHandle() {
    return _errorCount > _maxErrorsBeforeSilent;
  }

  /// 缓存错误
  void _cacheError(String errorKey) {
    _errorCache[errorKey] = DateTime.now();
  }

  /// 清理过期的错误缓存
  void _cleanupErrorCache() {
    final now = DateTime.now();
    _errorCache.removeWhere((key, timestamp) {
      return now.difference(timestamp) > _errorCacheTimeout;
    });
  }

  /// 重置错误计数
  void resetErrorCount() {
    _errorCount = 0;
    _errorCache.clear();
    FontErrorHandler.resetFontErrorCount();
    NetworkService().resetNetworkErrorCount();
    debugPrint('🔄 错误计数已重置');
  }

  /// 获取错误统计信息
  Map<String, dynamic> getErrorStats() {
    return {
      'totalErrors': _errorCount,
      'fontErrors': FontErrorHandler.getFontErrorStats(),
      'cachedErrors': _errorCache.length,
      'shouldSilentHandle': _shouldSilentHandle(),
    };
  }

  /// 显示错误统计信息
  void showErrorStats(BuildContext context) {
    final stats = getErrorStats();
    final message = '''
错误统计信息:
- 总错误数: ${stats['totalErrors']}
- 字体错误: ${stats['fontErrors']['totalErrors']}
- 缓存错误: ${stats['cachedErrors']}
- 静默处理: ${stats['shouldSilentHandle'] ? '是' : '否'}
    '''.trim();
    
    ErrorUtils.showInfo(context, message);
  }

  /// 清理所有错误记录
  void cleanupAllErrors() {
    resetErrorCount();
    debugPrint('🧹 所有错误记录已清理');
  }
}
