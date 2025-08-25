# 版本检查服务

## 概述

版本检查服务用于在应用启动时自动检查客户端版本是否需要升级，支持强制升级和推荐升级两种模式。

## 功能特性

- **自动版本检查**: 应用启动时自动检查版本更新
- **智能检查频率**: 24小时内只检查一次，避免频繁请求
- **强制升级**: 必须升级才能继续使用应用
- **推荐升级**: 用户可以选择是否升级
- **多语言支持**: 支持中文、英文、日文、韩文
- **Changelog展示**: 可展开查看更新日志
- **下载管理**: 点击下载按钮后自动跳转到下载链接

## 文件结构

```
lib/shared/services/
├── version_check_service.dart    # 版本检查核心服务
├── version_manager.dart          # 版本管理器和启动检查
└── ../widgets/
    └── version_update_dialog.dart # 版本升级对话框
```

## 使用方法

### 1. 自动版本检查

应用启动时会自动检查版本更新，无需手动调用：

```dart
// 在 main.dart 中已经配置
// 在 HomeScreen 的 initState 中自动调用
_checkVersionUpdate();
```

### 2. 手动版本检查

用户可以在Profile页面手动检查版本更新：

```dart
// 点击版本检查按钮
VersionManager().checkVersionManually(context);
```

### 3. 版本检查API

```dart
// 检查版本更新
final versionInfo = await VersionCheckService().checkVersion();

// 下载新版本
final success = await VersionCheckService().downloadUpdate(downloadUrl);
```

## API接口

### 版本检查接口

**POST** `/api/version/check`

请求参数：
```json
{
  "currentVersion": "1.0.0",
  "platform": "android" // 或 "ios"
}
```

响应数据：
```json
{
  "status": "SUCCESS",
  "data": {
    "currentVersion": "1.0.0",
    "latestVersion": "1.1.0",
    "downloadUrl": "https://example.com/app.apk",
    "changelog": "修复了一些bug，提升了性能",
    "forceUpdate": false,
    "hasUpdate": true
  }
}
```

## 配置说明

### 检查频率

默认24小时检查一次，可在 `version_manager.dart` 中修改：

```dart
static const Duration _checkInterval = Duration(hours: 24);
```

### 多语言支持

支持的语言：
- 中文 (zh_TW)
- 英文 (en_US)  
- 日文 (ja_JP)
- 韩文 (ko_KR)

语言文件位置：`assets/flutter_i18n/`

## 注意事项

1. **强制升级**: 当 `forceUpdate: true` 时，用户无法取消对话框，必须升级
2. **网络权限**: 需要网络权限来检查版本和下载更新
3. **平台检测**: 自动检测Android/iOS平台，调用相应的下载链接
4. **错误处理**: 网络错误或API错误时会显示相应的错误提示

## 测试

### 重置版本检查记录

```dart
// 用于测试，重置版本检查记录
await VersionManager().resetVersionCheckRecord();
```

### 模拟版本更新

修改API响应中的 `hasUpdate` 字段为 `true` 来测试版本更新流程。

## 依赖包

- `package_info_plus`: 获取应用版本信息
- `url_launcher`: 打开下载链接
- `shared_preferences`: 存储版本检查记录
