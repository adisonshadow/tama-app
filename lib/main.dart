import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'core/network/dio_client.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/video_provider.dart';
import 'features/following/providers/following_provider.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/video_token_manager.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Tama2',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              colorScheme: const ColorScheme.dark(
                primary: Colors.blue,
                secondary: Colors.pink,
                surface: Colors.black,
              ),
              useMaterial3: true,
            ),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
