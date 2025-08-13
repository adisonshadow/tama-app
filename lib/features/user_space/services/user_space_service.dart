import '../../../core/network/dio_client.dart';

class UserSpaceService {
  /// 获取用户文章列表
  /// 接口: GET /api/articles/user/getArticlesByUserId/{user_id}
  /// 功能: 获取指定用户的所有文章
  /// 参数: page - 页码, page_size - 每页数量
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
