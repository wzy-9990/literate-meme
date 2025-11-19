# AppIconManager 动态图标管理工具

根据日期自动切换 App 图标，支持 iOS 和 Android 平台。

## 特性

- ✅ 统一配置文件管理图标和日期规则
- ✅ 支持根据日期自动切换节日图标
- ✅ 支持手动切换任意图标
- ✅ iOS 和 Android 双平台支持
- ✅ 内置春节、劳动节、国庆节、圣诞节等节日图标

## 快速开始

### 1. 基础用法

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/app_icon_manager/index.dart';
import 'package:flutter_tem/config/app_icons.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态图标')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 根据日期自动切换
            ElevatedButton(
              onPressed: () async {
                await AppIconManager.changeIconByDate();
              },
              child: const Text('根据日期自动切换'),
            ),

            // 手动切换到春节图标
            ElevatedButton(
              onPressed: () async {
                await AppIconManager.changeIcon(AppIconConfig.springFestival);
              },
              child: const Text('切换到春节图标'),
            ),

            // 恢复默认图标
            ElevatedButton(
              onPressed: () async {
                await AppIconManager.restoreDefaultIcon();
              },
              child: const Text('恢复默认图标'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. 在应用启动时自动切换

在 `main.dart` 中添加：

```dart
import 'package:flutter_tem/utils/app_icon_manager/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 根据日期自动切换图标
  await AppIconManager.changeIconByDate();

  runApp(const MyApp());
}
```

### 3. 检查设备支持状态

```dart
final isSupported = await AppIconManager.isSupported();
if (isSupported) {
  print('设备支持动态图标');
} else {
  print('设备不支持动态图标');
}
```

### 4. 获取当前图标

```dart
final currentIcon = await AppIconManager.getCurrentIconName();
print('当前图标: $currentIcon');
```

## 配置说明

### 统一配置文件

所有图标和日期规则在 `lib/theme/app_icons.dart` 中统一管理：

```dart
class AppIconConfig {
  // 图标名称常量
  static const String defaultIcon = 'default';
  static const String springFestival = 'spring_festival';
  static const String laborDay = 'labor_day';
  static const String nationalDay = 'national_day';
  static const String christmas = 'christmas';

  // 可用图标列表
  static const List<String> availableIcons = [
    defaultIcon,
    springFestival,
    laborDay,
    nationalDay,
    christmas,
  ];

  // 图标显示名称
  static const Map<String, String> iconNames = {
    defaultIcon: '默认图标',
    springFestival: '春节图标',
    laborDay: '劳动节图标',
    nationalDay: '国庆节图标',
    christmas: '圣诞节图标',
  };

  // 日期规则配置
  static final List<IconDateRule> dateRules = [
    IconDateRule(
      iconName: springFestival,
      startMonth: 1,
      startDay: 1,
      endMonth: 2,
      endDay: 28,
    ),
    // ... 其他规则
  ];
}
```

### 添加新图标

1. **更新配置文件** (`lib/theme/app_icons.dart`)：

```dart
class AppIconConfig {
  // 1. 添加图标名称常量
  static const String newYear = 'new_year';

  // 2. 添加到可用图标列表
  static const List<String> availableIcons = [
    defaultIcon,
    newYear, // 新增
    // ... 其他图标
  ];

  // 3. 添加显示名称
  static const Map<String, String> iconNames = {
    newYear: '元旦图标', // 新增
    // ... 其他名称
  };

  // 4. 添加日期规则
  static final List<IconDateRule> dateRules = [
    IconDateRule(
      iconName: newYear,
      startMonth: 1,
      startDay: 1,
      endMonth: 1,
      endDay: 3,
    ),
    // ... 其他规则
  ];
}
```

2. **配置 iOS** (`ios/Runner/Info.plist`)：

```xml
<key>CFBundleAlternateIcons</key>
<dict>
    <key>new_year</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>new_year</string>
        </array>
        <key>UIPrerenderedIcon</key>
        <false/>
    </dict>
</dict>
```

3. **配置 Android** (`android/app/src/main/AndroidManifest.xml`)：

```xml
<activity-alias
    android:name=".NewYearIcon"
    android:enabled="false"
    android:exported="true"
    android:icon="@mipmap/new_year"
    android:targetActivity=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity-alias>
```

4. **准备图标文件**（见下方"图标文件准备"章节）

## API 文档

### changeIcon

切换到指定图标

```dart
static Future<bool> changeIcon(String iconName)
```

**参数：**
- `iconName`: 图标名称（参考 `AppIconConfig` 中的常量）

**返回：**
- `true`: 切换成功
- `false`: 切换失败

**示例：**
```dart
final success = await AppIconManager.changeIcon(AppIconConfig.springFestival);
if (success) {
  print('切换成功');
}
```

### changeIconByDate

根据当前日期自动切换图标

```dart
static Future<bool> changeIconByDate()
```

**返回：**
- `true`: 切换成功
- `false`: 切换失败

**示例：**
```dart
await AppIconManager.changeIconByDate();
```

### getCurrentIconName

获取当前图标名称

```dart
static Future<String?> getCurrentIconName()
```

**返回：**
- 当前图标名称，如果是默认图标则返回 `'default'`
- `null`: 获取失败

### isSupported

检查设备是否支持动态图标

```dart
static Future<bool> isSupported()
```

**返回：**
- `true`: 支持
- `false`: 不支持

### restoreDefaultIcon

恢复默认图标

```dart
static Future<bool> restoreDefaultIcon()
```

**返回：**
- `true`: 恢复成功
- `false`: 恢复失败

## 图标文件准备

### iOS 图标准备

iOS 需要为每个图标准备多个尺寸（不需要包含 alpha 通道）：

**尺寸要求：**
- iPhone: 60x60@2x, 60x60@3x
- iPad: 76x76, 76x76@2x
- App Store: 1024x1024

**放置位置：**

方法一：在 `ios/Runner/Assets.xcassets/` 中创建新的 AppIcon 集合

```
ios/Runner/Assets.xcassets/
├── AppIcon.appiconset/          # 默认图标
├── SpringFestival.appiconset/   # 春节图标
├── LaborDay.appiconset/         # 劳动节图标
└── ...
```

方法二：放在 `ios/Runner/` 根目录（推荐）

```
ios/Runner/
├── spring_festival@2x.png  (120x120)
├── spring_festival@3x.png  (180x180)
├── labor_day@2x.png
├── labor_day@3x.png
└── ...
```

### Android 图标准备

Android 需要为每个图标准备多个密度的版本：

**尺寸要求：**
- mdpi: 48x48
- hdpi: 72x72
- xhdpi: 96x96
- xxhdpi: 144x144
- xxxhdpi: 192x192

**放置位置：**

```
android/app/src/main/res/
├── mipmap-mdpi/
│   ├── spring_festival.png
│   └── labor_day.png
├── mipmap-hdpi/
│   ├── spring_festival.png
│   └── labor_day.png
├── mipmap-xhdpi/
│   ├── spring_festival.png
│   └── labor_day.png
├── mipmap-xxhdpi/
│   ├── spring_festival.png
│   └── labor_day.png
└── mipmap-xxxhdpi/
    ├── spring_festival.png
    └── labor_day.png
```

### 图标设计建议

1. **保持一致的风格**：所有图标应该保持相同的设计风格
2. **简洁明了**：图标要在小尺寸下清晰可辨
3. **避免文字**：尽量不要在图标上放文字（特别是小尺寸）
4. **测试多个尺寸**：确保在所有设备上都清晰
5. **遵守平台规范**：iOS 使用圆角矩形，Android 可以使用自适应图标

## 平台差异

### iOS

- ✅ iOS 10.3+ 支持动态图标
- ⚠️ 切换图标时会显示系统提示弹窗（无法禁用）
- ✅ 支持任意时间切换
- ✅ 图标立即生效

### Android

- ✅ Android 8.0+ 支持动态图标（通过 activity-alias）
- ✅ 切换图标时无系统提示
- ⚠️ 需要重启 App 才能看到效果
- ⚠️ 部分启动器可能不支持

## 注意事项

1. **图标文件必须存在**：
   - 配置中声明的图标必须有对应的图标文件
   - 否则切换会失败或显示空白图标

2. **iOS 系统弹窗**：
   - iOS 切换图标时会显示系统提示："[App名称] 的外观将发生更改"
   - 这是 iOS 系统行为，无法通过代码禁用

3. **Android 需要重启**：
   - Android 切换图标后需要 kill app 并重新打开才能看到新图标
   - 可以在切换后提示用户重启 App

4. **测试建议**：
   - iOS 必须在真机上测试（模拟器不支持）
   - Android 可以在模拟器和真机上测试

5. **性能考虑**：
   - 避免频繁切换图标（每次切换都有系统开销）
   - 建议只在必要时切换（如应用启动时检查日期）

## 完整示例

查看 `lib/page/example/appIconExample/view.dart` 获取完整的使用示例。

## 依赖

```yaml
dependencies:
  flutter_dynamic_icon: ^2.1.0
```

## 常见问题

### Q: iOS 切换图标后没有变化？

A: 确保：
1. 在真机上测试（模拟器不支持）
2. 图标文件已正确添加到项目中
3. Info.plist 中已配置 CFBundleAlternateIcons
4. 图标名称与配置一致

### Q: Android 切换图标后没有变化？

A: 确保：
1. 完全关闭并重启 App
2. 图标文件放在了正确的 mipmap 文件夹中
3. AndroidManifest.xml 中已配置 activity-alias
4. activity-alias 的 android:name 与代码中的名称匹配

### Q: 如何禁用 iOS 的系统提示弹窗？

A: 无法禁用，这是 iOS 系统行为，所有使用动态图标的 App 都会显示。

### Q: 可以在运行时生成图标吗？

A: 不可以。图标必须在编译时就包含在 App 包中。

## 参考资料

- [flutter_dynamic_icon 插件文档](https://pub.dev/packages/flutter_dynamic_icon)
- [iOS Human Interface Guidelines - App Icon](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
