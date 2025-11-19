# 代码质量检查示例

本文档展示 Git Hooks 如何自动修复代码缩进和强制删除未使用的变量。

## 1. 自动修复代码缩进

### ❌ 提交前（缩进混乱）

```dart
class BadIndentation {
void method() {
if (true) {
print('bad');
}
}
}
```

### ✅ 提交后（自动格式化）

```dart
class BadIndentation {
  void method() {
    if (true) {
      print('bad');
    }
  }
}
```

**执行过程：**
```bash
$ git commit -m "test"

正在格式化代码...
Formatted lib/test.dart

# 文件自动格式化后重新添加到暂存区
# 提交继续...
```

## 2. 强制删除未使用的变量

### ❌ 会被阻止的提交

```dart
class UnusedVariables {
  void example() {
    // ❌ 未使用的局部变量
    String unusedVariable = 'test';
    int unusedNumber = 42;

    // ❌ 未使用的导入
    // import 'package:flutter/material.dart'; // 如果没用到会报错

    print('hello');
  }

  // ❌ 未使用的私有字段
  String _unusedField = 'unused';

  // ❌ 未使用的私有方法
  void _unusedMethod() {
    print('never called');
  }
}
```

**执行过程：**
```bash
$ git commit -m "test"

正在格式化代码...
Formatted lib/test.dart

正在检查代码规范...
检查未使用的变量、导入和死代码...

Analyzing flutter_tem...

  error • The value of the local variable 'unusedVariable' isn't used • lib/test.dart:4:12 • unused_local_variable
  error • The value of the local variable 'unusedNumber' isn't used • lib/test.dart:5:9 • unused_local_variable
  error • Unused element '_unusedField' • lib/test.dart:12:10 • unused_element
  error • Unused element '_unusedMethod' • lib/test.dart:15:8 • unused_element

4 issues found.

❌ 提交被阻止！请修复上述问题后重新提交
```

### ✅ 正确的代码（会通过）

```dart
class GoodCode {
  void example() {
    // ✅ 只定义实际使用的变量
    String message = 'hello';
    print(message);
  }

  // ✅ 只保留使用的字段
  String _usedField = 'used';

  String getField() => _usedField;

  // ✅ 只保留被调用的方法
  void _usedMethod() {
    print('this is called');
  }

  void caller() {
    _usedMethod();
  }
}
```

## 3. 其他会被阻止的情况

### 未使用的导入

```dart
// ❌ 导入但未使用
import 'package:flutter/material.dart';  // 错误：未使用
import 'package:get/get.dart';  // 错误：未使用

void main() {
  print('hello');
}
```

修复：
```dart
// ✅ 只导入需要的
void main() {
  print('hello');
}
```

### 死代码（永远不会执行的代码）

```dart
void example() {
  return;
  print('dead code');  // ❌ 错误：永远不会执行
}
```

修复：
```dart
void example() {
  print('alive code');  // ✅ 正确
  return;
}
```

### 不必要的 this

```dart
class Example {
  String name = 'test';

  void method() {
    print(this.name);  // ❌ 警告：不必要的 this
  }
}
```

修复：
```dart
class Example {
  String name = 'test';

  void method() {
    print(name);  // ✅ 正确
  }
}
```

### 不必要的 new

```dart
void example() {
  var list = new List<int>();  // ❌ 警告：不必要的 new
}
```

修复：
```dart
void example() {
  var list = <int>[];  // ✅ 正确
}
```

## 4. 如何修复这些问题

### 自动修复（推荐）

大多数格式问题可以自动修复：

```bash
# 格式化所有代码
dart format .

# 修复部分 lint 问题（如删除未使用的导入）
dart fix --apply
```

### 手动修复

1. 运行 `flutter analyze` 查看所有问题
2. 逐个修复错误和警告
3. 删除未使用的变量、导入和方法

### 在 IDE 中修复

**VS Code:**
- 将鼠标悬停在警告/错误上
- 点击"Quick Fix"（快速修复）
- 选择修复选项

**Android Studio / IntelliJ:**
- Alt + Enter（Windows/Linux）
- Option + Enter（macOS）
- 选择修复选项

## 5. 临时允许未使用的代码（不推荐）

如果确实需要保留未使用的代码（极少情况），可以添加注释：

```dart
// ignore: unused_local_variable
String futureUse = 'will use later';

// ignore: unused_element
void _futureMethod() {
  // 计划未来使用
}
```

但**强烈不推荐**这样做，应该：
- 真正用不到的代码直接删除
- 计划未来使用的功能，等实际需要时再添加

## 6. 完整工作流程

```bash
# 1. 编写代码（可能有缩进问题和未使用的变量）
vim lib/my_code.dart

# 2. 添加到暂存区
git add lib/my_code.dart

# 3. 提交（会自动检查）
git commit -m "feat: 添加新功能"

# 执行过程：
# ✅ 自动格式化代码
# ✅ 检查代码规范
# ❌ 如果有未使用的变量，提交失败

# 4. 修复问题
dart fix --apply  # 自动修复
# 或手动删除未使用的变量

# 5. 重新提交
git add .
git commit -m "feat: 添加新功能"

# ✅ 所有检查通过，提交成功
```

## 7. 检查严格程度

当前配置会将以下问题视为**错误**（阻止提交）：

- ❌ 未使用的局部变量 `unused_local_variable`
- ❌ 未使用的私有成员 `unused_element`
- ❌ 未使用的私有字段 `unused_field`
- ❌ 未使用的导入 `unused_import`
- ❌ 未使用的 show 语句 `unused_shown_name`
- ❌ 死代码（永远不会执行）`dead_code`

这些问题会在提交时被拦截，必须修复后才能提交。

## 8. 禁用检查（紧急情况）

如果在紧急情况下需要跳过检查：

```bash
# 跳过所有 Git hooks
git commit --no-verify -m "emergency fix"

# 或使用简写
git commit -n -m "emergency fix"
```

**⚠️ 警告：** 只在紧急情况下使用，之后应该立即修复代码问题。
