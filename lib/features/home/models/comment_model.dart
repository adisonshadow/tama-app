class CommentModel {
  final int id;
  final String content;
  final String nickname;
  final String? avatar;
  final DateTime createdAt;
  final double start; // 视频播放时长
  final String articleId; // 文章/视频ID

  CommentModel({
    required this.id,
    required this.content,
    required this.nickname,
    this.avatar,
    required this.createdAt,
    required this.start,
    required this.articleId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      nickname: json['nickname'] ?? '用户${json['id']}',
      avatar: json['avatar'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      start: json['start'] != null 
          ? double.tryParse(json['start'].toString()) ?? 0.0
          : 0.0,
      articleId: json['article_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'nickname': nickname,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'start': start,
      'article_id': articleId,
    };
  }
}

class CreateCommentRequest {
  final String content;
  final double start;
  final String articleId;

  CreateCommentRequest({
    required this.content,
    required this.start,
    required this.articleId,
  });

  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) {
    return CreateCommentRequest(
      content: json['content'] ?? '',
      start: (json['start'] ?? 0.0).toDouble(),
      articleId: json['article_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'start': start,
      'article_id': articleId,
    };
  }
}
