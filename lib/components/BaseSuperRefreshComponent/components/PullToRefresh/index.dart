import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseEmpty/index.dart';
import 'package:flutter_tem/components/BaseSuperRefreshComponent/components/WaterDropHeader/index.dart';
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
  @override
  Widget build(BuildContext context) {
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
