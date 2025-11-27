# BaseRadio

单选组件，支持按钮模式和普通单选框模式。

## 功能特性

- ✅ 两种显示模式（按钮/单选框）
- ✅ 支持 Map 和 BaseRadioOption 数据源
- ✅ 自定义字段名映射
- ✅ 完整的样式自定义
- ✅ 返回选中值和完整对象

## 基础用法

```dart
import 'package:flutter_tem/components/BaseRadio/index.dart';

final options = [
  {'label': '男', 'value': 'male'},
  {'label': '女', 'value': 'female'},
];

BaseRadioGroup(
  options: options,
  value: selectedGender,
  onChanged: (value) {
    setState(() => selectedGender = value);
  },
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| options | List<dynamic> | - | 必需，选项列表 |
| value | T? | null | 当前选中值 |
| onChanged | ValueChanged<T>? | null | 选中变化回调 |
| onChangedWithItem | ValueChanged<Map>? | null | 返回完整对象的回调 |
| asButton | bool | false | 是否使用按钮模式 |
| labelField | String | 'label' | 显示字段名 |
| valueField | String | 'value' | 值字段名 |

## 使用示例

### 示例1：性别选择

```dart
final genders = [
  {'label': '男', 'value': 'male'},
  {'label': '女', 'value': 'female'},
];

BaseRadioGroup(
  options: genders,
  value: gender,
  onChanged: (value) {
    setState(() => gender = value);
  },
)
```

### 示例2：按钮模式

```dart
BaseRadioGroup(
  options: options,
  value: selectedValue,
  asButton: true,
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

## 相关组件

- [BaseCheckbox](../BaseCheckbox/README.md) - 多选组件
- [BaseButton](../BaseButton/README.md) - 按钮组件
