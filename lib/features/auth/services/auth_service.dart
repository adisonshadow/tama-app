import '../../../core/network/dio_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await DioClient.instance.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String nickname) async {
    try {
      final response = await DioClient.instance.post('/auth/register', data: {
        'email': email,
        'password': password,
        'nickname': nickname,
      });
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await DioClient.instance.get('/auth/current');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await DioClient.instance.post('/auth/logout');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await DioClient.instance.post('/auth/refresh');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
