# 错误处理系统使用说明

## 概述

本系统提供了一套完整的错误处理机制，包括：
- 错误去重和频率控制
- 网络错误处理
- 字体加载错误处理
- 全局错误捕获
- 用户友好的错误提示

## 主要组件

### 1. ErrorUtils - 错误提示工具

用于显示各种类型的错误提示，支持去重机制。

```dart
// 显示普通错误
ErrorUtils.showError(context, '操作失败');

// 显示网络错误（带频率控制）
ErrorUtils.showNetworkError(context, '网络连接失败');

// 显示字体错误（带频率控制）
ErrorUtils.showFontError(context, 'Noto Sans SC');

// 显示网络状态
ErrorUtils.showNetworkStatus(context, isOnline);
```

### 2. FontErrorHandler - 字体错误处理器

专门处理字体加载失败的问题，避免重复显示相同错误。

```dart
// 处理单个字体错误
FontErrorHandler.handleFontError('Noto Sans SC');

// 处理多个字体错误
FontErrorHandler.handleMultipleFontErrors(['Noto Sans SC', 'Noto Sans HK']);

// 获取字体错误统计
final stats = FontErrorHandler.getFontErrorStats();
```

### 3. NetworkService - 网络状态服务

监控网络连接状态，提供网络状态信息。

```dart
// 初始化网络服务
NetworkService().initialize();

// 检查网络状态
if (NetworkService().canMakeNetworkRequest()) {
  // 执行网络请求
}

// 等待网络恢复
final isConnected = await NetworkService().waitForNetworkConnection();
```

### 4. GlobalErrorHandler - 全局错误处理器

捕获应用级别的错误，统一处理。

```dart
// 初始化全局错误处理
GlobalErrorHandler().initialize();

// 获取错误统计
final stats = GlobalErrorHandler().getErrorStats();

// 显示错误统计
GlobalErrorHandler().showErrorStats(context);
```

## 使用方法

### 在 main.dart 中初始化

```dart
void main() {
  // 初始化全局错误处理
  GlobalErrorHandler().initialize();
  
  runApp(MyApp());
}
```

### 在服务中使用安全请求

```dart
class VideoService {
  static Future<Map<String, dynamic>> getVideos({
    BuildContext? context,
  }) async {
    // 检查网络状态
    if (!NetworkService().canMakeNetworkRequest()) {
      return {
        'status': 'ERROR',
        'message': '网络连接已断开，请检查网络设置',
        'data': null,
        'statusCode': 0,
      };
    }

    try {
      return await DioClient.safeRequest(
        () => DioClient.instance.get('/videos'),
        errorKey: 'get_videos',
        context: context,
      );
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': '获取视频失败: $e',
        'data': null,
        'statusCode': 0,
      };
    }
  }
}
```

### 在 Widget 中处理错误

```dart
class VideoListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: VideoService.getVideos(context: context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('加载失败: ${snapshot.error}'),
          );
        }
        
        if (snapshot.hasData) {
          final response = snapshot.data!;
          if (DioClient.isApiSuccess(response)) {
            return VideoList(videos: response['data']);
          } else {
            return Center(
              child: Text('加载失败: ${response['message']}'),
            );
          }
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

## 错误处理策略

### 1. 错误去重

- 相同错误在5分钟内只显示一次
- 避免重复的错误提示打扰用户

### 2. 频率控制

- 网络错误超过3次后静默处理
- 字体错误超过2次后静默处理
- 总错误超过10次后静默处理

### 3. 用户友好

- 提供清晰的错误描述
- 区分不同类型的错误
- 网络恢复时自动重置错误计数

## 配置选项

### 错误缓存时间

```dart
// 在 ErrorUtils 中
static const Duration _errorCacheTimeout = Duration(minutes: 5);
```

### 错误频率限制

```dart
// 网络错误限制
static const int _maxNetworkErrorsBeforeSilent = 3;

// 字体错误限制
static const int _maxFontErrorsBeforeSilent = 2;

// 总错误限制
static const int _maxErrorsBeforeSilent = 10;
```

### 网络检测间隔

```dart
// 在 NetworkService 中
static const Duration _checkInterval = Duration(seconds: 5);
```

## 调试和监控

### 查看错误统计

```dart
// 获取错误统计信息
final stats = GlobalErrorHandler().getErrorStats();
print('错误统计: $stats');

// 显示错误统计
GlobalErrorHandler().showErrorStats(context);
```

### 重置错误计数

```dart
// 重置所有错误计数
GlobalErrorHandler().resetErrorCount();

// 重置特定类型的错误计数
FontErrorHandler.resetFontErrorCount();
NetworkService().resetNetworkErrorCount();
```

### 清理错误记录

```dart
// 清理所有错误记录
GlobalErrorHandler().cleanupAllErrors();

// 清理字体错误记录
FontErrorHandler.cleanupOldFontErrors();
```

## 最佳实践

1. **始终传递 context**：在服务方法中传递 context 参数，以便显示用户友好的错误提示

2. **使用安全请求**：使用 `DioClient.safeRequest` 而不是直接调用 Dio 方法

3. **检查网络状态**：在发起网络请求前检查网络状态

4. **错误键唯一性**：为每个错误提供唯一的 errorKey，便于去重和调试

5. **用户反馈**：提供清晰的错误信息和恢复建议

## 故障排除

### 常见问题

1. **错误提示不显示**：检查是否传递了 context 参数
2. **错误重复显示**：检查 errorKey 是否唯一
3. **网络错误过多**：检查网络连接和服务器状态

### 调试技巧

1. 查看控制台日志，了解错误处理流程
2. 使用 `getErrorStats()` 查看错误统计
3. 检查网络状态和字体加载状态

## 更新日志

- v1.0.0: 初始版本，包含基本的错误处理功能
- v1.1.0: 添加字体错误处理和网络状态监控
- v1.2.0: 添加全局错误处理器和错误统计功能
