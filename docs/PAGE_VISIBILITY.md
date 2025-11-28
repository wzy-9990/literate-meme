# 页面可见性监听（Page Visibility）

实现页面显示（onShow）和隐藏（onHide）的生命周期回调，支持页面返回时自动刷新数据。

---

## 📖 功能说明

### 生命周期对比

| 生命周期 | 触发时机 | 执行次数 | 用途 |
|---------|---------|---------|------|
| `onLoad()` | 页面首次加载 | 1次 | 初始化数据、配置 |
| `onShow()` | 页面显示（包括返回） | 多次 | 刷新数据、恢复动画 |
| `onHide()` | 页面隐藏（跳转其他页面） | 多次 | 暂停操作、保存状态 |

### onShow() 触发时机

✅ **会触发的场景**：
- 页面首次进入
- 从其他页面返回到当前页面（**关键功能**）
- 应用从后台切换到前台（当前页面在栈顶）

### onHide() 触发时机

✅ **会触发的场景**：
- 跳转到其他页面（push）
- 应用切换到后台

---

## 🚀 快速开始

### 1️⃣ 配置全局路由观察器（已配置）

在 `main.dart` 中添加 `PageVisibilityObserver`：

```dart
GetMaterialApp(
  // ...
  navigatorObservers: [PageVisibilityObserver.instance], // ✅ 已配置
)
```

### 2️⃣ Logic 层使用 Mixin

```dart
import 'package:flutter_tem/utils/logic/base/base_logic.dart';
import 'package:flutter_tem/utils/logic/base/mixin/page_visibility_mixin.dart';

class MyLogic extends BaseLogic with PageVisibilityMixin {
  @override
  Future<void> onLoad() async {
    debugPrint('📍 onLoad - 页面首次加载');
    await loadInitialData();
  }

  @override
  void onShow() {
    super.onShow(); // 可选：调用父类方法打印日志
    debugPrint('👀 onShow - 页面显示，刷新数据');
    refreshData(); // 刷新数据
  }

  @override
  void onHide() {
    super.onHide(); // 可选：调用父类方法打印日志
    debugPrint('🙈 onHide - 页面隐藏');
    pauseAnimation(); // 暂停动画
  }
}
```

### 3️⃣ View 层使用 PageVisibilityWrapper

⚠️ **关键**：必须用 `PageVisibilityWrapper` 包裹整个页面

```dart
import 'package:flutter_tem/utils/logic/base/mixin/page_visibility_mixin.dart';
import 'package:get/get.dart';

class MyPage extends GetView<MyLogic> {
  @override
  Widget build(BuildContext context) {
    return PageVisibilityWrapper(
      controller: controller, // ⭐ 传入 controller
      child: Scaffold(
        appBar: AppBar(title: Text('我的页面')),
        body: ...,
      ),
    );
  }
}
```

---

## 💡 实际应用场景

### 场景 1：列表页返回刷新

```dart
class UserListLogic extends BasePaginationLogic<User> with PageVisibilityMixin {
  @override
  void onShow() {
    super.onShow();
    // 从用户详情页返回时，自动刷新列表
    onRefresh();
  }
}
```

### 场景 2：暂停视频播放

```dart
class VideoPlayerLogic extends BaseLogic with PageVisibilityMixin {
  VideoPlayerController? _controller;

  @override
  void onShow() {
    super.onShow();
    _controller?.play(); // 页面显示时恢复播放
  }

  @override
  void onHide() {
    super.onHide();
    _controller?.pause(); // 页面隐藏时暂停播放
  }
}
```

### 场景 3：定时器控制

```dart
class DashboardLogic extends BaseLogic with PageVisibilityMixin {
  Timer? _timer;

  @override
  void onShow() {
    super.onShow();
    // 页面显示时启动定时器
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      refreshDashboard();
    });
  }

  @override
  void onHide() {
    super.onHide();
    // 页面隐藏时停止定时器
    _timer?.cancel();
    _timer = null;
  }
}
```

### 场景 4：统计页面停留时长

```dart
class AnalyticsLogic extends BaseLogic with PageVisibilityMixin {
  DateTime? _enterTime;

  @override
  void onShow() {
    super.onShow();
    _enterTime = DateTime.now();
  }

  @override
  void onHide() {
    super.onHide();
    if (_enterTime != null) {
      final duration = DateTime.now().difference(_enterTime!);
      reportPageDuration(duration); // 上报停留时长
    }
  }
}
```

---

## 🔍 技术实现

### 监听原理

```
RouteObserver + RouteAware + WidgetsBindingObserver
         ↓
监听路由栈变化 + 应用生命周期
         ↓
   判断页面可见性
         ↓
  触发 onShow / onHide
```

### 可见性判断

页面真正可见 = **路由可见** AND **应用可见**

- **路由可见**：当前页面在路由栈顶
- **应用可见**：应用处于前台运行状态

---

## ⚠️ 注意事项

### 1. 必须使用 PageVisibilityWrapper

❌ **错误示例**：
```dart
class MyPage extends GetView<MyLogic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(...); // ❌ 没有包裹 PageVisibilityWrapper
  }
}
```

✅ **正确示例**：
```dart
class MyPage extends GetView<MyLogic> {
  @override
  Widget build(BuildContext context) {
    return PageVisibilityWrapper( // ✅ 正确
      controller: controller,
      child: Scaffold(...),
    );
  }
}
```

### 2. 避免在 onShow 中执行耗时操作

onShow 会频繁触发，避免执行网络请求等耗时操作：

```dart
@override
void onShow() {
  super.onShow();

  // ❌ 不推荐：每次都请求
  await fetchData();

  // ✅ 推荐：判断是否需要刷新
  if (shouldRefresh) {
    await fetchData();
    shouldRefresh = false;
  }
}
```

### 3. onLoad vs onShow 的选择

| 操作类型 | 使用 onLoad | 使用 onShow |
|---------|------------|------------|
| 初始化配置 | ✅ | ❌ |
| 首次加载数据 | ✅ | ❌ |
| 返回刷新数据 | ❌ | ✅ |
| 启动定时器 | ❌ | ✅ |
| 播放动画 | ❌ | ✅ |

---

## 📊 生命周期执行顺序

### 场景 1：首次进入页面

```
1. onInit()
2. onLoad()
3. onReady()
4. onShow() ← 首次显示
```

### 场景 2：跳转到其他页面

```
A页面 → B页面
  ↓
A.onHide() ← A 被隐藏
  ↓
B.onShow() ← B 显示
```

### 场景 3：从其他页面返回

```
B页面 → 返回 → A页面
  ↓
B.onHide() ← B 被隐藏
  ↓
A.onShow() ← A 重新显示（关键！）
```

---

## 🎯 完整示例

参考文件：
- Logic: `lib/page/example/pageVisibility/logic.dart`
- View: `lib/page/example/pageVisibility/view.dart`

---

## 🐛 常见问题

### Q1: onShow 没有触发？

**检查清单**：
- ✅ 在 main.dart 中配置了 `PageVisibilityObserver`
- ✅ View 使用了 `PageVisibilityWrapper` 包裹
- ✅ Logic 混入了 `PageVisibilityMixin`

### Q2: 每次都触发两次 onShow？

这是正常的，因为：
1. 首次进入时触发一次（`didPush`）
2. 路由准备好后再触发一次（`didPopNext`）

如需避免重复，可以添加防抖逻辑：

```dart
DateTime? _lastShowTime;

@override
void onShow() {
  super.onShow();

  // 防抖：500ms 内只执行一次
  final now = DateTime.now();
  if (_lastShowTime != null &&
      now.difference(_lastShowTime!) < Duration(milliseconds: 500)) {
    return;
  }
  _lastShowTime = now;

  // 执行刷新逻辑
  refreshData();
}
```

### Q3: 支持 Tab 切换吗？

**不支持**。`PageVisibilityMixin` 只监听路由级别的页面切换。

Tab 切换需要在 Tab 控制器中手动调用 Logic 的方法。

---

## 🚀 最佳实践

### 1. 按需使用

不是所有页面都需要监听可见性，只在必要时使用。

### 2. 组合使用

```dart
// ✅ 同时使用多个 Mixin
class MyLogic extends BaseLogic
    with PageVisibilityMixin,
         CustomMixin {
  // ...
}
```

### 3. 日志调试

开发时保留 `super.onShow()` 和 `super.onHide()`，方便查看日志：

```dart
@override
void onShow() {
  super.onShow(); // 打印日志
  // 你的逻辑
}
```

生产环境可以移除，减少日志输出。

---

## 📚 相关文档

- [BaseLogic 使用文档](./BASE_LOGIC.md)
- [BasePaginationLogic 使用文档](./BASE_PAGINATION_LOGIC.md)
- [GetX 生命周期](https://github.com/jonataslaw/getx#lifecycle)

---

**Happy Coding! 🎉**
