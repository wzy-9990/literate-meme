import 'package:flutter/material.dart';
import 'package:flutter_tem/api/modules/my.dart';
import 'package:flutter_tem/utils/base/base_pagination_logic.dart';

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
  @override
  void onInit() {
    // 页面打开时先展示 loading，等待路由动画结束后再进行首轮加载
    isLoading.value = true;
    super.onInit();
  }

  @override
  bool get autoLoadOnInit => false;

  @override
  Duration get initialLoadDelay => const Duration(milliseconds: 100);

  // 搜索框控制器
  final TextEditingController searchController = TextEditingController();
  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page,
    int pageSize,
    Map<String, dynamic>? searchParams,
  ) async {
    // 1️⃣ 构建请求参数（根据你的接口要求调整）
    final params = {
      'pageNo': page,
      'pageSize': pageSize,
      'organizationId': '0', // 示例：固定的业务参数
      ...?searchParams, // 合并搜索参数（可以是任意字段）
    };

    // 2️⃣ 调用你的业务接口（替换为你自己的接口）
    final response = await listPageUserByOrganizationIdApi(params);

    // 3️⃣ 一行代码搞定（自动处理所有转换）
    return PaginationResponse.fromMap(response);
  }

  // 💡 自定义搜索方法示例
  // 方法名、参数名都可以根据你的需求自定义
  // 例如：
  // - searchByName(String name) -> {'name': name}
  // - filterByStatus(String status) -> {'status': status}
  // - searchByKeyword(String kw) -> {'keyword': kw}

  /// 示例：按用户名搜索
  /// 💡 你可以改成自己需要的方法名和参数
  void searchUser(String keyword) {
    final params = keyword.trim().isEmpty
        ? null
        : {'userName': keyword.trim()}; // 👈 这里的 'userName' 是示例，改成你的字段名

    search(params); // 调用基类的 search 方法
  }

  /// 清空搜索
  void clearSearch() {
    searchController.clear();
    search(null); // 传 null 清空搜索参数
  }

  // 💡 你还可以添加更多自定义搜索方法，例如：
  //
  // void searchByPhone(String phone) {
  //   search({'mobile': phone});
  // }
  //
  // void filterByPosition(String position) {
  //   search({'position': position});
  // }
  //
  // void searchWithMultipleParams(String name, String status) {
  //   search({
  //     'userName': name,
  //     'status': status,
  //   });
  // }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
