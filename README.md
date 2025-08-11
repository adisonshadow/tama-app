# Tama2 移动APP （练手用，不完整）

基于Flutter开发的移动端应用，仿抖音风格的视频分享平台。

## 项目特性

- 🎬 **推荐页面** - 抖音风格的视频推荐流
- 👥 **关注功能** - 关注用户和查看关注的内容  
- 🔐 **用户认证** - 完整的登录注册系统
- 📱 **响应式设计** - 适配不同屏幕尺寸
- 🚀 **性能优化** - 视频预加载和图片缓存

## 技术栈

- **Flutter** - UI框架
- **Provider** - 状态管理
- **Dio** - 网络请求
- **Go Router** - 路由管理
- **Video Player** - 视频播放
- **Cached Network Image** - 图片缓存

## 项目结构

```
lib/
├── core/                    # 核心功能
│   ├── constants/          # 常量定义
│   ├── network/           # 网络配置
│   └── utils/             # 工具函数
├── features/              # 功能模块
│   ├── auth/             # 认证模块
│   ├── home/             # 首页模块
│   └── following/        # 关注模块
└── shared/               # 共享组件
    ├── models/           # 数据模型
    ├── services/         # 服务层
    └── widgets/          # 通用组件
```

## 开发环境要求

- Flutter SDK >= 3.13.0
- Dart SDK >= 3.1.0
- Android SDK (Android开发)
- Xcode (iOS开发，可选)

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成代码

```bash
flutter packages pub run build_runner build
```

### 3. 运行项目

```bash
# Android
flutter run

# iOS (需要macOS环境)
flutter run -d ios
```

## API接口

应用连接到现有的后端API服务：

- **基础URL**: `http://localhost:3003/api`
- **认证**: JWT Token
- **主要接口**:
  - `POST /auth/login` - 用户登录
  - `POST /auth/register` - 用户注册
  - `GET /articles/recommendeds` - 获取推荐视频
  - `GET /my/getMyFollows` - 获取关注列表

## 功能说明

### 推荐页面
- 垂直滑动切换视频
- 自动播放/暂停
- 点赞、收藏、分享、评论
- 用户信息展示

### 关注功能
- 查看关注的用户列表
- 浏览关注用户的作品
- 取消关注操作

### 用户认证
- 邮箱注册/登录
- JWT Token管理
- 自动登录
- 安全登出

## 开发状态

- ✅ 项目初始化
- ✅ 登录注册功能
- ✅ 推荐页面
- ✅ 关注功能
- ⏳ 个人中心（暂未开发）
- ⏳ 发布功能（暂未开发）
- ⏳ 消息功能（暂未开发）

## 注意事项

1. 确保后端API服务正在运行
2. 视频播放需要网络连接
3. 首次运行可能需要较长时间下载依赖
4. Android需要允许网络明文传输（开发环境）

## 许可证

MIT License
