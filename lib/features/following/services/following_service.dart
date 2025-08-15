import '../../../core/network/dio_client.dart';

class FollowingService {
  static Future<Map<String, dynamic>> getMyFollows({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      const url = '/my/followings';
      final params = {'page': page, 'page_size': pageSize};
      
      // print('🔍 FollowingService - 调用 getMyFollows API');
      // print('🔍 FollowingService - URL: $url');
      // print('🔍 FollowingService - 参数: $params');
      
      final response = await DioClient.instance.get(url, queryParameters: params);
      
      // print('🔍 FollowingService - 响应状态码: ${response.statusCode}');
      // print('🔍 FollowingService - 响应数据: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ FollowingService - getMyFollows 错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getFollowingArticles({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // print('🔍 FollowingService - 调用 getFollowingArticles API: /articles/following');
      final response = await DioClient.instance.get('/articles/following', queryParameters: {
        'page': page,
        'page_size': pageSize, // 修复：使用page_size而不是limit
      });
      // print('🔍 FollowingService - getFollowingArticles 响应: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ FollowingService - getFollowingArticles 错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      // print('🔍 FollowingService - 调用 followUser API: /my/follow');
      final response = await DioClient.instance.post('/my/follow', data: {
        'user_id': userId,
      });
      // print('🔍 FollowingService - followUser 响应: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ FollowingService - followUser 错误: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      // print('🔍 FollowingService - 调用 unfollowUser API: /my/unfollow');
      final response = await DioClient.instance.delete('/my/unfollow', data: {
        'user_id': userId,
      });
      // print('🔍 FollowingService - unfollowUser 响应: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ FollowingService - unfollowUser 错误: $e');
      rethrow;
    }
  }
}
