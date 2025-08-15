import '../../../core/network/dio_client.dart';

class StarredService {
  static Future<Map<String, dynamic>> getMyStarred({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      const url = '/my/starred';
      final params = {'page': page, 'page_size': pageSize};
      
      // print('🔍 StarredService - 调用 getMyStarred API');
      // print('🔍 StarredService - URL: $url');
      // print('🔍 StarredService - 参数: $params');
      
      final response = await DioClient.instance.get(url, queryParameters: params);
      
      // print('🔍 StarredService - 响应状态码: ${response.statusCode}');
      // print('🔍 StarredService - 响应数据: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ StarredService - getMyStarred 错误: $e');
      rethrow;
    }
  }
}
