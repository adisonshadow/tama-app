# 关注功能使用说明

## 概述
本模块提供了完整的用户关注功能，包括检查关注状态、切换关注状态等。所有功能都是可复用的，可以在多个页面中使用。

## 组件结构

### 1. FollowService (关注服务)
- **位置**: `lib/shared/services/follow_service.dart`
- **功能**: 提供关注相关的API调用
- **方法**:
  - `checkFollowStatus(String targetUserId)`: 检查是否已关注用户
  - `toggleFollow(String targetUserId)`: 切换关注状态

### 2. FollowProvider (关注状态管理器)
- **位置**: `lib/shared/providers/follow_provider.dart`
- **功能**: 管理关注状态，提供状态管理和缓存
- **特性**:
  - 支持多个用户的关注状态管理
  - 自动缓存关注状态
  - 提供加载状态管理
  - 支持批量检查关注状态

### 3. FollowButton (关注按钮组件)
- **位置**: `lib/shared/widgets/follow_button.dart`
- **功能**: 可复用的关注按钮UI组件
- **特性**:
  - 自动显示关注/已关注状态
  - 支持自定义样式（颜色、大小、字体等）
  - 内置加载状态显示
  - 支持状态改变回调

## 使用方法

### 在页面中使用

#### 1. 添加Provider
```dart
import 'package:provider/provider.dart';
import '../../../shared/providers/follow_provider.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FollowProvider(),
      child: MyPageContent(),
    );
  }
}
```

#### 2. 使用FollowButton组件
```dart
import '../../../shared/widgets/follow_button.dart';

FollowButton(
  userId: 'user123',
  onFollowChanged: () {
    print('关注状态已改变');
  },
)
```

#### 3. 在Provider中检查关注状态
```dart
Consumer<FollowProvider>(
  builder: (context, followProvider, child) {
    final isFollowing = followProvider.isFollowing('user123');
    
    return Text(isFollowing ? '已关注' : '未关注');
  },
)
```

### 自定义样式

```dart
FollowButton(
  userId: 'user123',
  width: 80,
  height: 36,
  fontSize: 14,
  borderRadius: BorderRadius.circular(18),
  followingColor: Colors.grey,
  unfollowingColor: Colors.blue,
  textColor: Colors.white,
  onFollowChanged: () {
    // 处理关注状态改变
  },
)
```

## API接口

### 检查关注状态
- **端点**: `GET /api/my/isFollowed/{targetUserId}`
- **返回**: 
```json
{
  "status": "SUCCESS",
  "data": {
    "is_following": true
  }
}
```

### 切换关注状态
- **端点**: `POST /api/my/toggleFollow/{targetUserId}`
- **返回**:
```json
{
  "status": "SUCCESS",
  "data": {
    "is_following": true
  }
}
```

## 注意事项

1. **Provider管理**: 确保在使用FollowButton的页面中添加了FollowProvider
2. **状态同步**: 关注状态会在多个页面间自动同步
3. **错误处理**: 网络错误不会影响UI显示，会保持当前状态
4. **性能优化**: 关注状态会被缓存，避免重复请求

## 示例页面

- **用户空间页面**: `lib/features/user_space/screens/user_space_screen.dart`
- **视频操作按钮**: `lib/features/home/widgets/video_action_buttons.dart`

## 扩展功能

如需添加更多功能，可以在FollowProvider中添加：
- 批量关注/取消关注
- 关注列表管理
- 关注推荐等
