# 样式系统 (Design System)

## 概述

这是应用的设计系统基础层，定义了所有基础的样式常量，包括颜色、间距、圆角等。

## 文件结构

```
lib/config/styles/
  ├── colors.dart    # 颜色常量
  ├── spacing.dart   # 间距常量
  ├── radius.dart    # 圆角常量
  ├── index.dart     # 统一导出
  └── README.md      # 说明文档
```

## 使用方法

### 导入

```dart
import 'package:flutter_tem/styles/index.dart';
```

这会自动导入所有样式常量：`AppColors`、`AppSpacing`、`AppRadius`

## 颜色系统 (AppColors)

### 主题色

```dart
AppColors.primary       // 主题色 - 橙色 #FE6601
AppColors.primaryLight  // 主题色浅色变体
AppColors.primaryDark   // 主题色深色变体
```

**使用示例：**
```dart
Container(
  color: AppColors.primary,
  child: Text('主题色背景'),
)
```

### 功能色

```dart
AppColors.success  // 成功色 - 绿色
AppColors.warning  // 警告色 - 黄色
AppColors.error    // 错误色 - 红色
AppColors.info     // 信息色 - 蓝色
```

**使用示例：**
```dart
// 成功提示
Icon(Icons.check_circle, color: AppColors.success)

// 错误提示
Text('错误信息', style: TextStyle(color: AppColors.error))
```

### 文字颜色

```dart
AppColors.textPrimary       // 标题/重要文字 - 深灰 #333333
AppColors.textSecondary     // 正文/次要文字 - 中灰 #666666
AppColors.textTertiary      // 辅助文字 - 浅灰 #999999
AppColors.textPlaceholder   // 占位文字 - 更浅灰 #CCCCCC
```

**使用示例：**
```dart
Text(
  '这是标题',
  style: TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)

Text(
  '这是正文',
  style: TextStyle(color: AppColors.textSecondary),
)
```

### 背景色

```dart
AppColors.background  // 页面背景色 #F6F6F6
AppColors.surface     // 卡片/组件背景色 #FFFFFF
AppColors.divider     // 分割线颜色 #EEEEEE
AppColors.border      // 边框颜色 #DDDDDD
```

**使用示例：**
```dart
Scaffold(
  backgroundColor: AppColors.background,
  body: Container(
    color: AppColors.surface,
    // ...
  ),
)
```

### 透明度变体

```dart
AppColors.primaryOpacity10  // 主题色 10% 透明度
AppColors.primaryOpacity20  // 主题色 20% 透明度
AppColors.primaryOpacity50  // 主题色 50% 透明度
```

**使用示例：**
```dart
Container(
  color: AppColors.primaryOpacity10, // 浅色背景
  child: Text('高亮区域'),
)
```

## 间距系统 (AppSpacing)

### 基础间距

```dart
AppSpacing.xs    // 4px  - 极小间距
AppSpacing.sm    // 8px  - 小间距
AppSpacing.md    // 12px - 中等间距
AppSpacing.base  // 16px - 默认间距
AppSpacing.lg    // 24px - 大间距
AppSpacing.xl    // 32px - 超大间距
AppSpacing.xxl   // 48px - 特大间距
```

**使用示例：**
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.base), // 16px
  child: Column(
    children: [
      Text('标题'),
      SizedBox(height: AppSpacing.md), // 12px 垂直间距
      Text('内容'),
    ],
  ),
)
```

### 组件间距

```dart
AppSpacing.cardPadding            // 卡片内边距
AppSpacing.listItemPadding        // 列表项内边距
AppSpacing.buttonPaddingHorizontal // 按钮水平内边距
AppSpacing.buttonPaddingVertical   // 按钮垂直内边距
AppSpacing.inputPadding           // 输入框内边距
```

**使用示例：**
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.cardPadding),
    child: Text('卡片内容'),
  ),
)
```

### 间距倍数

```dart
AppSpacing.multiple(2.0)  // 16 * 2 = 32px
AppSpacing.multiple(0.5)  // 16 * 0.5 = 8px
```

## 圆角系统 (AppRadius)

### 基础圆角

```dart
AppRadius.xs      // 2px  - 极小圆角
AppRadius.sm      // 4px  - 小圆角
AppRadius.md      // 8px  - 中等圆角
AppRadius.base    // 12px - 默认圆角
AppRadius.lg      // 16px - 大圆角
AppRadius.xl      // 24px - 超大圆角
AppRadius.circle  // 9999 - 完全圆形
```

**使用示例（数值）：**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadius.base), // 12px
  ),
)
```

### BorderRadius 对象

```dart
AppRadius.baseRadius   // BorderRadius.circular(12)
AppRadius.lgRadius     // BorderRadius.circular(16)
// ... 其他同理
```

**使用示例（对象）：**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: AppRadius.baseRadius, // 更简洁
  ),
)
```

### 组件圆角

```dart
AppRadius.button      // 按钮圆角 - 8px
AppRadius.card        // 卡片圆角 - 12px
AppRadius.input       // 输入框圆角 - 8px
AppRadius.dialog      // 对话框圆角 - 16px
AppRadius.bottomSheet // 底部弹窗圆角（仅顶部圆角）
```

**使用示例：**
```dart
// 底部弹窗
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: AppRadius.bottomSheet,
  ),
)
```

## 完整示例

### 卡片组件

```dart
Container(
  margin: EdgeInsets.all(AppSpacing.base),
  padding: EdgeInsets.all(AppSpacing.cardPadding),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.baseRadius,
    border: Border.all(color: AppColors.border),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '卡片标题',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      Text(
        '卡片内容描述',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      SizedBox(height: AppSpacing.md),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
        ),
        onPressed: () {},
        child: Text('操作按钮'),
      ),
    ],
  ),
)
```

## 迁移指南

### 从 BaseColor 迁移到 AppColors

**旧代码：**
```dart
color: BaseColor.main
```

**新代码：**
```dart
color: AppColors.primary
```

**注意：** `BaseColor.main` 仍然可用（向后兼容），但建议迁移到 `AppColors.primary`。

## 最佳实践

### ✅ 应该做的

1. **使用样式常量而非硬编码**
   ```dart
   // ✅ 好
   color: AppColors.primary
   padding: EdgeInsets.all(AppSpacing.base)
   borderRadius: AppRadius.baseRadius

   // ❌ 不好
   color: Color(0xFFFE6601)
   padding: EdgeInsets.all(16.0)
   borderRadius: BorderRadius.circular(12.0)
   ```

2. **选择语义化的颜色名称**
   ```dart
   // ✅ 好 - 语义明确
   color: AppColors.textPrimary  // 主要文字
   color: AppColors.success      // 成功状态

   // ❌ 不好 - 不够语义化
   color: AppColors.primary      // 用于文字？还是背景？
   ```

3. **保持间距一致**
   ```dart
   // ✅ 好 - 使用统一的间距系统
   SizedBox(height: AppSpacing.md)  // 12px
   SizedBox(height: AppSpacing.lg)  // 24px

   // ❌ 不好 - 随意的间距值
   SizedBox(height: 13.0)
   SizedBox(height: 25.0)
   ```

### ❌ 不应该做的

1. **不要硬编码颜色和尺寸**
2. **不要在业务代码中定义样式常量**
3. **不要使用魔法数字（magic numbers）**

## 扩展样式系统

如果需要添加新的样式常量：

1. **添加新颜色** - 编辑 `lib/config/styles/colors.dart`
2. **添加新间距** - 编辑 `lib/config/styles/spacing.dart`
3. **添加新圆角** - 编辑 `lib/config/styles/radius.dart`

所有更改会自动通过 `index.dart` 导出。

## 相关文件

- `lib/config/styles/colors.dart` - 颜色常量定义
- `lib/config/styles/spacing.dart` - 间距常量定义
- `lib/config/styles/radius.dart` - 圆角常量定义
- `lib/config/theme/index.dart` - 主题配置（使用这些常量）
