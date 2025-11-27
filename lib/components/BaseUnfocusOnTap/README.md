# BaseUnfocusOnTap

点击空白处自动收起键盘的包装组件。

## 功能特性

- ✅ 点击子组件空白区域自动收起键盘
- ✅ 提升表单输入体验
- ✅ 简单易用的包装组件
- ✅ 不影响其他交互

## 基础用法

```dart
import 'package:flutter_tem/components/BaseUnfocusOnTap/index.dart';

BaseUnfocusOnTap(
  child: Scaffold(
    body: FormContent(),
  ),
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| child | Widget | - | 必需，被包装的子组件 |

## 使用示例

### 示例1：包装表单页面

```dart
class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseUnfocusOnTap(
      child: Scaffold(
        appBar: AppBar(title: Text('表单')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: '用户名'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: '密码'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 示例2：仅包装内容区域

```dart
Scaffold(
  appBar: AppBar(title: Text('登录')),
  body: BaseUnfocusOnTap(
    child: LoginForm(),
  ),
)
```

### 示例3：嵌套滚动视图

```dart
BaseUnfocusOnTap(
  child: SingleChildScrollView(
    child: Column(
      children: [
        TextField(decoration: InputDecoration(labelText: '姓名')),
        TextField(decoration: InputDecoration(labelText: '邮箱')),
        TextField(decoration: InputDecoration(labelText: '电话')),
      ],
    ),
  ),
)
```

### 示例4：结合对话框

```dart
showDialog(
  context: context,
  builder: (context) => BaseUnfocusOnTap(
    child: AlertDialog(
      title: Text('输入信息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(decoration: InputDecoration(labelText: '名称')),
          TextField(decoration: InputDecoration(labelText: '备注')),
        ],
      ),
      actions: [
        TextButton(onPressed: () {}, child: Text('确定')),
      ],
    ),
  ),
);
```

## 工作原理

```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent, // 允许点击穿透到子组件
    onTap: () => FocusManager.instance.primaryFocus?.unfocus(), // 收起键盘
    child: child,
  );
}
```

## 注意事项

1. **点击行为**
   - 使用 `HitTestBehavior.translucent` 允许事件穿透
   - 不会拦截子组件的点击事件
   - 只在点击空白区域时收起键盘

2. **使用位置**
   - 通常包装整个页面或表单容器
   - 不需要包装每个输入框

3. **键盘收起**
   - 使用 `FocusManager.instance.primaryFocus?.unfocus()`
   - 适用于所有类型的输入框（TextField、TextFormField等）

4. **性能影响**
   - 组件非常轻量
   - 不会影响应用性能

## 使用场景

### ✅ 适合使用

- 表单页面
- 搜索页面
- 聊天输入页面
- 包含多个输入框的页面

### ❌ 不需要使用

- 单个输入框的简单页面
- 不包含输入框的页面
- 已有其他收起键盘逻辑的页面

## 最佳实践

1. **包装最外层**
```dart
// ✅ 好的做法：包装整个页面
BaseUnfocusOnTap(
  child: Scaffold(
    body: FormContent(),
  ),
)

// ❌ 不好的做法：包装每个输入框
Column(
  children: [
    BaseUnfocusOnTap(child: TextField()),
    BaseUnfocusOnTap(child: TextField()),
  ],
)
```

2. **配合 Scaffold**
```dart
// 推荐：在 Scaffold 内部使用
Scaffold(
  appBar: AppBar(),
  body: BaseUnfocusOnTap(
    child: Content(),
  ),
)
```

3. **结合 ScrollView**
```dart
BaseUnfocusOnTap(
  child: ListView(
    children: [
      // 表单项
    ],
  ),
)
```

## 扩展用法

### 自定义收起逻辑

```dart
class CustomUnfocusOnTap extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CustomUnfocusOnTap({
    required this.child,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        onTap?.call(); // 额外的回调
      },
      child: child,
    );
  }
}
```

### 条件收起键盘

```dart
class ConditionalUnfocus extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ConditionalUnfocus({
    required this.child,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
```

## 替代方案

### 方案1：直接使用 GestureDetector

```dart
GestureDetector(
  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
  behavior: HitTestBehavior.translucent,
  child: child,
)
```

### 方案2：使用 Scaffold 的 resizeToAvoidBottomInset

```dart
Scaffold(
  resizeToAvoidBottomInset: false, // 键盘不影响布局
  body: content,
)
```

### 方案3：手动控制焦点

```dart
FocusScope.of(context).unfocus(); // 收起键盘
FocusScope.of(context).requestFocus(FocusNode()); // 移除焦点
```

## 相关组件

- FocusManager - Flutter 焦点管理
- FocusScope - 焦点作用域
- TextField - 文本输入框
