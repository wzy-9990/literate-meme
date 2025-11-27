import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/api/http.dart';
import 'package:flutter_tem/components/BaseImage/preview.dart';
import 'package:flutter_tem/components/BaseInkWell/index.dart';
import 'package:flutter_tem/config/api/index.dart';
import 'package:flutter_tem/utils/permission/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

/// 上传文件信息
class BaseUploadFileInfo {
  /// 文件路径
  final String filePath;

  /// 文件名
  final String fileName;

  /// 文件大小（字节）
  final int fileSize;

  /// MIME 类型
  final String? mimeType;

  /// 是否是图片
  bool get isImage {
    if (mimeType == null) return false;
    return mimeType!.startsWith('image/');
  }

  /// 格式化文件大小
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  BaseUploadFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
  });

  factory BaseUploadFileInfo.fromFile(File file) {
    final fileName = path.basename(file.path);
    final fileSize = file.lengthSync();
    final mimeType = lookupMimeType(file.path);

    return BaseUploadFileInfo(
      filePath: file.path,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
    );
  }
}

/// 图片来源
enum BaseImageSourceType {
  camera, // 相机
  gallery, // 相册
}

/// 上传状态
enum UploadStatus {
  ready, // 准备上传
  uploading, // 上传中
  success, // 上传成功
  failed, // 上传失败
}

/// 上传项数据
class UploadItem {
  final String id;
  final BaseUploadFileInfo fileInfo;
  UploadStatus status;
  double progress;
  String? errorMessage;
  dynamic result;

  UploadItem({
    required this.id,
    required this.fileInfo,
    this.status = UploadStatus.ready,
    this.progress = 0,
    this.errorMessage,
    this.result,
  });
}

/// 上传组件
class BaseUpload extends StatefulWidget {
  /// 最多上传数量
  final int maxCount;

  /// 是否只允许上传图片
  final bool imageOnly;

  /// 允许的文件扩展名
  final List<String>? allowedExtensions;

  /// 单个文件最大大小（字节），默认 10MB
  final int maxFileSize;

  /// 是否使用默认上传接口（/pklApi/private/file/uploadFile）
  /// 默认为 true，设为 false 时需要提供 customUpload
  final bool useDefaultUpload;

  /// 上传成功回调
  final void Function(UploadItem item)? onUploadSuccess;

  /// 上传失败回调
  final void Function(UploadItem item, String error)? onUploadFailed;

  /// 文件列表变化回调
  final void Function(List<UploadItem> items)? onFilesChanged;

  /// 上传成功的数据列表变化回调
  /// 返回所有上传成功的文件数据 [{ fileKey: "xxx", fileUrl: "xxx" }, ...]
  final void Function(List<Map<String, dynamic>> uploadedData)?
      onUploadedDataChanged;

  /// 自定义上传方法（当 useDefaultUpload 为 false 时使用）
  final Future<dynamic> Function(BaseUploadFileInfo fileInfo)? customUpload;

  /// 显示删除按钮
  final bool showDelete;

  /// 显示样式：grid-网格，list-列表
  final String displayMode;

  const BaseUpload({
    super.key,
    this.maxCount = 9,
    this.imageOnly = false,
    this.allowedExtensions,
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.useDefaultUpload = true,
    this.onUploadSuccess,
    this.onUploadFailed,
    this.onFilesChanged,
    this.onUploadedDataChanged,
    this.customUpload,
    this.showDelete = true,
    this.displayMode = 'grid',
  });

  @override
  State<BaseUpload> createState() => _BaseUploadState();
}

/// 上传组件内部工具类
class BaseUploadUtil {
  static final ImagePicker _imagePicker = ImagePicker();

  /// 选择图片（单张）
  ///
  /// [source] 图片来源（相机/相册）
  /// [maxWidth] 最大宽度
  /// [maxHeight] 最大高度
  /// [imageQuality] 图片质量 0-100
  static Future<BaseUploadFileInfo?> pickImage({
    BaseImageSourceType source = BaseImageSourceType.gallery,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) async {
    try {
      // 权限检查
      bool hasPermission = false;
      if (source == BaseImageSourceType.camera) {
        // 调试：打印权限状态
        await PermissionUtil.debugPermissionStatus(Permission.camera);

        hasPermission = await PermissionUtil.requestCamera(
          tip: '需要访问相机以拍摄照片',
        );

        debugPrint('相机权限请求结果: $hasPermission');
      } else {
        // 调试：打印权限状态
        await PermissionUtil.debugPermissionStatus(Permission.photos);

        hasPermission = await PermissionUtil.requestPhotos(
          tip: '需要访问相册以选择照片',
        );

        debugPrint('相册权限请求结果: $hasPermission');
      }

      if (!hasPermission) {
        debugPrint('权限未授予');
        return null;
      }

      final ImageSource imageSource = source == BaseImageSourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery;

      final XFile? image = await _imagePicker.pickImage(
        source: imageSource,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image == null) {
        return null;
      }

      final file = File(image.path);
      return BaseUploadFileInfo.fromFile(file);
    } catch (e) {
      debugPrint('选择图片失败: $e');
      return null;
    }
  }

  /// 选择多张图片
  ///
  /// [maxWidth] 最大宽度
  /// [maxHeight] 最大高度
  /// [imageQuality] 图片质量 0-100
  /// [limit] 最多选择数量
  static Future<List<BaseUploadFileInfo>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
    int? limit,
  }) async {
    try {
      // 权限检查
      final hasPermission = await PermissionUtil.requestPhotos(
        tip: '需要访问相册以选择照片',
      );

      if (!hasPermission) {
        debugPrint('权限未授予');
        return [];
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        limit: limit,
      );

      return images.map((xFile) {
        final file = File(xFile.path);
        return BaseUploadFileInfo.fromFile(file);
      }).toList();
    } catch (e) {
      debugPrint('选择多张图片失败: $e');
      return [];
    }
  }

  /// 选择文件（单个）
  ///
  /// [allowedExtensions] 允许的文件扩展名，例如：['pdf', 'doc', 'docx']
  /// [type] 文件类型
  static Future<BaseUploadFileInfo?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final platformFile = result.files.first;
      if (platformFile.path == null) {
        return null;
      }

      final file = File(platformFile.path!);
      return BaseUploadFileInfo.fromFile(file);
    } catch (e) {
      debugPrint('选择文件失败: $e');
      return null;
    }
  }

  /// 选择多个文件
  ///
  /// [allowedExtensions] 允许的文件扩展名
  /// [type] 文件类型
  static Future<List<BaseUploadFileInfo>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      return result.files
          .where((file) => file.path != null)
          .map((platformFile) {
        final file = File(platformFile.path!);
        return BaseUploadFileInfo.fromFile(file);
      }).toList();
    } catch (e) {
      debugPrint('选择多个文件失败: $e');
      return [];
    }
  }

  /// 使用项目默认上传接口上传文件
  ///
  /// [fileInfo] 文件信息
  /// [onProgress] 上传进度回调
  /// 返回格式: { fileKey: "xxx", fileUrl: "xxx" }
  static Future<Map<String, dynamic>?> uploadFileToDefault({
    required BaseUploadFileInfo fileInfo,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          fileInfo.filePath,
          filename: fileInfo.fileName,
        ),
      });

      // 使用项目的 ApiService 实例上传文件
      final result = await Api.instance.uploadFile(
        '/pklApi/private/file/uploadFile',
        formData: formData,
        onProgress: onProgress,
      );

      return result;
    } on DioException catch (e) {
      // 如果是认证错误，尝试重新上传
      if (e.response?.statusCode == ApiConfig.unauthorizedCode ||
          e.error ==
              'Login required for FormData request, please re-initiate the upload') {
        try {
          // 重新创建FormData并上传
          final FormData formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              fileInfo.filePath,
              filename: fileInfo.fileName,
            ),
          });

          final result = await Api.instance.uploadFile(
            '/pklApi/private/file/uploadFile',
            formData: formData,
            onProgress: onProgress,
          );

          return result;
        } catch (retryError) {
          debugPrint('重新上传文件失败: $retryError');
          rethrow;
        }
      }
      debugPrint('上传文件失败: $e');
      rethrow;
    } catch (e) {
      debugPrint('上传文件失败: $e');
      rethrow;
    }
  }

  /// 上传文件到服务器（通用方法）
  ///
  /// [fileInfo] 文件信息
  /// [uploadUrl] 上传地址
  /// [fieldName] 字段名，默认 'file'
  /// [data] 额外的表单数据
  /// [onProgress] 上传进度回调
  static Future<Response?> uploadFile({
    required BaseUploadFileInfo fileInfo,
    required String uploadUrl,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        fieldName: await MultipartFile.fromFile(
          fileInfo.filePath,
          filename: fileInfo.fileName,
        ),
      });

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final response = await dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: onProgress,
      );

      return response;
    } catch (e) {
      debugPrint('上传文件失败: $e');
      return null;
    }
  }

  /// 批量上传文件
  ///
  /// [files] 文件列表
  /// [uploadUrl] 上传地址
  /// [fieldName] 字段名，默认 'files'
  /// [data] 额外的表单数据
  /// [onProgress] 上传进度回调
  static Future<Response?> uploadMultipleFiles({
    required List<BaseUploadFileInfo> files,
    required String uploadUrl,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final multipartFiles = await Future.wait(
        files.map((fileInfo) => MultipartFile.fromFile(
              fileInfo.filePath,
              filename: fileInfo.fileName,
            )),
      );

      final formData = FormData.fromMap({
        if (data != null) ...data,
        fieldName: multipartFiles,
      });

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 120), // 批量上传需要更长时间
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      final response = await dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: onProgress,
      );

      return response;
    } catch (e) {
      debugPrint('批量上传文件失败: $e');
      return null;
    }
  }

  /// 显示选择图片来源弹窗（iOS 风格）
  static Future<BaseImageSourceType?> showImageSourceDialog(
    BuildContext context,
  ) async {
    return showCupertinoModalPopup<BaseImageSourceType>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('选择图片'),
        message: const Text('请选择图片来源'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, BaseImageSourceType.camera);
            },
            child: const Text('拍照'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, BaseImageSourceType.gallery);
            },
            child: const Text('从相册选择'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
      ),
    );
  }
}

class _BaseUploadState extends State<BaseUpload> {
  final List<UploadItem> _uploadItems = [];
  final List<Map<String, dynamic>> _uploadedDataList = [];

  /// 选择并添加文件
  Future<void> _pickFiles() async {
    if (_uploadItems.length >= widget.maxCount) {
      _showMessage('最多上传 ${widget.maxCount} 个文件');
      return;
    }

    if (widget.imageOnly) {
      await _pickImages();
    } else {
      await _pickAnyFiles();
    }
  }

  /// 选择图片
  Future<void> _pickImages() async {
    final remaining = widget.maxCount - _uploadItems.length;

    // 先弹出弹窗让用户选择来源
    final source = await BaseUploadUtil.showImageSourceDialog(context);
    if (source == null) {
      return;
    }

    // 根据来源选择
    if (source == BaseImageSourceType.camera) {
      // 相机只能拍一张
      final fileInfo = await BaseUploadUtil.pickImage(source: source);
      if (fileInfo != null) {
        _addFile(fileInfo);
      }
    } else {
      // 相册可以选多张
      if (remaining == 1) {
        // 只能选一张
        final fileInfo = await BaseUploadUtil.pickImage(source: source);
        if (fileInfo != null) {
          _addFile(fileInfo);
        }
      } else {
        // 可以选多张
        final files = await BaseUploadUtil.pickMultipleImages(limit: remaining);

        // 手动限制选择的数量（以防平台不支持 limit 参数）
        final limitedFiles = files.take(remaining).toList();

        // 如果用户选择的图片超过了限制，给出提示
        if (files.length > remaining) {
          _showMessage('最多只能上传 $remaining 张图片，已自动选择前 $remaining 张');
        }

        for (final fileInfo in limitedFiles) {
          _addFile(fileInfo);
        }
      }
    }
  }

  /// 选择文件
  Future<void> _pickAnyFiles() async {
    final remaining = widget.maxCount - _uploadItems.length;

    if (remaining == 1) {
      final fileInfo = await BaseUploadUtil.pickFile(
        allowedExtensions: widget.allowedExtensions,
      );
      if (fileInfo != null) {
        _addFile(fileInfo);
      }
    } else {
      final files = await BaseUploadUtil.pickMultipleFiles(
        allowedExtensions: widget.allowedExtensions,
      );

      // 手动限制选择的数量
      final limitedFiles = files.take(remaining).toList();

      // 如果用户选择的文件超过了限制，给出提示
      if (files.length > remaining) {
        _showMessage('最多只能上传 $remaining 个文件，已自动选择前 $remaining 个');
      }

      for (final fileInfo in limitedFiles) {
        _addFile(fileInfo);
      }
    }
  }

  /// 添加文件并上传
  void _addFile(BaseUploadFileInfo fileInfo) {
    // 检查文件大小
    if (fileInfo.fileSize > widget.maxFileSize) {
      final maxSizeMB = (widget.maxFileSize / (1024 * 1024)).toStringAsFixed(0);
      _showMessage('文件大小超过限制（最大 ${maxSizeMB}MB）');
      return;
    }

    if (!mounted) {
      return;
    }

    final item = UploadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileInfo: fileInfo,
    );

    setState(() {
      _uploadItems.add(item);
    });

    widget.onFilesChanged?.call(_uploadItems);

    // 自动上传（默认使用项目上传接口或自定义上传）
    if (widget.useDefaultUpload || widget.customUpload != null) {
      _uploadFile(item);
    }
  }

  /// 获取文件类型名称
  String _getFileTypeName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    // 图片类型
    const imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'svg',
      'ico'
    ];
    if (imageExtensions.contains(extension)) {
      return '图片';
    }

    // 视频类型
    const videoExtensions = [
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'mkv',
      'webm',
      'm4v',
      '3gp'
    ];
    if (videoExtensions.contains(extension)) {
      return '视频';
    }

    // 音频类型
    const audioExtensions = [
      'mp3',
      'wav',
      'flac',
      'aac',
      'ogg',
      'wma',
      'm4a',
      'ape'
    ];
    if (audioExtensions.contains(extension)) {
      return '音频';
    }

    // 其他文件类型
    return '文件';
  }

  /// 上传文件
  Future<void> _uploadFile(UploadItem item) async {
    if (!mounted) {
      return;
    }

    setState(() {
      item.status = UploadStatus.uploading;
      item.progress = 0;
    });

    try {
      dynamic result;

      if (widget.customUpload != null) {
        // 使用自定义上传方法
        result = await widget.customUpload!(item.fileInfo);
      } else if (widget.useDefaultUpload) {
        // 使用项目默认上传接口
        result = await BaseUploadUtil.uploadFileToDefault(
          fileInfo: item.fileInfo,
          onProgress: (sent, total) {
            if (mounted) {
              setState(() {
                item.progress = sent / total;
              });
            }
          },
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        item.status = UploadStatus.success;
        item.progress = 1.0;
        item.result = result;
      });

      // 添加到上传成功的数据列表
      if (result != null && result is Map<String, dynamic>) {
        _uploadedDataList.add(result);
        widget.onUploadedDataChanged?.call(_uploadedDataList);
      }

      // 显示上传成功提示
      final fileTypeName = _getFileTypeName(item.fileInfo.fileName);
      EasyLoading.showSuccess('$fileTypeName上传成功');

      widget.onUploadSuccess?.call(item);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        item.status = UploadStatus.failed;
        item.errorMessage = e.toString();
      });

      // 错误提示已在 uploadFile 方法中处理（显示 returnMsg）
      widget.onUploadFailed?.call(item, e.toString());
    }
  }

  /// 删除文件
  void _removeFile(UploadItem item) {
    if (!mounted) {
      return;
    }

    setState(() {
      // 如果文件上传成功，从上传数据列表中移除
      if (item.status == UploadStatus.success && item.result != null) {
        _uploadedDataList.remove(item.result);
        widget.onUploadedDataChanged?.call(_uploadedDataList);
      }

      _uploadItems.remove(item);
    });
    widget.onFilesChanged?.call(_uploadItems);
  }

  /// 显示提示
  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.displayMode == 'list') {
      return _buildListMode();
    }
    return _buildGridMode();
  }

  /// 网格模式
  Widget _buildGridMode() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.w,
      children: [
        ..._uploadItems.map((item) => _buildGridItem(item)),
        if (_uploadItems.length < widget.maxCount) _buildAddButton(),
      ],
    );
  }

  /// 列表模式
  Widget _buildListMode() {
    return Column(
      children: [
        ..._uploadItems.map((item) => _buildListItem(item)),
        if (_uploadItems.length < widget.maxCount) _buildAddButtonList(),
      ],
    );
  }

  /// 打开图片预览
  void _openImagePreview(UploadItem item) {
    if (!mounted) {
      return;
    }

    // 优先使用上传后的 fileUrl，否则使用本地路径
    String imageUrl = item.fileInfo.filePath;

    // 如果上传成功且有返回的 fileUrl，使用网络图片
    if (item.status == UploadStatus.success &&
        item.result != null &&
        item.result is Map<String, dynamic>) {
      final fileUrl = (item.result as Map<String, dynamic>)['fileUrl'];
      if (fileUrl != null && fileUrl is String && fileUrl.isNotEmpty) {
        imageUrl = fileUrl;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(imageUrl: imageUrl),
      ),
    );
  }

  /// 网格项
  Widget _buildGridItem(UploadItem item) {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Stack(
        children: [
          // 图片预览
          if (item.fileInfo.isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openImagePreview(item),
                  child: Ink.image(
                    image: FileImage(File(item.fileInfo.filePath)),
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            _buildFileIcon(item.fileInfo),

          // 上传进度
          if (item.status == UploadStatus.uploading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: item.progress >= 1.0
                    ? // 文件已上传，等待服务器处理
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40.w,
                            height: 40.w,
                            child: const CircularProgressIndicator(
                              backgroundColor: Colors.white30,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 4,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '上传中...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : // 文件上传中，显示百分比
                    Stack(
                        alignment: Alignment.center,
                        children: [
                          // 进度圆圈
                          SizedBox(
                            width: 50.w,
                            height: 50.w,
                            child: CircularProgressIndicator(
                              value: item.progress,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              strokeWidth: 4.w,
                            ),
                          ),
                          // 百分比文字
                          Text(
                            '${(item.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

          // 上传失败
          if (item.status == UploadStatus.failed)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(height: 4.h),
                    Text(
                      '上传失败',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),

          // 删除按钮
          if (widget.showDelete)
            Positioned(
              top: 4.w,
              right: 4.w,
              child: GestureDetector(
                onTap: () => _removeFile(item),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 列表项
  Widget _buildListItem(UploadItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // 文件图标/缩略图
          if (item.fileInfo.isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openImagePreview(item),
                  child: Ink.image(
                    image: FileImage(File(item.fileInfo.filePath)),
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(Icons.insert_drive_file,
                  color: Colors.grey[600], size: 24.w),
            ),

          SizedBox(width: 12.w),

          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileInfo.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.fileInfo.fileSizeFormatted,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                if (item.status == UploadStatus.uploading) ...[
                  SizedBox(height: 4.h),
                  LinearProgressIndicator(value: item.progress),
                ],
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // 状态图标
          _buildStatusIcon(item),

          // 删除按钮
          if (widget.showDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeFile(item),
            ),
        ],
      ),
    );
  }

  /// 状态图标
  Widget _buildStatusIcon(UploadItem item) {
    switch (item.status) {
      case UploadStatus.ready:
        return Icon(Icons.schedule, color: Colors.grey, size: 20.w);
      case UploadStatus.uploading:
        return SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(strokeWidth: 2.w),
        );
      case UploadStatus.success:
        return Icon(Icons.check_circle, color: Colors.green, size: 20.w);
      case UploadStatus.failed:
        return Icon(Icons.error, color: Colors.red, size: 20.w);
    }
  }

  /// 文件图标
  Widget _buildFileIcon(BaseUploadFileInfo fileInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 40.w, color: Colors.grey[600]),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              fileInfo.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// 添加按钮（网格）
  Widget _buildAddButton() {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.grey[50],
      ),
      child: BaseInkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: _pickFiles,
        backgroundColor: Colors.transparent,
        expand: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32.w, color: Colors.grey[600]),
            SizedBox(height: 4.h),
            Text(
              '添加${widget.imageOnly ? "图片" : "文件"}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加按钮（列表）
  Widget _buildAddButtonList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.grey[50],
      ),
      child: BaseInkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: _pickFiles,
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline,
                  color: Colors.grey[600], size: 24.w),
              SizedBox(width: 8.w),
              Text(
                '添加${widget.imageOnly ? "图片" : "文件"}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
