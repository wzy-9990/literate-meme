# PhoneCallUtil 打电话工具类

iOS 风格的拨打电话工具，支持 iOS 和 Android 平台的不同交互方式。

## 特性

- ✅ iOS 风格底部弹窗（CupertinoActionSheet）
- ✅ iOS 直接拨打电话
- ✅ Android 二次确认后拨打
- ✅ 自动清理电话号码格式
- ✅ 电话号码格式化显示

## 平台差异

| 平台 | 行为 |
|------|------|
| **iOS** | 直接拨打电话（系统弹窗确认） |
| **Android** | 显示底部弹窗，用户点击后拨打 |

## 使用方法

### 基础用法

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/phone_call/index.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            PhoneCallUtil.makePhoneCall(context, '13812345678');
          },
          child: const Text('拨打电话'),
        ),
      ),
    );
  }
}
```

### 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/phone_call/index.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String phone;

  const ContactCard({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(name),
        subtitle: Text(PhoneCallUtil.formatPhoneNumber(phone)),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            PhoneCallUtil.makePhoneCall(context, phone);
          },
        ),
      ),
    );
  }
}

// 使用示例
ContactCard(
  name: '张三',
  phone: '13812345678',
)
```

### 格式化电话号码

```dart
// 默认不格式化，清理空格和横线
final clean = PhoneCallUtil.formatPhoneNumber('138-1234-5678');
// 输出: 13812345678

// 需要格式化时，传入 format: true
final formatted = PhoneCallUtil.formatPhoneNumber('13812345678', format: true);
// 输出: 138 1234 5678

final formatted2 = PhoneCallUtil.formatPhoneNumber('1234567890', format: true);
// 输出: (123) 456 7890
```

## API 文档

### makePhoneCall

拨打电话

```dart
static Future<void> makePhoneCall(
  BuildContext context,
  String phoneNumber,
)
```

**参数：**
- `context`: BuildContext，用于显示弹窗（Android）
- `phoneNumber`: 电话号码字符串

**行为：**
- iOS: 直接调用 `tel:` scheme 拨打电话
- Android: 显示 iOS 风格底部弹窗，用户确认后拨打

**支持的电话号码格式：**
- `13812345678`
- `138 1234 5678`
- `138-1234-5678`
- `(138) 1234-5678`

工具会自动清理空格、横线、括号等字符。

### formatPhoneNumber

格式化电话号码显示

```dart
static String formatPhoneNumber(String phoneNumber, {bool format = false})
```

**参数：**
- `phoneNumber`: 原始电话号码
- `format`: 是否格式化，默认 `false`（不格式化）

**返回：**
- 处理后的电话号码字符串

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

## UI 效果

### Android 底部弹窗

```
┌─────────────────────┐
│                     │
│      拨打电话       │ ← 标题
│                     │
│   138 1234 5678    │ ← 电话号码（粗体显示）
│                     │
├─────────────────────┤
│       拨打          │ ← 确认按钮
├─────────────────────┤
│       取消          │ ← 取消按钮（加粗）
└─────────────────────┘
```

### iOS 行为

直接调用系统拨号功能，iOS 系统会显示自己的确认弹窗。

## 依赖

```yaml
dependencies:
  url_launcher: ^6.3.1  # 启动 URL、拨打电话等
```

## 注意事项

1. **context 必须有效**：调用 `makePhoneCall` 时，确保 `context` 是有效的（页面未销毁）

2. **电话号码格式**：支持各种格式的电话号码，工具会自动清理

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

5. **错误处理**：
   - 如果无法拨打电话，会在 console 输出错误日志
   - 不会显示错误提示给用户，可根据需要自行添加

## 最佳实践

```dart
// ✅ 推荐：在用户点击时调用
IconButton(
  icon: const Icon(Icons.phone),
  onPressed: () {
    PhoneCallUtil.makePhoneCall(context, phoneNumber);
  },
)

// ✅ 推荐：显示格式化的电话号码
Text(PhoneCallUtil.formatPhoneNumber(phoneNumber))

// ❌ 不推荐：在页面初始化时调用
@override
void initState() {
  super.initState();
  PhoneCallUtil.makePhoneCall(context, phoneNumber); // 不要这样做
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/phone_call/index.dart';

class ContactListPage extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': '张三', 'phone': '13812345678'},
    {'name': '李四', 'phone': '13987654321'},
    {'name': '王五', 'phone': '13611112222'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('联系人')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(contact['name']!),
            subtitle: Text(
              PhoneCallUtil.formatPhoneNumber(contact['phone']!),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.phone),
              color: Colors.green,
              onPressed: () {
                PhoneCallUtil.makePhoneCall(
                  context,
                  contact['phone']!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```
