import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/error_handling/global_error_handler.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/video_provider.dart';
import 'features/following/providers/following_provider.dart';
import 'shared/providers/follow_provider.dart';
import 'features/video_player/providers/video_player_provider.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/video_token_manager.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化全局错误处理
  GlobalErrorHandler().initialize();
  
  // 初始化本地存储
  await StorageService.init();
  
  // 初始化网络客户端
  DioClient.init();
  
  // 尝试获取视频播放token（如果用户已登录）
  _tryFetchVideoToken();
  
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
        ChangeNotifierProvider(create: (_) => VideoPlayerProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'TAMA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: AppRouter.router,
            // 添加错误处理
            builder: (context, child) {
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
