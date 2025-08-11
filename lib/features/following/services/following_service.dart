import '../../../core/network/dio_client.dart';

class FollowingService {
  static Future<Map<String, dynamic>> getMyFollows({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioClient.instance.get('/my/getMyFollows', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getFollowingArticles({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioClient.instance.get('/articles/following', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      final response = await DioClient.instance.post('/my/follow', data: {
        'user_id': userId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      final response = await DioClient.instance.delete('/my/unfollow', data: {
        'user_id': userId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
