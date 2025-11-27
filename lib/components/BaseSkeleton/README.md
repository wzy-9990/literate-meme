# BaseSkeleton

骨架屏占位组件，用于内容加载时的优雅过渡。

## 功能特性

- ✅ 基于 skeleton_text 封装
- ✅ 动画闪烁效果
- ✅ 可自定义尺寸和圆角
- ✅ 支持外边距配置
- ✅ 轻量级占位方案

## 基础用法

```dart
import 'package:flutter_tem/components/BaseSkeleton/index.dart';

// 基础骨架屏
BaseSkeleton()

// 自定义尺寸
BaseSkeleton(
  width: 200,
  height: 60,
  borderRadius: BorderRadius.circular(8),
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| width | double? | null | 宽度（不传则自适应父级）|
| height | double | 40 | 高度 |
| color | Color? | null | 占位颜色（默认灰色）|
| borderRadius | BorderRadiusGeometry | 15 | 圆角 |
| margin | EdgeInsetsGeometry? | null | 外边距 |

## 使用示例

### 示例1：列表骨架屏

```dart
class SkeletonListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // 头像
            BaseSkeleton(
              width: 50,
              height: 50,
              borderRadius: BorderRadius.circular(25),
            ),
            SizedBox(width: 12),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseSkeleton(height: 16, width: 150),
                  SizedBox(height: 8),
                  BaseSkeleton(height: 14, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 示例2：卡片骨架屏

```dart
class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位
          BaseSkeleton(
            height: 200,
            borderRadius: BorderRadius.circular(12),
          ),
          SizedBox(height: 12),
          // 标题
          BaseSkeleton(height: 20, width: double.infinity),
          SizedBox(height: 8),
          // 副标题
          BaseSkeleton(height: 16, width: 200),
        ],
      ),
    );
  }
}
```

### 示例3：条件渲染

```dart
class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool isLoading = true;
  List<Item> data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      data = fetchedData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => SkeletonItem(),
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => ItemWidget(data[index]),
    );
  }
}
```

### 示例4：文章详情骨架屏

```dart
class ArticleDetailSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          BaseSkeleton(height: 24, width: double.infinity),
          SizedBox(height: 8),
          BaseSkeleton(height: 24, width: 250),
          SizedBox(height: 16),
          // 作者信息
          Row(
            children: [
              BaseSkeleton(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseSkeleton(height: 14, width: 80),
                  SizedBox(height: 4),
                  BaseSkeleton(height: 12, width: 120),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          // 内容段落
          BaseSkeleton(height: 16, width: double.infinity),
          SizedBox(height: 8),
          BaseSkeleton(height: 16, width: double.infinity),
          SizedBox(height: 8),
          BaseSkeleton(height: 16, width: 300),
        ],
      ),
    );
  }
}
```

### 示例5：网格骨架屏

```dart
class GridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseSkeleton(
            height: 150,
            borderRadius: BorderRadius.circular(8),
          ),
          SizedBox(height: 8),
          BaseSkeleton(height: 16),
          SizedBox(height: 4),
          BaseSkeleton(height: 14, width: 80),
        ],
      ),
    );
  }
}
```

### 示例6：可复用的骨架屏组件

```dart
class UserItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          BaseSkeleton(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(30),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseSkeleton(height: 18, width: 120),
                SizedBox(height: 8),
                BaseSkeleton(height: 14, width: 200),
                SizedBox(height: 6),
                BaseSkeleton(height: 12, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 使用
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) => UserItemSkeleton(),
)
```

## 注意事项

1. **尺寸适配**
   - 使用 flutter_screenutil 进行尺寸适配
   - width 不传时自适应父容器宽度

2. **颜色配置**
   - 默认使用 `Colors.grey[300]`
   - 可通过 color 参数自定义

3. **动画效果**
   - 基于 skeleton_text 包提供闪烁动画
   - 无需额外配置

4. **性能考虑**
   - 骨架屏数量不宜过多（建议<10个）
   - 避免在滚动列表中显示大量骨架屏

## 设计建议

1. **保持一致**
```dart
// 骨架屏的尺寸应与实际内容一致
BaseSkeleton(height: 20, width: 150) // 骨架屏
Text('实际标题', style: TextStyle(fontSize: 20))  // 实际内容
```

2. **合理的圆角**
```dart
// 头像
BaseSkeleton(borderRadius: BorderRadius.circular(圆形))

// 卡片
BaseSkeleton(borderRadius: BorderRadius.circular(8-12))

// 文本
BaseSkeleton(borderRadius: BorderRadius.circular(4-6))
```

3. **适当的间距**
```dart
Column(
  children: [
    BaseSkeleton(height: 20),
    SizedBox(height: 8), // 保持与实际内容一致的间距
    BaseSkeleton(height: 16),
  ],
)
```

## 最佳实践

1. **模拟真实布局**
```dart
// ✅ 好的做法：尽可能接近真实内容
Column(
  children: [
    BaseSkeleton(height: 200), // 图片
    BaseSkeleton(height: 24, width: 250), // 标题
    BaseSkeleton(height: 16, width: 180), // 副标题
  ],
)

// ❌ 不好的做法：简单堆叠
Column(
  children: [
    BaseSkeleton(),
    BaseSkeleton(),
    BaseSkeleton(),
  ],
)
```

2. **适时显示**
```dart
// ✅ 只在初次加载时显示骨架屏
if (isFirstLoad && isLoading) {
  return SkeletonList();
}

// 下拉刷新时使用 loading indicator
if (isRefreshing) {
  return RefreshIndicator(...);
}
```

## 相关组件

- skeleton_text - 第三方骨架屏库
- [BaseLoading](../BaseLoading/README.md) - 加载遮罩
- [BaseEmpty](../BaseEmpty/README.md) - 空状态
- CircularProgressIndicator - 加载指示器
