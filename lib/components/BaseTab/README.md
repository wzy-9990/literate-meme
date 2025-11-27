# BaseTab

基础 Tab 切换组件，支持自定义样式和指示器。

## 功能特性

- ✅ 自定义选中/未选中样式
- ✅ 底部指示器动画
- ✅ 支持 Map 和 BaseTabItem 数据源
- ✅ 灵活的对齐方式
- ✅ 可横向滚动

## 基础用法

```dart
import 'package:flutter_tem/components/BaseTab/index.dart';

final tabs = [
  {'label': '全部', 'value': 'all'},
  {'label': '待付款', 'value': 'unpaid'},
  {'label': '已完成', 'value': 'completed'},
];

BaseTab(
  options: tabs,
  value: currentTab,
  onChanged: (value) {
    setState(() => currentTab = value);
  },
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| options | List<dynamic> | - | 必需，选项列表 |
| value | dynamic | - | 必需，当前选中值 |
| onChanged | ValueChanged | - | 必需，选中回调 |
| labelField | String | 'label' | 显示字段名 |
| valueField | String | 'value' | 值字段名 |
| indicatorHeight | double | 2 | 指示器高度 |
| spacing | double | 16 | Tab 间距 |
| alignment | MainAxisAlignment | start | 对齐方式 |

## 使用示例

### 示例1：订单状态切换

```dart
final orderTabs = [
  {'label': '全部', 'value': 'all'},
  {'label': '待付款', 'value': 'unpaid'},
  {'label': '待发货', 'value': 'unshipped'},
  {'label': '已完成', 'value': 'completed'},
];

BaseTab(
  options: orderTabs,
  value: orderStatus,
  onChanged: (value) {
    setState(() {
      orderStatus = value;
      loadOrders(value);
    });
  },
)
```

### 示例2：居中对齐

```dart
BaseTab(
  options: tabs,
  value: currentTab,
  alignment: MainAxisAlignment.center,
  onChanged: (value) {},
)
```

## 相关组件

- TabBar - Flutter 原生 Tab
- [BaseButton](../BaseButton/README.md) - 按钮组件
