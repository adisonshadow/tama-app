import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';
  
  String _currentLanguage = _defaultLanguage;
  
  String get currentLanguage => _currentLanguage;
  
  // 支持的语言列表
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'zh_TW', 'name': 'Traditional Chinese', 'nativeName': '繁體中文'},
  ];

  LanguageProvider() {
    _loadLanguage();
  }

  // 加载保存的语言设置
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      if (savedLanguage != _currentLanguage) {
        _currentLanguage = savedLanguage;
        notifyListeners();
      }
    } catch (e) {
      // 如果加载失败，使用默认语言
      debugPrint('Failed to load language preference: $e');
    }
  }

  // 切换语言
  Future<void> switchLanguage(BuildContext context, String languageCode) async {
    debugPrint('LanguageProvider: Switching language from $_currentLanguage to $languageCode');
    
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      
      // 保存到本地存储
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        debugPrint('LanguageProvider: Language saved to preferences');
      } catch (e) {
        debugPrint('LanguageProvider: Failed to save language preference: $e');
      }
      
      // 刷新 FlutterI18n 系统
      if (context.mounted) {
        try {
          final locale = getLocaleFromLanguageCode(languageCode);
          debugPrint('LanguageProvider: Refreshing FlutterI18n with locale: $locale');
          await FlutterI18n.refresh(context, locale);
          debugPrint('LanguageProvider: FlutterI18n refresh completed');
        } catch (e) {
          debugPrint('LanguageProvider: Failed to refresh FlutterI18n: $e');
        }
      }
      
      // 通知所有监听者更新界面
      debugPrint('LanguageProvider: Notifying listeners');
      notifyListeners();
      debugPrint('LanguageProvider: Language switch completed');
    } else {
      debugPrint('LanguageProvider: Language already set to $languageCode');
    }
  }

  // 获取语言名称
  String getLanguageName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['name'] ?? 'English';
  }

  // 获取本地语言名称
  String getNativeLanguageName(String languageCode) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => supportedLanguages.first,
    );
    return language['nativeName'] ?? 'English';
  }

  // 获取当前语言的语言代码和地区代码
  Locale getLocaleFromLanguageCode(String languageCode) {
    if (languageCode.contains('_')) {
      final parts = languageCode.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(languageCode);
  }
}
