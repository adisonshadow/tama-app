import '../../../core/network/dio_client.dart';

class LikedService {
  static Future<Map<String, dynamic>> getMyLiked({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      const url = '/my/liked';
      final params = {'page': page, 'page_size': pageSize};
      
      // print('🔍 LikedService - 调用 getMyLiked API');
      // print('🔍 LikedService - URL: $url');
      // print('🔍 LikedService - 参数: $params');
      
      final response = await DioClient.instance.get(url, queryParameters: params);
      
      // print('🔍 LikedService - 响应状态码: ${response.statusCode}');
      // print('🔍 LikedService - 响应数据: ${response.data}');
      
      return response.data;
    } catch (e) {
      print('❌ LikedService - getMyLiked 错误: $e');
      rethrow;
    }
  }
}
