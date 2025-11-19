# BaseAppBar 通用 AppBar 组件

基于全局主题配置的通用 AppBar 组件，支持自定义标题、左侧按钮、右侧按钮。

## ✨ 特性

- ✅ 自动应用全局主题配置（白色背景、深色图标、无 surface tint）
- ✅ 支持自定义标题文字或组件
- ✅ 支持自定义左侧按钮（默认显示返回按钮）
- ✅ 支持自定义右侧按钮列表
- ✅ 支持所有原生 AppBar 参数

## 📦 全局主题配置

已在 `main.dart` 中配置全局 AppBar 样式：

```dart
appBarTheme: const AppBarTheme(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,
  surfaceTintColor: Colors.transparent, // 去除 Material 3 的 surface tint 效果
  scrolledUnderElevation: 0, // 滚动时不改变阴影
  centerTitle: true,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ),
),
```

## 🚀 使用方式

### 方式一：直接使用原生 AppBar（推荐）

由于全局主题已配置，直接使用原生 AppBar 即可：

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('页面标题'),
  ),
)
```

### 方式二：使用 BaseAppBar（更明确）

如果想要更明确的语义或额外的便利性：

```dart
import 'package:flutter_tem/components/BaseAppBar/index.dart';

Scaffold(
  appBar: BaseAppBar(
    title: '页面标题',
  ),
)
```

## 📝 使用示例

### 1. 基础用法

```dart
BaseAppBar(
  title: '用户列表',
)
```

### 2. 自定义标题组件

```dart
BaseAppBar(
  titleWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: Colors.amber),
      SizedBox(width: 8),
      Text('收藏夹'),
    ],
  ),
)
```

### 3. 自定义左侧按钮

```dart
BaseAppBar(
  title: '设置',
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () {
      // 打开侧边栏
    },
  ),
)
```

### 4. 隐藏返回按钮

```dart
BaseAppBar(
  title: '首页',
  automaticallyImplyLeading: false,
)
```

### 5. 添加右侧按钮

```dart
BaseAppBar(
  title: '消息',
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        // 搜索
      },
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {
        // 更多选项
      },
    ),
  ],
)
```

### 6. 自定义背景色

```dart
BaseAppBar(
  title: '特殊页面',
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  systemOverlayStyle: SystemUiOverlayStyle.light, // 状态栏亮色图标
)
```

### 7. 带 TabBar 的 AppBar

```dart
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: BaseAppBar(
      title: '分类',
      bottom: TabBar(
        tabs: [
          Tab(text: '推荐'),
          Tab(text: '热门'),
          Tab(text: '最新'),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        // ...
      ],
    ),
  ),
)
```

### 8. 自定义高度

```dart
BaseAppBar(
  title: '自定义高度',
  toolbarHeight: 80,
)
```

## 🎨 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:get/get.dart';

class UserProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: '个人资料',
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.toNamed('/edit-profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // 分享
            },
          ),
        ],
      ),
      body: Center(
        child: Text('个人资料页面'),
      ),
    );
  }
}
```

## 📋 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|-----|------|--------|------|
| `title` | `String?` | `null` | 标题文字 |
| `titleWidget` | `Widget?` | `null` | 标题组件（优先级高于 title） |
| `leading` | `Widget?` | `null` | 左侧组件 |
| `actions` | `List<Widget>?` | `null` | 右侧按钮列表 |
| `automaticallyImplyLeading` | `bool` | `true` | 是否自动显示返回按钮 |
| `backgroundColor` | `Color?` | 主题配置 | 背景颜色 |
| `foregroundColor` | `Color?` | 主题配置 | 前景色 |
| `centerTitle` | `bool?` | 主题配置 | 是否居中标题 |
| `toolbarHeight` | `double?` | 系统默认 | AppBar 高度 |
| `elevation` | `double?` | 主题配置 | 阴影高度 |
| `systemOverlayStyle` | `SystemUiOverlayStyle?` | 主题配置 | 状态栏样式 |
| `bottom` | `PreferredSizeWidget?` | `null` | 底部组件（如 TabBar） |

## 💡 最佳实践

1. **优先使用全局主题**：大多数页面直接使用 `AppBar` 即可，无需使用 `BaseAppBar`
2. **特殊页面使用 BaseAppBar**：需要自定义样式时使用 `BaseAppBar`
3. **保持一致性**：尽量保持 AppBar 样式在整个应用中的一致性
4. **合理使用 actions**：右侧按钮不宜过多，建议不超过 3 个
