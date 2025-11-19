# UploadUtil 上传工具类

提供统一的文件选择和上传功能，支持图片和任意文件类型。

## 特性

- ✅ 图片选择（相机/相册）
- ✅ 多图片选择
- ✅ 文件选择（支持类型过滤）
- ✅ 多文件选择
- ✅ 文件上传（支持进度回调）
- ✅ 上传进度可视化（CircularProgressIndicator + 百分比）
- ✅ 批量上传
- ✅ MIME 类型检测
- ✅ 文件大小格式化
- ✅ 图片质量和尺寸控制
- ✅ iOS 风格的图片来源选择弹窗
- ✅ 自动权限检查和申请（集成 PermissionUtil）

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

#### 选择单张图片（iOS 风格弹窗选择来源）

```dart
// 显示 iOS 风格的弹窗让用户选择相机或相册
// 会自动检查和申请相应权限（相机权限或相册权限）
final source = await UploadUtil.showImageSourceDialog(context);
if (source != null) {
  final fileInfo = await UploadUtil.pickImage(source: source);
  if (fileInfo != null) {
    debugPrint('文件路径: ${fileInfo.filePath}');
    debugPrint('文件名: ${fileInfo.fileName}');
    debugPrint('文件大小: ${fileInfo.fileSizeFormatted}');
    debugPrint('是否为图片: ${fileInfo.isImage}');
  }
}
```

**注意**：`pickImage` 方法会自动进行权限检查：
- 选择相机时，自动申请相机权限
- 选择相册时，自动申请相册权限
- 如果权限被拒绝，会自动显示引导弹窗

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

debugPrint('选择了 ${files.length} 张图片');
for (var file in files) {
  debugPrint('${file.fileName} - ${file.fileSizeFormatted}');
}
```

### 3. 选择文件

#### 选择任意类型文件

```dart
final fileInfo = await UploadUtil.pickFile();
if (fileInfo != null) {
  debugPrint('选择的文件: ${fileInfo.fileName}');
  debugPrint('MIME类型: ${fileInfo.mimeType}');
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

debugPrint('选择了 ${files.length} 个文件');
```

### 5. 上传文件

#### 使用项目默认上传接口（推荐）

```dart
try {
  final result = await UploadUtil.uploadFileToDefault(
    fileInfo: fileInfo,
    onProgress: (sent, total) {
      final progress = (sent / total * 100).toInt();
      debugPrint('上传进度: $progress%');
    },
  );

  debugPrint('文件 Key: ${result?['fileKey']}');
  debugPrint('文件 URL: ${result?['fileUrl']}');
} catch (e) {
  debugPrint('上传失败: $e');
}
```

**说明**：使用 `BaseUpload` 组件时，进度会自动显示在图片缩略图上（CircularProgressIndicator + 百分比文字）

#### 使用自定义接口上传

```dart
try {
  final response = await UploadUtil.uploadFile(
    fileInfo: fileInfo,
    uploadUrl: 'https://api.example.com/upload',
    onProgress: (sent, total) {
      final progress = (sent / total * 100).toInt();
      debugPrint('上传进度: $progress%');
    },
  );

  debugPrint('上传成功: ${response?.data}');
} catch (e) {
  debugPrint('上传失败: $e');
}
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
      debugPrint('文件 ${index + 1} 上传进度: $progress%');
    },
  );

  debugPrint('成功上传 ${results.length} 个文件');
} catch (e) {
  debugPrint('上传失败: $e');
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

显示 iOS 风格的图片来源选择对话框

```dart
static Future<ImageSourceType?> showImageSourceDialog(BuildContext context)
```

**参数：**
- `context`: 构建上下文

**返回：**
- `ImageSourceType?`: 用户选择的来源，取消时返回 null

**特点：**
- 使用 `CupertinoActionSheet` 显示 iOS 风格弹窗
- 从底部弹出，包含"拍照"、"从相册选择"和"取消"选项
- 无论在 iOS 还是 Android 平台都显示统一的 iOS 风格

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
                  debugPrint('结果: ${response?.data}');
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

## 权限处理

上传工具类已经集成了 [PermissionUtil](../permission/README.md)，会自动处理权限申请：

### 自动权限检查流程

1. **选择图片时**：
   - 调用 `pickImage` 或 `pickMultipleImages` 时会自动检查权限
   - 相机来源：自动申请相机权限
   - 相册来源：自动申请相册权限
   - 权限被拒绝时：显示权限说明弹窗
   - 权限被永久拒绝时：引导用户前往设置页面

2. **权限提示**：
   - 相机权限提示："需要访问相机以拍摄照片"
   - 相册权限提示："需要访问相册以选择照片"
   - 用户可以选择授予权限或取消操作

3. **无需手动处理**：
   - 无需在调用前手动检查权限
   - 无需手动显示权限申请对话框
   - 所有权限逻辑已内置处理

### 示例

```dart
// 直接调用即可，内部会自动处理权限
final source = await UploadUtil.showImageSourceDialog(context);
if (source != null) {
  // pickImage 内部会自动检查和申请权限
  final fileInfo = await UploadUtil.pickImage(source: source);
  if (fileInfo != null) {
    // 权限已授予，成功选择了图片
    debugPrint('选择的图片: ${fileInfo.fileName}');
  } else {
    // 用户取消选择或权限被拒绝
    debugPrint('未选择图片');
  }
}
```

## 注意事项

1. **权限配置**：需要在 `AndroidManifest.xml` 和 `Info.plist` 中配置权限声明（详见下方配置说明）

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
