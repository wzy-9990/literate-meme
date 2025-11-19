# 验证未使用变量拦截功能

本文档演示如何验证 Git hooks 正确拦截未使用的变量、字段和导入。

## ✅ 配置确认

当前配置已正确设置，会将以下问题视为**错误**（阻止提交）：

**analysis_options.yaml:**
```yaml
errors:
  unused_local_variable: error  # 未使用的局部变量
  unused_element: error         # 未使用的私有成员
  unused_field: error           # 未使用的私有字段
  unused_import: error          # 未使用的导入
  unused_shown_name: error      # 未使用的 show 语句
  dead_code: error              # 死代码
```

**lefthook.yml:**
```yaml
analyze:
  run: flutter analyze --fatal-warnings  # 将警告视为错误
```

## 🧪 本地验证测试

### 测试 1: 未使用的类字段

创建测试文件 `test_unused.dart`:

```dart
import 'package:flutter/material.dart';

class TestUnused extends StatelessWidget {
  // ❌ 错误：定义但从未使用的字段
  final List<Map<String, dynamic>> _uploadedData = [];
  final String _unusedField = 'test';

  const TestUnused({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello'),
    );
  }
}
```

**尝试提交：**
```bash
git add test_unused.dart
git commit -m "test: 测试未使用字段"
```

**预期结果（会被阻止）：**
```
╭──────────────────────────────────────╮
│ 🥊 lefthook v2.0.4  hook: pre-commit │
╰──────────────────────────────────────╯

正在格式化代码...
Formatted test_unused.dart

正在检查代码规范...
检查未使用的变量、导入和死代码...

Analyzing flutter_tem...

  error • Unused field '_uploadedData' • test_unused.dart:5:43 • unused_field
  error • Unused field '_unusedField' • test_unused.dart:6:16 • unused_field

2 issues found.

❌ 提交被阻止！
```

### 测试 2: 未使用的局部变量

```dart
import 'package:flutter/material.dart';

class TestUnused extends StatelessWidget {
  const TestUnused({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ❌ 错误：定义但从未使用的局部变量
    String unusedVariable = 'test';
    int count = 0;

    return Container(
      child: Text('Hello'),
    );
  }
}
```

**预期结果：**
```
error • The value of the local variable 'unusedVariable' isn't used • test_unused.dart:9:12 • unused_local_variable
error • The value of the local variable 'count' isn't used • test_unused.dart:10:9 • unused_local_variable

❌ 提交被阻止！
```

### 测试 3: 未使用的导入

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';  // ❌ 错误：导入但未使用

class TestUnused extends StatelessWidget {
  const TestUnused({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello'),
    );
  }
}
```

**预期结果：**
```
error • Unused import: 'package:get/get.dart' • test_unused.dart:2:8 • unused_import

❌ 提交被阻止！
```

### 测试 4: 死代码

```dart
import 'package:flutter/material.dart';

class TestUnused extends StatelessWidget {
  const TestUnused({Key? key}) : super(key: key);

  void example() {
    return;
    print('这行代码永远不会执行');  // ❌ 错误：死代码
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello'),
    );
  }
}
```

**预期结果：**
```
error • Dead code • test_unused.dart:8:5 • dead_code

❌ 提交被阻止！
```

## 🔧 修复方法

### 方法 1: 自动修复（推荐）

```bash
# 自动删除未使用的导入
dart fix --apply

# 查看所有错误
flutter analyze
```

### 方法 2: 手动修复

1. **删除未使用的字段：**
```dart
// ❌ 错误
class TestUnused {
  final List<Map<String, dynamic>> _uploadedData = [];  // 删除这行
}

// ✅ 正确
class TestUnused {
  // 只保留实际使用的字段
}
```

2. **删除未使用的局部变量：**
```dart
// ❌ 错误
void example() {
  String unusedVariable = 'test';  // 删除这行
  print('hello');
}

// ✅ 正确
void example() {
  print('hello');
}
```

3. **删除未使用的导入：**
```dart
// ❌ 错误
import 'package:get/get.dart';  // 删除这行

// ✅ 正确
// 只保留实际使用的导入
```

4. **删除死代码：**
```dart
// ❌ 错误
void example() {
  return;
  print('dead code');  // 删除这行
}

// ✅ 正确
void example() {
  return;
}
```

## 📋 完整测试流程

```bash
# 1. 创建包含未使用代码的文件
cat > test_unused.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';  // 未使用的导入

class TestUnused extends StatelessWidget {
  final String _unusedField = 'test';  // 未使用的字段

  const TestUnused({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String unusedVar = 'test';  // 未使用的局部变量
    return Container(child: Text('Hello'));
  }
}
EOF

# 2. 尝试提交
git add test_unused.dart
git commit -m "test: 未使用代码"

# ❌ 预期输出：
# error • Unused import: 'package:get/get.dart'
# error • Unused field '_unusedField'
# error • The value of the local variable 'unusedVar' isn't used
# 提交被阻止！

# 3. 自动修复
dart fix --apply

# 4. 手动删除剩余未使用代码
vim test_unused.dart  # 删除 _unusedField 和 unusedVar

# 5. 重新提交
git add test_unused.dart
git commit -m "test: 已修复未使用代码"

# ✅ 成功提交！
```

## ⚠️ 重要提示

1. **所有未使用的代码都必须删除才能提交**
2. **`dart fix --apply` 只能自动修复部分问题**（如未使用的导入）
3. **未使用的字段和局部变量需要手动删除**
4. **提交时使用 `--no-verify` 跳过检查是不推荐的**

## 🎯 实际使用示例

### 场景：你定义了 `_uploadedData` 但从未使用

```dart
class UploadExample {
  // ❌ 错误：定义但从未使用
  List<Map<String, dynamic>> _uploadedData = [];

  void uploadFile() {
    // ... 上传逻辑，但没有使用 _uploadedData
  }
}
```

**提交时会被阻止：**
```
error • Unused field '_uploadedData' • lib/xxx.dart:2:35 • unused_field
```

**修复方法：**

**选项 1：如果确实不需要，直接删除**
```dart
class UploadExample {
  // 删除 _uploadedData

  void uploadFile() {
    // ... 上传逻辑
  }
}
```

**选项 2：如果需要但忘记使用，添加使用逻辑**
```dart
class UploadExample {
  List<Map<String, dynamic>> _uploadedData = [];

  void uploadFile() {
    // 使用 _uploadedData
    _uploadedData.add({'file': 'test.jpg'});
  }

  List<Map<String, dynamic>> getUploadedData() {
    return _uploadedData;  // 现在 _uploadedData 被使用了
  }
}
```

## 🚀 验证配置是否生效

运行以下命令确认配置正确：

```bash
# 1. 确认 Git hooks 已安装
ls -la .git/hooks/pre-commit
# 应该看到 pre-commit 文件

# 2. 确认 lefthook 已安装
lefthook version
# 应该显示版本号

# 3. 手动测试代码分析
flutter analyze --fatal-warnings
# 会显示所有错误（包括未使用的代码）

# 4. 手动运行 pre-commit hooks
lefthook run pre-commit
# 会执行格式化和代码检查
```

## 📌 总结

✅ **配置已正确设置**
✅ **未使用的变量会阻止提交**
✅ **需要在有 Flutter SDK 的本地环境测试**
✅ **使用 `dart fix --apply` 可自动修复部分问题**
✅ **手动删除未使用的字段和局部变量**

**下次提交代码时，任何未使用的变量都会被自动检测并阻止提交！**
