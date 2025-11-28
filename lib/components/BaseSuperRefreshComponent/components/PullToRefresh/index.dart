import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseEmpty/index.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_tem/components/BaseSuperRefreshComponent/components/WaterDropHeader/index.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatefulWidget {
  final Widget child;
  final RefreshController refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final bool enablePullDown;
  final bool enablePullUp;
  final String? noDataText;
  final String? noMoreText;

  const PullToRefresh({
    required this.child,
    required this.refreshController,
    super.key,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.noDataText = '暂无数据',
    this.noMoreText = '没有更多了～',
  });

  @override
  State<PullToRefresh> createState() => _BasePullToRefreshState();
}

class _BasePullToRefreshState extends State<PullToRefresh> {
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: widget.refreshController,
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoadMore,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      header: const ChineseWaterDropHeader(), // 自定义中文下拉刷新头部
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(widget.noMoreText!);
          } else if (mode == LoadStatus.loading) {
            body = const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('加载中...'),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text('加载失败！');
          } else if (mode == LoadStatus.canLoading) {
            body = const Text('释放加载...');
          } else {
            body = Text(widget.noMoreText!);
          }
          return SizedBox(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      child: widget.child,
    );
  }
}

class BasePullToRefreshList extends StatefulWidget {
  final List<Widget> children;
  final RefreshController refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final bool enablePullDown;
  final bool enablePullUp;
  final String? noDataText;
  final String? noMoreText;
  final ScrollController? scrollController;

  /// 是否需要登录才能查看列表（默认需要）
  final bool requireAuth;

  /// 未登录状态（null 时自动根据 token 判断）
  final bool? isUnAuth;

  /// 未登录空页面配置
  final String? unAuthImagePath;
  final String? unAuthTitle;
  final String? unAuthSubtitle;
  final String? unAuthButtonText;

  // 空页面相关配置
  /// 是否正在加载（用于判断是否显示空页面）
  final bool isLoading;

  /// 是否处于搜索状态（用于区分普通空和搜索空）
  final bool isSearching;

  /// 普通空页面图片路径
  final String? emptyImagePath;

  /// 普通空页面标题
  final String? emptyTitle;

  /// 普通空页面副标题
  final String? emptySubtitle;

  /// 普通空页面按钮文字
  final String? emptyButtonText;

  /// 搜索空页面图片路径
  final String? searchEmptyImagePath;

  /// 搜索空页面标题
  final String? searchEmptyTitle;

  /// 搜索空页面副标题
  final String? searchEmptySubtitle;

  /// 搜索空页面按钮文字
  final String? searchEmptyButtonText;

  /// 空页面按钮点击回调（不提供则使用 onRefresh）
  final VoidCallback? onEmptyButtonPressed;

  const BasePullToRefreshList({
    required this.children,
    required this.refreshController,
    super.key,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.noDataText = '暂无数据',
    this.noMoreText = '没有更多了～',
    this.scrollController,
    this.requireAuth = false,
    this.isUnAuth,
    this.unAuthImagePath,
    this.unAuthTitle,
    this.unAuthSubtitle,
    this.unAuthButtonText,
    // 空页面配置
    this.isLoading = false,
    this.isSearching = false,
    // 普通空页面配置
    this.emptyImagePath,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyButtonText,
    // 搜索空页面配置
    this.searchEmptyImagePath,
    this.searchEmptyTitle,
    this.searchEmptySubtitle,
    this.searchEmptyButtonText,
    // 按钮回调
    this.onEmptyButtonPressed,
  });

  @override
  State<BasePullToRefreshList> createState() => _BasePullToRefreshListState();
}

class _BasePullToRefreshListState extends State<BasePullToRefreshList> {
  bool? _autoUnAuth;
  StreamSubscription<String>? _tokenSub;
  bool _wasUnAuthed = false; // 记录上一次的未登录状态

  @override
  void initState() {
    super.initState();
    if (widget.requireAuth && widget.isUnAuth == null) {
      _setupAuthListener();
    }
  }

  void _setupAuthListener() {
    if (Get.isRegistered<IndexLogic>()) {
      final indexLogic = Get.find<IndexLogic>();
      _autoUnAuth = !indexLogic.isLoggedIn;
      _wasUnAuthed = _autoUnAuth ?? false; // 初始化上一次状态

      _tokenSub = indexLogic.token.listen((value) {
        if (!mounted) {
          return;
        }

        final bool isCurrentlyUnAuthed = value.isEmpty;

        // 检测到从未登录变为已登录（登录成功）
        if (_wasUnAuthed && !isCurrentlyUnAuthed) {
          debugPrint('🔄 检测到登录状态变化：未登录 -> 已登录，自动刷新数据');

          // 延迟执行，确保 UI 更新完成
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && widget.onRefresh != null) {
              widget.onRefresh!();
            }
          });
        }

        // 更新状态
        setState(() {
          _autoUnAuth = isCurrentlyUnAuthed;
          _wasUnAuthed = isCurrentlyUnAuthed;
        });
      });
    } else {
      _loadTokenStatus();
    }
  }

  Future<void> _loadTokenStatus() async {
    final token = await Storage.getString(StorageKeys.token);
    if (!mounted) {
      return;
    }
    setState(() {
      _autoUnAuth = token == null || token.isEmpty;
      _wasUnAuthed = _autoUnAuth ?? false; // 初始化上一次状态
    });
  }

  @override
  void dispose() {
    _tokenSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算未登录态
    final bool resolvedUnAuth;
    if (!widget.requireAuth) {
      // 不需要登录，直接视为已登录
      _autoUnAuth = false;
    }

    if (widget.isUnAuth != null) {
      resolvedUnAuth = widget.isUnAuth!;
    } else if (_autoUnAuth == null) {
      return const BaseLoading();
    } else {
      resolvedUnAuth = _autoUnAuth!;
    }

    // 未登录态优先展示
    if (resolvedUnAuth) {
      return BaseEmpty(
        imagePath: widget.unAuthImagePath,
        title: widget.unAuthTitle ?? '未登录',
        subtitle: widget.unAuthSubtitle ?? '登录后查看内容',
        buttonText: widget.unAuthButtonText ?? '去登录',
        onButtonPressed: widget.onEmptyButtonPressed ??
            () {
              // 跳转登录页
              if (Get.currentRoute != '/login') {
                Get.toNamed('/login');
              }
            },
      );
    }

    // 加载中且暂无数据时，直接显示 loading
    if (widget.isLoading && widget.children.isEmpty) {
      return const BaseLoading();
    }

    // 如果数据为空且不在加载中，显示空页面
    if (widget.children.isEmpty && !widget.isLoading) {
      // 根据是否搜索状态显示不同的空页面
      if (widget.isSearching) {
        // 搜索空状态
        return BaseEmpty(
          imagePath: widget.searchEmptyImagePath,
          title: widget.searchEmptyTitle ?? '搜索无结果',
          subtitle: widget.searchEmptySubtitle,
          buttonText: widget.searchEmptyButtonText,
          onButtonPressed: widget.onEmptyButtonPressed ?? widget.onRefresh,
        );
      } else {
        // 普通空状态
        return BaseEmpty(
          imagePath: widget.emptyImagePath,
          title: widget.emptyTitle ?? widget.noDataText ?? '暂无数据',
          subtitle: widget.emptySubtitle,
          buttonText: widget.emptyButtonText,
          onButtonPressed: widget.onEmptyButtonPressed ?? widget.onRefresh,
        );
      }
    }

    // 有数据或正在加载，显示列表
    return SmartRefresher(
      controller: widget.refreshController,
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoadMore,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      header: const ChineseWaterDropHeader(), // 自定义中文下拉刷新头部
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(widget.noMoreText!);
          } else if (mode == LoadStatus.loading) {
            body = const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('加载中...'),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text('加载失败！');
          } else if (mode == LoadStatus.canLoading) {
            body = const Text('释放加载...');
          } else {
            body = Text(widget.noMoreText!);
          }
          return SizedBox(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      child: ListView(
        controller: widget.scrollController,
        children: widget.children,
      ),
    );
  }
}
