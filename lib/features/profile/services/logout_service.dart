import '../../../core/network/dio_client.dart';

class LogoutService {
  static Future<Map<String, dynamic>> logout() async {
    try {
      const url = '/auth/logout';
      
      // print('🔍 LogoutService - 调用 logout API');
      // print('🔍 LogoutService - URL: $url');
      
      final response = await DioClient.instance.post(url);
      
      // print('🔍 LogoutService - 响应状态码: ${response.statusCode}');
      // print('🔍 LogoutService - 响应数据: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ LogoutService - logout 错误: $e');
      rethrow;
    }
  }
}
