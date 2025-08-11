import '../../../core/network/dio_client.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserInfoById(String userId) async {
    try {
      final response = await DioClient.instance.get('/user/getUserInfoById/$userId');
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
