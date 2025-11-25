import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/api/modules/my.dart';
import 'package:flutter_tem/utils/base/base_pagination_logic.dart';
import 'package:get/get.dart';

class MessageLogic extends BasePaginationLogic<Map<String, dynamic>> {
  /// Tab 选中值：0 全部、1 未读、2 已读（示例）
  final RxInt tabValue = 0.obs;
  String? type;

  @override
  void onInit() {
    isLoading.value = true;
    super.onInit();
    refresh();
  }

  /// 切换 Tab，并根据 Tab 值过滤数据
  void changeTab(int value, {String? type}) {
    tabValue.value = value;
    // 示例过滤字段：status/type，可根据外部传入 type
    EasyLoading.show();
    search();
  }

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
      ...?searchParams,
    };
    final response = await listPageUserByOrganizationIdApi(params);
    return PaginationResponse.fromMap(response);
  }
}
