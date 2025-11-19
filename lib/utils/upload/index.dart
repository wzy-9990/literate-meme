import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

/// 上传文件信息
class UploadFileInfo {
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

  UploadFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
  });

  factory UploadFileInfo.fromFile(File file) {
    final fileName = path.basename(file.path);
    final fileSize = file.lengthSync();
    final mimeType = lookupMimeType(file.path);

    return UploadFileInfo(
      filePath: file.path,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
    );
  }
}

/// 图片来源
enum ImageSourceType {
  camera, // 相机
  gallery, // 相册
}

/// 上传工具类
class UploadUtil {
  static final ImagePicker _imagePicker = ImagePicker();

  /// 选择图片（单张）
  ///
  /// [source] 图片来源（相机/相册）
  /// [maxWidth] 最大宽度
  /// [maxHeight] 最大高度
  /// [imageQuality] 图片质量 0-100
  static Future<UploadFileInfo?> pickImage({
    ImageSourceType source = ImageSourceType.gallery,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) async {
    try {
      final ImageSource imageSource = source == ImageSourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery;

      final XFile? image = await _imagePicker.pickImage(
        source: imageSource,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      final file = File(image.path);
      return UploadFileInfo.fromFile(file);
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
  static Future<List<UploadFileInfo>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
    int? limit,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        limit: limit,
      );

      return images.map((xFile) {
        final file = File(xFile.path);
        return UploadFileInfo.fromFile(file);
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
  static Future<UploadFileInfo?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) return null;

      final platformFile = result.files.first;
      if (platformFile.path == null) return null;

      final file = File(platformFile.path!);
      return UploadFileInfo.fromFile(file);
    } catch (e) {
      debugPrint('选择文件失败: $e');
      return null;
    }
  }

  /// 选择多个文件
  ///
  /// [allowedExtensions] 允许的文件扩展名
  /// [type] 文件类型
  static Future<List<UploadFileInfo>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return [];

      return result.files
          .where((file) => file.path != null)
          .map((platformFile) {
        final file = File(platformFile.path!);
        return UploadFileInfo.fromFile(file);
      }).toList();
    } catch (e) {
      debugPrint('选择多个文件失败: $e');
      return [];
    }
  }

  /// 上传文件到服务器
  ///
  /// [fileInfo] 文件信息
  /// [uploadUrl] 上传地址
  /// [fieldName] 字段名，默认 'file'
  /// [data] 额外的表单数据
  /// [onProgress] 上传进度回调
  static Future<Response?> uploadFile({
    required UploadFileInfo fileInfo,
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

      final dio = Dio();
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
    required List<UploadFileInfo> files,
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

      final dio = Dio();
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

  /// 显示选择图片来源弹窗
  static Future<ImageSourceType?> showImageSourceDialog(
    BuildContext context,
  ) async {
    return showModalBottomSheet<ImageSourceType>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSourceType.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSourceType.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
