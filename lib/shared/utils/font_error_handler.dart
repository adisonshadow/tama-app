import 'package:flutter/material.dart';
import 'error_utils.dart';

class FontErrorHandler {
  // 字体错误缓存，避免重复处理相同字体
  static final Set<String> _processedFonts = <String>{};
  
  // 字体错误计数
  static int _fontErrorCount = 0;
  static const int _maxFontErrors = 5; // 最多处理5个字体错误
  
  /// 处理字体加载错误
  /// [fontName] 字体名称
  /// [context] 上下文（可选）
  /// [showUserMessage] 是否显示用户提示
  static void handleFontError(
    String fontName, {
    BuildContext? context,
    bool showUserMessage = true,
  }) {
    // 如果已经处理过这个字体，直接返回
    if (_processedFonts.contains(fontName)) {
      return;
    }
    
    // 添加到已处理集合
    _processedFonts.add(fontName);
    
    // 增加错误计数
    _fontErrorCount++;
    
    // 如果字体错误过多，静默处理
    if (_fontErrorCount > _maxFontErrors) {
      debugPrint('🔇 字体错误过多，静默处理: $fontName');
      return;
    }
    
    // 记录错误
    debugPrint('🔤 字体加载失败: $fontName');
    
    // 如果显示用户提示且有上下文
    if (showUserMessage && context != null) {
      ErrorUtils.showFontError(context, fontName);
    }
  }
  
  /// 处理多个字体错误
  /// [fontNames] 字体名称列表
  /// [context] 上下文（可选）
  static void handleMultipleFontErrors(
    List<String> fontNames, {
    BuildContext? context,
    bool showUserMessage = true,
  }) {
    for (final fontName in fontNames) {
      handleFontError(
        fontName,
        context: context,
        showUserMessage: showUserMessage,
      );
    }
  }
  
  /// 重置字体错误计数
  static void resetFontErrorCount() {
    _fontErrorCount = 0;
    _processedFonts.clear();
  }
  
  /// 获取字体错误统计
  static Map<String, dynamic> getFontErrorStats() {
    return {
      'totalErrors': _fontErrorCount,
      'processedFonts': _processedFonts.length,
      'processedFontList': _processedFonts.toList(),
    };
  }
  
  /// 检查是否应该继续处理字体错误
  static bool shouldContinueProcessing() {
    return _fontErrorCount <= _maxFontErrors;
  }
  
  /// 获取用户友好的字体错误消息
  static String getUserFriendlyMessage(String fontName) {
    return '字体 "$fontName" 加载失败，将使用系统默认字体';
  }
  
  /// 处理字体加载超时
  /// [fontName] 字体名称
  /// [timeout] 超时时间
  static void handleFontTimeout(
    String fontName, {
    Duration timeout = const Duration(seconds: 10),
  }) {
    debugPrint('⏰ 字体加载超时: $fontName (${timeout.inSeconds}秒)');
    
    // 超时后也标记为已处理
    _processedFonts.add(fontName);
  }
  
  /// 清理过期的字体错误记录
  /// [maxAge] 最大保留时间
  static void cleanupOldFontErrors({
    Duration maxAge = const Duration(hours: 1),
  }) {
    // 这里可以实现更复杂的清理逻辑
    // 目前只是简单的计数重置
    if (_fontErrorCount > _maxFontErrors) {
      debugPrint('🧹 清理字体错误记录');
      resetFontErrorCount();
    }
  }
}
