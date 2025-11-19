# UploadUtil 上传工具类

提供统一的文件选择和上传功能，支持图片和任意文件类型。

## 特性

- ✅ 图片选择（相机/相册）
- ✅ 多图片选择
- ✅ 文件选择（支持类型过滤）
- ✅ 多文件选择
- ✅ 文件上传（支持进度回调）
- ✅ 批量上传
- ✅ MIME 类型检测
- ✅ 文件大小格式化
- ✅ 图片质量和尺寸控制

## 依赖

```yaml
dependencies:
  image_picker: ^1.1.2    # 图片选择
  file_picker: ^8.1.6     # 文件选择
  path: ^1.9.0            # 路径处理
  mime: ^1.0.6            # MIME类型检测
  dio: ^5.8.0             # HTTP请求和文件上传
```

## 使用方法

### 1. 选择图片

#### 选择单张图片（弹窗选择来源）

```dart
// 显示对话框让用户选择相机或相册
final source = await UploadUtil.showImageSourceDialog(context);
if (source != null) {
  final fileInfo = await UploadUtil.pickImage(source: source);
  if (fileInfo != null) {
    print('文件路径: ${fileInfo.filePath}');
    print('文件名: ${fileInfo.fileName}');
    print('文件大小: ${fileInfo.fileSizeFormatted}');
    print('是否为图片: ${fileInfo.isImage}');
  }
}
```

#### 直接从相册选择

```dart
final fileInfo = await UploadUtil.pickImage(
  source: ImageSourceType.gallery,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);
```

#### 直接从相机拍照

```dart
final fileInfo = await UploadUtil.pickImage(
  source: ImageSourceType.camera,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);
```

### 2. 选择多张图片

```dart
final files = await UploadUtil.pickMultipleImages(
  limit: 5,              // 最多选择5张
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);

print('选择了 ${files.length} 张图片');
for (var file in files) {
  print('${file.fileName} - ${file.fileSizeFormatted}');
}
```

### 3. 选择文件

#### 选择任意类型文件

```dart
final fileInfo = await UploadUtil.pickFile();
if (fileInfo != null) {
  print('选择的文件: ${fileInfo.fileName}');
  print('MIME类型: ${fileInfo.mimeType}');
}
```

#### 限制文件类型

```dart
// 只允许选择 PDF 和 Word 文档
final fileInfo = await UploadUtil.pickFile(
  allowedExtensions: ['pdf', 'doc', 'docx'],
);
```

```dart
// 只允许选择图片
final fileInfo = await UploadUtil.pickFile(
  type: FileType.image,
);
```

```dart
// 只允许选择视频
final fileInfo = await UploadUtil.pickFile(
  type: FileType.video,
);
```

### 4. 选择多个文件

```dart
final files = await UploadUtil.pickMultipleFiles(
  allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
);

print('选择了 ${files.length} 个文件');
```

### 5. 上传文件

#### 基础上传

```dart
try {
  final response = await UploadUtil.uploadFile(
    fileInfo: fileInfo,
    uploadUrl: 'https://api.example.com/upload',
  );

  print('上传成功: ${response?.data}');
} catch (e) {
  print('上传失败: $e');
}
```

#### 带进度的上传

```dart
final response = await UploadUtil.uploadFile(
  fileInfo: fileInfo,
  uploadUrl: 'https://api.example.com/upload',
  onProgress: (sent, total) {
    final progress = (sent / total * 100).toInt();
    print('上传进度: $progress%');
  },
);
```

#### 上传时附加额外数据

```dart
final response = await UploadUtil.uploadFile(
  fileInfo: fileInfo,
  uploadUrl: 'https://api.example.com/upload',
  fieldName: 'file',
  data: {
    'userId': '123',
    'category': 'avatar',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
);
```

### 6. 批量上传文件

```dart
final files = await UploadUtil.pickMultipleImages(limit: 5);

try {
  final results = await UploadUtil.uploadMultipleFiles(
    files: files,
    uploadUrl: 'https://api.example.com/upload',
    onProgress: (index, sent, total) {
      final progress = (sent / total * 100).toInt();
      print('文件 ${index + 1} 上传进度: $progress%');
    },
  );

  print('成功上传 ${results.length} 个文件');
} catch (e) {
  print('上传失败: $e');
}
```

## API 文档

### pickImage

选择单张图片

```dart
static Future<UploadFileInfo?> pickImage({
  ImageSourceType source = ImageSourceType.gallery,
  double? maxWidth,
  double? maxHeight,
  int imageQuality = 85,
})
```

**参数：**
- `source`: 图片来源（相机或相册），默认相册
- `maxWidth`: 图片最大宽度（像素）
- `maxHeight`: 图片最大高度（像素）
- `imageQuality`: 图片质量（0-100），默认85

**返回：**
- `UploadFileInfo?`: 文件信息，取消选择时返回 null

### pickMultipleImages

选择多张图片

```dart
static Future<List<UploadFileInfo>> pickMultipleImages({
  double? maxWidth,
  double? maxHeight,
  int imageQuality = 85,
  int? limit,
})
```

**参数：**
- `maxWidth`: 图片最大宽度（像素）
- `maxHeight`: 图片最大高度（像素）
- `imageQuality`: 图片质量（0-100），默认85
- `limit`: 最多选择数量

**返回：**
- `List<UploadFileInfo>`: 文件信息列表

### pickFile

选择单个文件

```dart
static Future<UploadFileInfo?> pickFile({
  List<String>? allowedExtensions,
  FileType type = FileType.any,
})
```

**参数：**
- `allowedExtensions`: 允许的文件扩展名列表（如 ['pdf', 'doc']）
- `type`: 文件类型（any, image, video, audio, custom）

**返回：**
- `UploadFileInfo?`: 文件信息，取消选择时返回 null

### pickMultipleFiles

选择多个文件

```dart
static Future<List<UploadFileInfo>> pickMultipleFiles({
  List<String>? allowedExtensions,
})
```

**参数：**
- `allowedExtensions`: 允许的文件扩展名列表

**返回：**
- `List<UploadFileInfo>`: 文件信息列表

### uploadFile

上传单个文件

```dart
static Future<Response?> uploadFile({
  required UploadFileInfo fileInfo,
  required String uploadUrl,
  String fieldName = 'file',
  Map<String, dynamic>? data,
  void Function(int sent, int total)? onProgress,
})
```

**参数：**
- `fileInfo`: 要上传的文件信息
- `uploadUrl`: 上传地址
- `fieldName`: 文件字段名，默认 'file'
- `data`: 额外的表单数据
- `onProgress`: 上传进度回调

**返回：**
- `Response?`: Dio 响应对象

### uploadMultipleFiles

批量上传文件

```dart
static Future<List<Response?>> uploadMultipleFiles({
  required List<UploadFileInfo> files,
  required String uploadUrl,
  String fieldName = 'file',
  Map<String, dynamic>? data,
  void Function(int index, int sent, int total)? onProgress,
})
```

**参数：**
- `files`: 要上传的文件列表
- `uploadUrl`: 上传地址
- `fieldName`: 文件字段名，默认 'file'
- `data`: 额外的表单数据
- `onProgress`: 上传进度回调（包含文件索引）

**返回：**
- `List<Response?>`: Dio 响应对象列表

### showImageSourceDialog

显示图片来源选择对话框

```dart
static Future<ImageSourceType?> showImageSourceDialog(BuildContext context)
```

**参数：**
- `context`: 构建上下文

**返回：**
- `ImageSourceType?`: 用户选择的来源，取消时返回 null

## 数据结构

### UploadFileInfo

文件信息类

```dart
class UploadFileInfo {
  final String filePath;      // 文件路径
  final String fileName;      // 文件名
  final int fileSize;         // 文件大小（字节）
  final String? mimeType;     // MIME类型

  // 是否为图片
  bool get isImage => mimeType?.startsWith('image/') ?? false;

  // 格式化的文件大小（如 "1.5 MB"）
  String get fileSizeFormatted { ... }
}
```

### ImageSourceType

图片来源枚举

```dart
enum ImageSourceType {
  camera,   // 相机
  gallery,  // 相册
}
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/upload/index.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UploadDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('上传示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 选择并上传图片
            ElevatedButton(
              onPressed: () async {
                // 显示来源选择对话框
                final source = await UploadUtil.showImageSourceDialog(context);
                if (source == null) return;

                // 选择图片
                final fileInfo = await UploadUtil.pickImage(
                  source: source,
                  maxWidth: 1920,
                  maxHeight: 1080,
                  imageQuality: 85,
                );

                if (fileInfo == null) return;

                // 上传图片
                try {
                  EasyLoading.show(status: '上传中...');

                  final response = await UploadUtil.uploadFile(
                    fileInfo: fileInfo,
                    uploadUrl: 'https://api.example.com/upload',
                    data: {'type': 'avatar'},
                    onProgress: (sent, total) {
                      final progress = (sent / total * 100).toInt();
                      EasyLoading.showProgress(
                        progress / 100,
                        status: '上传中 $progress%',
                      );
                    },
                  );

                  EasyLoading.showSuccess('上传成功');
                  print('结果: ${response?.data}');
                } catch (e) {
                  EasyLoading.showError('上传失败: $e');
                }
              },
              child: Text('选择并上传图片'),
            ),

            SizedBox(height: 20),

            // 选择并上传多个文件
            ElevatedButton(
              onPressed: () async {
                // 选择多个文件
                final files = await UploadUtil.pickMultipleFiles(
                  allowedExtensions: ['pdf', 'doc', 'docx'],
                );

                if (files.isEmpty) return;

                // 批量上传
                try {
                  EasyLoading.show(status: '上传中...');

                  final results = await UploadUtil.uploadMultipleFiles(
                    files: files,
                    uploadUrl: 'https://api.example.com/upload',
                    onProgress: (index, sent, total) {
                      final progress = (sent / total * 100).toInt();
                      EasyLoading.showProgress(
                        progress / 100,
                        status: '上传文件 ${index + 1}/${files.length} ($progress%)',
                      );
                    },
                  );

                  EasyLoading.showSuccess('成功上传 ${results.length} 个文件');
                } catch (e) {
                  EasyLoading.showError('上传失败: $e');
                }
              },
              child: Text('选择并上传多个文件'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 权限配置

### iOS (ios/Runner/Info.plist)

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问您的相册以选择图片</string>
<key>NSCameraUsageDescription</key>
<string>需要访问您的相机以拍摄照片</string>
```

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

## 注意事项

1. **权限处理**：使用前需要先获取相应的权限，建议配合 [PermissionUtil](../permission/README.md) 使用

2. **图片质量**：`imageQuality` 参数只对 JPEG 格式有效，PNG 格式会忽略此参数

3. **文件大小**：选择文件时没有大小限制，建议在上传前检查文件大小

4. **错误处理**：上传失败时会抛出异常，需要使用 try-catch 捕获

5. **网络配置**：确保 Dio 实例已正确配置（超时、拦截器等）

## 相关组件

- [BaseUpload 上传组件](../../components/BaseUpload/README.md)
- [PermissionUtil 权限工具](../permission/README.md)

## 更新日志

### v1.0.0 (2024)
- 初始版本发布
- 支持图片和文件选择
- 支持单个和批量上传
- 支持上传进度回调
