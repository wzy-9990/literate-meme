# BaseButton

基础按钮组件，支持多种样式风格和自定义配置。

## 功能特性

- ✅ 7种按钮类型（主题/常规/文本/镂空/渐变/信息/透明）
- ✅ 内置点击节流（500ms 防抖）
- ✅ 支持渐变背景
- ✅ 独立配置圆角（四个角可单独设置）
- ✅ 水波纹点击效果
- ✅ 自适应宽度或全宽模式
- ✅ 完全自定义内容（文本或 Widget）

## 按钮类型

| 类型 | 说明 | 默认样式 |
|------|------|----------|
| primary | 主题按钮 | 主题色背景 + 白色文字 |
| info | 信息按钮 | 灰色背景 + 黑色文字 |
| normal | 常规按钮 | 透明背景 + 边框 + 边框色文字 |
| ghost | 透明按钮 | 透明背景 + 灰色边框 + 灰色文字 |
| text | 文本按钮 | 无背景 + 灰色文字 |
| outline | 镂空按钮 | 主题色边框 + 10%主题色背景 + 主题色文字 |
| gradient | 渐变按钮 | 渐变背景（橙色到黄色）|

## 基础用法

```dart
import 'package:flutter_tem/components/BaseButton/index.dart';

// 主题按钮
BaseButton(
  text: '主题按钮',
  onTap: () => print('点击'),
)

// 自定义内容
BaseButton(
  type: BaseButtonType.primary,
  onTap: () => print('点击'),
  child: Row(
    children: [
      Icon(Icons.add, color: Colors.white),
      SizedBox(width: 8),
      Text('添加'),
    ],
  ),
)
```

## API 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| type | BaseButtonType | primary | 按钮类型 |
| text | String | '按钮' | 按钮文字 |
| onTap | VoidCallback? | null | 点击回调（500ms防抖）|
| child | Widget? | null | 自定义内容，优先于 text |
| width | double? | null | 按钮宽度 |
| height | double | 40 | 按钮高度 |
| fullWidth | bool | true | 是否占满父容器宽度 |
| fontSize | double | 14 | 文字大小 |
| fontWeight | FontWeight | w500 | 文字粗细 |
| textColor | Color? | null | 文字颜色（自动根据类型）|
| backgroundColor | Color? | null | 背景颜色 |
| borderColor | Color? | null | 边框颜色 |
| borderWidth | double | 1 | 边框宽度 |
| borderRadius | double | AppRadius.button | 统一圆角 |
| topLeftRadius | double? | null | 左上角圆角 |
| topRightRadius | double? | null | 右上角圆角 |
| bottomLeftRadius | double? | null | 左下角圆角 |
| bottomRightRadius | double? | null | 右下角圆角 |
| enableRipple | bool | true | 是否启用水波纹 |
| splashColor | Color? | null | 水波纹颜色 |
| padding | EdgeInsetsGeometry? | null | 内边距 |
| gradientColors | List<Color>? | null | 渐变颜色列表 |
| gradientBegin | Alignment? | null | 渐变起点 |
| gradientEnd | Alignment? | null | 渐变终点 |
| gradientStops | List<double>? | null | 渐变停止点 |

## 使用示例

### 示例1：不同类型按钮

```dart
Column(
  children: [
    // 主题按钮
    BaseButton(
      type: BaseButtonType.primary,
      text: '主题按钮',
      onTap: () {},
    ),

    // 信息按钮
    BaseButton(
      type: BaseButtonType.info,
      text: '信息按钮',
      onTap: () {},
    ),

    // 常规按钮
    BaseButton(
      type: BaseButtonType.normal,
      text: '常规按钮',
      onTap: () {},
    ),

    // 透明按钮
    BaseButton(
      type: BaseButtonType.ghost,
      text: '透明按钮',
      onTap: () {},
    ),

    // 文本按钮
    BaseButton(
      type: BaseButtonType.text,
      text: '文本按钮',
      onTap: () {},
    ),

    // 镂空按钮
    BaseButton(
      type: BaseButtonType.outline,
      text: '镂空按钮',
      onTap: () {},
    ),

    // 渐变按钮
    BaseButton(
      type: BaseButtonType.gradient,
      text: '渐变按钮',
      onTap: () {},
    ),
  ],
)
```

### 示例2：尺寸和宽度

```dart
// 全宽按钮（默认）
BaseButton(
  text: '全宽按钮',
  fullWidth: true,
)

// 固定宽度
BaseButton(
  text: '固定宽度',
  width: 120,
  fullWidth: false,
)

// 自适应宽度
BaseButton(
  text: '自适应',
  fullWidth: false,
)

// 自定义高度
BaseButton(
  text: '高度 50',
  height: 50,
)
```

### 示例3：自定义颜色

```dart
// 自定义背景色
BaseButton(
  text: '自定义背景',
  backgroundColor: Colors.purple,
  textColor: Colors.white,
)

// 自定义边框色
BaseButton(
  type: BaseButtonType.normal,
  text: '自定义边框',
  borderColor: Colors.red,
  textColor: Colors.red,
)
```

### 示例4：圆角配置

```dart
// 统一圆角
BaseButton(
  text: '圆角 20',
  borderRadius: 20,
)

// 单独配置每个角
BaseButton(
  text: '不同圆角',
  topLeftRadius: 0,
  topRightRadius: 20,
  bottomLeftRadius: 20,
  bottomRightRadius: 0,
)

// 左右圆角不同（药丸形状）
BaseButton(
  text: '药丸按钮',
  topLeftRadius: 20,
  bottomLeftRadius: 20,
  topRightRadius: 5,
  bottomRightRadius: 5,
)
```

### 示例5：渐变按钮

```dart
// 默认渐变
BaseButton(
  type: BaseButtonType.gradient,
  text: '默认渐变',
)

// 自定义渐变
BaseButton(
  type: BaseButtonType.gradient,
  text: '自定义渐变',
  gradientColors: [Colors.blue, Colors.purple],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,
)
```

### 示例6：自定义内容

```dart
// 图标 + 文字
BaseButton(
  onTap: () {},
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.download, color: Colors.white),
      SizedBox(width: 8),
      Text('下载', style: TextStyle(color: Colors.white)),
    ],
  ),
)

// 加载状态
BaseButton(
  child: SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
  ),
)
```

### 示例7：表单提交按钮

```dart
class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);

    try {
      await submitForm();
      // 成功处理
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      text: _submitting ? '提交中...' : '提交',
      onTap: _submitting ? null : _submit,
      child: _submitting
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : null,
    );
  }
}
```

### 示例8：按钮组

```dart
Row(
  children: [
    Expanded(
      child: BaseButton(
        type: BaseButtonType.ghost,
        text: '取消',
        onTap: () => Navigator.pop(context),
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: BaseButton(
        text: '确定',
        onTap: () => _confirm(),
      ),
    ),
  ],
)
```

## 防抖机制

按钮内置 500ms 防抖，防止重复点击：

```dart
static int _lastTapTs = 0;

void _handleTap() {
  final now = DateTime.now().millisecondsSinceEpoch;
  if (now - _lastTapTs > 500) {
    _lastTapTs = now;
    onTap?.call();
  }
}
```

## 注意事项

1. **宽度计算**
   - `fullWidth=true` 且无 padding 时占满父容器
   - 指定 `width` 时使用固定宽度
   - 否则使用 `IntrinsicWidth` 自适应内容

2. **圆角优先级**
   - 单独设置的圆角优先于 borderRadius
   - 未设置时使用 borderRadius 的值

3. **文字颜色**
   - 指定 textColor 时使用指定颜色
   - 否则根据按钮类型自动选择合适的颜色

4. **渐变按钮**
   - 使用 gradientColors 时需设置 type 为 gradient
   - 默认渐变方向从左上到右下

5. **点击回调**
   - onTap 为 null 时按钮不可点击
   - 内置 500ms 防抖，快速点击只触发一次

## 最佳实践

1. **按钮命名规范**
```dart
// 明确的操作动词
BaseButton(text: '保存')
BaseButton(text: '删除')
BaseButton(text: '取消')
```

2. **主次按钮区分**
```dart
// 主操作：primary
BaseButton(type: BaseButtonType.primary, text: '确认')

// 次要操作：ghost 或 normal
BaseButton(type: BaseButtonType.ghost, text: '取消')
```

3. **禁用状态**
```dart
BaseButton(
  text: '已禁用',
  onTap: isEnabled ? () {} : null,
  backgroundColor: isEnabled ? null : Colors.grey,
)
```

## 相关组件

- [BaseInkWell](../BaseInkWell/README.md) - 水波纹效果组件
- [BaseRadio](../BaseRadio/README.md) - 单选按钮
- [BaseCheckbox](../BaseCheckbox/README.md) - 多选按钮
