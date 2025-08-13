import '../../../core/network/dio_client.dart';

class VideoService {
  static Future<Map<String, dynamic>> getRandomVideos({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'count': limit,
      };
      final response = await DioClient.instance.get('/articles/random', queryParameters: queryParams);
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getRecommendedVideos({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioClient.instance.get('/articles/recommended2', queryParameters: {
        'page': page,
        'page_size': limit,
      });
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getHotVideos({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioClient.instance.get('/articles/hot', queryParameters: {
        'page': page,
        'page_size': limit,
      });
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getShortVideos({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioClient.instance.get('/articles/short', queryParameters: {
        'page': page,
        'page_size': limit,
      });
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getVideoDetail(String videoId) async {
    try {
      final response = await DioClient.instance.get('/articles/$videoId');
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 切换视频点赞状态
  /// 接口: GET /api/my/toggleLikeArticle/{articleId}
  /// 功能: 切换点赞状态
  static Future<Map<String, dynamic>> likeVideo(String videoId) async {
    try {
      final response = await DioClient.instance.get('/my/toggleLikeArticle/$videoId');
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// 切换视频收藏状态
  /// 接口: GET /api/my/toggleStarArticle/{articleId}
  /// 功能: 切换收藏状态
  static Future<Map<String, dynamic>> starVideo(String videoId) async {
    try {
      final response = await DioClient.instance.get('/my/toggleStarArticle/$videoId');
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
