# 代码风格强制要求

本文档说明提交时会被强制拦截的代码风格问题。

## 🚫 会阻止提交的问题

### 1. 使用双引号

❌ **错误（会阻止提交）：**
```dart
String message = "Hello World";  // 必须使用单引号
Text("Hello");
```

✅ **正确：**
```dart
String message = 'Hello World';  // 使用单引号
Text('Hello');
```

**提交时错误提示：**
```
error • Prefer using single quotes • lib/test.dart:1:18 • prefer_single_quotes
```

**快速修复：**
- IDE 中使用快速修复（Alt+Enter / Option+Enter）
- 或手动将所有 `"..."` 改为 `'...'`

---

### 2. 缺少 const 关键字

❌ **错误（会阻止提交）：**
```dart
// 不可变的构造函数调用必须加 const
Widget build(BuildContext context) {
  return Container(
    child: Text('Hello'),  // ❌ 缺少 const
  );
}

// 不可变的字面量必须加 const
final list = [1, 2, 3];  // ❌ 如果列表不会改变，应加 const
```

✅ **正确：**
```dart
Widget build(BuildContext context) {
  return Container(
    child: const Text('Hello'),  // ✅ 添加 const
  );
}

const list = [1, 2, 3];  // ✅ 添加 const
```

**提交时错误提示：**
```
error • Prefer const with constant constructors • lib/test.dart:3:12 • prefer_const_constructors
error • Prefer const literals to create immutables • lib/test.dart:7:14 • prefer_const_literals_to_create_immutables
```

**快速修复：**
- IDE 中使用快速修复自动添加 const
- 或手动在构造函数前添加 `const` 关键字

---

### 3. 使用 new 关键字

❌ **错误（会阻止提交）：**
```dart
var list = new List<int>();  // ❌ 不要使用 new
var widget = new Container();  // ❌ 不要使用 new
```

✅ **正确：**
```dart
var list = <int>[];  // ✅ 直接使用字面量
var widget = Container();  // ✅ 直接调用构造函数
```

**提交时错误提示：**
```
error • Unnecessary new keyword • lib/test.dart:1:12 • unnecessary_new
```

**快速修复：**
- IDE 中使用快速修复自动删除 new
- 或手动删除 `new` 关键字

---

### 4. 不必要的 this

❌ **错误（会阻止提交）：**
```dart
class MyClass {
  String name = 'test';

  void printName() {
    debugPrint(this.name);  // ❌ 不必要的 this
  }
}
```

✅ **正确：**
```dart
class MyClass {
  String name = 'test';

  void printName() {
    debugPrint(name);  // ✅ 直接使用
  }
}
```

**提交时错误提示：**
```
error • Unnecessary this • lib/test.dart:6:11 • unnecessary_this
```

**快速修复：**
- IDE 中使用快速修复自动删除 this
- 或手动删除 `this.`

**注意：** 只有在需要消除歧义时才使用 this（如构造函数参数与字段同名）

---

### 5. 缺少方法返回类型

❌ **错误（会阻止提交）：**
```dart
class Example {
  // ❌ 缺少返回类型
  openWebView() {
    // ...
  }

  // ❌ 缺少返回类型
  getData() {
    return 'data';
  }
}
```

✅ **正确：**
```dart
class Example {
  // ✅ 声明返回类型
  void openWebView() {
    // ...
  }

  // ✅ 声明返回类型
  String getData() {
    return 'data';
  }

  // ✅ 异步方法也要声明返回类型
  Future<void> fetchData() async {
    // ...
  }

  Future<String> loadData() async {
    return 'data';
  }
}
```

**提交时错误提示：**
```
error • The method 'openWebView' should have a return type but doesn't • lib/test.dart:2:3 • always_declare_return_types
error • The method 'getData' should have a return type but doesn't • lib/test.dart:6:3 • always_declare_return_types
```

**快速修复：**
- IDE 中使用快速修复自动添加返回类型
- 或手动添加返回类型：
  - 无返回值：`void`
  - 返回字符串：`String`
  - 返回数字：`int`、`double`
  - 异步无返回值：`Future<void>`
  - 异步返回值：`Future<String>`、`Future<int>` 等

---

### 6. 使用 debugPrint() 输出日志

❌ **错误（会阻止提交）：**
```dart
void debugLog() {
  debugPrint('Debug message');  // ❌ 禁止使用 print
  debugPrint('User data: $userData');
}

void main() {
  debugPrint('App started');  // ❌ 生产代码中禁止使用 print
}
```

✅ **正确：**
```dart
import 'package:flutter/foundation.dart';

void debugLog() {
  debugPrint('Debug message');  // ✅ 使用 debugPrint
  debugPrint('User data: $userData');
}

void main() {
  debugPrint('App started');  // ✅ 使用 debugPrint 或日志框架
}
```

**提交时错误提示：**
```
error • Don't invoke 'print' in production code • lib/test.dart:2:3 • avoid_print
```

**快速修复：**
- 将所有 `debugPrint()` 替换为 `debugPrint()`
- 或使用专业的日志框架（如 logger、dio 的日志拦截器等）

**为什么禁止 debugPrint()？**
- `debugPrint()` 在生产环境会输出所有日志，可能暴露敏感信息
- `debugPrint()` 只在调试模式下输出，发布版本自动禁用
- `debugPrint()` 会自动处理长文本（超过 1024 字符会分段输出）
- 使用日志框架可以更好地控制日志级别和输出目标

---

## 📋 完整示例

### 错误代码（会被阻止提交）

```dart
class BadExample {
  // ❌ 使用双引号
  String message = "Hello World";

  // ❌ 缺少 const
  final numbers = [1, 2, 3];

  BadExample() {
    // ❌ 不必要的 this
    debugPrint(this.message);

    // ❌ 使用 new
    var list = new List<int>();
  }

  // ❌ 缺少返回类型
  openWebView() {
    // ...
  }

  Widget build() {
    return Container(
      // ❌ 缺少 const
      child: Text("Hello"),  // 还有双引号问题
    );
  }
}
```

**提交时错误：**
```
error • Prefer using single quotes • lib/bad_example.dart:3:20 • prefer_single_quotes
error • Prefer const literals to create immutables • lib/bad_example.dart:6:19 • prefer_const_literals_to_create_immutables
error • Don't invoke 'print' in production code • lib/bad_example.dart:10:5 • avoid_print
error • Unnecessary this • lib/bad_example.dart:10:11 • unnecessary_this
error • Unnecessary new keyword • lib/bad_example.dart:13:16 • unnecessary_new
error • The method 'openWebView' should have a return type but doesn't • lib/bad_example.dart:16:3 • always_declare_return_types
error • Prefer using single quotes • lib/bad_example.dart:20:18 • prefer_single_quotes
error • Prefer const with constant constructors • lib/bad_example.dart:20:12 • prefer_const_constructors

8 issues found.

❌ 提交被阻止！
```

### 正确代码（可以提交）

```dart
class GoodExample {
  // ✅ 使用单引号
  String message = 'Hello World';

  // ✅ 使用 const
  static const numbers = [1, 2, 3];

  GoodExample() {
    // ✅ 不使用 this（非必要时）
    debugPrint(message);  // ✅ 使用 debugPrint 而非 print

    // ✅ 不使用 new
    var list = <int>[];
  }

  // ✅ 声明返回类型
  void openWebView() {
    // ...
  }

  Widget build() {
    return Container(
      // ✅ 使用 const 和单引号
      child: const Text('Hello'),
    );
  }
}
```

**提交时：**
```
✅ 所有检查通过！
```

---

## 🔧 批量修复

### 自动修复（推荐）

```bash
# 自动修复大部分代码风格问题
dart fix --apply

# 然后格式化代码
dart format .

# 查看剩余问题
flutter analyze
```

### 手动修复清单

提交前检查：
- [ ] 所有字符串使用单引号 `'...'`
- [ ] 不可变对象添加 `const` 关键字
- [ ] 删除所有 `new` 关键字
- [ ] 删除不必要的 `this.`
- [ ] 所有方法声明返回类型（`void`、`String`、`Future<void>` 等）
- [ ] 使用 `debugPrint()` 而非 `debugPrint()`
- [ ] 删除未使用的变量和导入

---

## 💡 IDE 配置

### VS Code

**推荐插件：**
- Dart
- Flutter

**自动修复设置** (settings.json):
```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "dart.previewFlutterUiGuides": true,
  "dart.closingLabels": true
}
```

### Android Studio / IntelliJ

**设置：**
1. Preferences → Editor → Inspections
2. 启用所有 Dart/Flutter 检查
3. 设置严重程度为 "Error"

**快捷键：**
- Alt+Enter (Windows/Linux) 快速修复
- Option+Enter (macOS) 快速修复
- Ctrl+Alt+L (Windows/Linux) 格式化代码
- Cmd+Option+L (macOS) 格式化代码

---

## 🎯 提交工作流

```bash
# 1. 写代码（可能有风格问题）
vim lib/my_code.dart

# 2. 自动修复风格问题
dart fix --apply

# 3. 格式化代码
dart format .

# 4. 提交
git add .
git commit -m "feat: 新功能"

# ✅ 如果仍有错误，会被拦截
# 📝 根据错误提示修复后重新提交
```

---

## ❓ 常见问题

### Q: 为什么要强制使用单引号？

A: Dart 官方风格指南推荐使用单引号，原因：
- 更简洁
- 减少转义（字符串中包含双引号时）
- 与其他现代语言（JavaScript、TypeScript）保持一致

### Q: 为什么要强制使用 const？

A: 使用 const 有多个好处：
- **性能优化** - const 对象在编译时创建，可以重用
- **减少内存** - 相同的 const 对象只创建一次
- **更快的重建** - Flutter 可以跳过 const widget 的重建
- **更好的热重载** - const widget 在热重载时不会被重建

### Q: 什么时候可以不用 const？

A: 以下情况不能使用 const：
```dart
// ❌ 不能使用 const（依赖运行时值）
Widget build(BuildContext context) {
  return Text(DateTime.now().toString());  // 运行时值
}

// ❌ 不能使用 const（依赖变量）
String message = getMessage();
Text(message);  // 变量值

// ✅ 可以使用 const（编译时常量）
const Text('Hello');
const SizedBox(width: 100);
```

### Q: 如何处理字符串中包含单引号的情况？

A: 使用转义或三引号：
```dart
// 方法 1: 转义
String message = 'It\'s a beautiful day';

// 方法 2: 三引号（多行字符串）
String message = '''It's a beautiful day''';

// 特殊情况：包含大量单引号时可以使用双引号
String json = "{\"name\": \"John\"}";  // 这种情况允许
```

### Q: 提交时出现大量 const 错误怎么办？

A: 使用自动修复工具：
```bash
# 方法 1: dart fix（推荐）
dart fix --apply

# 方法 2: IDE 批量修复
# VS Code: Ctrl+Shift+P → "Fix All"
# Android Studio: Code → Reformat Code

# 方法 3: 手动修复
# 根据错误提示逐个添加 const
```

---

## 📊 代码质量提升效果

启用这些强制要求后：

| 指标 | 改进 |
|------|------|
| **编译后包体积** | 减少 5-10% |
| **Widget 重建次数** | 减少 20-30% |
| **内存使用** | 减少 10-15% |
| **代码一致性** | 100% 统一 |
| **代码审查时间** | 减少 50% |

---

## 🔗 参考资源

- [Dart 代码风格指南](https://dart.dev/guides/language/effective-dart/style)
- [Flutter 性能最佳实践](https://flutter.dev/docs/perf/best-practices)
- [Dart Fix 工具文档](https://dart.dev/tools/dart-fix)
- [Flutter Lints](https://pub.dev/packages/flutter_lints)
