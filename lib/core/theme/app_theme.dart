import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppTheme {
  /// 获取应用主题
  static ThemeData get theme {
    return ThemeData(
      // 在Web环境中使用系统字体，避免Google Fonts加载问题
      fontFamily: _getFontFamily(),
      
      // 基础颜色配置
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.black,
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      // 颜色方案
      colorScheme: const ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.pink,
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      
      // 使用Material 3
      useMaterial3: true,
      
      // 文本主题
      textTheme: _getTextTheme(),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[900],
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  /// 获取字体族
  static String? _getFontFamily() {
    if (kIsWeb) {
      // Web环境：使用系统字体，避免Google Fonts加载问题
      return null; // 使用系统默认字体
    } else {
      // 移动端：可以使用自定义字体
      return null; // 暂时使用系统字体
    }
  }

  /// 获取文本主题
  static TextTheme _getTextTheme() {
    return const TextTheme(
      // 标题样式
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      
      // 标题样式
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      
      // 正文样式
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      
      // 标签样式
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    );
  }

  /// 获取亮色主题（如果需要）
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: _getFontFamily(),
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.pink,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      useMaterial3: true,
      textTheme: _getLightTextTheme(),
    );
  }

  /// 获取亮色文本主题
  static TextTheme _getLightTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    );
  }
}
