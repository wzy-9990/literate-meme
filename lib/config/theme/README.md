# 主题配置说明

## 概述

`AppTheme` 类统一管理应用的主题配置，包括浅色主题和深色主题。

## 配置文件

- **位置**: `lib/config/theme/index.dart`
- **用途**: 集中管理应用的所有主题相关配置

## 使用方法

### 1. 基础使用（仅浅色主题）

```dart
GetMaterialApp(
  theme: AppTheme.lightTheme,
)
```

### 2. 支持深色模式

```dart
GetMaterialApp(
  theme: AppTheme.lightTheme,        // 浅色主题
  darkTheme: AppTheme.darkTheme,     // 深色主题
  themeMode: ThemeMode.system,       // 跟随系统设置
  // themeMode: ThemeMode.light,     // 强制使用浅色主题
  // themeMode: ThemeMode.dark,      // 强制使用深色主题
)
```

## 主题配置项

### 主色调

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: BaseColor.main,  // 种子颜色（橙色 #FE6601）
  primary: BaseColor.main,    // 主色
),
```

- **seedColor**: 基于此颜色生成整套和谐的 Material 3 配色
- **primary**: 主色，用于按钮、链接、进度条等

### AppBar 主题

```dart
appBarTheme: AppBarTheme(
  backgroundColor: Colors.white,              // 背景色
  foregroundColor: Colors.black,              // 前景色（标题、图标颜色）
  elevation: 0,                               // 阴影高度
  surfaceTintColor: Colors.transparent,       // 去除 Material 3 的 surface tint
  scrolledUnderElevation: 0,                  // 滚动时不改变阴影
  centerTitle: true,                          // 标题居中
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,       // 状态栏透明
    statusBarIconBrightness: Brightness.dark, // 状态栏图标深色
  ),
),
```

### 全局样式

```dart
splashColor: Colors.transparent,        // 禁用点击水波纹
highlightColor: Colors.transparent,     // 禁用点击高亮
scaffoldBackgroundColor: Color(0xFFF6F6F6), // 页面背景色
```

## 修改主题

### 修改主色调

编辑 `lib/styles/index.dart`：

```dart
class BaseColor {
  static const Color main = Color(0xFFFE6601); // 改为你的主题色
}
```

### 修改其他配置

编辑 `lib/config/theme/index.dart`：

```dart
static ThemeData get lightTheme {
  return ThemeData(
    // 修改这里的配置
    scaffoldBackgroundColor: Colors.white, // 例如：改背景色
    // ...
  );
}
```

## 常见问题

### Q: 如何切换主题色？

**A:** 只需修改 `lib/styles/index.dart` 中的 `BaseColor.main` 即可，所有使用主题色的地方会自动更新。

### Q: 如何实现深色模式切换？

**A:**
1. 在 `main.dart` 中取消注释深色主题配置
2. 使用 GetX 或 Provider 管理 `themeMode` 状态
3. 根据用户设置动态切换

示例：
```dart
// 使用 GetX
class ThemeController extends GetxController {
  var themeMode = ThemeMode.system.obs;

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }
}

// 在 GetMaterialApp 中使用
Obx(() => GetMaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeController.themeMode.value,
))
```

### Q: 为什么要抽离主题配置？

**A:**
1. **集中管理** - 所有主题配置在一个地方，便于维护
2. **代码整洁** - `main.dart` 更简洁，职责清晰
3. **易于扩展** - 添加深色模式或其他主题变体更方便
4. **便于测试** - 主题配置可以独立测试
5. **复用性** - 可以在其他项目中快速复用

## 最佳实践

### ✅ 应该做的

1. **使用主题色而非硬编码颜色**
   ```dart
   // ✅ 好
   color: Theme.of(context).primaryColor

   // ❌ 不好
   color: Color(0xFFFE6601)
   ```

2. **统一修改主题配置文件**
   - 所有主题相关配置都在 `lib/config/theme/index.dart` 中修改

3. **保持浅色和深色主题一致性**
   - 两个主题应该有相同的结构，只是颜色值不同

### ❌ 不应该做的

1. **不要在组件中硬编码主题样式**
2. **不要直接修改 `main.dart` 中的主题配置**
3. **不要在多个地方定义相同的主题配置**

## 相关文件

- `lib/config/theme/index.dart` - 主题配置类
- `lib/styles/index.dart` - 颜色常量定义
- `lib/main.dart` - 应用主题使用
