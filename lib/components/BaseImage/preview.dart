import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// 图片预览页面
class ImagePreviewPage extends StatelessWidget {
  /// 图片地址
  final String imageUrl;

  /// 背景颜色
  final Color backgroundColor;

  const ImagePreviewPage({
    super.key,
    required this.imageUrl,
    this.backgroundColor = Colors.black,
  });

  /// 判断是否为网络图片
  bool get _isNetworkImage {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 图片预览主体
          PhotoView(
            imageProvider: _isNetworkImage
                ? CachedNetworkImageProvider(imageUrl)
                : AssetImage(imageUrl) as ImageProvider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: BoxDecoration(
              color: backgroundColor,
            ),
            loadingBuilder: (context, event) {
              return Center(
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
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

          // 关闭按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
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
          ),
        ],
      ),
    );
  }
}
