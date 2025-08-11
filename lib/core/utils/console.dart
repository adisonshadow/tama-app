import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js_interop';

@JS('console.log')
external void consoleLog(String message);

/// 跨平台控制台输出工具类
class Console {
  /// 在适当的位置输出调试信息
  /// 如果是web环境则使用浏览器控制台，否则使用终端输出
  static void log(Object? message) {
    if (kIsWeb) {
      // Web环境使用console.log
      // ignore: avoid_web_libraries_in_flutter
      consoleLog(message.toString());
    } else {
      // 移动端或桌面端使用print
      print(message);
    }
  }
}