import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../../core/network/dio_client.dart';

class FollowProvider extends ChangeNotifier {
  final Map<String, bool> _followStatus = {};
  final Map<String, bool> _loadingStatus = {};

  /// 获取指定用户的关注状态
  bool isFollowing(String userId) {
    return _followStatus[userId] ?? false;
  }

  /// 检查是否已经有指定用户的关注状态缓存
  bool hasFollowStatus(String userId) {
    return _followStatus.containsKey(userId);
  }

  /// 获取指定用户的加载状态
  bool isLoading(String userId) {
    return _loadingStatus[userId] ?? false;
  }

  /// 检查关注状态
  Future<void> checkFollowStatus(String userId) async {
    // 如果已经有状态且不在加载中，直接返回
    if (_followStatus.containsKey(userId) && _loadingStatus[userId] != true) {
      return;
    }

    try {
      _loadingStatus[userId] = true;
      notifyListeners();

      final response = await FollowService.checkFollowStatus(userId);
      
      if (DioClient.isApiSuccess(response)) {
        final newStatus = response['data']['isFollowed'] ?? false;
        // 只有当状态真正改变时才更新和通知
        if (_followStatus[userId] != newStatus) {
          _followStatus[userId] = newStatus;
          notifyListeners();
        }
      } else {
        // 记录错误日志，但不显示Toast（由UI组件处理）
        if (kIsWeb) {
          debugPrint('❌ 检查关注状态失败: ${DioClient.getApiErrorMessage(response)}');
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 检查关注状态异常: $e');
      }
    } finally {
      _loadingStatus[userId] = false;
      notifyListeners();
    }
  }

  /// 切换关注状态
  Future<bool> toggleFollow(String userId) async {
    if (_loadingStatus[userId] == true) return false;

    try {
      _loadingStatus[userId] = true;
      notifyListeners();

      final response = await FollowService.toggleFollow(userId);
      
      if (DioClient.isApiSuccess(response)) {
        final newStatus = response['data']['isFollowed'] ?? false;
        _followStatus[userId] = newStatus;
        
        if (kIsWeb) {
          debugPrint('✅ 关注状态切换成功: $userId -> ${newStatus ? "已关注" : "未关注"}');
        }
        
        notifyListeners();
        return true;
      } else {
        // 记录错误日志，但不显示Toast（由UI组件处理）
        final errorMessage = DioClient.getApiErrorMessage(response);
        if (kIsWeb) {
          debugPrint('❌ 关注状态切换失败: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 关注状态切换异常: $e');
      }
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
