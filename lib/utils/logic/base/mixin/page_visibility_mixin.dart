import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 页面可见性监听 Mixin
///
/// 提供页面显示（onShow）和隐藏（onHide）的生命周期回调
///
/// 使用示例：
/// ```dart
/// class MyLogic extends BaseLogic with PageVisibilityMixin {
///   @override
///   void onShow() {
///     super.onShow();
///     debugPrint('页面显示，刷新数据');
///     refreshData();
///   }
///
///   @override
///   void onHide() {
///     super.onHide();
///     debugPrint('页面隐藏，暂停动画');
///     pauseAnimation();
///   }
/// }
/// ```
///
/// **注意**：需要在视图层使用 PageVisibilityWrapper 包裹
mixin PageVisibilityMixin on GetxController {
  /// 页面是否可见
  final RxBool _isPageVisible = false.obs;

  /// 获取页面可见状态
  bool get isPageVisible => _isPageVisible.value;

  /// 内部方法：设置页面可见性（由 PageVisibilityWrapper 调用）
  void setPageVisibility(bool visible) {
    if (_isPageVisible.value == visible) {
      return; // 状态未变化，不触发回调
    }

    _isPageVisible.value = visible;

    if (visible) {
      onShow();
    } else {
      onHide();
    }
  }

  /// 页面显示时回调
  ///
  /// 触发时机：
  /// - 页面首次进入
  /// - 从其他页面返回到当前页面
  /// - 应用从后台切换到前台（当前页面在栈顶）
  void onShow() {
    debugPrint('[PageVisibility] ${runtimeType} - onShow');
  }

  /// 页面隐藏时回调
  ///
  /// 触发时机：
  /// - 跳转到其他页面
  /// - 应用切换到后台
  void onHide() {
    debugPrint('[PageVisibility] ${runtimeType} - onHide');
  }
}

/// 页面可见性包装器
///
/// 用于监听页面的显示和隐藏，需要包裹在页面根部
///
/// 使用示例：
/// ```dart
/// class MyPage extends GetView<MyLogic> {
///   @override
///   Widget build(BuildContext context) {
///     return PageVisibilityWrapper(
///       controller: controller,
///       child: Scaffold(
///         appBar: AppBar(title: Text('我的页面')),
///         body: ...,
///       ),
///     );
///   }
/// }
/// ```
class PageVisibilityWrapper extends StatefulWidget {
  final Widget child;
  final GetxController controller;

  const PageVisibilityWrapper({
    required this.child,
    required this.controller,
    super.key,
  });

  @override
  State<PageVisibilityWrapper> createState() => _PageVisibilityWrapperState();
}

class _PageVisibilityWrapperState extends State<PageVisibilityWrapper>
    with RouteAware, WidgetsBindingObserver {
  /// 应用状态是否可见
  bool _appVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 注册路由监听
    final route = ModalRoute.of(context);
    if (route != null && route is PageRoute) {
      PageVisibilityObserver.instance.subscribe(this, route);
    }

    // 首次进入时触发 onShow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibility(true);
    });
  }

  @override
  void dispose() {
    PageVisibilityObserver.instance.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 监听应用生命周期状态变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final visible = state == AppLifecycleState.resumed;
    if (_appVisible != visible) {
      _appVisible = visible;
      _updateVisibility(visible);
    }
  }

  /// 页面顶部可见（从其他页面返回）
  @override
  void didPopNext() {
    debugPrint('[RouteAware] ${widget.controller.runtimeType} - didPopNext (返回到当前页面)');
    _updateVisibility(true);
  }

  /// 页面推入新页面（当前页面被覆盖）
  @override
  void didPushNext() {
    debugPrint('[RouteAware] ${widget.controller.runtimeType} - didPushNext (跳转到其他页面)');
    _updateVisibility(false);
  }

  /// 页面从栈中弹出（当前页面被销毁）
  @override
  void didPop() {
    debugPrint('[RouteAware] ${widget.controller.runtimeType} - didPop (页面被销毁)');
    _updateVisibility(false);
  }

  /// 页面推入栈（当前页面被创建）
  @override
  void didPush() {
    debugPrint('[RouteAware] ${widget.controller.runtimeType} - didPush (页面被创建)');
    _updateVisibility(true);
  }

  /// 更新页面可见性
  void _updateVisibility(bool visible) {
    if (widget.controller is PageVisibilityMixin) {
      // 只有当应用可见且路由可见时，页面才真正可见
      final pageVisible = visible && _appVisible;
      (widget.controller as PageVisibilityMixin).setPageVisibility(pageVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 全局路由观察器（单例）
///
/// 需要在 MaterialApp 的 navigatorObservers 中注册
class PageVisibilityObserver extends RouteObserver<PageRoute<dynamic>> {
  PageVisibilityObserver._();

  static final PageVisibilityObserver _instance = PageVisibilityObserver._();
  static PageVisibilityObserver get instance => _instance;
}
