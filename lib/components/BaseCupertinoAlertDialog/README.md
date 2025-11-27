# BaseCupertinoAlertDialog

iOS 风格的弹窗组件，基于 CupertinoAlertDialog 封装。

## 功能特性

- ✅ iOS 原生风格
- ✅ 支持标题和副标题
- ✅ 可自定义按钮（单按钮/多按钮）
- ✅ 自动适配主题色
- ✅ 便捷的快捷方法

## 基础用法

```dart
import 'package:flutter_tem/components/BaseCupertinoAlertDialog/index.dart';

// 方式1：使用快捷方法
await showBaseCupertinoAlertDialog(
  context,
  title: '提示',
  subtitle: '确认要删除吗？',
  onConfirm: () {
    // 确认操作
    Navigator.pop(context);
  },
);

// 方式2：使用组件
showCupertinoDialog(
  context: context,
  builder: (context) => BaseCupertinoAlertDialog(
    title: '提示',
    subtitle: '这是内容',
  ),
);
```

## API 参数

### BaseCupertinoAlertDialog 组件

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| title | String | - | 必需，标题文字 |
| subtitle | String? | null | 副标题/内容文字 |
| titleStyle | TextStyle? | null | 标题样式 |
| subtitleStyle | TextStyle? | null | 副标题样式 |
| actions | List<BaseCupertinoAction>? | null | 自定义按钮列表 |
| cancelText | String | '取消' | 默认取消按钮文字 |
| confirmText | String | '确定' | 默认确认按钮文字 |
| cancelTextStyle | TextStyle? | null | 取消按钮样式 |
| confirmTextStyle | TextStyle? | null | 确认按钮样式 |
| onCancel | VoidCallback? | null | 取消回调 |
| onConfirm | VoidCallback? | null | 确认回调 |

### BaseCupertinoAction 按钮配置

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| text | String | - | 必需，按钮文字 |
| onPressed | VoidCallback? | null | 点击回调 |
| isDefault | bool | false | 是否为默认按钮（粗体）|
| isDestructive | bool | false | 是否为危险操作（红色）|
| textStyle | TextStyle? | null | 文字样式 |
| isCancel | bool | false | 是否为取消按钮（灰色）|

## 使用示例

### 示例1：基础确认对话框

```dart
await showBaseCupertinoAlertDialog(
  context,
  title: '删除确认',
  subtitle: '确定要删除这条记录吗？此操作无法撤销。',
  onConfirm: () {
    // 执行删除
    deleteRecord();
    Navigator.pop(context);
  },
);
```

### 示例2：仅确认按钮

```dart
await showBaseCupertinoAlertDialog(
  context,
  title: '操作成功',
  subtitle: '数据已保存',
  cancelText: '', // 不显示取消按钮
  confirmText: '知道了',
);
```

### 示例3：自定义按钮样式

```dart
await showBaseCupertinoAlertDialog(
  context,
  title: '提示',
  subtitle: '请选择操作',
  cancelTextStyle: TextStyle(color: Colors.grey),
  confirmTextStyle: TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.bold,
  ),
);
```

### 示例4：多按钮对话框

```dart
await showBaseCupertinoAlertDialog(
  context,
  title: '选择操作',
  subtitle: '请选择你要进行的操作',
  actions: [
    BaseCupertinoAction(
      text: '编辑',
      onPressed: () {
        Navigator.pop(context);
        editItem();
      },
    ),
    BaseCupertinoAction(
      text: '删除',
      isDestructive: true,
      onPressed: () {
        Navigator.pop(context);
        deleteItem();
      },
    ),
    BaseCupertinoAction(
      text: '取消',
      isCancel: true,
      onPressed: () => Navigator.pop(context),
    ),
  ],
);
```

### 示例5：危险操作确认

```dart
await showBaseCupertinoAlertDialog(
  context,
  title: '警告',
  subtitle: '此操作将永久删除所有数据，确定继续吗？',
  actions: [
    BaseCupertinoAction(
      text: '取消',
      isCancel: true,
      onPressed: () => Navigator.pop(context),
    ),
    BaseCupertinoAction(
      text: '删除',
      isDestructive: true,
      isDefault: true,
      onPressed: () {
        Navigator.pop(context);
        deleteAllData();
      },
    ),
  ],
);
```

### 示例6：异步操作

```dart
Future<void> _showConfirmDialog() async {
  await showBaseCupertinoAlertDialog(
    context,
    title: '提交确认',
    subtitle: '确定要提交表单吗？',
    onConfirm: () async {
      Navigator.pop(context);

      // 显示加载
      EasyLoading.show();

      try {
        await submitForm();
        EasyLoading.showSuccess('提交成功');
      } catch (e) {
        EasyLoading.showError('提交失败');
      }
    },
  );
}
```

### 示例7：条件判断

```dart
void _deleteItem() async {
  if (item.isImportant) {
    // 重要数据需要二次确认
    await showBaseCupertinoAlertDialog(
      context,
      title: '重要数据',
      subtitle: '这是重要数据，确定要删除吗？',
      confirmText: '仍然删除',
      actions: [
        BaseCupertinoAction(
          text: '取消',
          isCancel: true,
          onPressed: () => Navigator.pop(context),
        ),
        BaseCupertinoAction(
          text: '仍然删除',
          isDestructive: true,
          onPressed: () {
            Navigator.pop(context);
            performDelete();
          },
        ),
      ],
    );
  } else {
    // 普通数据直接删除
    performDelete();
  }
}
```

## 按钮颜色

- **默认按钮** (`isDefault: true`): 粗体，主题色
- **危险按钮** (`isDestructive: true`): 红色
- **取消按钮** (`isCancel: true`): 灰色
- **普通按钮**: 蓝色

## 注意事项

1. **按钮顺序**
   - iOS 规范：取消按钮在左，确认按钮在右
   - 多按钮时按数组顺序排列

2. **默认行为**
   - 不传 actions 时自动生成取消和确认两个按钮
   - 按钮默认点击后不会自动关闭对话框，需手动 `Navigator.pop(context)`

3. **文字长度**
   - 标题建议不超过 20 字
   - 内容建议不超过 100 字
   - 过长文字会自动换行

4. **回调处理**
   - onConfirm/onCancel 需要手动关闭对话框
   - 传 actions 时每个 action 也需要手动关闭

## 最佳实践

1. **明确的标题**
```dart
// ✅ 好的标题
title: '删除确认'
title: '提交成功'

// ❌ 不好的标题
title: '提示'
title: '警告'
```

2. **清晰的内容**
```dart
// ✅ 描述具体操作和后果
subtitle: '确定要删除这条记录吗？删除后无法恢复。'

// ❌ 过于简单
subtitle: '确定吗？'
```

3. **合理的按钮文字**
```dart
// ✅ 动词形式，明确操作
confirmText: '删除'
confirmText: '确认提交'

// ❌ 模糊不清
confirmText: '是'
confirmText: 'OK'
```

## 相关组件

- CupertinoAlertDialog - Flutter 原生 iOS 对话框
- [BaseAuthDialog](../BaseAuthDialog/README.md) - 认证对话框
- EasyLoading - 加载提示组件
