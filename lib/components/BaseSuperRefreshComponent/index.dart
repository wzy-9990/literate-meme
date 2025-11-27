import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseSuperRefreshComponent/components/WaterDropHeader/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 超级刷新组件，集成下拉刷新、上拉加载、空页面和加载状态处理
class SuperRefreshComponent extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 刷新控制器
  final RefreshController refreshController;

  /// 下拉刷新回调
  final VoidCallback? onRefresh;

  /// 上拉加载回调
  final VoidCallback? onLoadMore;

  /// 是否启用下拉刷新
  final bool enablePullDown;

  /// 是否启用上拉加载
  final bool enablePullUp;

  /// 没有更多数据时显示的文本
  final String noMoreText;

  /// 暂无数据时显示的文本
  final String noDataText;

  /// 是否显示空页面
  final bool showEmpty;

  /// 是否显示加载中
  final bool showLoading;

  /// 空页面组件
  final Widget? emptyWidget;

  /// 加载中组件
  final Widget? loadingWidget;

  const SuperRefreshComponent({
    required this.child,
    required this.refreshController,
    super.key,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.noMoreText = '没有更多了～',
    this.noDataText = '暂无数据',
    this.showEmpty = false,
    this.showLoading = false,
    this.emptyWidget,
    this.loadingWidget,
  });

  @override
  State<SuperRefreshComponent> createState() => _SuperRefreshComponentState();
}

class _SuperRefreshComponentState extends State<SuperRefreshComponent> {
  @override
  Widget build(BuildContext context) {
    // 显示加载中
    if (widget.showLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    // 显示空页面
    if (widget.showEmpty) {
      return widget.emptyWidget ??
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60.w,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.noDataText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: widget.onRefresh,
                    child: Text(
                      '重新加载',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // 正常显示列表内容
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
            body = Text(widget.noMoreText, style: TextStyle(fontSize: 14.sp));
          } else if (mode == LoadStatus.loading) {
            body = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(strokeWidth: 2.w),
                ),
                SizedBox(width: 10.w),
                Text('加载中...', style: TextStyle(fontSize: 14.sp)),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = Text('加载失败！', style: TextStyle(fontSize: 14.sp));
          } else if (mode == LoadStatus.canLoading) {
            body = Text('释放加载...', style: TextStyle(fontSize: 14.sp));
          } else {
            body = Text(widget.noMoreText, style: TextStyle(fontSize: 14.sp));
          }
          return SizedBox(
            height: 55.h,
            child: Center(child: body),
          );
        },
      ),
      child: widget.child,
    );
  }
}

/// 超级刷新列表组件，专门用于处理列表数据
class SuperRefreshListComponent extends StatefulWidget {
  /// 列表数据项
  final List<Widget> children;

  /// 刷新控制器
  final RefreshController refreshController;

  /// 下拉刷新回调
  final VoidCallback? onRefresh;

  /// 上拉加载回调
  final VoidCallback? onLoadMore;

  /// 是否启用下拉刷新
  final bool enablePullDown;

  /// 是否启用上拉加载
  final bool enablePullUp;

  /// 没有更多数据时显示的文本
  final String noMoreText;

  /// 暂无数据时显示的文本
  final String noDataText;

  /// 是否显示空页面
  final bool showEmpty;

  /// 是否显示加载中
  final bool showLoading;

  /// 空页面组件
  final Widget? emptyWidget;

  /// 加载中组件
  final Widget? loadingWidget;

  /// 滚动控制器
  final ScrollController? scrollController;

  const SuperRefreshListComponent({
    required this.children,
    required this.refreshController,
    super.key,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.noMoreText = '没有更多了～',
    this.noDataText = '暂无数据',
    this.showEmpty = false,
    this.showLoading = false,
    this.emptyWidget,
    this.loadingWidget,
    this.scrollController,
  });

  @override
  State<SuperRefreshListComponent> createState() =>
      _SuperRefreshListComponentState();
}

class _SuperRefreshListComponentState extends State<SuperRefreshListComponent> {
  @override
  Widget build(BuildContext context) {
    // 显示加载中
    if (widget.showLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    // 显示空页面
    if (widget.showEmpty) {
      // 移除了 || widget.children.isEmpty
      return widget.emptyWidget ??
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60.w,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.noDataText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: widget.onRefresh,
                    child: Text(
                      '重新加载',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // 如果数据为空并且有刷新回调，可能正在加载数据，不立即显示空页面
    if (widget.children.isEmpty && widget.onRefresh != null) {
      // 不显示空页面，而是显示SmartRefresher以触发加载
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
              body = Text(widget.noMoreText, style: TextStyle(fontSize: 14.sp));
            } else if (mode == LoadStatus.loading) {
              body = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(strokeWidth: 2.w),
                  ),
                  SizedBox(width: 10.w),
                  Text('加载中...', style: TextStyle(fontSize: 14.sp)),
                ],
              );
            } else if (mode == LoadStatus.failed) {
              body = Text('加载失败！', style: TextStyle(fontSize: 14.sp));
            } else if (mode == LoadStatus.canLoading) {
              body = Text('释放加载', style: TextStyle(fontSize: 14.sp));
            } else {
              body = Text(widget.noMoreText, style: TextStyle(fontSize: 14.sp));
            }
            return SizedBox(
              height: 55.h,
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

    // 如果数据为空且没有刷新回调，或者明确需要显示空页面，则显示空页面
    if (widget.children.isEmpty) {
      return widget.emptyWidget ??
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60.w,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.noDataText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: widget.onRefresh,
                    child: Text(
                      '重新加载',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // 正常显示列表内容
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
            body = Text(widget.noMoreText, style: TextStyle(fontSize: 14.sp));
          } else if (mode == LoadStatus.loading) {
            body = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(strokeWidth: 2.w),
                ),
                SizedBox(width: 10.w),
                Text('加载中...', style: TextStyle(fontSize: 14.sp)),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = Text('加载失败！', style: TextStyle(fontSize: 14.sp));
          } else if (mode == LoadStatus.canLoading) {
            body = Text('释放加载', style: TextStyle(fontSize: 14.sp));
          } else {
            body = Text(widget.noMoreText, style: TextStyle(fontSize: 14.sp));
          }
          return SizedBox(
            height: 55.h,
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
