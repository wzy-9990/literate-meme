# BaseDatePicker

iOS 风格的日期时间选择器，支持日期、时间、日期时间三种模式。

## 功能特性

- ✅ iOS 原生 CupertinoDatePicker 风格
- ✅ 三种选择模式（日期/时间/日期时间）
- ✅ 可设置最小/最大日期范围
- ✅ 支持初始日期
- ✅ 24小时制
- ✅ 可自定义缩放比例
- ✅ 底部弹窗展示

## 选择模式

| 模式 | 说明 | 示例 |
|------|------|------|
| date | 仅日期 | 2024年 1月 1日 |
| time | 仅时间 | 14:30 |
| dateTime | 日期+时间 | 2024年 1月 1日 14:30 |

## 基础用法

```dart
import 'package:flutter_tem/components/BaseDatePicker/index.dart';

// 选择日期
final date = await showBaseDatePicker(
  context,
  mode: BaseDatePickerMode.date,
  title: '选择日期',
);

if (date != null) {
  print('选中日期: $date');
}
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| context | BuildContext | - | 必需，上下文 |
| initial | DateTime? | null | 初始日期（默认当前时间）|
| min | DateTime? | null | 最小日期（默认1970-01-01）|
| max | DateTime? | null | 最大日期（默认2100-12-31）|
| mode | BaseDatePickerMode | date | 选择模式 |
| title | String | '请选择' | 标题文字 |
| cancelText | String | '取消' | 取消按钮文字 |
| confirmText | String | '完成' | 确认按钮文字 |
| scale | double | 1.0 | 选择器缩放比例 |

## 使用示例

### 示例1：选择日期

```dart
final selectedDate = await showBaseDatePicker(
  context,
  mode: BaseDatePickerMode.date,
  title: '选择生日',
  initial: DateTime(2000, 1, 1),
  min: DateTime(1900, 1, 1),
  max: DateTime.now(),
);

if (selectedDate != null) {
  setState(() {
    birthday = selectedDate;
  });
}
```

### 示例2：选择时间

```dart
final selectedTime = await showBaseDatePicker(
  context,
  mode: BaseDatePickerMode.time,
  title: '选择时间',
  initial: DateTime.now(),
);

if (selectedTime != null) {
  final hour = selectedTime.hour;
  final minute = selectedTime.minute;
  print('选中时间: $hour:$minute');
}
```

### 示例3：选择日期时间

```dart
final selectedDateTime = await showBaseDatePicker(
  context,
  mode: BaseDatePickerMode.dateTime,
  title: '选择预约时间',
  min: DateTime.now(),
  max: DateTime.now().add(Duration(days: 30)),
);

if (selectedDateTime != null) {
  print('预约时间: ${selectedDateTime.toString()}');
}
```

### 示例4：限制日期范围

```dart
// 只能选择未来7天
final futureDate = await showBaseDatePicker(
  context,
  mode: BaseDatePickerMode.date,
  title: '选择日期',
  min: DateTime.now(),
  max: DateTime.now().add(Duration(days: 7)),
);

// 只能选择过去一年
final pastDate = await showBaseDatePicker(
  context,
  mode: BaseDatePickerMode.date,
  title: '选择日期',
  min: DateTime.now().subtract(Duration(days: 365)),
  max: DateTime.now(),
);
```

### 示例5：配合表单使用

```dart
class DateFormField extends StatefulWidget {
  @override
  _DateFormFieldState createState() => _DateFormFieldState();
}

class _DateFormFieldState extends State<DateFormField> {
  DateTime? selectedDate;

  Future<void> _selectDate() async {
    final date = await showBaseDatePicker(
      context,
      mode: BaseDatePickerMode.date,
      title: '选择日期',
      initial: selectedDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          selectedDate != null
            ? '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}'
            : '请选择日期',
        ),
      ),
    );
  }
}
```

### 示例6：格式化显示

```dart
import 'package:intl/intl.dart';

final date = await showBaseDatePicker(
  context,
  mode: BaseDatePickerMode.dateTime,
);

if (date != null) {
  // 格式化日期
  final formatted = DateFormat('yyyy年MM月dd日 HH:mm').format(date);
  print(formatted); // 2024年01月01日 14:30
}
```

### 示例7：工作日选择

```dart
Future<DateTime?> selectWorkday() async {
  DateTime? selected;

  do {
    selected = await showBaseDatePicker(
      context,
      mode: BaseDatePickerMode.date,
      title: '选择工作日',
      initial: selected ?? DateTime.now(),
    );

    if (selected == null) break;

    // 检查是否为周末
    if (selected.weekday == DateTime.saturday ||
        selected.weekday == DateTime.sunday) {
      EasyLoading.showToast('请选择工作日');
      selected = selected.add(Duration(days: 1));
      continue;
    }

    break;
  } while (true);

  return selected;
}
```

### 示例8：定时任务设置

```dart
class ScheduleTaskPage extends StatefulWidget {
  @override
  _ScheduleTaskPageState createState() => _ScheduleTaskPageState();
}

class _ScheduleTaskPageState extends State<ScheduleTaskPage> {
  DateTime? startTime;
  DateTime? endTime;

  Future<void> _selectStartTime() async {
    final time = await showBaseDatePicker(
      context,
      mode: BaseDatePickerMode.dateTime,
      title: '选择开始时间',
      min: DateTime.now(),
      initial: startTime ?? DateTime.now(),
    );

    if (time != null) {
      setState(() {
        startTime = time;
        // 结束时间不能早于开始时间
        if (endTime != null && endTime!.isBefore(time)) {
          endTime = null;
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    if (startTime == null) {
      EasyLoading.showToast('请先选择开始时间');
      return;
    }

    final time = await showBaseDatePicker(
      context,
      mode: BaseDatePickerMode.dateTime,
      title: '选择结束时间',
      min: startTime!,
      initial: endTime ?? startTime!.add(Duration(hours: 1)),
    );

    if (time != null) {
      setState(() {
        endTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('开始时间'),
          subtitle: Text(startTime?.toString() ?? '未选择'),
          onTap: _selectStartTime,
        ),
        ListTile(
          title: Text('结束时间'),
          subtitle: Text(endTime?.toString() ?? '未选择'),
          onTap: _selectEndTime,
        ),
      ],
    );
  }
}
```

## 注意事项

1. **返回值**
   - 点击确认返回 DateTime 对象
   - 点击取消或背景返回 null

2. **时间格式**
   - 使用 24 小时制
   - 返回完整的 DateTime 对象

3. **日期范围**
   - min/max 未设置时使用默认范围
   - min 必须早于 max
   - initial 会自动调整到有效范围内

4. **模式选择**
   - time 模式仍返回 DateTime，日期部分为当前日期
   - date 模式时间部分为 00:00:00

## 日期处理技巧

### 获取日期部分

```dart
final date = await showBaseDatePicker(context, mode: BaseDatePickerMode.date);
if (date != null) {
  final dateOnly = DateTime(date.year, date.month, date.day);
}
```

### 获取时间部分

```dart
final time = await showBaseDatePicker(context, mode: BaseDatePickerMode.time);
if (time != null) {
  final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
```

### 日期比较

```dart
final date1 = DateTime.now();
final date2 = await showBaseDatePicker(context);

if (date2 != null) {
  if (date2.isAfter(date1)) {
    print('date2 在 date1 之后');
  }
  if (date2.isBefore(date1)) {
    print('date2 在 date1 之前');
  }
}
```

## 最佳实践

1. **合理设置范围**
```dart
// 生日选择：限制在合理范围
await showBaseDatePicker(
  context,
  min: DateTime(1900),
  max: DateTime.now(),
);

// 预约时间：只能选择未来
await showBaseDatePicker(
  context,
  min: DateTime.now(),
);
```

2. **提供合理的初始值**
```dart
// ✅ 提供合理的默认值
await showBaseDatePicker(
  context,
  initial: existingDate ?? DateTime.now(),
);

// ❌ 不提供初始值（使用当前时间）
await showBaseDatePicker(context);
```

## 相关组件

- [BaseActionSheet](../BaseActionSheet/README.md) - 底部选择器
- [BaseCascader](../BaseCascader/README.md) - 级联选择器
- CupertinoDatePicker - Flutter 原生日期选择器
