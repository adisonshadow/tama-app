# 评论功能实现说明

## 功能概述
实现了视频评论的发布和展示功能，包括：
- 评论列表展示
- 发布新评论
- 评论时间戳显示（视频播放时间）
- 表情选择器
- 防恶意评论机制（5分钟内最多100条）
- 发送成功提示

## 组件结构

### 1. CommentModel (评论模型)
- `id`: 评论ID
- `content`: 评论内容
- `nickname`: 用户昵称
- `avatar`: 用户头像
- `createdAt`: 创建时间
- `start`: 视频播放时间点
- `articleId`: 视频ID

### 2. CommentService (评论服务)
- `getComments(String articleId)`: 获取视频评论列表
- `createComment(String content, double start, String articleId)`: 发布新评论

### 3. CommentSheet (评论弹窗)
- 屏幕高度2/3的底部弹窗
- 评论列表展示
- 发布评论输入框
- 支持多行输入
- 表情选择器（64个常用表情）
- 剩余评论数量显示

### 4. CommentRateLimiter (评论频率限制器)
- 防止恶意连续评论
- 5分钟内最多100条评论
- 智能时间窗口管理
- 自动清理过期数据

## API接口

### 获取评论列表
```
GET /api/danmus/{article_id}
```

### 发布评论
```
POST /api/my/createDanmaku
Body: {
  "content": "评论内容",
  "start": 视频播放时间(秒),
  "article_id": "视频ID"
}
```

## 使用方法

在VideoPlaybackComponent中，点击评论按钮会调用：
```dart
void _showCommentSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => CommentSheet(
      videoId: widget.video.id,
      currentTime: 0.0, // TODO: 获取当前视频播放时间
    ),
  );
}
```

## 待优化项
1. 获取当前视频播放时间，用于评论的时间戳
2. 添加评论分页加载
3. 添加评论点赞功能
4. 添加评论回复功能
5. 优化评论列表性能（虚拟滚动）
6. 集成真实的用户认证系统
7. 添加评论内容过滤和敏感词检测
8. 优化表情选择器的性能
