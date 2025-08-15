import 'package:flutter/services.dart';

class ScreenOrientationService {
  static const List<DeviceOrientation> _portraitOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  /// 设置应用为竖屏模式
  static Future<void> setPortraitMode() async {
    try {
      await SystemChrome.setPreferredOrientations(_portraitOrientations);
      print('✅ Screen orientation set to portrait mode');
    } catch (e) {
      print('❌ Failed to set screen orientation: $e');
    }
  }

  /// 锁定屏幕方向为竖屏向上
  static Future<void> lockPortraitUp() async {
    try {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      print('✅ Screen orientation locked to portrait up');
    } catch (e) {
      print('❌ Failed to lock screen orientation: $e');
    }
  }

  /// 恢复所有屏幕方向支持
  static Future<void> restoreAllOrientations() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      print('✅ All screen orientations restored');
    } catch (e) {
      print('❌ Failed to restore screen orientations: $e');
    }
  }

  /// 获取当前支持的屏幕方向
  static List<DeviceOrientation> get getPreferredOrientations => _portraitOrientations;
}
