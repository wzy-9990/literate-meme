import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefreshExampleLogic extends GetxController {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RxList<String> items = <String>[].obs;
  int _page = 1;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    loadData();
    print('pullToRefresh');
  }

  // 模拟加载数据
  Future<void> loadData() async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 1000));

    // 模拟数据
    List<String> newItems = List.generate(
        _pageSize, (index) => 'Item ${(_page - 1) * _pageSize + index + 1}');

    if (_page == 1) {
      items.value = newItems;
    } else {
      items.addAll(newItems);
    }
  }

  // 下拉刷新
  void onRefresh() async {
    _page = 1;
    await loadData();
    refreshController.refreshCompleted();
  }

  // 上拉加载更多
  void onLoadMore() async {
    _page++;
    await loadData();

    if (items.length >= 100) {
      // 没有更多数据
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
