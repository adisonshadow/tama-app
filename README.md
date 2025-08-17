# TAMA APP Client

基于Flutter开发的移动端应用，仿抖音风格的美食视频分享平台。

## 项目特性
- 🎬 **推荐页面** - 抖音风格的视频推荐流
- 👥 **关注功能** - 关注用户和查看关注的内容  
- 🔐 **用户认证** - 完整的登录注册系统
- 📱 **响应式设计** - 适配不同屏幕尺寸
- 🚀 **性能优化** - 视频预加载和图片缓存
- 🍄 **支持多语言** - 使用i18n

## 功能说明

### ✅ 推荐页面

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/home.png" alt="推荐截图" width="188">

- 垂直滑动切换视频
- 自动播放/暂停/全屏播放
- 点赞、收藏、分享、评论和评论浏览
- 作者信息展示
- 视频详情展示

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/video%20detail.png" alt="视频详情截图" width="188">

- 搜索
- 根据tag浏览更多视频
- 用户Space

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/user%20space.png" alt="用户Space截图" width="188">


### ✅ 关注功能

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/following%20videos.png" alt="关注截图" width="188">

- 查看关注的用户列表
- 浏览关注用户的作品
- 取消关注操作

### ✅ 用户认证
- 邮箱注册/登录

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/auth.png" alt="登录截图" width="188">

- JWT Token管理
- 自动登录
- 安全登出

### ✅ 消息

### ⏳ 发布视频 

### ✅ 我
- 个人资料展示、编辑
- 粉丝、点赞、收藏

## 技术性功能

- ✅ 多语言

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/i18n.png" alt="切换语言截图" width="188">

- ⏳ OTA更新

## 技术栈

- **Flutter** - UI框架
- **Provider** - 状态管理
- **Dio** - 网络请求
- **Go Router** - 路由管理
- **Video Player** - 视频播放
- **Cached Network Image** - 图片缓存
- **flutter i18n** - 多语言

## 项目结构

```
lib/
├── core/                 # 核心功能
│   ├── constants/        # 常量定义
│   ├── network/          # 网络配置
│   └── utils/            # 工具函数
├── features/             # 功能模块
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

# Chrome
flutter run -d chrome --hot

# Validate 多语言
flutter pub run flutter_i18n validate

# 项目语法性检测
flutter analyze
```

### 4. 编译项目
```bash

# Android
flutter build apk --release
# gradle 配置在 android/gradle/wrapper/gradle-wrapper.properties
# 注意 gradle 与 Java 版本的对应关系
# 注意墙

# ios
flutter build ios --release

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

## 注意事项

1. 确保后端API服务正在运行
2. 视频播放需要网络连接
3. 首次运行可能需要较长时间下载依赖
4. Android需要允许网络明文传输（开发环境）

## 许可证
MIT License
