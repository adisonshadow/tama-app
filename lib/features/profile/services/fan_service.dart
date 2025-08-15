import '../../../core/network/dio_client.dart';

class FanService {
  static Future<Map<String, dynamic>> getMyFollowers({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      const url = '/my/followers';
      final params = {'page': page, 'page_size': pageSize};
      
      print('🔍 FanService - 调用 getMyFollowers API');
      print('🔍 FanService - URL: $url');
      print('🔍 FanService - 参数: $params');
      
      final response = await DioClient.instance.get(url, queryParameters: params);
      
      print('🔍 FanService - 响应状态码: ${response.statusCode}');
      print('🔍 FanService - 响应数据: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ FanService - getMyFollowers 错误: $e');
      rethrow;
    }
  }
}
