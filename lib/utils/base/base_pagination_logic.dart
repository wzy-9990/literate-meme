import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 通用分页逻辑基类
///
/// 使用示例：
/// ```dart
/// class UserListLogic extends BasePaginationLogic<Map<String, dynamic>> {
///   @override
///   Future<PaginationResponse<Map<String, dynamic>>> fetchData(int page, int pageSize, Map<String, dynamic>? searchParams) async {
///     final params = {
///       'pageNo': page,
///       'pageSize': pageSize,
///       ...?searchParams,
///     };
///     final response = await yourApi(params);
///     return PaginationResponse(
///       records: response['records'],
///       total: response['total'],
///       pages: response['pages'],
///     );
///   }
/// }
/// ```
abstract class BasePaginationLogic<T> extends GetxController {
  /// 刷新控制器
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  /// 数据列表
  final RxList<T> items = <T>[].obs;

  /// 加载状态
  final RxBool isLoading = false.obs;

  /// 当前页码
  int _page = 1;

  /// 每页数据量（可以在子类中覆盖）
  int get pageSize => 15;

  /// 总记录数
  int _total = 0;
  int get total => _total;

  /// 总页数
  int _totalPages = 0;
  int get totalPages => _totalPages;

  /// 搜索参数（可选）
  Map<String, dynamic>? _searchParams;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  /// 子类必须实现：获取数据的接口
  ///
  /// [page] 页码
  /// [pageSize] 每页数量
  /// [searchParams] 搜索参数（可选）
  ///
  /// 返回 [PaginationResponse] 包含数据列表、总数、总页数
  Future<PaginationResponse<T>> fetchData(
    int page,
    int pageSize,
    Map<String, dynamic>? searchParams,
  );

  /// 加载数据
  Future<void> loadData() async {
    try {
      // 首次加载时显示 loading
      if (_page == 1 && items.isEmpty) {
        isLoading.value = true;
      }

      debugPrint('⏩ 开始加载数据，页码: $_page，每页: $pageSize，搜索参数: $_searchParams');

      // 调用子类实现的接口
      final response = await fetchData(_page, pageSize, _searchParams);

      // 保存分页信息
      _total = response.total ?? 0;
      _totalPages = response.pages ?? 0;

      // 处理数据
      final List<T> newItems = response.records ?? [];

      if (_page == 1) {
        items.value = newItems;
      } else {
        items.addAll(newItems);
      }

      debugPrint('✅ 加载了 ${newItems.length} 条数据，当前共 ${items.length} 条，总共 $_total 条，第 $_page/$_totalPages 页');

      // 加载完成后隐藏 loading
      isLoading.value = false;
    } catch (e) {
      debugPrint('❌ 加载数据失败: $e');
      isLoading.value = false;
      // 错误已经在拦截器中处理并显示 toast
    }
  }

  /// 搜索（带搜索参数）
  void search([Map<String, dynamic>? searchParams]) {
    _searchParams = searchParams;
    _page = 1;
    items.clear();
    _total = 0;
    _totalPages = 0;
    loadData();
    refreshController.resetNoData();
  }

  /// 下拉刷新
  void onRefresh() async {
    _page = 1;
    await loadData();
    refreshController.refreshCompleted();

    // 如果数据为空，重置加载更多状态
    if (items.isEmpty) {
      refreshController.resetNoData();
    }
  }

  /// 上拉加载更多
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
}

/// 分页响应数据模型
class PaginationResponse<T> {
  /// 数据列表
  final List<T>? records;

  /// 总记录数
  final int? total;

  /// 总页数
  final int? pages;

  PaginationResponse({
    this.records,
    this.total,
    this.pages,
  });

  /// 从 Map 创建（适配不同的 API 响应格式）
  factory PaginationResponse.fromMap(Map<String, dynamic> map, T Function(Map<String, dynamic>) itemMapper) {
    List<T>? records;

    // 尝试从 records 字段获取
    if (map['records'] != null) {
      records = (map['records'] as List).map((item) => itemMapper(item as Map<String, dynamic>)).toList();
    }
    // 兼容 list 字段
    else if (map['list'] != null) {
      records = (map['list'] as List).map((item) => itemMapper(item as Map<String, dynamic>)).toList();
    }

    return PaginationResponse<T>(
      records: records,
      total: map['total'] as int?,
      pages: map['pages'] as int?,
    );
  }

  /// 从 List 创建（直接返回数组的情况）
  factory PaginationResponse.fromList(List list, T Function(Map<String, dynamic>) itemMapper) {
    return PaginationResponse<T>(
      records: list.map((item) => itemMapper(item as Map<String, dynamic>)).toList(),
    );
  }
}
