# PermissionUtil 权限工具类

统一的权限请求、检查、引导功能，支持 Android 和 iOS。

## 功能特性

- ✅ 支持所有常用权限类型（相机、相册、位置、麦克风等）
- ✅ 自动处理权限状态（已授权、拒绝、永久拒绝）
- ✅ 权限用途说明提示
- ✅ 永久拒绝时引导跳转设置
- ✅ 批量权限请求
- ✅ 快捷方法（相机、相册、位置等）
- ✅ 中文权限名称映射

## 基础用法

### 1. 简单请求权限

```dart
// 请求相机权限
final granted = await PermissionUtil.requestPermission(Permission.camera);
if (granted) {
  // 权限已授予，执行操作
  debugPrint('相机权限已授予');
} else {
  // 权限被拒绝
  debugPrint('相机权限被拒绝');
}
```

### 2. 带提示的权限请求

```dart
// 带权限说明的请求
final granted = await PermissionUtil.requestPermissionWithTip(
  Permission.camera,
  tipMessage: '需要访问相机以拍摄照片上传',
);

if (granted) {
  // 打开相机
}
```

### 3. 使用快捷方法

```dart
// 相机权限
final cameraGranted = await PermissionUtil.requestCamera();

// 相册权限
final photosGranted = await PermissionUtil.requestPhotos();

// 位置权限
final locationGranted = await PermissionUtil.requestLocation();

// 麦克风权限
final micGranted = await PermissionUtil.requestMicrophone();

// 自定义提示
final granted = await PermissionUtil.requestCamera(
  tip: '用于扫描二维码',
);
```

### 4. 检查权限并执行回调

```dart
await PermissionUtil.checkAndExecute(
  Permission.camera,
  onGranted: () {
    // 权限已授予，打开相机
    debugPrint('打开相机');
  },
  onDenied: () {
    // 权限被拒绝
    debugPrint('无法打开相机');
  },
  tipMessage: '需要相机权限以扫描二维码',
);
```

## 高级用法

### 批量请求权限

```dart
final results = await PermissionUtil.requestMultiplePermissions([
  Permission.camera,
  Permission.photos,
  Permission.location,
]);

// 检查结果
if (results[Permission.camera] == true) {
  debugPrint('相机权限已授予');
}
if (results[Permission.photos] == true) {
  debugPrint('相册权限已授予');
}
```

### 检查权限状态

```dart
final status = await PermissionUtil.checkPermission(Permission.camera);

if (status.isGranted) {
  debugPrint('权限已授予');
} else if (status.isDenied) {
  debugPrint('权限被拒绝');
} else if (status.isPermanentlyDenied) {
  debugPrint('权限被永久拒绝');
} else if (status.isRestricted) {
  debugPrint('权限受限');
} else if (status.isLimited) {
  debugPrint('权限受限（iOS 14+）');
}
```

### 获取权限中文名称

```dart
final name = PermissionUtil.getPermissionName(Permission.camera);
debugPrint(name); // 输出：相机
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/permission/index.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionExample extends StatelessWidget {
  const PermissionExample({super.key});

  // 拍照示例
  Future<void> _takePhoto() async {
    final granted = await PermissionUtil.requestCamera(
      tip: '需要相机权限以拍摄照片',
    );

    if (granted) {
      // 打开相机拍照
      debugPrint('打开相机');
    }
  }

  // 选择照片示例
  Future<void> _pickPhoto() async {
    final granted = await PermissionUtil.requestPhotos(
      tip: '需要访问相册以选择照片',
    );

    if (granted) {
      // 打开相册选择
      debugPrint('打开相册');
    }
  }

  // 获取位置示例
  Future<void> _getLocation() async {
    await PermissionUtil.checkAndExecute(
      Permission.location,
      onGranted: () {
        // 获取位置信息
        debugPrint('开始获取位置');
      },
      onDenied: () {
        debugPrint('无法获取位置，权限被拒绝');
      },
      tipMessage: '需要位置权限以提供附近的服务',
    );
  }

  // 批量请求示例
  Future<void> _requestMultiple() async {
    final results = await PermissionUtil.requestMultiplePermissions([
      Permission.camera,
      Permission.microphone,
    ]);

    final allGranted = results.values.every((granted) => granted);
    if (allGranted) {
      debugPrint('所有权限已授予，开始录制视频');
    } else {
      debugPrint('部分权限未授予');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text('拍照（需要相机权限）'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickPhoto,
              child: const Text('选择照片（需要相册权限）'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('获取位置（需要位置权限）'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestMultiple,
              child: const Text('录制视频（需要相机+麦克风）'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 支持的权限类型

| 权限 | 说明 | 快捷方法 |
|------|------|----------|
| `Permission.camera` | 相机 | `requestCamera()` |
| `Permission.photos` | 相册 | `requestPhotos()` |
| `Permission.location` | 位置信息 | `requestLocation()` |
| `Permission.microphone` | 麦克风 | `requestMicrophone()` |
| `Permission.storage` | 存储 | `requestStorage()` |
| `Permission.notification` | 通知 | `requestNotification()` |
| `Permission.contacts` | 通讯录 | - |
| `Permission.phone` | 电话 | - |
| `Permission.sms` | 短信 | - |
| `Permission.calendar` | 日历 | - |
| `Permission.bluetooth` | 蓝牙 | - |

## 方法说明

### requestPermission

简单的权限请求，无提示。

```dart
Future<bool> requestPermission(Permission permission)
```

### requestPermissionWithTip

带权限用途说明的请求。

```dart
Future<bool> requestPermissionWithTip(
  Permission permission, {
  String? tipMessage,
  bool showDeniedDialog = true,
})
```

### checkAndExecute

检查权限并执行回调。

```dart
Future<void> checkAndExecute(
  Permission permission, {
  required VoidCallback onGranted,
  VoidCallback? onDenied,
  String? tipMessage,
})
```

### requestMultiplePermissions

批量请求多个权限。

```dart
Future<Map<Permission, bool>> requestMultiplePermissions(
  List<Permission> permissions,
)
```

## 权限状态

| 状态 | 说明 |
|------|------|
| `isGranted` | 已授予 |
| `isDenied` | 已拒绝（可再次请求） |
| `isPermanentlyDenied` | 永久拒绝（需引导到设置） |
| `isRestricted` | 受限（iOS） |
| `isLimited` | 受限访问（iOS 14+） |

## 平台配置

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<manifest>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <!-- 其他权限... -->
</manifest>
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择照片</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问位置信息以提供服务</string>

<key>NSMicrophoneUsageDescription</key>
<string>需要访问麦克风以录制音频</string>
```

## 注意事项

1. **Android 13+**：需要在 `AndroidManifest.xml` 中添加 `READ_MEDIA_IMAGES`、`READ_MEDIA_VIDEO` 等权限
2. **iOS 14+**：相册权限可能返回 `isLimited` 状态，表示用户只授予了部分照片访问权限
3. **永久拒绝**：Android 用户拒绝权限 2 次后会变为永久拒绝，需引导到设置页面
4. **提示时机**：建议在用户主动触发功能时请求权限，而不是应用启动时批量请求

## 依赖

```yaml
dependencies:
  permission_handler: ^11.3.1
```

## 最佳实践

1. **及时请求**：在需要使用功能时才请求权限
2. **说明用途**：使用 `tipMessage` 参数向用户说明权限用途
3. **优雅降级**：权限被拒绝时提供替代方案
4. **避免频繁请求**：不要在短时间内重复请求被拒绝的权限
