import '../../../core/network/dio_client.dart';

class FollowService {
  /// 检查是否已关注用户
  /// [targetUserId] 目标用户ID
  /// 返回: {"status": "SUCCESS", "data": {"is_following": true/false}}
  static Future<Map<String, dynamic>> checkFollowStatus(String targetUserId) async {
    try {
      final response = await DioClient.instance.get('/my/isFollowed/$targetUserId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 切换关注状态
  /// [targetUserId] 目标用户ID
  /// 返回: {"status": "SUCCESS", "data": {"is_following": true/false}}
  static Future<Map<String, dynamic>> toggleFollow(String targetUserId) async {
    try {
      final response = await DioClient.instance.post('/my/toggleFollow/$targetUserId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
