import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/follow_service.dart';

class FollowProvider extends ChangeNotifier {
  final Map<String, bool> _followStatus = {};
  final Map<String, bool> _loadingStatus = {};

  /// 获取指定用户的关注状态
  bool isFollowing(String userId) {
    return _followStatus[userId] ?? false;
  }

  /// 获取指定用户的加载状态
  bool isLoading(String userId) {
    return _loadingStatus[userId] ?? false;
  }

  /// 检查关注状态
  Future<void> checkFollowStatus(String userId) async {
    try {
      final response = await FollowService.checkFollowStatus(userId);
      if (response['status'] == 'SUCCESS') {
        _followStatus[userId] = response['data']['isFollowed'] ?? false;
        notifyListeners();
      } else {
        // 显示错误消息
        _showToastMessage(response['message'] ?? '检查关注状态失败');
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 检查关注状态失败: $e');
      }
      _showToastMessage('网络错误，请稍后重试');
    }
  }

  /// 切换关注状态
  Future<bool> toggleFollow(String userId) async {
    if (_loadingStatus[userId] == true) return false;

    try {
      _loadingStatus[userId] = true;
      notifyListeners();

      final response = await FollowService.toggleFollow(userId);
      
      if (response['status'] == 'SUCCESS') {
        final newStatus = response['data']['isFollowed'] ?? false;
        _followStatus[userId] = newStatus;
        
        // 显示成功消息
        _showToastMessage(
          newStatus ? '关注成功' : '取消关注成功',
          isSuccess: true,
        );
        
        if (kIsWeb) {
          debugPrint('✅ 关注状态切换成功: $userId -> ${newStatus ? "已关注" : "未关注"}');
        }
        
        notifyListeners();
        return true;
      } else {
        // 显示错误消息
        final errorMessage = response['message'] ?? '操作失败';
        _showToastMessage(errorMessage);
        
        if (kIsWeb) {
          debugPrint('❌ 关注状态切换失败: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 关注状态切换异常: $e');
      }
      _showToastMessage('网络错误，请稍后重试');
      return false;
    } finally {
      _loadingStatus[userId] = false;
      notifyListeners();
    }
  }

  /// 批量检查多个用户的关注状态
  Future<void> checkMultipleFollowStatus(List<String> userIds) async {
    for (final userId in userIds) {
      await checkFollowStatus(userId);
    }
  }

  /// 清除指定用户的关注状态缓存
  void clearFollowStatus(String userId) {
    _followStatus.remove(userId);
    _loadingStatus.remove(userId);
    notifyListeners();
  }

  /// 清除所有关注状态缓存
  void clearAllFollowStatus() {
    _followStatus.clear();
    _loadingStatus.clear();
    notifyListeners();
  }

  /// 显示Toast消息
  void _showToastMessage(String message, {bool isSuccess = false}) {
    // 使用全局的ScaffoldMessenger来显示消息
    // 这里需要传入BuildContext，所以我们改为在调用处处理
    if (kIsWeb) {
      debugPrint('${isSuccess ? "✅" : "❌"} Toast: $message');
    }
  }

  /// 显示Toast消息（需要BuildContext）
  static void showToastMessage(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
