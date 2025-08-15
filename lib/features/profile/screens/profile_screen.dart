import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../providers/fan_provider.dart';
import '../providers/liked_provider.dart';
import '../providers/starred_provider.dart';
import '../services/logout_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'fans_screen.dart';
import 'liked_screen.dart';
import 'starred_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (kIsWeb) {
      // debugPrint('🔍 ProfileScreen initState');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => FanProvider()),
        ChangeNotifierProvider(create: (context) => LikedProvider()),
        ChangeNotifierProvider(create: (context) => StarredProvider()),
      ],
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          // 初始化时获取用户信息
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (profileProvider.user == null && !profileProvider.isLoading) {
              profileProvider.getCurrentUser();
            }
          });

          return Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              children: [
                _buildUserHeader(profileProvider),
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(ProfileProvider profileProvider) {
    final user = profileProvider.user;
    
    return Container(
      height: 240,
      padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: _buildBackgroundImage(profileProvider),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 编辑按钮
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (kIsWeb) {
                        // debugPrint('🔍 编辑按钮被点击');
                      }
                      _navigateToEditProfile(context, user);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // 退出按钮
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (kIsWeb) {
                        // debugPrint('🔍 退出按钮被点击');
                      }
                      _showLogoutDialog(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(44),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: _buildAvatarImage(user?.avatar),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.nickname ?? '加载中...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.bio ?? '这个人很懒，还没有写简介',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(ProfileProvider profileProvider) {
    final user = profileProvider.user;
    
    if (user?.spaceBg != null && user!.spaceBg!.isNotEmpty) {
      return Image.network(
        '${AppConstants.baseUrl}/api/image/${user.spaceBg}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (kIsWeb) {
            debugPrint('❌ 封面图片加载失败: $error，使用默认背景');
          }
          return _buildDefaultBackground();
        },
      );
    } else {
      return _buildDefaultBackground();
    }
  }

  Widget _buildDefaultBackground() {
    return Image.asset(
      'assets/images/space_bg.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (kIsWeb) {
          debugPrint('❌ 默认背景图片加载失败: $error，使用纯色背景');
        }
        return Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(
              Icons.image,
              color: Colors.grey,
              size: 64,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarImage(String? avatar) {
    if (avatar != null && avatar.isNotEmpty) {
      return Image.network(
        '${AppConstants.baseUrl}/api/image/$avatar',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (kIsWeb) {
            debugPrint('❌ 头像加载失败: $error，使用默认头像');
          }
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 64,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        tabs: const [
          Tab(text: '粉丝'),
          Tab(text: '点赞'),
          Tab(text: '收藏'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFansTab(),
        _buildLikesTab(),
        _buildFavoritesTab(),
      ],
    );
  }

  Widget _buildFansTab() {
    return const FansScreen();
  }

  Widget _buildLikesTab() {
    return const LikedScreen();
  }

  Widget _buildFavoritesTab() {
    return const StarredScreen();
  }

  void _navigateToEditProfile(BuildContext context, user) {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('用户信息未加载，请稍后再试'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (kIsWeb) {
      // debugPrint('🔍 准备跳转到编辑资料页面');
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: user),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            '确认退出',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '确定要退出登录吗？',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      if (kIsWeb) {
        // debugPrint('🔍 开始执行登出操作');
      }

      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            backgroundColor: Colors.transparent,
            content: Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          );
        },
      );

      // 调用登出API
      final response = await LogoutService.logout();
      
      // 检查context是否仍然有效
      if (!context.mounted) return;
      
      // 关闭加载指示器
      Navigator.of(context).pop();

      if (response['status'] == 'SUCCESS') {
        if (kIsWeb) {
          // debugPrint('🔍 登出成功');
        }
        
        // 显示成功消息
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登出成功'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // 清除本地用户数据并跳转到登录页
        // 调用AuthProvider的登出方法来清除本地状态
        if (context.mounted) {
          final authProvider = context.read<AuthProvider>();
          await authProvider.logout();
          
          // 使用go_router跳转到登录页
          if (context.mounted) {
            context.go('/auth/login');
          }
        }
      } else {
        if (kIsWeb) {
          debugPrint('❌ 登出失败: ${response['message']}');
        }
        
        // 显示错误消息
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('登出失败: ${response['message'] ?? '未知错误'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 检查context是否仍然有效
      if (!context.mounted) return;
      
      // 关闭加载指示器
      Navigator.of(context).pop();
      
      if (kIsWeb) {
        debugPrint('❌ 登出过程中发生错误: $e');
      }
      
      // 显示错误消息
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
