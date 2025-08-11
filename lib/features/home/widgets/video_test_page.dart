import 'package:flutter/material.dart';

import '../models/video_model.dart';
import 'video_player_widget.dart';

class VideoTestPage extends StatefulWidget {
  const VideoTestPage({super.key});

  @override
  State<VideoTestPage> createState() => _VideoTestPageState();
}

class _VideoTestPageState extends State<VideoTestPage> {
  late VideoModel _testVideo;

  @override
  void initState() {
    super.initState();
    
    // 创建测试视频
    _testVideo = VideoModel(
      id: 'test_video_1',
      title: '测试视频',
      content: '这是一个测试视频',
      userId: 'author_1',
      nickname: '测试作者',
      avatar: 'https://example.com/author-avatar.jpg',
      coverUrl: 'https://example.com/test-cover.jpg',
      videoHash: 'test-video-hash',
      likedCount: 100,
      starredCount: 50,
      viewCount: 20,
      createdAt: DateTime.now().toIso8601String(),
      isShort: 0,
      coverType: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放测试'),
      ),
      body: Center(
        child: VideoPlayerWidget(
          video: _testVideo,
          isActive: true,
        ),
      ),
    );
  }
}