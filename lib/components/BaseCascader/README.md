# BaseCascader

级联选择器组件，支持省市区三级联动选择。

## 功能特性

- ✅ 省市区三级联动
- ✅ 单选/多选模式
- ✅ 搜索功能
- ✅ 自动加载地区数据
- ✅ 可自定义数据源
- ✅ 支持"全国/全省/全市"快捷入口
- ✅ 路径面包屑导航

## 基础用法

```dart
import 'package:flutter_tem/components/BaseCascader/index.dart';

// 显示地区选择器
final result = await showCascaderPicker(
  context,
  title: '选择地区',
);

if (result != null) {
  print('选中: ${result[0]['provinceName']} ${result[0]['cityName']} ${result[0]['districtName']}');
}
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| context | BuildContext | - | 必需，上下文 |
| options | List<BaseCascaderNode>? | null | 自定义数据源（默认自动加载）|
| multiSelect | bool | false | 是否多选 |
| selectableLevels | Set<int> | {3} | 可选层级（1=省，2=市，3=区）|
| initialSelectedIds | List<String> | [] | 初始选中ID列表 |
| showAllEntry | bool | false | 是否显示全国/全省/全市入口 |
| showPathBreadcrumb | bool | false | 是否显示路径面包屑 |
| columnCount | int | 3 | 显示列数（1=省、2=省市、3=省市区）|
| title | String | '选择地区' | 标题 |

## 使用示例

### 示例1：基础地区选择

```dart
final result = await showCascaderPicker(
  context,
  title: '选择所在地区',
);

if (result != null && result.isNotEmpty) {
  final location = result[0];
  print('省: ${location['provinceName']}');
  print('市: ${location['cityName']}');
  print('区: ${location['districtName']}');
}
```

### 示例2：多选模式

```dart
final result = await showCascaderPicker(
  context,
  multiSelect: true,
  maxSelectCount: 5,
  title: '选择服务地区',
);

if (result != null) {
  for (var item in result) {
    print('选中: ${item['provinceName']} ${item['cityName']}');
  }
}
```

### 示例3：只选择省市

```dart
final result = await showCascaderPicker(
  context,
  columnCount: 2,
  selectableLevels: {2},
  title: '选择省市',
);
```

### 示例4：自定义数据源

```dart
final customOptions = [
  BaseCascaderNode(
    id: '1',
    label: '技术部',
    children: [
      BaseCascaderNode(id: '1-1', label: '前端组'),
      BaseCascaderNode(id: '1-2', label: '后端组'),
    ],
  ),
  BaseCascaderNode(
    id: '2',
    label: '市场部',
    children: [
      BaseCascaderNode(id: '2-1', label: '销售组'),
      BaseCascaderNode(id: '2-2', label: '运营组'),
    ],
  ),
];

final result = await showCascaderPicker(
  context,
  options: customOptions,
  title: '选择部门',
);
```

## 返回数据格式

```dart
[
  {
    'provinceName': '北京市',
    'provinceCode': '110000',
    'cityName': '北京市',
    'cityCode': '110100',
    'districtName': '东城区',
    'districtCode': '110101',
  }
]
```

## 相关组件

- [BaseActionSheet](../BaseActionSheet/README.md) - 单列选择器
- [BaseDatePicker](../BaseDatePicker/README.md) - 日期选择器
