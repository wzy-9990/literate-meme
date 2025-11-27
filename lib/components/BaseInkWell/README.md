# BaseInkWell

基础水波纹点击效果组件，提供可自定义的 Material Design 点击反馈。

## 功能特性

- ✅ Material Design 水波纹效果
- ✅ 支持点击、长按、双击
- ✅ 可配置圆角
- ✅ 自定义水波纹和高亮颜色
- ✅ 快捷构造函数（card、circle）

## 基础用法

```dart
import 'package:flutter_tem/components/BaseInkWell/index.dart';

BaseInkWell(
  onTap: () => print('点击'),
  child: Text('点我有水波纹'),
)

// 卡片样式
BaseInkWell.card(
  onTap: () {},
  child: CardContent(),
)

// 圆形样式
BaseInkWell.circle(
  onTap: () {},
  child: Icon(Icons.add),
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| child | Widget | - | 必需，子组件 |
| onTap | VoidCallback? | null | 点击回调 |
| onLongPress | VoidCallback? | null | 长按回调 |
| onDoubleTap | VoidCallback? | null | 双击回调 |
| borderRadius | BorderRadius? | null | 圆角（默认方形）|
| enableRipple | bool | true | 是否启用水波纹 |
| splashColor | Color? | null | 水波纹颜色 |
| highlightColor | Color? | null | 高亮颜色 |
| backgroundColor | Color? | null | 背景颜色 |
| padding | EdgeInsetsGeometry? | null | 内边距 |
| margin | EdgeInsetsGeometry? | null | 外边距 |
| expand | bool | false | 是否填充父组件 |

## 使用示例

### 示例1：自定义圆角

```dart
BaseInkWell(
  borderRadius: BorderRadius.circular(12),
  onTap: () {},
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('圆角按钮'),
  ),
)
```

### 示例2：自定义水波纹颜色

```dart
BaseInkWell(
  splashColor: Colors.blue.withOpacity(0.3),
  highlightColor: Colors.blue.withOpacity(0.1),
  onTap: () {},
  child: Text('蓝色水波纹'),
)
```

### 示例3：卡片点击

```dart
BaseInkWell.card(
  onTap: () => Navigator.push(...),
  child: Container(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('标题'),
        Text('内容'),
      ],
    ),
  ),
)
```

### 示例4：图标按钮

```dart
BaseInkWell.circle(
  onTap: () {},
  padding: EdgeInsets.all(8),
  child: Icon(Icons.favorite),
)
```

### 示例5：禁用水波纹

```dart
BaseInkWell(
  enableRipple: false,
  onTap: () {},
  child: Text('无水波纹'),
)
```

## 相关组件

- [BaseButton](../BaseButton/README.md) - 按钮组件
- InkWell - Flutter 原生水波纹组件
