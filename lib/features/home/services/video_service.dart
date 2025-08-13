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

  static Future<Map<String, dynamic>> likeVideo(String videoId) async {
    try {
      final response = await DioClient.instance.post('/my/like', data: {
        'article_id': videoId,
      });
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> starVideo(String videoId) async {
    try {
      final response = await DioClient.instance.post('/my/star', data: {
        'article_id': videoId,
      });
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
