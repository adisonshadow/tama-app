# DioClient 修复说明

## 问题描述

之前的问题：Dio客户端把非200状态码都当作异常处理，但实际上服务端是正常返回了错误信息。

例如：
```json
{"status":"ERROR","message":"不能关注自己","data":null}
```

这个响应被Dio当作异常抛出，导致无法获取到错误信息。

## 修复方案

### 1. 修改 validateStatus 配置

```dart
// 关键：不抛出非200状态码的异常
validateStatus: (status) {
  return status != null && status < 500; // 接受所有非5xx状态码
},
```

现在Dio会接受以下状态码：
- `200` - 成功
- `400` - 请求参数错误（如"不能关注自己"）
- `401` - 未认证
- `403` - 权限不足
- `404` - 资源未找到
- `429` - 请求过于频繁

只有5xx服务器错误才会被当作异常。

### 2. 新增公共方法

#### handleApiResponse(Response response)
统一处理API响应，返回标准格式的Map。

#### isApiSuccess(Map<String, dynamic> response)
检查API响应是否成功。

#### getApiErrorMessage(Map<String, dynamic> response)
获取API错误消息。

#### getApiData(Map<String, dynamic> response)
获取API数据部分。

## 使用示例

### 在Service中使用

```dart
static Future<Map<String, dynamic>> toggleFollow(String targetUserId) async {
  try {
    final response = await DioClient.instance.post('/my/toggleFollow/$targetUserId');
    return DioClient.handleApiResponse(response); // 使用公共方法
  } catch (e) {
    rethrow;
  }
}
```

### 在Provider中处理响应

```dart
final response = await FollowService.toggleFollow(userId);

if (DioClient.isApiSuccess(response)) {
  // 成功处理
  final newStatus = response['data']['isFollowed'] ?? false;
} else {
  // 错误处理
  final errorMessage = DioClient.getApiErrorMessage(response);
  _showToastMessage(errorMessage);
}
```

## 已修复的服务

- ✅ FollowService
- ✅ VideoService  
- ✅ UserSpaceService
- ✅ AuthService
- ✅ MediaService

## 错误处理流程

1. **API调用** → 返回Response（包含状态码和数据）
2. **handleApiResponse** → 统一处理响应格式
3. **isApiSuccess** → 检查是否成功
4. **成功** → 处理数据
5. **失败** → 显示错误消息（如"不能关注自己"）

## 优势

1. **统一错误处理**：所有API错误都能正确获取到错误信息
2. **用户友好**：显示具体的错误消息，而不是"网络错误"
3. **开发友好**：调试时能看到完整的错误信息
4. **维护性**：统一的错误处理逻辑，易于维护

## 注意事项

- 只有真正的网络异常（如连接失败）才会抛出异常
- 服务端返回的错误信息（如400、401等）都会被正确处理
- 所有服务都应该使用 `DioClient.handleApiResponse()` 来处理响应
