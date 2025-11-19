import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 空页面组件
///
/// 用于显示空状态页面，包含图片、标题、副标题和可选按钮
///
/// 示例用法:
/// ```dart
/// BaseEmpty(
///   imagePath: 'assets/images/empty.png',
///   title: '暂无数据',
///   subtitle: '当前没有任何内容',
///   buttonText: '去添加',
///   onButtonPressed: () {
///     // 处理按钮点击
///   },
/// )
/// ```
class BaseEmpty extends StatelessWidget {
  /// 空状态图片路径
  final String? imagePath;

  /// 主标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 按钮文字
  final String? buttonText;

  /// 按钮点击回调
  final VoidCallback? onButtonPressed;

  /// 图片宽度
  final double? imageWidth;

  /// 图片高度
  final double? imageHeight;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 副标题样式
  final TextStyle? subtitleStyle;

  /// 按钮样式
  final ButtonStyle? buttonStyle;

  /// 图片与标题之间的间距
  final double? imageToTitleSpacing;

  /// 标题与副标题之间的间距
  final double? titleToSubtitleSpacing;

  /// 副标题与按钮之间的间距
  final double? subtitleToButtonSpacing;

  const BaseEmpty({
    super.key,
    this.imagePath,
    this.title = '暂无数据',
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.imageWidth,
    this.imageHeight,
    this.titleStyle,
    this.subtitleStyle,
    this.buttonStyle,
    this.imageToTitleSpacing,
    this.titleToSubtitleSpacing,
    this.subtitleToButtonSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 空状态图片
          _buildImage(),

          SizedBox(height: imageToTitleSpacing ?? 24.h),

          // 主标题
          _buildTitle(),

          // 副标题
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: titleToSubtitleSpacing ?? 12.h),
            _buildSubtitle(),
          ],

          // 按钮
          if (buttonText != null && buttonText!.isNotEmpty) ...[
            SizedBox(height: subtitleToButtonSpacing ?? 24.h),
            _buildButton(),
          ],
        ],
      ),
    );
  }

  /// 构建图片
  Widget _buildImage() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      // 如果提供了图片路径，使用图片
      return Image.asset(
        imagePath!,
        width: imageWidth ?? 200.w,
        height: imageHeight ?? 200.w,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // 图片加载失败时显示默认占位符
          return _buildPlaceholder();
        },
      );
    } else {
      // 没有提供图片路径时使用默认占位符
      return _buildPlaceholder();
    }
  }

  /// 构建默认占位符
  Widget _buildPlaceholder() {
    return Container(
      width: imageWidth ?? 200.w,
      height: imageHeight ?? 200.w,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        Icons.inbox_outlined,
        size: 80.w,
        color: Colors.grey[400],
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Text(
      title,
      style: titleStyle ??
          TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
      textAlign: TextAlign.center,
    );
  }

  /// 构建副标题
  Widget _buildSubtitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Text(
        subtitle!,
        style: subtitleStyle ??
            TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 构建按钮
  Widget _buildButton() {
    return ElevatedButton(
      onPressed: onButtonPressed,
      style: buttonStyle ??
          ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 32.w,
              vertical: 12.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
      child: Text(
        buttonText!,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
