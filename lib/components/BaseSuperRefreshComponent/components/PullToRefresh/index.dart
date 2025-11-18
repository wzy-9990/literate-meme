import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../WaterDropHeader/index.dart';

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
    Key? key,
    required this.child,
    required this.refreshController,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.noDataText = '暂无数据',
    this.noMoreText = '没有更多了～',
  }) : super(key: key);

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
                Text("加载中..."),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text("加载失败！");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("释放加载...");
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

  const BasePullToRefreshList({
    Key? key,
    required this.children,
    required this.refreshController,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.noDataText = '暂无数据',
    this.noMoreText = '没有更多了～',
    this.scrollController,
  }) : super(key: key);

  @override
  State<BasePullToRefreshList> createState() => _BasePullToRefreshListState();
}

class _BasePullToRefreshListState extends State<BasePullToRefreshList> {
  @override
  Widget build(BuildContext context) {
    // 如果数据为空并且有刷新回调，说明可能正在加载数据，不立即显示空页面
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
                  Text("加载中..."),
                ],
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("加载失败！");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("释放加载...");
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

    // 如果数据为空且没有刷新回调，或者明确需要显示空页面，则显示空页面
    if (widget.children.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 60,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                widget.noDataText!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onRefresh,
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

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
                Text("加载中..."),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text("加载失败！");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("释放加载...");
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
