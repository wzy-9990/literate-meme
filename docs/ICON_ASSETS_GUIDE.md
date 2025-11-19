# App 图标资源准备指南

本文档说明如何为动态 App 图标准备所需的图标资源文件。

## 概述

动态图标功能已配置完成，但需要准备实际的图标图片文件。本项目配置了以下图标：

- `default` - 默认图标（已存在）
- `spring_festival` - 春节图标（1月1日 - 2月28日）
- `labor_day` - 劳动节图标（5月1日 - 5月3日）
- `national_day` - 国庆节图标（10月1日 - 10月7日）
- `christmas` - 圣诞节图标（12月24日 - 12月26日）

## 图标设计要求

### 通用要求

1. **保持一致的风格**：所有图标应使用相同的设计风格
2. **简洁清晰**：图标在小尺寸下也要清晰可辨
3. **节日特色**：每个图标应体现对应节日的特点
   - 春节：红色、灯笼、福字、烟花等元素
   - 劳动节：蓝色、工具、齿轮等元素
   - 国庆节：红色、国旗、天安门等元素
   - 圣诞节：绿色/红色、圣诞树、礼物等元素

### iOS 设计要求

- **形状**：使用圆角矩形（系统会自动添加）
- **背景**：必须填充整个图标区域
- **透明度**：不要使用 alpha 通道
- **阴影**：不要添加阴影（系统会自动添加）

### Android 设计要求

- **形状**：可以使用任意形状（建议圆角矩形）
- **背景**：建议使用纯色或渐变背景
- **自适应图标**：建议使用自适应图标（foreground + background）

## iOS 图标尺寸

### 方式一：使用 Assets.xcassets（推荐）

在 Xcode 中创建新的 AppIcon 集合：

1. 打开 `ios/Runner.xcworkspace`
2. 在 `Assets.xcassets` 中右键 -> New iOS App Icon
3. 命名为 `SpringFestival`、`LaborDay`、`NationalDay`、`Christmas`
4. 拖拽对应尺寸的图标文件

**所需尺寸：**

| 设备 | 尺寸 | 文件名示例 |
|------|------|-----------|
| iPhone | 120x120 (60@2x) | icon-60@2x.png |
| iPhone | 180x180 (60@3x) | icon-60@3x.png |
| iPad | 76x76 | icon-76.png |
| iPad | 152x152 (76@2x) | icon-76@2x.png |
| App Store | 1024x1024 | icon-1024.png |

### 方式二：直接放在 Runner 目录

将图标文件直接放在 `ios/Runner/` 目录：

```
ios/Runner/
├── spring_festival@2x.png  (120x120)
├── spring_festival@3x.png  (180x180)
├── labor_day@2x.png        (120x120)
├── labor_day@3x.png        (180x180)
├── national_day@2x.png     (120x120)
├── national_day@3x.png     (180x180)
├── christmas@2x.png        (120x120)
└── christmas@3x.png        (180x180)
```

**注意**：文件名必须与 `Info.plist` 中 `CFBundleIconFiles` 配置的名称一致。

## Android 图标尺寸

### 目录结构

将不同密度的图标放在对应的 mipmap 文件夹：

```
android/app/src/main/res/
├── mipmap-mdpi/
│   ├── spring_festival.png    (48x48)
│   ├── labor_day.png          (48x48)
│   ├── national_day.png       (48x48)
│   └── christmas.png          (48x48)
├── mipmap-hdpi/
│   ├── spring_festival.png    (72x72)
│   ├── labor_day.png          (72x72)
│   ├── national_day.png       (72x72)
│   └── christmas.png          (72x72)
├── mipmap-xhdpi/
│   ├── spring_festival.png    (96x96)
│   ├── labor_day.png          (96x96)
│   ├── national_day.png       (96x96)
│   └── christmas.png          (96x96)
├── mipmap-xxhdpi/
│   ├── spring_festival.png    (144x144)
│   ├── labor_day.png          (144x144)
│   ├── national_day.png       (144x144)
│   └── christmas.png          (144x144)
└── mipmap-xxxhdpi/
    ├── spring_festival.png    (192x192)
    ├── labor_day.png          (192x192)
    ├── national_day.png       (192x192)
    └── christmas.png          (192x192)
```

### 密度说明

| 密度 | 缩放比例 | 图标尺寸 |
|------|---------|---------|
| mdpi | 1.0x | 48x48 |
| hdpi | 1.5x | 72x72 |
| xhdpi | 2.0x | 96x96 |
| xxhdpi | 3.0x | 144x144 |
| xxxhdpi | 4.0x | 192x192 |

## 图标生成工具

如果您没有设计资源，可以使用以下在线工具生成图标：

### 在线图标生成器

1. **AppIcon.co** - https://www.appicon.co/
   - 上传一张 1024x1024 的图片
   - 自动生成 iOS 和 Android 所有尺寸

2. **MakeAppIcon** - https://makeappicon.com/
   - 支持 iOS、Android、Web 图标生成
   - 免费且快速

3. **IconKitchen** - https://icon.kitchen/
   - Android 自适应图标生成器
   - 支持预览不同启动器效果

### 本地生成工具

如果您使用 Node.js，可以使用 `app-icon` 包：

```bash
npm install -g app-icon

# 生成 iOS 图标
app-icon generate -i icon.png --platforms ios -o ios/Runner/

# 生成 Android 图标
app-icon generate -i icon.png --platforms android -o android/app/src/main/res/
```

## 临时方案：使用纯色占位图标

如果暂时没有设计资源，可以先创建纯色占位图标用于测试：

### 使用 ImageMagick

```bash
# 安装 ImageMagick
# macOS: brew install imagemagick
# Ubuntu: sudo apt-get install imagemagick

# 生成春节图标（红色）
convert -size 120x120 xc:#FF0000 ios/Runner/spring_festival@2x.png
convert -size 180x180 xc:#FF0000 ios/Runner/spring_festival@3x.png

# 生成劳动节图标（蓝色）
convert -size 120x120 xc:#0000FF ios/Runner/labor_day@2x.png
convert -size 180x180 xc:#0000FF ios/Runner/labor_day@3x.png

# 生成国庆节图标（红色+黄色）
convert -size 120x120 xc:#FFFF00 ios/Runner/national_day@2x.png
convert -size 180x180 xc:#FFFF00 ios/Runner/national_day@3x.png

# 生成圣诞节图标（绿色）
convert -size 120x120 xc:#00FF00 ios/Runner/christmas@2x.png
convert -size 180x180 xc:#00FF00 ios/Runner/christmas@3x.png
```

### Android 图标生成脚本

```bash
#!/bin/bash

# 创建临时图标目录
COLORS=("FF0000:spring_festival" "0000FF:labor_day" "FFFF00:national_day" "00FF00:christmas")
DENSITIES=("mdpi:48" "hdpi:72" "xhdpi:96" "xxhdpi:144" "xxxhdpi:192")

for color_name in "${COLORS[@]}"; do
  IFS=':' read -r color name <<< "$color_name"

  for density_size in "${DENSITIES[@]}"; do
    IFS=':' read -r density size <<< "$density_size"
    dir="android/app/src/main/res/mipmap-$density"
    mkdir -p "$dir"
    convert -size ${size}x${size} xc:#${color} "$dir/${name}.png"
  done
done
```

## 验证图标

### iOS 验证

1. 在 Xcode 中打开项目
2. 检查 Assets.xcassets 或 Runner 目录中的图标文件
3. 在真机上运行应用并测试切换功能

### Android 验证

1. 检查 `android/app/src/main/res/mipmap-*` 目录中的图标文件
2. 运行 `flutter clean && flutter build apk`
3. 安装 APK 并测试切换功能

## 常见问题

### Q: 图标切换后显示空白或默认图标？

A: 检查以下几点：
1. 图标文件是否存在于正确位置
2. 文件名是否与配置一致（注意大小写）
3. iOS：文件名应该不包含 `.png` 后缀在 Info.plist 中
4. Android：检查 activity-alias 中的 `android:icon` 配置

### Q: iOS 图标文件应该放在哪里？

A: 两种方式都可以：
1. Assets.xcassets 中的 AppIcon 集合（需要在 Xcode 中操作）
2. 直接放在 `ios/Runner/` 目录（更简单，推荐）

### Q: Android 图标没有生效？

A: 确保：
1. 图标文件放在了所有密度的 mipmap 文件夹中
2. 至少提供 mdpi、hdpi、xhdpi、xxhdpi、xxxhdpi 五种密度
3. 运行 `flutter clean` 后重新构建

### Q: 可以只准备一个尺寸的图标吗？

A: 不建议。虽然系统会缩放图标，但可能导致：
- 图标模糊或锯齿
- 不同设备上显示效果差异大
- 用户体验下降

## 下一步

1. **准备图标**：使用上述工具或方法生成所需图标文件
2. **测试切换**：运行应用并在首页点击"App 图标切换"按钮
3. **验证效果**：返回主屏幕查看图标是否正确切换
4. **根据日期自动切换**：在 `main.dart` 中添加启动时自动切换逻辑

## 参考资料

- [iOS App Icon Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Android App Icon Design Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [flutter_dynamic_icon 插件文档](https://pub.dev/packages/flutter_dynamic_icon)
