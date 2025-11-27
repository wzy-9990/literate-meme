# BaseCheckbox

多选组件，支持按钮模式和普通复选框模式。

## 功能特性

- ✅ 两种显示模式（按钮/复选框）
- ✅ 支持 Map 和 BaseCheckboxOption 数据源
- ✅ 自定义字段名映射
- ✅ 完整的样式自定义
- ✅ 返回选中值和完整对象

## 基础用法

```dart
import 'package:flutter_tem/components/BaseCheckbox/index.dart';

final options = [
  {'label': '选项1', 'value': '1'},
  {'label': '选项2', 'value': '2'},
  {'label': '选项3', 'value': '3'},
];

BaseCheckboxGroup(
  options: options,
  values: selectedValues,
  onChanged: (values) {
    setState(() => selectedValues = values);
  },
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| options | List<dynamic> | - | 必需，选项列表 |
| values | List<T> | [] | 已选中的值列表 |
| onChanged | ValueChanged<List<T>>? | null | 选中变化回调 |
| onChangedWithItem | ValueChanged<Map>? | null | 返回完整对象的回调 |
| asButton | bool | false | 是否使用按钮模式 |
| labelField | String | 'label' | 显示字段名 |
| valueField | String | 'value' | 值字段名 |

## 使用示例

### 示例1：普通复选框

```dart
final hobbies = [
  {'label': '阅读', 'value': 'reading'},
  {'label': '运动', 'value': 'sports'},
  {'label': '音乐', 'value': 'music'},
];

BaseCheckboxGroup(
  options: hobbies,
  values: selectedHobbies,
  onChanged: (values) {
    setState(() => selectedHobbies = values);
  },
)
```

### 示例2：按钮模式

```dart
BaseCheckboxGroup(
  options: options,
  values: selectedValues,
  asButton: true,
  onChanged: (values) {
    setState(() => selectedValues = values);
  },
)
```

### 示例3：自定义按钮样式

```dart
BaseCheckboxGroup(
  options: options,
  values: selectedValues,
  asButton: true,
  selectedButtonType: BaseButtonType.primary,
  unselectedButtonType: BaseButtonType.ghost,
  buttonWidth: 100,
  buttonHeight: 40,
  onChanged: (values) {},
)
```

## 相关组件

- [BaseRadio](../BaseRadio/README.md) - 单选组件
- [BaseButton](../BaseButton/README.md) - 按钮组件
