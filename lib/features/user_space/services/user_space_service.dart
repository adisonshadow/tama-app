import '../../../core/network/dio_client.dart';

class UserSpaceService {
  static Future<Map<String, dynamic>> getUserVideos({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioClient.instance.get('/articles/user/getArticlesByUserId/$userId', queryParameters: {
        'page': page,
        'page_size': limit,
      });
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
