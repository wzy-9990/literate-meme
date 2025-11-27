# BaseText

统一的文本展示组件，支持空值处理、金额格式化和动态字号。

## 功能特性

- ✅ 自动处理空值（null/undefined）
- ✅ 金额模式：自动格式化 + 动态字号
- ✅ 支持自适应字号
- ✅ 透传 Text 组件所有属性

## 基础用法

```dart
import 'package:flutter_tem/components/BaseText/index.dart';

// 普通文本
BaseText('Hello')

// 金额显示
BaseText(1234.56, isMoney: true)

// 自适应字号
BaseText('长文本内容...', autoFit: true)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| data | dynamic | - | 必需，要显示的内容 |
| isMoney | bool | false | 是否按金额格式显示 |
| moneyBaseFontSize | double | 14 | 金额模式基准字号 |
| autoFit | bool | false | 是否自适应字号 |
| style | TextStyle? | null | 文字样式 |

## 使用示例

### 金额显示

```dart
BaseText(1234.56, isMoney: true)  // 1,234.56
BaseText(null, isMoney: true)     // --
```

### 空值处理

```dart
BaseText(null)        // --
BaseText('')          // --
BaseText('content')   // content
```

## 相关组件

- Text - Flutter 原生文本组件
