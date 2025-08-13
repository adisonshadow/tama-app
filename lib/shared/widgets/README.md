# 搜索组件使用说明

## 概述
搜索组件是一个可复用的全屏搜索覆盖层，包含毛玻璃效果、搜索输入框和结果展示功能。

## 组件结构
- `SearchOverlay`: 主要的搜索覆盖层组件
- `SearchManager`: 搜索管理器，用于显示搜索覆盖层
- `SearchService`: 搜索服务，处理API调用

## 使用方法

### 1. 基本使用
```dart
import '../../../shared/widgets/search_manager.dart';

// 在需要显示搜索的地方调用
IconButton(
  icon: const Icon(Icons.search),
  onPressed: () {
    SearchManager.showSearch(context);
  },
)
```

### 2. 自定义搜索
如果需要自定义搜索逻辑，可以直接使用 `SearchOverlay` 组件：
```dart
showDialog(
  context: context,
  barrierDismissible: true,
  barrierColor: Colors.transparent,
  builder: (BuildContext context) {
    return SearchOverlay(
      onClose: () {
        Navigator.of(context).pop();
      },
    );
  },
);
```

## 功能特性
- 毛玻璃背景效果
- 自动聚焦搜索输入框
- 支持键盘搜索按钮
- 搜索结果以2列瀑布流展示
- 完整的错误处理和加载状态
- 响应式设计，支持不同屏幕尺寸

## API接口
搜索组件调用 `/api/articles/search` 接口：
- 方法: GET
- 参数: 
  - `q`: 搜索关键词
  - `page`: 页码（默认1）
  - `pageSize`: 每页数量（默认20）

## 搜索结果展示
搜索结果使用 `MasonryGridView` 以2列布局展示，每个视频项使用 `VideoCard` 组件渲染。

## 注意事项
1. 确保项目中已安装 `flutter_staggered_grid_view` 依赖
2. 搜索组件会自动处理网络错误和空结果状态
3. 搜索结果点击后会关闭搜索覆盖层，可根据需要自定义跳转逻辑
