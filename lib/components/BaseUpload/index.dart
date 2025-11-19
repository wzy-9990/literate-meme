import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/components/BaseImage/preview.dart';
import 'package:flutter_tem/utils/upload/index.dart';

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
  final UploadFileInfo fileInfo;
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
  final Future<dynamic> Function(UploadFileInfo fileInfo)? customUpload;

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
    final source = await UploadUtil.showImageSourceDialog(context);
    if (source == null) return;

    // 根据来源选择
    if (source == ImageSourceType.camera) {
      // 相机只能拍一张
      final fileInfo = await UploadUtil.pickImage(source: source);
      if (fileInfo != null) {
        _addFile(fileInfo);
      }
    } else {
      // 相册可以选多张
      if (remaining == 1) {
        // 只能选一张
        final fileInfo = await UploadUtil.pickImage(source: source);
        if (fileInfo != null) {
          _addFile(fileInfo);
        }
      } else {
        // 可以选多张
        final files = await UploadUtil.pickMultipleImages(limit: remaining);

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
      final fileInfo = await UploadUtil.pickFile(
        allowedExtensions: widget.allowedExtensions,
      );
      if (fileInfo != null) {
        _addFile(fileInfo);
      }
    } else {
      final files = await UploadUtil.pickMultipleFiles(
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
  void _addFile(UploadFileInfo fileInfo) {
    // 检查文件大小
    if (fileInfo.fileSize > widget.maxFileSize) {
      final maxSizeMB = (widget.maxFileSize / (1024 * 1024)).toStringAsFixed(0);
      _showMessage('文件大小超过限制（最大 ${maxSizeMB}MB）');
      return;
    }

    if (!mounted) return;

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
    if (!mounted) return;

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
        result = await UploadUtil.uploadFileToDefault(
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

      if (!mounted) return;

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
    if (!mounted) return;

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
    if (!mounted) return;
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
      spacing: 10,
      runSpacing: 10,
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
    if (!mounted) return;

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
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // 图片预览
          if (item.fileInfo.isImage)
            GestureDetector(
              onTap: () => _openImagePreview(item),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(item.fileInfo.filePath),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 进度圆圈
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: item.progress,
                        backgroundColor: Colors.white30,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 4,
                      ),
                    ),
                    // 百分比文字
                    Text(
                      '${(item.progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(height: 4),
                    Text(
                      '上传失败',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          // 删除按钮
          if (widget.showDelete)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeFile(item),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 文件图标/缩略图
          if (item.fileInfo.isImage)
            GestureDetector(
              onTap: () => _openImagePreview(item),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(item.fileInfo.filePath),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.insert_drive_file, color: Colors.grey[600]),
            ),

          const SizedBox(width: 12),

          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileInfo.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  item.fileInfo.fileSizeFormatted,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (item.status == UploadStatus.uploading) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: item.progress),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

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
        return const Icon(Icons.schedule, color: Colors.grey);
      case UploadStatus.uploading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UploadStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case UploadStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  /// 文件图标
  Widget _buildFileIcon(UploadFileInfo fileInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 40, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              fileInfo.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// 添加按钮（网格）
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border:
              Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              '添加${widget.imageOnly ? "图片" : "文件"}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加按钮（列表）
  Widget _buildAddButtonList() {
    return GestureDetector(
      onTap: _pickFiles,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '添加${widget.imageOnly ? "图片" : "文件"}',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
