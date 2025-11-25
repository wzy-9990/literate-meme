import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/utils/base/delayed_initial_load_mixin.dart';
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
abstract class BasePaginationLogic<T> extends GetxController
    with DelayedInitialLoadMixin {
  StreamSubscription<String>? _tokenSub;

  /// 刷新控制器
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  /// 数据列表
  final RxList<T> items = <T>[].obs;

  /// 列表加载状态（基类自动控制）
  final RxBool isLoading = false.obs;

  /// 页面整体加载状态（可在子类中覆盖，用于组合多个接口的 loading）
  ///
  /// 默认返回列表加载状态，子类可以覆盖这个 getter 来组合多个 loading：
  /// ```dart
  /// class MyLogic extends BasePaginationLogic {
  ///   final RxBool otherLoading = false.obs;
  ///
  ///   @override
  ///   bool get pageLoading => isLoading.value || otherLoading.value;
  /// }
  /// ```
  bool get pageLoading => isLoading.value;

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

  /// 是否处于搜索状态
  bool get isSearching => _searchParams != null && _searchParams!.isNotEmpty;

  /// 登出时是否自动清空列表（子类可覆盖）
  bool get clearOnLogout => false;

  @override
  void onClose() {
    _tokenSub?.cancel();
    refreshController.dispose();
    super.onClose();
  }

  @override
  bool get autoLoadOnInit => true;

  @override
  Duration get initialLoadDelay => const Duration(milliseconds: 100);

  @override
  Future<void> onLoad() => loadData();

  @override
  void onInit() {
    super.onInit();
    if (clearOnLogout && Get.isRegistered<IndexLogic>()) {
      final indexLogic = Get.find<IndexLogic>();
      _tokenSub = indexLogic.token.listen((value) {
        if (value.isEmpty) {
          _resetPaginationState();
        }
      });
    }
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

      debugPrint(
          '✅ 加载了 ${newItems.length} 条数据，当前共 ${items.length} 条，总共 $_total 条，第 $_page/$_totalPages 页');

      // 加载完成后隐藏 loading
      isLoading.value = false;
      EasyLoading.dismiss();
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
    refreshController.resetNoData();
    refreshController.position?.jumpTo(0);
    await loadData();
    refreshController.refreshCompleted();

    // 如果数据为空，重置加载更多状态
    if (items.isEmpty) {
      refreshController.resetNoData();
    }
  }

  /// 清空分页状态
  void _resetPaginationState() {
    _page = 1;
    _total = 0;
    _totalPages = 0;
    items.clear();
    isLoading.value = false;
    refreshController.resetNoData();
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
  ///
  /// [response] API 响应数据（自动处理 null 和类型转换）
  /// [itemMapper] 可选的数据转换函数
  ///   - 不提供时：自动将 Map 转换为 Map<String, dynamic>
  ///   - 提供时：使用自定义转换（如转换为 Model 类）
  factory PaginationResponse.fromMap(
    dynamic response, [
    T Function(dynamic)? itemMapper, // 👈 改为可选参数
  ]) {
    // 处理 null
    if (response == null) {
      return PaginationResponse<T>(records: [], total: 0, pages: 0);
    }

    // 处理非 Map 类型
    if (response is! Map) {
      return PaginationResponse<T>(records: [], total: 0, pages: 0);
    }

    // 转换为 Map<String, dynamic>
    final map = Map<String, dynamic>.from(response);
    List<T>? records;

    // 默认的转换函数：将 Map 转换为 Map<String, dynamic>
    T defaultMapper(dynamic item) {
      if (item is Map) {
        return Map<String, dynamic>.from(item) as T;
      }
      return item as T;
    }

    // 使用提供的 mapper 或默认 mapper
    final mapper = itemMapper ?? defaultMapper;

    // 尝试从 records 字段获取
    if (map['records'] != null) {
      records = (map['records'] as List).map((item) => mapper(item)).toList();
    }
    // 兼容 list 字段
    else if (map['list'] != null) {
      records = (map['list'] as List).map((item) => mapper(item)).toList();
    }

    return PaginationResponse<T>(
      records: records,
      total: map['total'] as int?,
      pages: map['pages'] as int?,
    );
  }

  /// 从 List 创建（直接返回数组的情况）
  factory PaginationResponse.fromList(
      List list, T Function(Map<String, dynamic>) itemMapper) {
    return PaginationResponse<T>(
      records:
          list.map((item) => itemMapper(item as Map<String, dynamic>)).toList(),
    );
  }
}
