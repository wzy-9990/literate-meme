import 'package:flutter_tem/api/modules/my.dart';
import 'package:flutter_tem/utils/base/base_pagination_logic.dart';

/// 用户列表逻辑
///
/// 继承 BasePaginationLogic，只需实现 fetchData 方法
class PullToRefreshExampleLogic extends BasePaginationLogic<Map<String, dynamic>> {
  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page,
    int pageSize,
    Map<String, dynamic>? searchParams,
  ) async {
    // 构建请求参数
    final params = {
      'pageNo': page,
      'pageSize': pageSize,
      'organizationId': '0', // 组织ID（保留远程版本的参数）
      ...?searchParams, // 合并搜索参数
    };

    // 调用真实接口
    final response = await listPageUserByOrganizationIdApi(params);

    // 解析响应
    if (response == null) {
      return PaginationResponse<Map<String, dynamic>>(
        records: [],
        total: 0,
        pages: 0,
      );
    }

    // 处理不同的响应格式
    if (response is Map) {
      return PaginationResponse.fromMap(
        response,
        (item) => Map<String, dynamic>.from(item),
      );
    } else if (response is List) {
      return PaginationResponse.fromList(
        response,
        (item) => Map<String, dynamic>.from(item),
      );
    }

    return PaginationResponse<Map<String, dynamic>>(
      records: [],
      total: 0,
      pages: 0,
    );
  }

  /// 搜索用户（带用户名参数）
  void searchUser(String keyword) {
    final searchParams = keyword.trim().isEmpty
        ? null
        : {'userName': keyword.trim()};
    search(searchParams);
  }
}
