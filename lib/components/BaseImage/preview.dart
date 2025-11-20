import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_tem/utils/base/image_saver.dart';

/// 图片预览页面
class ImagePreviewPage extends StatefulWidget {
  /// 图片地址
  final String imageUrl;

  /// 背景颜色
  final Color backgroundColor;

  const ImagePreviewPage({
    required this.imageUrl,
    super.key,
    this.backgroundColor = Colors.black,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  /// 判断是否为网络图片
  bool get _isNetworkImage {
    return widget.imageUrl.startsWith('http://') ||
        widget.imageUrl.startsWith('https://');
  }

  /// 保存图片到本地
  Future<void> _saveImage() async {
    if (_isNetworkImage) {
      // 保存网络图片
      await ImageSaver.saveNetworkImage(widget.imageUrl);
    } else {
      // 对于本地图片，显示提示信息或实现本地图片保存逻辑
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('本地图片无需保存'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          // 图片预览主体
          PhotoView(
            imageProvider: _isNetworkImage
                ? CachedNetworkImageProvider(widget.imageUrl)
                : AssetImage(widget.imageUrl) as ImageProvider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: BoxDecoration(
              color: widget.backgroundColor,
            ),
            loadingBuilder: (context, event) {
              return Center(
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded /
                          (event.expectedTotalBytes ?? 1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image_outlined,
                      size: 80,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '图片加载失败',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 顶部工具栏
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 保存按钮
                GestureDetector(
                  onTap: _saveImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // 关闭按钮
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
