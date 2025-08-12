# 推荐页面布局结构

## 整体架构

```
HomeScreen (推荐页面)
├── Scaffold
│   ├── AppBar (透明背景)
│   │   ├── 左侧Logo区域
│   │   │   ├── Icon (video_collection, 蓝色)
│   │   │   └── Text ("TAMA2", 白色, 22px, 粗体)
│   │   └── 右侧操作区域
│   │       ├── IconButton (搜索图标, 白色)
│   │       └── PopupMenuButton (用户头像)
│   │           ├── CircleAvatar (用户头像或默认图标)
│   │           └── 弹出菜单
│   │               ├── 个人资料
│   │               ├── 设置
│   │               └── 退出登录
│   └── Body (Stack布局)
│       ├── 第1层: 红色调试背景层 (最底层) - 已注释，保留以备将来使用
│       │   └── Container (红色, 30%透明度, 全屏覆盖) - 已注释
│       ├── 第2层: 模糊背景层 (条件显示)
│       │   └── Stack
│       │       ├── ImageFiltered (模糊效果, sigma=15.0)
│       │       │   └── Container (基于视频封面的背景图)
│       │       └── Container (绿色, 20%透明度, 调试用)
│       ├── 第3层: 调试信息框 (始终显示)
│       │   └── Container (黑色半透明背景)
│       │       ├── Text (封面URL)
│       │       └── Text (URL长度)
│       └── 第4层: 主内容区域 (最上层)
│           └── Consumer<VideoProvider>
│               ├── 加载状态: CircularProgressIndicator
│               ├── 错误状态: 错误提示 + 重试按钮
│               └── 正常状态: SmartRefresher
│                   ├── WaterDropHeader (下拉刷新头部)
│                   ├── VideoFeedWidget (视频流)
│                   │   └── PageView.builder (垂直滚动)
│                   │       └── VideoItemWidget (单个视频项)
│                   │           ├── VideoPlayerWidget (视频播放器)
│                   │           │   ├── VideoView (视频内容)
│                   │           │   ├── 播放/暂停按钮
│                   │           │   └── 全屏按钮 (仅横屏视频)
│                   │           ├── 底部信息区域
│                   │           │   ├── 作者信息 (@用户名 + 时间)
│                   │           │   └── 视频描述 (标题 + 标签)
│                   │           └── 右侧操作按钮
│                   │               ├── 点赞按钮
│                   │               ├── 收藏按钮
│                   │               ├── 分享按钮
│                   │               └── 评论按钮
│                   └── CustomFooter (上拉加载更多底部)
```

## 关键特性

### 1. 透明AppBar
- `backgroundColor: Colors.transparent`
- `extendBodyBehindAppBar: true`
- 状态栏透明

### 2. 模糊背景系统
- 基于当前播放视频的封面图片
- 使用 `ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0)`
- 从屏幕顶部延伸到tabbar（不含tabbar）
- 视频切换时自动更新

### 3. 层级管理
- 使用Stack确保正确的z-index顺序
- 调试层在最底层，主内容在最上层
- 避免内容相互遮挡

### 4. 视频播放
- 支持横屏和竖屏视频
- 自动播放/暂停管理
- 全屏模式支持
- 封面图自动获取和缓存

### 5. 交互功能
- 下拉刷新
- 上拉加载更多
- 视频点赞/收藏/分享/评论
- 用户头像下拉菜单

## 数据流

```
VideoProvider → HomeScreen → VideoFeedWidget → VideoItemWidget → VideoPlayerWidget
     ↓              ↓              ↓              ↓              ↓
  视频列表     封面URL状态    页面切换回调    视频数据     播放控制
```

## 状态管理

- `_currentVideoCoverUrl`: 当前视频封面URL
- `_refreshController`: 刷新控制器
- `VideoProvider`: 视频数据提供者
- `AuthProvider`: 用户认证状态
