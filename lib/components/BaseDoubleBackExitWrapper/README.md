# BaseDoubleBackExitWrapper

双击返回退出应用包装组件。

## 功能特性

- ✅ 需要在2秒内双击返回键才能退出应用
- ✅ 首次按下显示提示 Toast
- ✅ 防止误触退出
- ✅ 简单易用的包装组件

## 基础用法

```dart
import 'package:flutter_tem/components/BaseDoubleBackExitWrapper/index.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BaseDoubleBackExitWrapper(
        child: HomePage(),
      ),
    );
  }
}
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| child | Widget | - | 必需，被包装的子组件 |

## 使用示例

### 示例1：包装主页

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseDoubleBackExitWrapper(
      child: Scaffold(
        appBar: AppBar(title: Text('首页')),
        body: Center(child: Text('再按一次退出应用')),
      ),
    );
  }
}
```

### 示例2：配合底部导航

```dart
class TabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseDoubleBackExitWrapper(
      child: Scaffold(
        body: TabBarView(...),
        bottomNavigationBar: BottomNavigationBar(...),
      ),
    );
  }
}
```

## 工作原理

```dart
DateTime? _lastPressedAt;

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      final now = DateTime.now();
      if (_lastPressedAt == null ||
          now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
        _lastPressedAt = now;
        EasyLoading.showToast('再按一次退出应用');
        return false;  // 阻止退出
      }
      return true;  // 允许退出
    },
    child: widget.child,
  );
}
```

## 注意事项

1. **时间间隔**
   - 两次按返回键的间隔需在 2 秒内
   - 超过 2 秒需重新双击

2. **提示消息**
   - 默认提示："再按一次退出应用"
   - 使用 EasyLoading.showToast 显示

3. **使用位置**
   - 通常包装应用的主页或 Tab 页面
   - 只在需要防误触退出的页面使用

4. **平台兼容性**
   - 主要用于 Android 平台
   - iOS 通常使用手势返回，此组件仍可工作

## 自定义提示消息

如需自定义提示消息，可修改源码中的提示文字：

```dart
EasyLoading.showToast('您自定义的提示消息');
```

或者封装一个可配置的版本：

```dart
class CustomDoubleBackExitWrapper extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration duration;

  const CustomDoubleBackExitWrapper({
    required this.child,
    this.message = '再按一次退出应用',
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  // ... 实现代码
}
```

## 最佳实践

1. **仅在根页面使用**
```dart
// ✅ 正确：在应用主页使用
BaseDoubleBackExitWrapper(
  child: MainTabPage(),
)

// ❌ 错误：在详情页等子页面使用
BaseDoubleBackExitWrapper(
  child: DetailPage(),
)
```

2. **配合路由**
```dart
MaterialApp(
  home: BaseDoubleBackExitWrapper(
    child: HomePage(),
  ),
  routes: {
    '/home': (context) => BaseDoubleBackExitWrapper(
      child: HomePage(),
    ),
    '/detail': (context) => DetailPage(), // 不需要包装
  },
)
```

## 相关组件

- EasyLoading - Toast 提示组件
- WillPopScope - Flutter 返回拦截组件
