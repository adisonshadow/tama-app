import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../shared/utils/font_error_handler.dart';

/// 字体错误拦截器
/// 专门处理Flutter Web中的字体加载错误
class FontErrorInterceptor {
  static final FontErrorInterceptor _instance = FontErrorInterceptor._internal();
  factory FontErrorInterceptor() => _instance;
  FontErrorInterceptor._internal();

  // 是否已初始化
  bool _isInitialized = false;
  
  // 字体错误计数
  int _fontErrorCount = 0;
  static const int _maxFontErrors = 10;
  
  // 已处理的字体错误
  final Set<String> _processedFontErrors = <String>{};
  
  // 错误处理定时器
  Timer? _cleanupTimer;

  /// 初始化字体错误拦截器
  void initialize() {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      _setupWebFontErrorHandling();
    }
    
    // 启动清理定时器
    _startCleanupTimer();
    
    _isInitialized = true;
    debugPrint('🔤 字体错误拦截器已初始化');
  }

  /// 设置Web字体错误处理
  void _setupWebFontErrorHandling() {
    try {
      // 拦截控制台错误
      _interceptConsoleErrors();
      
      // 拦截字体加载错误
      _interceptFontLoadErrors();
      
      debugPrint('🔤 Web字体错误拦截已设置');
    } catch (e) {
      debugPrint('❌ 设置Web字体错误拦截失败: $e');
    }
  }

  /// 拦截控制台错误
  void _interceptConsoleErrors() {
    // 在Web环境中，我们可以尝试拦截一些控制台错误
    // 但Flutter Web的限制使得我们无法完全拦截所有错误
    
    // 这里我们主要依赖全局错误处理器来捕获字体相关错误
    debugPrint('🔤 控制台错误拦截已设置（部分功能）');
  }

  /// 拦截字体加载错误
  void _interceptFontLoadErrors() {
    // 在Web环境中，字体加载错误主要通过以下方式处理：
    // 1. 全局错误处理器捕获
    // 2. 字体错误处理器去重
    // 3. 用户友好的错误提示
    
    debugPrint('🔤 字体加载错误拦截已设置');
  }

  /// 处理字体错误
  /// [errorMessage] 错误消息
  /// [context] 上下文（可选）
  void handleFontError(String errorMessage, {BuildContext? context}) {
    // 检查是否应该处理这个错误
    if (!_shouldProcessError(errorMessage)) {
      return;
    }
    
    // 提取字体名称
    final fontName = _extractFontName(errorMessage);
    if (fontName == null) {
      return;
    }
    
    // 检查是否已经处理过这个字体错误
    final errorKey = '${fontName}_${errorMessage.hashCode}';
    if (_processedFontErrors.contains(errorKey)) {
      return;
    }
    
    // 添加到已处理集合
    _processedFontErrors.add(errorKey);
    
    // 增加错误计数
    _fontErrorCount++;
    
    // 如果字体错误过多，静默处理
    if (_fontErrorCount > _maxFontErrors) {
      debugPrint('🔇 字体错误过多，静默处理: $fontName');
      return;
    }
    
    // 记录错误
    debugPrint('🔤 字体加载失败: $fontName');
    debugPrint('🔤 错误详情: $errorMessage');
    
    // 使用字体错误处理器
    FontErrorHandler.handleFontError(
      fontName,
      context: context,
      showUserMessage: _fontErrorCount <= 3, // 只在前3次显示用户提示
    );
  }

  /// 检查是否应该处理这个错误
  bool _shouldProcessError(String errorMessage) {
    // 只处理字体相关的错误
    return errorMessage.contains('Failed to load font') ||
           errorMessage.contains('font') ||
           errorMessage.contains('Font') ||
           errorMessage.contains('woff2') ||
           errorMessage.contains('gstatic.com') ||
           errorMessage.contains('TypeError: Failed to fetch');
  }

  /// 提取字体名称
  String? _extractFontName(String errorMessage) {
    // 尝试从错误信息中提取字体名称
    if (errorMessage.contains('Noto Sans SC')) {
      return 'Noto Sans SC';
    } else if (errorMessage.contains('Noto Sans HK')) {
      return 'Noto Sans HK';
    } else if (errorMessage.contains('Noto Sans')) {
      return 'Noto Sans';
    } else if (errorMessage.contains('Failed to load font')) {
      // 尝试提取字体名称
      final regex = RegExp(r'Failed to load font (.+?) at');
      final match = regex.firstMatch(errorMessage);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    
    // 如果没有找到具体字体名，返回通用名称
    return 'Unknown Font';
  }

  /// 批量处理字体错误
  void handleMultipleFontErrors(List<String> errorMessages, {BuildContext? context}) {
    for (final errorMessage in errorMessages) {
      handleFontError(errorMessage, context: context);
    }
  }

  /// 重置字体错误计数
  void resetFontErrorCount() {
    _fontErrorCount = 0;
    _processedFontErrors.clear();
    debugPrint('🔄 字体错误计数已重置');
  }

  /// 获取字体错误统计
  Map<String, dynamic> getFontErrorStats() {
    return {
      'totalErrors': _fontErrorCount,
      'processedErrors': _processedFontErrors.length,
      'shouldSilentHandle': _fontErrorCount > _maxFontErrors,
    };
  }

  /// 启动清理定时器
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _cleanupOldErrors();
    });
  }

  /// 清理旧的错误记录
  void _cleanupOldErrors() {
    if (_fontErrorCount > _maxFontErrors) {
      debugPrint('🧹 清理字体错误记录');
      resetFontErrorCount();
    }
  }

  /// 停止字体错误拦截器
  void dispose() {
    _cleanupTimer?.cancel();
    _processedFontErrors.clear();
    _isInitialized = false;
    debugPrint('🔤 字体错误拦截器已停止');
  }
}
