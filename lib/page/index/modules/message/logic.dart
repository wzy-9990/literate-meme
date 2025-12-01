import 'package:flutter/material.dart';
import 'package:flutter_tem/api/modules/my.dart';
import 'package:flutter_tem/utils/helpers/loading_manager.dart';
import 'package:flutter_tem/utils/logic/pagination/base_pagination_logic.dart';
import 'package:get/get.dart';

class MessageLogic extends BasePaginationLogic<Map<String, dynamic>> {
  /// Tab 选中值：0 全部、1 未读、2 已读（示例）
  final RxString tabValue = ''.obs;
  bool _initialized = false;
  Map<String, dynamic>? _currentParams;

  @override
  bool get clearOnLogout => true;

  /// 消息页手动触发加载，避免未进入即请求
  @override
  bool get autoLoadOnInit => false;

  /// 跳过 onReady 的自动加载，完全由 initData 控制
  @override
  bool get skipDelayedOnReady => true;

  /// 统一的加载入口：首次进入显示 loading，后续无感刷新
  @override
  Future<void> onLoad() async {
    debugPrint('📍 消息页 - onLoad: 数据加载');
    if (_initialized) {
      await onRefresh(); // 保留现有数据，静默刷新
      return;
    }
    _initialized = true;
    isLoading.value = true;
    refreshController.resetNoData();
    await onRefresh();
  }

  @override
  void onShow() {
    super.onShow(); // 打印日志
    debugPrint('👀 消息页 - onShow: 页面显示，执行数据初始化');
    onLoad(); // 每次显示时刷新数据
  }

  @override
  void onHide() {
    super.onHide(); // 打印日志
    debugPrint('🙈 消息页 - onHide: 页面隐藏');
  }

  /// 切换 Tab，并根据 Tab 值过滤数据
  void changeTab(String value, {String? type}) {
    tabValue.value = value;
    _currentParams = {'userName': tabValue.value};

    LoadingManager.show();
    onRefresh();
  }

  @override
  Future<PaginationResponse<Map<String, dynamic>>> fetchData(
    int page,
    int pageSize,
    Map<String, dynamic>? searchParams,
  ) async {
    // 使用 LoadingManager 自动管理，无需 try-finally
    final params = {
      'pageNo': page,
      'pageSize': pageSize,
      'organizationId': '0',
      ...?_currentParams,
    };
    final response = await listPageUserByOrganizationIdApi222(params);
    LoadingManager.dismiss(); // 手动关闭 changeTab 中显示的 loading
    return PaginationResponse.fromMap(response);
  }
}
