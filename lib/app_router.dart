import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/following/screens/following_screen.dart';
import 'features/message/screens/message_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/fans_screen.dart';
import 'features/home/widgets/video_test_page.dart';
import 'shared/widgets/main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;
      final currentPath = state.uri.toString();
      final isAuthRoute = currentPath.startsWith('/auth');
      
      // 如果未登录且不在认证页面，跳转到登录页
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth/login';
      }
      
      // 如果已登录且在认证页面，跳转到首页
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // 认证路由
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // 主要功能路由
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/following',
            builder: (context, state) => const FollowingScreen(),
          ),
          GoRoute(
            path: '/message',
            builder: (context, state) => const MessageScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/fans',
            builder: (context, state) => const FansScreen(),
          ),
          GoRoute(
            path: '/video-test',
            builder: (context, state) => const VideoTestPage(),
          ),
        ],
      ),
    ],
  );
}
