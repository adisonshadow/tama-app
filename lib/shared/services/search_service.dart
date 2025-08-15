import '../../core/network/dio_client.dart';

class SearchService {
  /// 搜索文章/视频
  static Future<Map<String, dynamic>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await DioClient.instance.get(
        '/articles/search',
        queryParameters: {
          'q': query,
          'page': page,
          'page_size': pageSize,
        },
      );
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
