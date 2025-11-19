# Git Hooks 和代码规范

本项目使用 [Lefthook](https://github.com/evilmartians/lefthook) 管理 Git Hooks，在提交代码时自动进行代码格式化和规范检查。

## 快速开始

### 1. 安装 Git Hooks

```bash
# 运行安装脚本（会自动安装 Lefthook 并设置 hooks）
./scripts/setup-git-hooks.sh
```

或者手动安装：

```bash
# macOS
brew install lefthook

# Linux
curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash
sudo apt install lefthook

# Windows (使用 Scoop)
scoop install lefthook

# 安装 hooks
lefthook install
```

### 2. 正常提交代码

```bash
git add .
git commit -m "feat: 添加新功能"
```

提交时会自动执行：
1. ✅ **代码自动格式化** - 使用 `dart format` 自动修复缩进、空格等格式问题
2. ✅ **代码规范检查** - 使用 `flutter analyze --fatal-warnings` 检查代码规范
3. ✅ **未使用代码检测** - 强制删除未使用的变量、导入、方法（会阻止提交）
4. ✅ **冲突标记检查** - 检查是否有未解决的 Git 冲突标记

## Pre-commit Hooks 详情

### 1. 代码自动格式化 (dart format)

**提交时自动修复**所有 `.dart` 文件的格式问题：
- ✅ **自动修复缩进异常** - 统一缩进为 2 空格
- ✅ **自动修复空格问题** - 运算符、括号周围的空格
- ✅ **自动修复换行** - 代码块、参数列表的换行
- ✅ **自动排序导入** - import 语句按字母顺序排列

格式化后的代码会**自动重新添加到暂存区**，无需手动操作。

**手动运行**：
```bash
# 格式化所有文件
dart format .

# 格式化特定文件
dart format lib/my_file.dart

# 仅检查不修改
dart format --set-exit-if-changed .
```

### 2. 代码规范检查 (dart analyze)

**只检查当前提交修改的文件**，以下问题会阻止提交：

**必须修复（会阻止提交）：**
- ❌ **未使用的变量** - 定义但未使用的局部变量
- ❌ **未使用的导入** - import 了但未使用的包
- ❌ **未使用的私有成员** - 定义但未调用的私有方法/字段
- ❌ **死代码** - 永远不会执行的代码
- ❌ **双引号** - 必须使用单引号 `'text'` 而非 `"text"`
- ❌ **缺少 const** - 不可变对象必须添加 `const` 关键字
- ❌ **使用 new** - 禁止使用 `new` 关键字（直接写构造函数）
- ❌ **不必要的 this** - 禁止不必要的 `this.`

**同时检查：**
- ✅ **类型安全** - 类型检查和转换
- ✅ **命名规范** - 变量、类、方法的命名
- ✅ **最佳实践** - Flutter/Dart 推荐的编码方式
- ✅ **潜在错误** - 可能导致运行时错误的代码

**重要提示**：
- ⚡ **提交时只检查修改的文件** - 快速高效，不会检查整个项目
- 📁 **全量检查** - 如需检查整个项目，使用手动命令

**手动运行**：
```bash
# 只分析修改的文件（快速）
dart analyze --fatal-warnings lib/my_file.dart

# 分析整个项目（全量检查）
flutter analyze

# 将警告视为错误
flutter analyze --fatal-warnings

# 自动修复部分问题（如删除未使用的导入）
dart fix --apply
```

### 3. 冲突标记检查

检查代码中是否包含 Git 冲突标记（如 `<<<<<<<`、`=======`、`>>>>>>>`）。

如果存在未解决的合并冲突，提交会被阻止。

## 代码规范配置

项目的代码规范配置在 `analysis_options.yaml` 文件中：

### 主要规范

#### 代码风格
- ✅ 使用单引号 `prefer_single_quotes`
- ✅ 声明返回类型 `always_declare_return_types`
- ✅ 避免使用 print `avoid_print`

#### 性能优化
- ✅ 使用 const 构造函数 `prefer_const_constructors`
- ✅ 使用 final 声明不变字段 `prefer_final_fields`
- ✅ 优先使用 const 声明 `prefer_const_declarations`

#### 错误预防
- ✅ 检查异步上下文使用 `use_build_context_synchronously`
- ✅ 取消订阅 `cancel_subscriptions`
- ✅ 关闭流 `close_sinks`

#### 可读性
- ✅ 使用空值感知运算符 `prefer_null_aware_operators`
- ✅ 使用 isEmpty/isNotEmpty `prefer_is_empty`
- ✅ 字符串插值而非拼接 `prefer_interpolation_to_compose_strings`

## 跳过 Hooks

如果需要临时跳过检查（**不推荐**）：

```bash
# 跳过 pre-commit hooks
git commit --no-verify -m "your message"

# 或使用简写
git commit -n -m "your message"
```

## 手动运行所有检查

```bash
# 运行所有 pre-commit 检查
lefthook run pre-commit

# 仅运行格式化检查
lefthook run pre-commit --commands format

# 仅运行代码分析
lefthook run pre-commit --commands analyze
```

## 自定义配置

### 修改 Lefthook 配置

编辑 `lefthook.yml` 文件：

```yaml
pre-commit:
  commands:
    format:
      glob: "*.dart"
      run: dart format --set-exit-if-changed {staged_files}
```

### 修改代码规范

编辑 `analysis_options.yaml` 文件：

```yaml
linter:
  rules:
    prefer_single_quotes: true
    # 添加或修改规则
```

修改后重新安装：
```bash
lefthook install
```

## 常见问题

### Q: 提交时提示"缩进异常"或格式问题？
A: 不用担心！`dart format` 会自动修复所有格式问题，包括缩进、空格、换行等。格式化后的代码会自动重新添加到暂存区，直接重新提交即可。

**示例：**
```bash
$ git commit -m "test"
正在格式化代码...
Formatted lib/test.dart  # 自动修复了缩进

# 代码已自动修复并重新暂存，提交继续...
```

### Q: 提交时提示"未使用的变量"错误？
A: 必须删除所有未使用的变量、导入和方法才能提交。

**查看具体错误：**
```bash
flutter analyze
```

**自动修复部分问题：**
```bash
dart fix --apply  # 会自动删除未使用的导入
```

**手动修复：**
- 删除未使用的局部变量
- 删除未使用的私有方法和字段
- 删除未使用的导入语句

**示例错误：**
```
error • The value of the local variable 'unusedVar' isn't used • lib/test.dart:10:12 • unused_local_variable
```

**修复方法：**
```dart
// ❌ 错误
void example() {
  String unusedVar = 'test';  // 删除这行
  print('hello');
}

// ✅ 正确
void example() {
  print('hello');
}
```

### Q: 提交时提示代码规范错误？
A: 运行 `flutter analyze --fatal-warnings` 查看所有错误，修复后重新提交。

常见错误类型：
- 未使用的变量/导入/方法 → 删除它们
- 类型错误 → 修正类型声明
- 命名不规范 → 使用正确的命名约定
- 缺少 const → 添加 const 关键字

### Q: 如何处理"死代码"错误？
A: 删除永远不会执行的代码。

```dart
// ❌ 错误：return 后的代码永远不会执行
void example() {
  return;
  print('dead code');  // 删除这行
}

// ✅ 正确
void example() {
  print('alive code');
  return;
}
```

### Q: 缩进是如何自动修复的？
A: `dart format` 会将所有代码统一格式化为标准的 Dart 代码风格：
- 缩进：2 个空格
- 大括号：K&R 风格
- 行宽：建议 80 字符（我们关闭了这个限制）
- 空格：运算符、逗号、括号周围的标准空格

无论你写的代码格式多混乱，提交时都会自动修复。

### Q: 如何在 CI/CD 中使用？
A: 在 CI 配置中添加：
```bash
# 检查格式（不自动修复）
dart format --set-exit-if-changed .

# 检查代码规范（包括未使用的代码）
flutter analyze --fatal-warnings
```

### Q: 如何卸载 Hooks？
A: 运行 `lefthook uninstall`

### Q: 紧急情况下如何跳过检查？
A: 使用 `--no-verify` 标志（不推荐）：
```bash
git commit --no-verify -m "emergency fix"
```
**注意：** 只在紧急情况下使用，之后应立即修复代码问题。

### Q: 在哪里可以看到更多示例？
A: 查看 [代码质量检查示例文档](CODE_QUALITY_EXAMPLES.md)，包含：
- 缩进自动修复的完整示例
- 未使用变量的错误和修复方法
- 死代码检测示例
- 完整的工作流程演示

## 更多信息

- [代码质量检查示例](CODE_QUALITY_EXAMPLES.md) - 详细示例和修复方法
- [Lefthook 文档](https://github.com/evilmartians/lefthook/blob/master/docs/full_guide.md)
- [Dart 代码风格指南](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Lints](https://pub.dev/packages/flutter_lints)
- [Dart Fix 工具](https://dart.dev/tools/dart-fix) - 自动修复代码问题
