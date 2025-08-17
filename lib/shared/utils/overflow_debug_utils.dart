import 'package:flutter/rendering.dart';

/// Overflow 调试工具类
/// 用于控制 Flutter 的 overflow 警告显示
class OverflowDebugUtils {
  static bool _isOverflowWarningEnabled = true;

  /// 获取当前 overflow 警告状态
  static bool get isOverflowWarningEnabled => _isOverflowWarningEnabled;

  /// 开启 overflow 警告
  static void enableOverflowWarning() {
    _isOverflowWarningEnabled = true;
    debugPaintSizeEnabled = true;
    debugPrint('✅ Overflow 警告已开启');
  }

  /// 关闭 overflow 警告
  static void disableOverflowWarning() {
    _isOverflowWarningEnabled = false;
    debugPaintSizeEnabled = false;
    debugPrint('❌ Overflow 警告已关闭');
  }

  /// 切换 overflow 警告状态
  static void toggleOverflowWarning() {
    if (_isOverflowWarningEnabled) {
      disableOverflowWarning();
    } else {
      enableOverflowWarning();
    }
  }

  /// 根据状态设置 overflow 警告
  static void setOverflowWarning(bool enabled) {
    if (enabled) {
      enableOverflowWarning();
    } else {
      disableOverflowWarning();
    }
  }
}
