import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';

import 'core/error_handling/global_error_handler.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/video_provider.dart';
import 'features/following/providers/following_provider.dart';
import 'shared/providers/follow_provider.dart';
import 'shared/providers/language_provider.dart';
import 'features/video_player/providers/video_player_provider.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/video_token_manager.dart';
import 'shared/services/screen_orientation_service.dart';
// import 'shared/utils/overflow_debug_utils.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置屏幕方向为竖屏模式
  await ScreenOrientationService.setPortraitMode();
  
  // 初始化全局错误处理
  GlobalErrorHandler().initialize();
  
  // 初始化本地存储
  await StorageService.init();
  
  // 初始化网络客户端
  DioClient.init();
  
  // 尝试获取视频播放token（如果用户已登录）
  _tryFetchVideoToken();
  
  // 关闭 overflow 警告（仅在开发时使用）
  // OverflowDebugUtils.disableOverflowWarning();
  
  runApp(const Tama2App());
}

/// 尝试获取视频播放token
Future<void> _tryFetchVideoToken() async {
  try {
    // 检查用户是否已登录
    final user = await StorageService.getUser();
    if (user != null) {
      // 用户已登录，尝试获取视频播放token
      await VideoTokenManager().getVideoToken();
    }
  } catch (e) {
    debugPrint('Failed to fetch video token on startup: $e');
  }
}

class Tama2App extends StatelessWidget {
  const Tama2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => FollowingProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => VideoPlayerProvider()),
      ],
              child: Consumer2<AuthProvider, LanguageProvider>(
        builder: (context, authProvider, languageProvider, _) {
          return MaterialApp.router(
            title: 'TAMA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: AppRouter.router,
            
            // 国际化配置
            localizationsDelegates: [
              FlutterI18nDelegate(
                translationLoader: FileTranslationLoader(
                  basePath: 'flutter_i18n',
                  useCountryCode: true, // 使用国家代码后缀
                  fallbackFile: 'en_US', // fallback语言文件（必须无扩展名）
                  decodeStrategies: [
                    JsonDecodeStrategy(), // 只处理JSON格式的语言文件，避免读取到其他格式文件
                  ],
                ),
                missingTranslationHandler: (key, locale) {
                  debugPrint('--- Missing Key: $key, locale: $locale');
                  // 尝试手动加载翻译
                  debugPrint('--- Attempting to load translation for key: $key');
                },
              ),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('zh', 'TW'), // Traditional Chinese (Taiwan)
              Locale('ja', 'JP'), // Japanese
              Locale('ko', 'KR'), // Korean
            ],
            locale: () {
              final locale = languageProvider.getLocaleFromLanguageCode(languageProvider.currentLanguage);
              debugPrint('MainApp: Setting locale to: $locale (from language: ${languageProvider.currentLanguage})');
              return locale;
            }(),
            
            // 添加错误处理和屏幕方向控制
            builder: (context, child) {
              // 确保应用始终保持竖屏模式
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScreenOrientationService.setPortraitMode();
              });
              
              // 捕获构建错误
              ErrorWidget.builder = (FlutterErrorDetails details) {
                // 记录错误但不显示给用户
                debugPrint('❌ Build Error: ${details.exception}');
                return const Scaffold(
                  body: Center(
                    child: Text('页面加载失败，请重试'),
                  ),
                );
              };
              return child!;
            },
          );
        },
      ),
    );
  }
}
