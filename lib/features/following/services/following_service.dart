import '../../../core/network/dio_client.dart';

class FollowingService {
  static Future<Map<String, dynamic>> getMyFollows({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 FollowingService - 调用 getMyFollows API: /my/getMyFollows');
      final response = await DioClient.instance.get('/my/getMyFollows', queryParameters: {
        'page': page,
        'page_size': limit, // 修复：使用page_size而不是limit
      });
      print('🔍 FollowingService - getMyFollows 响应: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ FollowingService - getMyFollows 错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getFollowingArticles({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 FollowingService - 调用 getFollowingArticles API: /articles/following');
      final response = await DioClient.instance.get('/articles/following', queryParameters: {
        'page': page,
        'page_size': limit, // 修复：使用page_size而不是limit
      });
      print('🔍 FollowingService - getFollowingArticles 响应: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ FollowingService - getFollowingArticles 错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      print('🔍 FollowingService - 调用 followUser API: /my/follow');
      final response = await DioClient.instance.post('/my/follow', data: {
        'user_id': userId,
      });
      print('🔍 FollowingService - followUser 响应: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ FollowingService - followUser 错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      print('🔍 FollowingService - 调用 unfollowUser API: /my/unfollow');
      final response = await DioClient.instance.delete('/my/unfollow', data: {
        'user_id': userId,
      });
      print('🔍 FollowingService - unfollowUser 响应: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ FollowingService - unfollowUser 错误: $e');
      rethrow;
    }
  }
}
