import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/app_constants.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  final String id;
  final String title;
  final String content;
  @JsonKey(name: 'user_id')
  final String userId;
  final String? nickname;
  final String? avatar;
  @JsonKey(name: 'videoHash')
  final String? videoHash;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @JsonKey(name: 'cover_type')
  final int coverType;
  @JsonKey(name: 'view_count')
  final int viewCount;
  @JsonKey(name: 'liked_count')
  final int likedCount;
  @JsonKey(name: 'starred_count')
  final int starredCount;
  @JsonKey(name: 'is_short')
  final int isShort;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'tags')
  final List<String>? tags;
  
  // 用户交互状态
  @JsonKey(name: 'isLiked')
  final bool? isLiked;
  @JsonKey(name: 'isStarred')
  final bool? isStarred;
  @JsonKey(name: 'isFollowing')
  final bool? isFollowing;

  const VideoModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.nickname,
    this.avatar,
    this.videoHash,
    this.coverUrl,
    this.coverType = 0,
    this.viewCount = 0,
    this.likedCount = 0,
    this.starredCount = 0,
    this.isShort = 0,
    required this.createdAt,
    this.tags,
    this.isLiked,
    this.isStarred,
    this.isFollowing,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);
  
  /// 更健壮的JSON解析方法，处理可能的null值和类型转换问题
  factory VideoModel.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return VideoModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        nickname: json['nickname']?.toString(),
        avatar: json['avatar']?.toString(),
        videoHash: json['videoHash']?.toString(),
        coverUrl: json['cover_url']?.toString(),
        coverType: _safeIntFromJson(json['cover_type']),
        viewCount: _safeIntFromJson(json['view_count']),
        likedCount: _safeIntFromJson(json['liked_count']),
        starredCount: _safeIntFromJson(json['starred_count']),
        isShort: _safeIntFromJson(json['is_short']),
        createdAt: json['created_at']?.toString() ?? '',
        tags: _safeStringListFromJson(json['tags']),
        isLiked: json['isLiked'] as bool?,
        isStarred: json['isStarred'] as bool?,
        isFollowing: json['isFollowing'] as bool?,
      );
    } catch (e) {
      throw FormatException('Failed to parse VideoModel from JSON: $e\nJSON: $json');
    }
  }
  
  /// 安全地将JSON值转换为int
  static int _safeIntFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }
  
  /// 安全地将JSON值转换为字符串列表
  static List<String>? _safeStringListFromJson(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    if (value is String) {
      return value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
    }
    return null;
  }
  
  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  String get videoUrl {
    if (videoHash != null) {
      // 参考web端的逻辑：使用stream接口
      return '${AppConstants.baseUrl}/api/media/stream?filename=$videoHash#.m3u8';
    }
    return '';
  }

  String get thumbnailUrl {
    // 基于web项目的实现逻辑
    if (coverType == 1 && coverUrl != null && coverUrl!.isNotEmpty) {
      // 如果有自定义封面图，使用 /api/image/ 接口
      return '${AppConstants.baseUrl}/api/image/$coverUrl';
    } else if (videoHash != null && videoHash!.isNotEmpty) {
      // 否则根据视频hash生成封面图，使用 /api/media/getCover 接口
      const coverIndex = 1; // 默认使用第1帧作为封面
      return '${AppConstants.baseUrl}/api/media/getCover?hash=$videoHash&index=$coverIndex';
    }
    return '';
  }

  /// 获取带resize参数的封面图URL，完全匹配web项目的实现
  String getCoverByRecord([String? resize]) {
    var cover = '';
    resize = resize ?? '';
    
    if (coverType == 1 || (coverUrl != null && coverUrl!.isNotEmpty)) {
      cover = '${AppConstants.baseUrl}/api/image/$coverUrl?$resize';
    } else if (videoHash != null && videoHash!.isNotEmpty) {
      const coverIndex = 1; // 对应web项目中的 selected_screen_index || 1
      cover = '${AppConstants.baseUrl}/api/media/getCover?hash=$videoHash&index=$coverIndex&$resize';
    }
    return cover;
  }

  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!;
  }
}
