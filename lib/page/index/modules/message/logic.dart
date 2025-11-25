import 'package:flutter_tem/api/modules/my.dart';
import 'package:flutter_tem/utils/base/base_pagination_logic.dart';
import 'package:get/get.dart';

class MessageLogic extends BasePaginationLogic<Map<String, dynamic>> {
  /// Tab 选中值：0 全部、1 未读、2 已读（示例）
  final RxString tabValue = ''.obs;
  bool _initialized = false;
  Map<String, dynamic>? _currentParams;

  /// 消息页手动触发加载，避免未进入即请求
  @override
  bool get autoLoadOnInit => false;

  /// 跳过 onReady 的自动加载，完全由 initData 控制
  @override
  bool get skipDelayedOnReady => true;

  /// 外部调用入口：首次进入显示 loading，后续无感刷新
  void initData() {
    if (_initialized) {
      onRefresh(); // 保留现有数据，静默刷新
      return;
    }
    _initialized = true;
    isLoading.value = true;
    refreshController.resetNoData();
    onRefresh();
  }

  /// 切换 Tab，并根据 Tab 值过滤数据
  void changeTab(String value, {String? type}) {
    tabValue.value = value;
    _currentParams = value.isEmpty
        ? (type == null ? null : {'userName': value})
        : {
            if (type != null) 'userName': value,
          };
    onRefresh();
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
      ...?_currentParams,
    };
    final response = await listPageUserByOrganizationIdApi(params);
    return PaginationResponse.fromMap(response);
  }
}
