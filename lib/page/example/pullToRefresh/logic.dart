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
  int _total = 0; // 总记录数
  int _totalPages = 0; // 总页数

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

        // 处理真实API响应格式
        if (response is Map) {
          // 保存分页信息
          _total = response['total'] ?? 0;
          _totalPages = response['pages'] ?? 0;

          // 从 records 字段获取数据列表
          if (response['records'] != null) {
            newItems = List<Map<String, dynamic>>.from(
              (response['records'] as List).map((item) => Map<String, dynamic>.from(item))
            );
          }
          // 兼容旧格式 list
          else if (response['list'] != null) {
            newItems = List<Map<String, dynamic>>.from(
              (response['list'] as List).map((item) => Map<String, dynamic>.from(item))
            );
          }
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

        debugPrint('✅ 加载了 ${newItems.length} 条数据，当前共 ${items.length} 条，总共 $_total 条，第 $_page/$_totalPages 页');
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
    // 判断是否还有更多页
    if (_page >= _totalPages) {
      debugPrint('⚠️ 已经是最后一页了');
      refreshController.loadNoData();
      return;
    }

    _page++;
    await loadData();

    // 判断是否还有下一页
    if (_page >= _totalPages) {
      debugPrint('✅ 加载完成，没有更多数据了');
      refreshController.loadNoData();
    } else {
      debugPrint('✅ 加载完成，还有更多数据');
      refreshController.loadComplete();
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
