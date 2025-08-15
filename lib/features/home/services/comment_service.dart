import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/comment_model.dart';

class CommentService {
  final Dio _dio = DioClient.instance;

  /// 获取视频评论列表
  Future<List<CommentModel>> getComments(String articleId) async {
    try {
      // print('🔍 正在获取评论，articleId: $articleId');
      final response = await _dio.get('/articles/danmus/$articleId');
      
      // print('🔍 API响应状态码: ${response.statusCode}');
      // print('🔍 API响应数据: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        // print('🔍 解析到的评论数据: $data');
        
        final comments = data.map((json) => CommentModel.fromJson(json)).toList();
        // print('🔍 解析后的评论对象: $comments');
        
        return comments;
      } else {
        throw Exception('获取评论失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 获取评论异常: $e');
      throw Exception('获取评论失败: $e');
    }
  }

  /// 发布评论
  Future<bool> createComment(String content, double start, String articleId) async {
    try {
      final request = CreateCommentRequest(
        content: content,
        start: start,
        articleId: articleId,
      );

      final response = await _dio.post(
        '/my/createDanmaku',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('发布评论失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('发布评论失败: $e');
    }
  }
}
