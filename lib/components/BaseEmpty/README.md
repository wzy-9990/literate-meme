# BaseEmpty 空页面组件

用于显示空状态页面，包含图片、标题、副标题和可选按钮。

## 基本用法

### 1. 最简单的用法（只显示标题）

```dart
BaseEmpty(
  title: '暂无数据',
)
```

### 2. 显示标题和副标题

```dart
BaseEmpty(
  title: '暂无订单',
  subtitle: '您还没有任何订单记录',
)
```

### 3. 显示标题、副标题和按钮

```dart
BaseEmpty(
  title: '购物车是空的',
  subtitle: '去逛逛，挑选心仪的商品吧',
  buttonText: '去购物',
  onButtonPressed: () {
    // 跳转到商品列表
    Get.toNamed(AppRoutes.products);
  },
)
```

### 4. 自定义图片

```dart
BaseEmpty(
  imagePath: 'assets/images/empty_cart.png',
  title: '购物车是空的',
  subtitle: '去逛逛，挑选心仪的商品吧',
  buttonText: '去购物',
  onButtonPressed: () {
    Get.toNamed(AppRoutes.products);
  },
)
```

### 5. 自定义样式

```dart
BaseEmpty(
  title: '网络异常',
  subtitle: '请检查您的网络连接',
  buttonText: '重试',
  onButtonPressed: () {
    // 重新加载数据
  },
  // 自定义图片大小
  imageWidth: 150.w,
  imageHeight: 150.w,
  // 自定义标题样式
  titleStyle: TextStyle(
    fontSize: 18.sp,
    color: Colors.red,
    fontWeight: FontWeight.bold,
  ),
  // 自定义副标题样式
  subtitleStyle: TextStyle(
    fontSize: 14.sp,
    color: Colors.grey[500],
  ),
  // 自定义按钮样式
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
)
```

### 6. 自定义间距

```dart
BaseEmpty(
  title: '暂无消息',
  subtitle: '目前没有新消息',
  imageToTitleSpacing: 30.h,      // 图片到标题的间距
  titleToSubtitleSpacing: 16.h,   // 标题到副标题的间距
  subtitleToButtonSpacing: 30.h,  // 副标题到按钮的间距
)
```

## 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|-----|------|--------|------|
| `imagePath` | `String?` | `null` | 空状态图片路径，不提供则显示默认占位符 |
| `title` | `String` | `'暂无数据'` | 主标题文字 |
| `subtitle` | `String?` | `null` | 副标题文字，不提供则不显示 |
| `buttonText` | `String?` | `null` | 按钮文字，不提供则不显示按钮 |
| `onButtonPressed` | `VoidCallback?` | `null` | 按钮点击回调 |
| `imageWidth` | `double?` | `200.w` | 图片宽度 |
| `imageHeight` | `double?` | `200.w` | 图片高度 |
| `titleStyle` | `TextStyle?` | 默认样式 | 标题文字样式 |
| `subtitleStyle` | `TextStyle?` | 默认样式 | 副标题文字样式 |
| `buttonStyle` | `ButtonStyle?` | 默认样式 | 按钮样式 |
| `imageToTitleSpacing` | `double?` | `24.h` | 图片与标题之间的间距 |
| `titleToSubtitleSpacing` | `double?` | `12.h` | 标题与副标题之间的间距 |
| `subtitleToButtonSpacing` | `double?` | `24.h` | 副标题与按钮之间的间距 |

## 使用场景

- 列表数据为空时
- 搜索无结果时
- 购物车为空时
- 收藏夹为空时
- 网络异常时
- 权限不足时
- 其他需要显示空状态的场景

## 注意事项

1. **按钮默认不显示**：只有提供了 `buttonText` 参数时才会显示按钮
2. **副标题默认不显示**：只有提供了 `subtitle` 参数时才会显示副标题
3. **图片自动容错**：如果提供的图片路径加载失败，会自动显示默认占位符
4. **默认占位符**：使用 `Icons.inbox_outlined` 图标作为默认占位符
