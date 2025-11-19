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
1. ✅ **代码格式化检查** - 使用 `dart format` 检查并格式化代码
2. ✅ **代码规范检查** - 使用 `flutter analyze` 检查代码规范
3. ✅ **冲突标记检查** - 检查是否有未解决的 Git 冲突标记

## Pre-commit Hooks 详情

### 1. 代码格式化 (dart format)

自动格式化所有 `.dart` 文件：
- 统一缩进、空格、换行
- 自动排序 import 语句
- 格式化代码结构

**手动运行**：
```bash
# 格式化所有文件
dart format .

# 仅检查不修改
dart format --set-exit-if-changed .
```

### 2. 代码规范检查 (flutter analyze)

检查代码是否符合 Dart/Flutter 规范：
- 类型安全
- 命名规范
- 最佳实践
- 潜在错误

**手动运行**：
```bash
flutter analyze
```

### 3. 冲突标记检查

检查代码中是否包含 Git 冲突标记：
```
<<<<<<< HEAD
=======
>>>>>>> branch
```

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

### Q: 提交时提示格式化失败？
A: 运行 `dart format .` 格式化所有代码后重新提交

### Q: 提交时提示代码规范错误？
A: 运行 `flutter analyze` 查看具体错误，修复后重新提交

### Q: 如何在 CI/CD 中使用？
A: 在 CI 配置中添加：
```bash
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
```

### Q: 如何卸载 Hooks？
A: 运行 `lefthook uninstall`

## 更多信息

- [Lefthook 文档](https://github.com/evilmartians/lefthook/blob/master/docs/full_guide.md)
- [Dart 代码风格指南](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Lints](https://pub.dev/packages/flutter_lints)
