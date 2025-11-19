import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseImage/preview.dart';

/// 通用图片组件
///
/// 支持加载静态图片和网络图片，提供加载动画、错误处理等功能
///
/// 使用示例：
/// ```dart
/// // 加载网络图片
/// BaseImage(
///   imageUrl: 'https://example.com/image.jpg',
///   width: 100,
///   height: 100,
/// )
///
/// // 加载本地图片
/// BaseImage(
///   imageUrl: 'assets/images/logo.png',
///   width: 100,
///   height: 100,
/// )
/// ```
class BaseImage extends StatelessWidget {
  /// 图片地址（支持网络地址和本地 assets 路径）
  final String imageUrl;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 图片裁剪模式
  final BoxFit fit;

  /// 圆角
  final double borderRadius;

  /// 占位图（加载中显示）
  final Widget? placeholder;

  /// 错误时显示的图片
  final Widget? errorWidget;

  /// 是否启用淡入动画
  final bool enableFadeIn;

  /// 淡入动画时长（毫秒）
  final int fadeInDuration;

  /// 占位图背景色
  final Color? placeholderColor;

  /// 是否是圆形图片
  final bool isCircle;

  /// 是否启用点击预览
  final bool enablePreview;

  const BaseImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.enableFadeIn = true,
    this.fadeInDuration = 300,
    this.placeholderColor,
    this.isCircle = false,
    this.enablePreview = true,
  });

  /// 判断是否为网络图片
  bool get _isNetworkImage {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  /// 构建占位图
  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return _ShimmerPlaceholder(
      width: width,
      height: height,
      baseColor: placeholderColor ?? Colors.grey[200]!,
    );
  }

  /// 构建错误图
  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.4 : height! * 0.4)
                : 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 包装图片（添加圆角或圆形）
  Widget _wrapImage(Widget child) {
    if (isCircle) {
      return ClipOval(
        child: child,
      );
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      );
    }

    return child;
  }

  /// 打开图片预览
  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(imageUrl: imageUrl),
      ),
    );
  }

  /// 包装点击事件
  Widget _wrapGesture(BuildContext context, Widget child) {
    if (!enablePreview) {
      return child;
    }

    return GestureDetector(
      onTap: () => _openPreview(context),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // 网络图片
    if (_isNetworkImage) {
      imageWidget = _wrapImage(
        CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          fadeInDuration: enableFadeIn
              ? Duration(milliseconds: fadeInDuration)
              : Duration.zero,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      );
    } else {
      // 本地图片
      imageWidget = _wrapImage(
        _LocalImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          enableFadeIn: enableFadeIn,
          fadeInDuration: fadeInDuration,
          errorWidget: _buildErrorWidget(),
        ),
      );
    }

    return _wrapGesture(context, imageWidget);
  }
}

/// 本地图片组件（内部使用）
class _LocalImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableFadeIn;
  final int fadeInDuration;
  final Widget errorWidget;

  const _LocalImage({
    required this.imageUrl,
    required this.fit,
    required this.enableFadeIn,
    required this.fadeInDuration,
    required this.errorWidget,
    this.width,
    this.height,
  });

  @override
  State<_LocalImage> createState() => _LocalImageState();
}

class _LocalImageState extends State<_LocalImage> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget;
    }

    if (widget.enableFadeIn) {
      return AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: widget.fadeInDuration),
        child: Image.asset(
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                });
              }
            });
            return widget.errorWidget;
          },
        ),
      );
    }

    return Image.asset(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget;
      },
    );
  }
}

/// Shimmer 占位图组件（内部使用）
class _ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final Color baseColor;

  const _ShimmerPlaceholder({
    required this.baseColor,
    this.width,
    this.height,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.baseColor.withOpacity(_animation.value),
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
