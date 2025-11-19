# BaseUpload 上传组件

一个功能完善的上传组件，支持图片和文件上传，提供网格和列表两种显示模式。

## 特性

- ✅ 支持图片和任意文件类型上传
- ✅ 网格（grid）和列表（list）两种显示模式
- ✅ 实时显示上传进度
- ✅ 文件大小和类型限制
- ✅ 图片预览和文件图标展示
- ✅ 自定义上传方法
- ✅ 上传成功/失败回调
- ✅ 可选的删除功能
- ✅ 文件数量限制
- ✅ 自动上传或手动触发
- ✅ iOS 风格的图片来源选择弹窗
- ✅ 自动权限检查和申请

## 依赖

```yaml
dependencies:
  image_picker: ^1.1.2    # 图片选择
  file_picker: ^8.1.6     # 文件选择
  path: ^1.9.0            # 路径处理
  mime: ^1.0.6            # MIME类型检测
  dio: ^5.8.0             # 文件上传
```

## 基础用法

### 1. 图片上传（网格模式）

```dart
BaseUpload(
  maxCount: 9,
  imageOnly: true,
  displayMode: 'grid',
  uploadUrl: 'https://api.example.com/upload',
  onUploadSuccess: (item) {
    debugPrint('上传成功: ${item.result}');
  },
  onUploadFailed: (item, error) {
    debugPrint('上传失败: $error');
  },
)
```

### 2. 文件上传（列表模式）

```dart
BaseUpload(
  maxCount: 5,
  imageOnly: false,
  displayMode: 'list',
  maxFileSize: 10 * 1024 * 1024, // 10MB
  uploadUrl: 'https://api.example.com/upload',
  fieldName: 'file',
  formData: {
    'userId': '123',
    'category': 'document',
  },
)
```

### 3. 限制文件类型

```dart
BaseUpload(
  maxCount: 3,
  imageOnly: false,
  allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
  displayMode: 'list',
  uploadUrl: 'https://api.example.com/upload',
)
```

### 4. 使用自定义上传方法

```dart
BaseUpload(
  maxCount: 5,
  imageOnly: false,
  customUpload: (fileInfo) async {
    // 实现自己的上传逻辑
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        fileInfo.filePath,
        filename: fileInfo.fileName,
      ),
    });

    final response = await dio.post('/upload', data: formData);
    return response.data;
  },
  onUploadSuccess: (item) {
    debugPrint('上传结果: ${item.result}');
  },
)
```

### 5. 监听文件列表变化

```dart
BaseUpload(
  maxCount: 5,
  imageOnly: true,
  onFilesChanged: (items) {
    debugPrint('当前已选择 ${items.length} 个文件');
    for (var item in items) {
      debugPrint('文件名: ${item.fileInfo.fileName}');
      debugPrint('状态: ${item.status}');
      debugPrint('进度: ${item.progress}');
    }
  },
)
```

## API 参数

### BaseUpload 参数

| 参数 | 类型 | 默认值 | 说明 |
|-----|------|--------|-----|
| maxCount | int | 9 | 最多上传数量 |
| imageOnly | bool | false | 是否只允许上传图片 |
| allowedExtensions | List<String>? | null | 允许的文件扩展名（如 ['pdf', 'doc']） |
| maxFileSize | int | 10MB | 单个文件最大大小（字节） |
| uploadUrl | String? | null | 上传地址 |
| fieldName | String | 'file' | 上传字段名 |
| formData | Map<String, dynamic>? | null | 额外的表单数据 |
| customUpload | Future<dynamic> Function(UploadFileInfo)? | null | 自定义上传方法 |
| onUploadSuccess | void Function(UploadItem)? | null | 上传成功回调 |
| onUploadFailed | void Function(UploadItem, String)? | null | 上传失败回调 |
| onFilesChanged | void Function(List<UploadItem>)? | null | 文件列表变化回调 |
| showDelete | bool | true | 是否显示删除按钮 |
| displayMode | String | 'grid' | 显示模式：'grid' 或 'list' |

### UploadItem 数据结构

```dart
class UploadItem {
  final String id;                    // 唯一标识
  final UploadFileInfo fileInfo;      // 文件信息
  UploadStatus status;                 // 上传状态
  double progress;                     // 上传进度 (0-1)
  String? errorMessage;                // 错误信息
  dynamic result;                      // 上传结果
}
```

### UploadStatus 状态

```dart
enum UploadStatus {
  ready,      // 准备上传
  uploading,  // 上传中
  success,    // 上传成功
  failed,     // 上传失败
}
```

### UploadFileInfo 文件信息

```dart
class UploadFileInfo {
  final String filePath;              // 文件路径
  final String fileName;              // 文件名
  final int fileSize;                 // 文件大小（字节）
  final String? mimeType;             // MIME类型

  bool get isImage;                   // 是否为图片
  String get fileSizeFormatted;       // 格式化的文件大小
}
```

## UploadUtil 工具类

### 选择单张图片

```dart
final fileInfo = await UploadUtil.pickImage(
  source: ImageSourceType.gallery,  // 或 ImageSourceType.camera
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);

if (fileInfo != null) {
  debugPrint('选择的图片: ${fileInfo.fileName}');
}
```

### 选择多张图片

```dart
final files = await UploadUtil.pickMultipleImages(
  limit: 5,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);

debugPrint('选择了 ${files.length} 张图片');
```

### 选择单个文件

```dart
final fileInfo = await UploadUtil.pickFile(
  allowedExtensions: ['pdf', 'doc', 'docx'],
);

if (fileInfo != null) {
  debugPrint('选择的文件: ${fileInfo.fileName}');
}
```

### 选择多个文件

```dart
final files = await UploadUtil.pickMultipleFiles(
  allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
);

debugPrint('选择了 ${files.length} 个文件');
```

### 上传单个文件

```dart
final response = await UploadUtil.uploadFile(
  fileInfo: fileInfo,
  uploadUrl: 'https://api.example.com/upload',
  fieldName: 'file',
  data: {
    'userId': '123',
    'category': 'document',
  },
  onProgress: (sent, total) {
    debugPrint('上传进度: ${(sent / total * 100).toInt()}%');
  },
);

debugPrint('上传结果: ${response?.data}');
```

### 批量上传文件

```dart
final results = await UploadUtil.uploadMultipleFiles(
  files: files,
  uploadUrl: 'https://api.example.com/upload',
  fieldName: 'file',
  onProgress: (index, sent, total) {
    debugPrint('文件 $index 上传进度: ${(sent / total * 100).toInt()}%');
  },
);

debugPrint('上传了 ${results.length} 个文件');
```

### 显示图片来源选择对话框

```dart
final source = await UploadUtil.showImageSourceDialog(context);

if (source != null) {
  if (source == ImageSourceType.camera) {
    debugPrint('用户选择拍照');
  } else {
    debugPrint('用户选择相册');
  }
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseUpload/index.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文件上传')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 图片上传
            Text('上传图片（最多3张）'),
            SizedBox(height: 8),
            BaseUpload(
              maxCount: 3,
              imageOnly: true,
              maxFileSize: 5 * 1024 * 1024, // 5MB
              displayMode: 'grid',
              uploadUrl: 'https://api.example.com/upload',
              onUploadSuccess: (item) {
                EasyLoading.showSuccess('上传成功');
              },
              onUploadFailed: (item, error) {
                EasyLoading.showError('上传失败: $error');
              },
            ),

            SizedBox(height: 24),

            // 文件上传
            Text('上传文档（PDF、Word）'),
            SizedBox(height: 8),
            BaseUpload(
              maxCount: 5,
              imageOnly: false,
              allowedExtensions: ['pdf', 'doc', 'docx'],
              displayMode: 'list',
              uploadUrl: 'https://api.example.com/upload',
              fieldName: 'document',
              formData: {
                'category': 'user_document',
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 权限处理

BaseUpload 组件已集成权限检查，使用时会自动处理：

1. **自动权限申请**：
   - 点击上传图片时，会弹出 iOS 风格的来源选择弹窗
   - 选择相机或相册后，自动检查和申请相应权限
   - 权限被拒绝时，自动显示说明弹窗引导用户

2. **无需手动处理**：
   - 组件内部已集成 [PermissionUtil](../../utils/permission/README.md)
   - 所有权限检查和申请流程自动完成
   - 开发者无需额外编写权限相关代码

3. **用户体验优化**：
   - iOS 风格的操作表单（ActionSheet）
   - 友好的权限说明提示
   - 永久拒绝时引导至系统设置

## 注意事项

1. **权限配置**：需要在原生平台配置文件中声明权限（见下方配置说明）

2. **iOS 配置**：在 `ios/Runner/Info.plist` 中添加：
   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>需要访问您的相册以选择图片</string>
   <key>NSCameraUsageDescription</key>
   <string>需要访问您的相机以拍摄照片</string>
   ```

3. **Android 配置**：在 `android/app/src/main/AndroidManifest.xml` 中添加：
   ```xml
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.CAMERA"/>
   ```

4. **上传地址**：如果既没有提供 `uploadUrl` 也没有提供 `customUpload`，文件只会被选择但不会自动上传

5. **文件大小**：默认最大文件大小为 10MB，可通过 `maxFileSize` 参数调整

6. **自定义上传**：使用 `customUpload` 时，需要自己处理上传逻辑和进度更新

## 相关组件

- [BaseImage 图片组件](../BaseImage/README.md)
- [PermissionUtil 权限工具](../../utils/permission/README.md)

## 更新日志

### v1.0.0 (2024)
- 初始版本发布
- 支持图片和文件上传
- 网格和列表两种显示模式
- 上传进度显示
- 文件大小和类型限制
