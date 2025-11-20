# BasePhoneCall 电话拨打组件

一个通用的电话拨打组件，支持 iOS 和 Android 平台的不同交互方式。

## 特性

- ✅ iOS 风格的拨打电话确认弹窗
- ✅ 支持多种展示形式（文本、图标、按钮）
- ✅ 自动清理电话号码格式
- ✅ 电话号码格式化显示
- ✅ 跨平台兼容

## 平台差异

| 平台 | 行为 |
|------|------|
| **iOS** | 直接拨打电话（系统弹窗确认） |
| **Android** | 显示底部弹窗，用户点击后拨打 |

## 使用方法

### 基础用法

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BasePhoneCall/index.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BasePhoneCall(
          phoneNumber: '13812345678',
          text: '拨打: 138****5678',
        ),
      ),
    );
  }
}
```

### 不同类型展示

```dart
// 文本类型（默认）
BasePhoneCall(
  phoneNumber: '13812345678',
  text: '联系我们',
)

// 图标类型
BasePhoneCall(
  phoneNumber: '13812345678',
  type: BasePhoneCallType.icon,
  icon: Icons.phone,
  iconSize: 24,
)

// 按钮类型
BasePhoneCall(
  phoneNumber: '13812345678',
  text: '拨打电话',
  type: BasePhoneCallType.button,
)
```

## API 文档

### BasePhoneCall

**参数：**
- `phoneNumber`（必需）：电话号码
- `text`：显示的文本，默认为格式化后的电话号码
- `style`：文本样式
- `type`：组件类型（text、icon、button），默认为 text
- `icon`：图标，仅在 icon 和 button 类型中使用
- `iconSize`：图标大小

### formatPhoneNumber

格式化电话号码显示

```dart
static String formatPhoneNumber(String phoneNumber, {bool format = false})
```

**参数：**
- `phoneNumber`: 原始电话号码
- `format`: 是否格式化，默认 `false`（不格式化）

**行为：**
- `format = false`（默认）：清理空格、横线、括号，返回纯数字
- `format = true`：按规则格式化
  - 11 位：中国手机号格式 `138 1234 5678`
  - 10 位：国际格式 `(123) 456 7890`
  - 其他：保持纯数字

## 平台配置

### iOS (ios/Runner/Info.plist)

需要添加电话权限描述（iOS 10.3+ 不再需要，但建议添加）：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
</array>
```

### Android (android/app/src/main/AndroidManifest.xml)

需要添加拨打电话权限：

```xml
<uses-permission android:name="android.permission.CALL_PHONE" />

<!-- 如果只是打开拨号界面，使用这个权限即可（无需运行时请求） -->
<queries>
  <intent>
    <action android:name="android.intent.action.DIAL" />
  </intent>
</queries>
```

**注意**：使用 `tel:` scheme 只是打开拨号界面，**不需要运行时权限请求**。如果要直接拨打电话（不经过拨号界面），才需要 `CALL_PHONE` 权限并在运行时请求。

## 注意事项

1. **context 必须有效**：组件被使用时，确保 `context` 是有效的（页面未销毁）

2. **电话号码格式**：支持各种格式的电话号码，组件会自动清理

3. **模拟器测试**：
   - **iOS 模拟器无法拨打电话**：这是模拟器的限制，不是代码问题
     - 调用 `tel:` scheme 会失败
     - `canLaunchUrl` 会返回 `false`
     - 控制台会输出 "拨打电话失败" 日志
     - **必须在 iOS 真机上测试**
   - Android 模拟器可以测试 UI 和拨号界面，但无法真正拨打

4. **权限配置**：
   - Android 只需在 `AndroidManifest.xml` 中声明 `queries`
   - 不需要运行时权限请求（因为只是打开拨号界面）