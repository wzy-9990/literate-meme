# BaseImage 组件

通用图片组件，支持加载静态图片和网络图片，提供加载动画、缓存、错误处理等功能。

## 功能特性

- ✅ 支持网络图片（自动缓存）
- ✅ 支持本地静态图片（assets）
- ✅ 支持主流图片格式（JPEG、PNG、GIF、WebP 等）
- ✅ 自定义裁剪模式（BoxFit）
- ✅ 可配置的淡入动画
- ✅ 加载中占位图
- ✅ 加载失败默认图
- ✅ 圆角支持
- ✅ 圆形图片支持
- ✅ 自定义占位图和错误图

## 基础用法

### 1. 加载网络图片

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 100,
  height: 100,
)
```

### 2. 加载本地图片

```dart
BaseImage(
  imageUrl: 'assets/images/logo.png',
  width: 100,
  height: 100,
)
```

### 3. 圆形头像

```dart
BaseImage(
  imageUrl: 'https://example.com/avatar.jpg',
  width: 60,
  height: 60,
  isCircle: true,
)
```

### 4. 圆角图片

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  borderRadius: 12,
)
```

## 高级用法

### 自定义裁剪模式

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 200,
  height: 150,
  fit: BoxFit.contain, // cover, contain, fill, fitWidth, fitHeight, none, scaleDown
)
```

### 禁用淡入动画

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 100,
  height: 100,
  enableFadeIn: false,
)
```

### 自定义动画时长

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 100,
  height: 100,
  fadeInDuration: 500, // 毫秒
)
```

### 自定义占位图

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 100,
  height: 100,
  placeholder: Container(
    color: Colors.grey[300],
    child: Center(
      child: Icon(Icons.image, color: Colors.grey),
    ),
  ),
)
```

### 自定义错误图

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 100,
  height: 100,
  errorWidget: Container(
    color: Colors.red[100],
    child: Center(
      child: Icon(Icons.error, color: Colors.red),
    ),
  ),
)
```

### 自定义占位图背景色

```dart
BaseImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 100,
  height: 100,
  placeholderColor: Colors.blue[50],
)
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseImage/index.dart';

class ImageExampleView extends StatelessWidget {
  const ImageExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片组件示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 网络图片
            const Text('网络图片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            BaseImage(
              imageUrl: 'https://picsum.photos/400/300',
              width: double.infinity,
              height: 200,
              borderRadius: 12,
            ),

            const SizedBox(height: 30),

            // 圆形头像
            const Text('圆形头像', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                BaseImage(
                  imageUrl: 'https://picsum.photos/200',
                  width: 60,
                  height: 60,
                  isCircle: true,
                ),
                const SizedBox(width: 20),
                BaseImage(
                  imageUrl: 'https://picsum.photos/201',
                  width: 60,
                  height: 60,
                  isCircle: true,
                ),
                const SizedBox(width: 20),
                BaseImage(
                  imageUrl: 'https://picsum.photos/202',
                  width: 60,
                  height: 60,
                  isCircle: true,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 不同裁剪模式
            const Text('不同裁剪模式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    BaseImage(
                      imageUrl: 'https://picsum.photos/300/400',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      borderRadius: 8,
                    ),
                    const SizedBox(height: 5),
                    const Text('cover', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    BaseImage(
                      imageUrl: 'https://picsum.photos/300/400',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      borderRadius: 8,
                    ),
                    const SizedBox(height: 5),
                    const Text('contain', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    BaseImage(
                      imageUrl: 'https://picsum.photos/300/400',
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                      borderRadius: 8,
                    ),
                    const SizedBox(height: 5),
                    const Text('fill', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 本地图片
            const Text('本地图片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            BaseImage(
              imageUrl: 'assets/images/logo.png',
              width: 120,
              height: 120,
              borderRadius: 8,
            ),

            const SizedBox(height: 30),

            // 错误处理
            const Text('错误处理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            BaseImage(
              imageUrl: 'https://invalid-url.com/image.jpg',
              width: 150,
              height: 150,
              borderRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
```

## 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|-----|------|--------|------|
| `imageUrl` | `String` | 必填 | 图片地址（网络地址或 assets 路径） |
| `width` | `double?` | `null` | 图片宽度 |
| `height` | `double?` | `null` | 图片高度 |
| `fit` | `BoxFit` | `BoxFit.cover` | 图片裁剪模式 |
| `borderRadius` | `double` | `0` | 圆角大小 |
| `isCircle` | `bool` | `false` | 是否为圆形图片 |
| `placeholder` | `Widget?` | `null` | 自定义占位图 |
| `errorWidget` | `Widget?` | `null` | 自定义错误图 |
| `enableFadeIn` | `bool` | `true` | 是否启用淡入动画 |
| `fadeInDuration` | `int` | `300` | 淡入动画时长（毫秒） |
| `placeholderColor` | `Color?` | `Colors.grey[200]` | 占位图背景色 |

## BoxFit 模式说明

| 模式 | 说明 |
|-----|------|
| `BoxFit.cover` | 填充满容器，保持宽高比，可能裁剪（默认） |
| `BoxFit.contain` | 完整显示图片，保持宽高比，可能有空白 |
| `BoxFit.fill` | 填充满容器，不保持宽高比，可能变形 |
| `BoxFit.fitWidth` | 宽度填满，高度自适应 |
| `BoxFit.fitHeight` | 高度填满，宽度自适应 |
| `BoxFit.none` | 原始大小显示 |
| `BoxFit.scaleDown` | 如果图片大于容器则缩小，否则原始大小 |

## 注意事项

1. **网络图片缓存**：网络图片会自动缓存到本地，提高加载速度
2. **本地图片路径**：本地图片需要在 `pubspec.yaml` 中配置 assets
3. **圆形图片**：使用 `isCircle=true` 时，建议 `width` 和 `height` 设置为相同值
4. **性能优化**：建议根据实际显示尺寸设置 `width` 和 `height`，避免加载过大的图片

## 依赖

本组件依赖以下包：
- `cached_network_image: ^3.4.1`

确保在 `pubspec.yaml` 中已添加此依赖。
