import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';
  
  // 支持的语言列表
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'zh_TW', 'name': 'Traditional Chinese', 'nativeName': '繁體中文'},
  ];

  // 获取当前语言代码
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  // 设置语言
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // 获取语言名称
  static String getLanguageName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['name'] ?? 'English';
  }

  // 获取本地语言名称
  static String getNativeLanguageName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['nativeName'] ?? 'English';
  }

  // 切换语言
  static Future<void> switchLanguage(BuildContext context, String languageCode) async {
    await setLanguage(languageCode);
    final locale = getLocaleFromLanguageCode(languageCode);
    if (context.mounted) {
      await FlutterI18n.refresh(context, locale);
    }
  }

  // 获取当前语言的语言代码和地区代码
  static Locale getLocaleFromLanguageCode(String languageCode) {
    if (languageCode.contains('_')) {
      final parts = languageCode.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(languageCode);
  }
}
