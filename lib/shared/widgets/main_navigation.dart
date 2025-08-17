// APP 主导航栏
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

// import '../utils/error_utils.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            currentIndex: _getCurrentIndex(context),
            onTap: (index) => _onTabTapped(context, index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore),
                label: FlutterI18n.translate(context, 'home.tabbar.home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.face_retouching_natural),
                label: FlutterI18n.translate(context, 'home.tabbar.following'),
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.add_box),
              //   label: FlutterI18n.translate(context, 'home.tabbar.create'),
              // ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.people),
              //   label: FlutterI18n.translate(context, 'tabbar.fans'),
              // ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_bubble),
                label: FlutterI18n.translate(context, 'home.tabbar.message'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: FlutterI18n.translate(context, 'home.tabbar.profile'),
              ),
            ],
          );
        },
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final location = routerState.uri.toString();
    switch (location) {
      case '/home':
        return 0;
      case '/following':
        return 1;
      // case '/fans':
      //   return 2;
      case '/message':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/following');
        break;
      // case 2:
      //   context.go('/fans');
      //   break;
      // case 3:
      //   // TODO: 实现发布功能
      //   ErrorUtils.showWarning(
      //     context,
      //     '发布功能暂未开放',
      //   );
      //   break;
      case 2:
        context.go('/message');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
