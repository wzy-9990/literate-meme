import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BaseUpload/index.dart';
import 'package:flutter_tem/utils/base/upload.dart';

/// 上传组件示例页面
class UploadExampleView extends StatefulWidget {
  const UploadExampleView({super.key});

  @override
  State<UploadExampleView> createState() => _UploadExampleViewState();
}

class _UploadExampleViewState extends State<UploadExampleView> {
  final List<UploadItem> _imageUploadList = [];
  final List<UploadItem> _fileUploadList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: '上传组件示例',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例1：图片上传（网格模式 - 使用默认上传接口）
            _buildSectionTitle('示例1：图片上传（使用默认接口）'),
            const SizedBox(height: 8),
            const Text(
              '最多上传3张图片，单张不超过5MB\n使用默认上传接口：/pklApi/private/file/uploadFile',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            BaseUpload(
              maxCount: 3,
              imageOnly: true,
              maxFileSize: 5 * 1024 * 1024, // 5MB
              displayMode: 'grid',
              useDefaultUpload: true, // 使用默认上传接口
              onFilesChanged: (items) {
                setState(() {
                  _imageUploadList.clear();
                  _imageUploadList.addAll(items);
                });
              },
              onUploadedDataChanged: (uploadedData) {
                debugPrint('已上传的文件数据: $uploadedData');
              },
            ),

            const SizedBox(height: 32),

            // 示例2：文件上传（列表模式）
            _buildSectionTitle('示例2：文件上传（列表模式）'),
            const SizedBox(height: 8),
            const Text(
              '支持所有文件类型，最多上传5个文件',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            BaseUpload(
              maxCount: 5,
              imageOnly: false,
              maxFileSize: 10 * 1024 * 1024, // 10MB
              displayMode: 'list',
              customUpload: _mockUpload,
              onUploadSuccess: (item) {
                debugPrint('文件上传成功: ${item.fileInfo.fileName}');
              },
              onUploadFailed: (item, error) {
                debugPrint('文件上传失败: ${item.fileInfo.fileName}, 错误: $error');
              },
              onFilesChanged: (items) {
                setState(() {
                  _fileUploadList.clear();
                  _fileUploadList.addAll(items);
                });
              },
            ),

            const SizedBox(height: 32),

            // 示例3：限制文件类型
            _buildSectionTitle('示例3：限制文件类型（仅PDF和Word）'),
            const SizedBox(height: 8),
            const Text(
              '只允许上传PDF和Word文档',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            BaseUpload(
              maxCount: 3,
              imageOnly: false,
              allowedExtensions: const ['pdf', 'doc', 'docx'],
              displayMode: 'list',
              customUpload: _mockUpload,
              onUploadSuccess: (item) {
                EasyLoading.showSuccess('文档上传成功');
              },
            ),

            const SizedBox(height: 32),

            // 示例4：不显示删除按钮
            _buildSectionTitle('示例4：不显示删除按钮'),
            const SizedBox(height: 12),
            BaseUpload(
              maxCount: 2,
              imageOnly: true,
              displayMode: 'grid',
              showDelete: false,
              customUpload: _mockUpload,
            ),

            const SizedBox(height: 32),

            // 使用说明
            _buildUsageGuide(),
          ],
        ),
      ),
    );
  }

  /// 构建标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 构建使用说明
  Widget _buildUsageGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '组件特性',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem('✅ 支持图片和文件上传'),
          _buildFeatureItem('✅ 网格和列表两种显示模式'),
          _buildFeatureItem('✅ 上传进度实时显示'),
          _buildFeatureItem('✅ 文件大小和类型限制'),
          _buildFeatureItem('✅ 图片预览和文件图标'),
          _buildFeatureItem('✅ 自定义上传方法'),
          _buildFeatureItem('✅ 上传成功/失败回调'),
          _buildFeatureItem('✅ 可选的删除功能'),
          _buildFeatureItem('✅ iOS 风格的来源选择弹窗'),
          _buildFeatureItem('✅ 自动权限检查和申请'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  /// 模拟上传（用于演示）
  /// 实际使用时应该调用真实的上传接口
  Future<dynamic> _mockUpload(BaseUploadFileInfo fileInfo) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 模拟上传成功，返回文件URL
    return {
      'code': 200,
      'data': {
        'url': 'https://example.com/uploads/${fileInfo.fileName}',
        'fileName': fileInfo.fileName,
        'fileSize': fileInfo.fileSize,
      },
      'message': '上传成功',
    };

    // 如果要模拟上传失败，可以抛出异常：
    // throw Exception('网络错误');
  }
}
