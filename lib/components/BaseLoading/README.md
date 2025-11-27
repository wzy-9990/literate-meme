# BaseLoading

页面加载中遮罩层组件。

## 功能特性

- ✅ 全屏遮罩
- ✅ 加载动画指示器
- ✅ 可自定义提示文字
- ✅ 阻止用户操作
- ✅ 适配屏幕尺寸

## 基础用法

```dart
import 'package:flutter_tem/components/BaseLoading/index.dart';

// 基础用法
BaseLoading()

// 自定义提示文字
BaseLoading(message: '数据加载中...')
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| message | String | '页面加载中...' | 加载提示文字 |

## 使用示例

### 示例1：页面初始化加载

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return BaseLoading();
    }

    return Scaffold(
      body: ContentWidget(),
    );
  }
}
```

### 示例2：条件渲染

```dart
Stack(
  children: [
    ContentWidget(),
    if (isLoading) BaseLoading(message: '请稍候...'),
  ],
)
```

### 示例3：配合 GetX 状态管理

```dart
class PageController extends GetxController {
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await fetchData();
    } finally {
      isLoading.value = false;
    }
  }
}

class PageView extends GetView<PageController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return BaseLoading();
      }
      return ContentWidget();
    });
  }
}
```

### 示例4：异步数据加载

```dart
class DataPage extends StatelessWidget {
  Future<List<Item>> fetchItems() async {
    await Future.delayed(Duration(seconds: 2));
    return [/* items */];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return BaseLoading(message: '加载数据中...');
        }

        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error);
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return ItemTile(snapshot.data![index]);
          },
        );
      },
    );
  }
}
```

## 注意事项

1. **使用场景**
   - 适用于页面级别的加载状态
   - 占满整个父容器
   - 会阻止用户操作

2. **不适用场景**
   - 局部组件加载：使用 CircularProgressIndicator
   - 轻量提示：使用 EasyLoading
   - 下拉刷新：使用 SuperRefreshComponent

3. **性能考虑**
   - 白色不透明背景（opacity=1）
   - 使用 AbsorbPointer 阻止点击事件

## 自定义样式

如需自定义样式，可以直接修改组件或创建自定义版本：

```dart
class CustomLoading extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const CustomLoading({
    super.key,
    this.message = '加载中...',
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Container(
        color: backgroundColor ?? Colors.white.withOpacity(0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: indicatorColor ?? Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 最佳实践

1. **合理的提示文字**
```dart
// ✅ 明确的提示
BaseLoading(message: '正在加载数据...')
BaseLoading(message: '正在提交表单...')

// ❌ 过于模糊
BaseLoading(message: '加载中')
```

2. **及时隐藏**
```dart
// ✅ 使用 try-finally 确保隐藏
Future<void> loadData() async {
  setState(() => isLoading = true);
  try {
    await fetchData();
  } finally {
    setState(() => isLoading = false);
  }
}

// ❌ 可能忘记隐藏
Future<void> loadData() async {
  setState(() => isLoading = true);
  await fetchData();
  setState(() => isLoading = false); // 异常时不会执行
}
```

3. **避免长时间显示**
```dart
// 设置超时处理
Future<void> loadData() async {
  setState(() => isLoading = true);
  try {
    await fetchData().timeout(Duration(seconds: 30));
  } on TimeoutException {
    EasyLoading.showError('请求超时');
  } finally {
    setState(() => isLoading = false);
  }
}
```

## 相关组件

- CircularProgressIndicator - Flutter 原生加载指示器
- EasyLoading - 轻量级加载提示
- [BaseSkeleton](../BaseSkeleton/README.md) - 骨架屏加载
- [BaseEmpty](../BaseEmpty/README.md) - 空状态组件
