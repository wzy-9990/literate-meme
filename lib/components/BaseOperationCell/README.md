# BaseOperationCell

操作单元格组件，支持输入和选择两种模式，常用于设置页面和表单。

## 功能特性

- ✅ 输入模式和选择模式
- ✅ 支持必填标记
- ✅ 自定义左侧标题和右侧内容
- ✅ 底部分割线
- ✅ 完整的样式自定义
- ✅ BaseOperationCellGroup 批量管理

## 基础用法

```dart
import 'package:flutter_tem/components/BaseOperationCell/index.dart';

// 输入模式
BaseOperationCell(
  label: '姓名',
  controller: nameController,
  mode: BaseOperationCellMode.input,
)

// 选择模式
BaseOperationCell(
  label: '城市',
  value: '北京',
  mode: BaseOperationCellMode.select,
  onSelect: () {
    // 弹出选择器
  },
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| label | String | - | 必需，左侧标题 |
| required | bool | false | 是否必填（显示星标）|
| mode | BaseOperationCellMode | input | 模式（input/select）|
| controller | TextEditingController? | null | 输入框控制器 |
| value | String? | null | 选择模式显示值 |
| hintText | String? | null | 占位文字 |
| onSelect | VoidCallback? | null | 选择模式点击回调 |
| onChanged | ValueChanged<String>? | null | 输入回调 |
| showBottomDivider | bool | true | 是否显示底部分割线 |
| enabled | bool | true | 是否可编辑 |

## 使用示例

### 示例1：表单输入

```dart
Column(
  children: [
    BaseOperationCell(
      label: '姓名',
      required: true,
      controller: nameController,
      hintText: '请输入姓名',
    ),
    BaseOperationCell(
      label: '手机号',
      required: true,
      controller: phoneController,
      keyboardType: TextInputType.phone,
    ),
  ],
)
```

### 示例2：选择模式

```dart
BaseOperationCell(
  label: '城市',
  mode: BaseOperationCellMode.select,
  value: selectedCity,
  onSelect: () async {
    final result = await showCityPicker(context);
    if (result != null) {
      setState(() => selectedCity = result);
    }
  },
)
```

### 示例3：使用 BaseOperationCellGroup

```dart
BaseOperationCellGroup(
  children: [
    BaseOperationCell(
      label: '姓名',
      controller: nameController,
    ),
    BaseOperationCell(
      label: '性别',
      mode: BaseOperationCellMode.select,
      value: gender,
      onSelect: selectGender,
    ),
    BaseOperationCell(
      label: '生日',
      mode: BaseOperationCellMode.select,
      value: birthday,
      onSelect: selectBirthday,
    ),
  ],
)
```

### 示例4：设置页面

```dart
ListView(
  children: [
    BaseOperationCellGroup(
      children: [
        BaseOperationCell(
          label: '账号',
          mode: BaseOperationCellMode.select,
          value: username,
          enabled: false,
        ),
        BaseOperationCell(
          label: '昵称',
          controller: nicknameController,
        ),
      ],
    ),
    SizedBox(height: 12),
    BaseOperationCellGroup(
      children: [
        BaseOperationCell(
          label: '语言',
          mode: BaseOperationCellMode.select,
          value: '简体中文',
          onSelect: selectLanguage,
        ),
        BaseOperationCell(
          label: '清除缓存',
          mode: BaseOperationCellMode.select,
          value: '128 MB',
          onSelect: clearCache,
        ),
      ],
    ),
  ],
)
```

## 相关组件

- [BaseButton](../BaseButton/README.md) - 按钮组件
- TextField - Flutter 输入框
