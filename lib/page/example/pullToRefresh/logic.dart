import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_tem/api/modules/my.dart';

class PullToRefreshExampleLogic extends GetxController {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  int _page = 1;
  static const int _pageSize = 15;
  String _searchKeyword = ''; // 搜索关键词

  @override
  void onInit() {
    super.onInit();
    loadData();
    debugPrint('pullToRefresh 初始化');
  }

  // 加载数据
  Future<void> loadData() async {
    try {
      // 首次加载时显示 loading
      if (_page == 1 && items.isEmpty) {
        isLoading.value = true;
      }

      // 构建请求参数
      Map<String, dynamic> params = {
        'pageNo': _page,
        'pageSize': _pageSize,
      };

      // 如果有搜索关键词，添加 userName 参数
      if (_searchKeyword.isNotEmpty) {
        params['userName'] = _searchKeyword;
      }

      debugPrint('⏩ 请求参数: $params');

      // 调用真实接口
      final response = await listPageUserByOrganizationIdApi(params);

      debugPrint('✅ 响应数据: $response');

      // 解析数据
      if (response != null) {
        List<Map<String, dynamic>> newItems = [];

        // 处理不同的响应格式
        if (response is Map && response['list'] != null) {
          // 如果返回格式是 {list: [...], total: xx}
          newItems = List<Map<String, dynamic>>.from(
            (response['list'] as List).map((item) => Map<String, dynamic>.from(item))
          );
        } else if (response is List) {
          // 如果直接返回数组
          newItems = List<Map<String, dynamic>>.from(
            response.map((item) => Map<String, dynamic>.from(item))
          );
        }

        if (_page == 1) {
          items.value = newItems;
        } else {
          items.addAll(newItems);
        }

        debugPrint('✅ 加载了 ${newItems.length} 条数据');
      }

      // 加载完成后隐藏 loading
      isLoading.value = false;
    } catch (e) {
      debugPrint('❌ 加载数据失败: $e');
      isLoading.value = false;
      // 错误已经在拦截器中处理并显示 toast
    }
  }

  // 搜索
  void search(String keyword) {
    _searchKeyword = keyword.trim();
    _page = 1;
    items.clear(); // 清空旧数据
    loadData();
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
