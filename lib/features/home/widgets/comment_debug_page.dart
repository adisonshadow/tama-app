import 'package:flutter/material.dart';
import 'comment_sheet.dart';

class CommentDebugPage extends StatefulWidget {
  const CommentDebugPage({super.key});

  @override
  State<CommentDebugPage> createState() => _CommentDebugPageState();
}

class _CommentDebugPageState extends State<CommentDebugPage> {
  final TextEditingController _videoIdController = TextEditingController(
    text: 'edcc6537-a004-4f8f-902f-2baa6ac34e4f', // 默认测试ID
  );

  @override
  void dispose() {
    _videoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评论功能调试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '评论功能调试页面',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // 视频ID输入
            TextField(
              controller: _videoIdController,
              decoration: const InputDecoration(
                labelText: '视频ID',
                hintText: '输入要测试的视频ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.video_library),
              ),
            ),
            const SizedBox(height: 20),
            
            // 测试按钮
            ElevatedButton(
              onPressed: () {
                final videoId = _videoIdController.text.trim();
                if (videoId.isNotEmpty) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => CommentSheet(
                      videoId: videoId,
                      currentTime: 30.5,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入视频ID')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '打开评论弹窗',
                style: TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 说明文字
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '调试说明：',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1. 输入要测试的视频ID\n'
                    '2. 点击"打开评论弹窗"按钮\n'
                    '3. 查看控制台输出的调试信息\n'
                    '4. 检查评论列表是否正确显示\n'
                    '5. 测试发布评论功能',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 当前配置信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前配置：',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('API基础URL: http://localhost:5200'),
                  Text('评论列表接口: /articles/danmus/{article_id}'),
                  Text('发布评论接口: /my/createDanmaku'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
