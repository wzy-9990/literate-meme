# BaseActionSheet（Base Picker）

iOS 风格的底部单列选择器组件。

## 功能特性

- ✅ iOS 原生 CupertinoPicker 风格
- ✅ 支持字典列表数据源（Map 数组）
- ✅ 自定义字段名映射（label/value）
- ✅ 初始选中项定位
- ✅ 可自定义标题、按钮文字和样式
- ✅ 返回完整选中对象
- ✅ 圆角底部弹窗设计

## 基础用法

```dart
import 'package:flutter_tem/components/BaseActionSheet/index.dart';

// 准备选项数据
final options = [
  {'label': '选项1', 'value': '1'},
  {'label': '选项2', 'value': '2'},
  {'label': '选项3', 'value': '3'},
];

// 显示选择器
final result = await showBasePicker(
  context,
  options: options,
  title: '请选择',
  initialIndex: 0,
);

if (result != null) {
  print('选中: ${result['label']} - ${result['value']}');
}
```

## API 参数

### showBasePicker

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| context | BuildContext | - | 必需，上下文 |
| options | List<Map<String, dynamic>> | - | 必需，选项列表 |
| labelField | String | 'label' | 显示文本的字段名 |
| valueField | String | 'value' | 值字段名 |
| initialIndex | int | 0 | 初始选中索引 |
| title | String | '请选择' | 标题文字 |
| cancelText | String | '取消' | 取消按钮文字 |
| confirmText | String | '完成' | 确认按钮文字 |
| itemTextStyle | TextStyle? | null | 选项文字样式 |
| selectedTextStyle | TextStyle? | null | 选中项文字样式 |

## 使用示例

### 示例1：基础选择器

```dart
final cities = [
  {'label': '北京', 'value': 'beijing'},
  {'label': '上海', 'value': 'shanghai'},
  {'label': '广州', 'value': 'guangzhou'},
  {'label': '深圳', 'value': 'shenzhen'},
];

final result = await showBasePicker(
  context,
  options: cities,
  title: '选择城市',
);
```

### 示例2：自定义字段名

```dart
final users = [
  {'name': '张三', 'id': '001'},
  {'name': '李四', 'id': '002'},
  {'name': '王五', 'id': '003'},
];

final result = await showBasePicker(
  context,
  options: users,
  labelField: 'name',
  valueField: 'id',
  title: '选择用户',
);
```

### 示例3：设置初始选中项

```dart
final result = await showBasePicker(
  context,
  options: options,
  initialIndex: 2, // 默认选中第3项
  title: '请选择',
);
```

### 示例4：自定义样式

```dart
final result = await showBasePicker(
  context,
  options: options,
  title: '自定义样式',
  itemTextStyle: TextStyle(
    fontSize: 16,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
  ),
  selectedTextStyle: TextStyle(
    fontSize: 16,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  ),
);
```

### 示例5：配合表单使用

```dart
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  Map<String, dynamic>? selectedCity;

  final cities = [
    {'label': '北京', 'value': 'beijing'},
    {'label': '上海', 'value': 'shanghai'},
  ];

  void _selectCity() async {
    final result = await showBasePicker(
      context,
      options: cities,
      title: '选择城市',
      initialIndex: cities.indexWhere(
        (e) => e['value'] == selectedCity?['value'],
      ),
    );

    if (result != null) {
      setState(() {
        selectedCity = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('已选城市: ${selectedCity?['label'] ?? '未选择'}'),
        ElevatedButton(
          onPressed: _selectCity,
          child: Text('选择城市'),
        ),
      ],
    );
  }
}
```

## 注意事项

1. **空数据处理**
   - options 为空时自动返回 null
   - initialIndex 超出范围时会自动修正到有效范围

2. **字段检查**
   - 确保 options 中的每个 Map 都包含 labelField 和 valueField 指定的字段
   - 字段值会自动转换为字符串显示

3. **返回值**
   - 点击取消或背景区域返回 null
   - 点击完成返回完整的选中项 Map 对象

4. **索引计算**
   - initialIndex 使用 clamp 进行边界保护
   - 索引从 0 开始

## 最佳实践

1. **数据准备**
```dart
// 推荐：统一字段名
final options = [
  {'label': '显示文本', 'value': '实际值'},
];

// 自定义字段名
final customOptions = [
  {'name': '显示文本', 'code': '实际值'},
];
```

2. **结果处理**
```dart
final result = await showBasePicker(context, options: options);
if (result != null) {
  final label = result['label'];  // 显示文本
  final value = result['value'];  // 实际值
  // 处理选中结果
}
```

3. **动态数据**
```dart
Future<void> showDynamicPicker() async {
  // 从接口获取数据
  final options = await fetchOptionsFromApi();

  final result = await showBasePicker(
    context,
    options: options,
    title: '请选择',
  );
}
```

## 相关组件

- [BaseCascader](../BaseCascader/README.md) - 多级联动选择器
- [BaseDatePicker](../BaseDatePicker/README.md) - 日期时间选择器
- [BaseRadio](../BaseRadio/README.md) - 单选按钮组
