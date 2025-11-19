import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 通用 AppBar 组件
///
/// 已集成全局主题配置，默认为白色背景、深色图标
/// 支持自定义标题、左侧按钮、右侧按钮
///
/// 基础用法：
/// ```dart
/// BaseAppBar(
///   title: '页面标题',
/// )
/// ```
///
/// 自定义左侧按钮：
/// ```dart
/// BaseAppBar(
///   title: '页面标题',
///   leading: IconButton(
///     icon: Icon(Icons.menu),
///     onPressed: () {},
///   ),
/// )
/// ```
///
/// 自定义右侧按钮：
/// ```dart
/// BaseAppBar(
///   title: '页面标题',
///   actions: [
///     IconButton(
///       icon: Icon(Icons.search),
///       onPressed: () {},
///     ),
///     IconButton(
///       icon: Icon(Icons.more_vert),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题文字
  final String? title;

  /// 标题组件（优先级高于 title）
  final Widget? titleWidget;

  /// 左侧组件（优先级高于默认返回按钮）
  final Widget? leading;

  /// 右侧按钮列表
  final List<Widget>? actions;

  /// 是否自动显示返回按钮（默认 true）
  final bool automaticallyImplyLeading;

  /// 背景颜色（默认使用主题配置）
  final Color? backgroundColor;

  /// 前景色（标题和图标颜色，默认使用主题配置）
  final Color? foregroundColor;

  /// 是否居中标题（默认使用主题配置）
  final bool? centerTitle;

  /// AppBar 高度（默认使用系统默认高度）
  final double? toolbarHeight;

  /// 阴影高度（默认使用主题配置的 0）
  final double? elevation;

  /// 状态栏样式（默认使用主题配置）
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// 底部组件（如 TabBar）
  final PreferredSizeWidget? bottom;

  const BaseAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle,
    this.toolbarHeight,
    this.elevation,
    this.systemOverlayStyle,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      elevation: elevation,
      systemOverlayStyle: systemOverlayStyle,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
      );
}
