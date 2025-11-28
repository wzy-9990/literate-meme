import 'package:flutter/material.dart';
import 'package:flutter_tem/api/modules/my.dart';
import 'package:flutter_tem/utils/logic/pagination/base_pagination_logic.dart';

/// 用户列表逻辑示例
///
/// 这是一个使用 BasePaginationLogic 的示例实现
/// 展示了如何：
/// 1. 继承基类并实现 fetchData 方法
/// 2. 调用具体的业务接口（这里是 listPageUserByOrganizationIdApi）
/// 3. 自定义搜索方法（这里是 searchUser，你可以根据需要命名和实现）
///
/// 💡 提示：不同页面的接口和搜索参数都可能不同，请根据实际需求修改
///
/// 📝 多接口场景示例（当有多个接口时）：
/// ```dart
/// class MyLogic extends BasePaginationLogic<Map<String, dynamic>> {
///   final RxBool statsLoading = false.obs;  // 其他接口的 loading
///
///   @override
///   bool get pageLoading => isLoading.value || statsLoading.value;
///
///   Future<void> loadStats() async {
///     try {
///       statsLoading.value = true;
///       await statsApi();
///     } finally {
///       statsLoading.value = false;
///     }
///   }
/// }
///
/// // View 中使用 logic.pageLoading 而不是 logic.isLoading.value
/// ```
class PullToRefreshExampleLogic
    extends BasePaginationLogic<Map<String, dynamic>> {
  // 搜索框控制器
  final TextEditingController searchController = TextEditingController();
  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page,
    int pageSize,
    Map<String, dynamic>? searchParams,
  ) async {
    final params = {
      'pageNo': page,
      'pageSize': pageSize,
      'organizationId': '0',
      ...?searchParams, // 合并搜索参数（可以是任意字段）
    };
    final response = await listPageUserByOrganizationIdApi(params);
    return PaginationResponse.fromMap(response);
  }

  /// 示例：按用户名搜索
  void searchUser(String keyword) {
    final params = keyword.trim().isEmpty ? null : {'userName': keyword.trim()};
    search(params);
  }

  /// 清空搜索
  void clearSearch() {
    searchController.clear();
    search(null);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
