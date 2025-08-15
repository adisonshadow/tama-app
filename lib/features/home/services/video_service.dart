import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/services/network_service.dart';

class VideoService {
  static Future<Map<String, dynamic>> getRandomVideos({
    int page = 1,
    int pageSize = 20,
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/articles/random', queryParameters: {
          'page_size': pageSize,
        }),
        errorKey: 'get_random_videos',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '获取随机视频失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> getRecommendedVideos({
    int page = 1,
    int pageSize = 20,
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/articles/recommended2', queryParameters: {
          'page': page,
          'page_size': pageSize,
        }),
        errorKey: 'get_recommended_videos',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '获取推荐视频失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> getHotVideos({
    int page = 1,
    int pageSize = 20,
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/articles/hot', queryParameters: {
          'page': page,
          'page_size': pageSize,
        }),
        errorKey: 'get_hot_videos',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '获取热门视频失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> getShortVideos({
    int page = 1,
    int pageSize = 20,
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/articles/short', queryParameters: {
          'page': page,
          'page_size': pageSize,
        }),
        errorKey: 'get_short_videos',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '获取短视频失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> getVideoDetail(
    String videoId, {
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/articles/$videoId'),
        errorKey: 'get_video_detail_$videoId',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '获取视频详情失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }

  /// 切换视频点赞状态
  /// 接口: GET /api/my/toggleLikeArticle/{articleId}
  /// 功能: 切换点赞状态
  static Future<Map<String, dynamic>> likeVideo(
    String videoId, {
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/my/toggleLikeArticle/$videoId'),
        errorKey: 'like_video_$videoId',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '点赞操作失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }

  /// 切换视频收藏状态
  /// 接口: GET /api/my/toggleStarArticle/{articleId}
  /// 功能: 切换收藏状态
  static Future<Map<String, dynamic>> starVideo(
    String videoId, {
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/my/toggleStarArticle/$videoId'),
        errorKey: 'star_video_$videoId',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '收藏操作失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }

  /// 根据标签获取推荐视频
  /// 接口: GET /api/my/articles/getRecommendsByTag/{tagname}
  /// 功能: 获取指定标签下的推荐视频列表
  static Future<Map<String, dynamic>> getVideosByTag({
    required String tagName,
    int page = 1,
    int pageSize = 20,
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get(
          '/my/articles/getRecommendsByTag/$tagName',
          queryParameters: {
            'page': page,
            'page_size': pageSize,
          },
        ),
        errorKey: 'get_videos_by_tag_$tagName',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '获取标签视频失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }
}
