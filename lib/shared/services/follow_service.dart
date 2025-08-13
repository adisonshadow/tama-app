import '../../../core/network/dio_client.dart';

class FollowService {
  /// 检查是否已关注用户
  /// [targetUserId] 目标用户ID
  /// 返回: {"status": "SUCCESS", "data": {"isFollowed": true/false}}
  static Future<Map<String, dynamic>> checkFollowStatus(String targetUserId) async {
    try {
      final response = await DioClient.instance.get('/my/isFollowed/$targetUserId');
      return DioClient.handleApiResponse(response);
    } catch (e) {
      // 只有在网络异常等情况下才会抛出异常
      rethrow;
    }
  }

  /// 切换关注状态
  /// [targetUserId] 目标用户ID
  /// 返回: {"status": "SUCCESS", "data": {"isFollowed": true/false}}
  static Future<Map<String, dynamic>> toggleFollow(String targetUserId) async {
    try {
      final response = await DioClient.instance.post('/my/toggleFollow/$targetUserId');
      return DioClient.handleApiResponse(response);
    } catch (e) {
      // 只有在网络异常等情况下才会抛出异常
      rethrow;
    }
  }
}
