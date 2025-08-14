// APP 主导航栏
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/error_utils.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '推荐',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_retouching_natural),
            label: '关注',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.add_box),
          //   label: '发布',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我',
          ),
        ],
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
      case '/message':
        return 2;
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
        // TODO: 实现个人中心
        ErrorUtils.showWarning(
          context,
          '个人中心功能暂未开放',
        );
        break;
    }
  }
}
