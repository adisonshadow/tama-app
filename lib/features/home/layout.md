
## 文件位置：lib/features/home/widgets/video_action_buttons.dart
右侧按钮组 (Positioned: right: 10, bottom: 20)
├── 作者头像
│   ├── 头像容器：68x68，圆形，白色边框
│   ├── 头像图片：从API获取，默认显示person图标
│   └── 关注按钮：20x20，圆形，位于头像下方，上半部分与头像重叠50%
│       ├── 未关注状态：红色底，白色+号图标
│       └── 已关注状态：白色底，深灰色☑️图标
│       └── 点击行为：
│           ├── 关注：显示"已关注"toast，图标变为已关注状态
│           └── 取消关注：显示"已取消关注"toast，图标变为未关注状态
├── SizedBox(height: 15)
├── 点赞按钮
├── SizedBox(height: 15)
├── 评论按钮
├── SizedBox(height: 15)
├── 收藏按钮
├── SizedBox(height: 15)
└── 分享按钮

## 文件位置：lib/features/home/widgets/video_item_widget.dart
底部视频信息容器 (Positioned: left: 5, right: 100, bottom: 20)
├── 第一行：@作者名 + SizedBox(width: 10) + 时间(透明度50%)
├── SizedBox(height: 8)
└── 第二行：视频标题 + #标签1 + #标签2... (最多2行，超出用...)