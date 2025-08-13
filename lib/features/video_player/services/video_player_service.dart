import '../../home/models/video_model.dart';
import '../../user_space/services/user_space_service.dart';

class VideoPlayerService {
  /// 获取用户的视频列表
  static Future<List<VideoModel>> getUserVideos(String userId) async {
    try {
      final response = await UserSpaceService.getUserVideos(userId: userId);
      
      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        return videoData
            .map((json) => VideoModel.fromJsonSafe(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// 获取指定索引范围的视频列表
  static Future<List<VideoModel>> getVideosInRange(
    String userId, {
    int startIndex = 0,
    int count = 20,
  }) async {
    try {
      final response = await UserSpaceService.getUserVideos(
        userId: userId,
        page: (startIndex ~/ count) + 1,
        limit: count,
      );
      
      if (response['status'] == 'SUCCESS') {
        final List<dynamic> videoData = response['data'] ?? [];
        final videos = videoData
            .map((json) => VideoModel.fromJsonSafe(json))
            .toList();
        
        // 返回指定范围的视频
        final start = startIndex % count;
        final end = start + count;
        if (start < videos.length) {
          return videos.sublist(start, end > videos.length ? videos.length : end);
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}
