import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'base_logic.dart';

/// 分页Logic基类，用于处理列表分页场景
/// 泛型T表示列表项的数据类型
abstract class BasePaginationLogic<T> extends BaseLogic {
  /// 刷新控制器
  late final RefreshController refreshController;

  /// 列表数据
  final RxList<T> dataList = <T>[].obs;

  /// 当前页码
  int currentPage = 1;

  /// 每页数量
  int pageSize = 20;

  /// 是否还有更多数据
  bool hasMoreData = true;

  /// 是否为空数据
  RxBool get isEmpty => (dataList.isEmpty && isInitialized.value).obs;

  @override
  void onInit() {
    refreshController = RefreshController(initialRefresh: false);
    super.onInit();
  }

  @override
  void initData() {
    super.initData();
    // 自动加载第一页数据
    loadData();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  /// 加载数据 - 子类必须实现
  /// 返回加载的数据列表
  Future<List<T>> fetchData(int page, int size);

  /// 加载数据的通用逻辑
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      final List<T> newData = await fetchData(currentPage, pageSize);

      if (currentPage == 1) {
        // 首页数据，直接替换
        dataList.value = newData;
      } else {
        // 追加数据
        dataList.addAll(newData);
      }

      // 判断是否还有更多数据
      hasMoreData = newData.length >= pageSize;

      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      handleError(error);
      rethrow;
    }
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    try {
      currentPage = 1;
      hasMoreData = true;
      await loadData();
      refreshController.refreshCompleted();
      refreshController.resetNoData();
    } catch (error) {
      refreshController.refreshFailed();
      // 错误已在loadData中处理
    }
  }

  /// 上拉加载更多
  Future<void> onLoadMore() async {
    if (!hasMoreData) {
      refreshController.loadNoData();
      return;
    }

    try {
      currentPage++;
      await loadData();

      if (hasMoreData) {
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    } catch (error) {
      currentPage--; // 失败时回退页码
      refreshController.loadFailed();
      // 错误已在loadData中处理
    }
  }

  /// 重新加载数据
  Future<void> reload() async {
    currentPage = 1;
    hasMoreData = true;
    await loadData();
  }

  /// 清空数据
  void clearData() {
    dataList.clear();
    currentPage = 1;
    hasMoreData = true;
  }

  /// 添加单个数据
  void addItem(T item, {bool toFirst = false}) {
    if (toFirst) {
      dataList.insert(0, item);
    } else {
      dataList.add(item);
    }
  }

  /// 删除单个数据
  void removeItem(T item) {
    dataList.remove(item);
  }

  /// 根据索引删除数据
  void removeAt(int index) {
    if (index >= 0 && index < dataList.length) {
      dataList.removeAt(index);
    }
  }

  /// 更新单个数据
  void updateItem(int index, T item) {
    if (index >= 0 && index < dataList.length) {
      dataList[index] = item;
      dataList.refresh();
    }
  }
}
