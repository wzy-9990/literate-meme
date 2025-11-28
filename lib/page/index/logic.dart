import 'package:flutter/material.dart';
import 'package:flutter_tem/api/modules/user.dart';
import 'package:flutter_tem/page/index/modules/home/logic.dart';
import 'package:flutter_tem/page/index/modules/message/logic.dart';
import 'package:flutter_tem/page/index/modules/my/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class IndexLogic extends GetxController {
  static const int homeTab = 0;
  static const int messageTab = 1;
  static const int myTab = 2;

  final currentIndex = 0.obs;
  final RxString token = ''.obs;
  RxMap userInfo = RxMap();
  HomeLogic? homeLogic;
  MessageLogic? messageLogic;
  MyLogic? myLogic;

  Worker? _tabVisibilityWorker;
  int? _previousTabIndex;

  bool get isLoggedIn => token.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _setupTabVisibilityListener(); // 设置自动监听 Tab 切换
    onLoad();
    _loadToken();
  }

  /// 设置 Tab 可见性自动监听
  void _setupTabVisibilityListener() {
    _tabVisibilityWorker = ever(currentIndex, (index) {
      // 隐藏之前的 Tab
      if (_previousTabIndex != null && _previousTabIndex != index) {
        _notifyTabHide(_previousTabIndex!);
      }

      // 显示当前 Tab
      _notifyTabShow(index);

      _previousTabIndex = index;
    });
  }

  /// 页面统一初始化入口
  Future<void> onLoad() async {
    debugPrint('tab页面初始化');
    // Worker 会自动触发首页的 onShow，无需手动调用
  }

  /// 切换 Tab - 只需修改 currentIndex，Worker 会自动触发 onShow/onHide
  void changeTab(int index) {
    if (currentIndex.value == index) {
      // 重复点击同一个 Tab，重新触发 onShow 刷新数据
      _notifyTabShow(index);
      return;
    }

    // 修改 currentIndex，Worker 会自动触发 onShow/onHide
    currentIndex.value = index;
  }

  @override
  void onClose() {
    _tabVisibilityWorker?.dispose(); // 释放 Worker
    super.onClose();
  }

  Future<void> _loadToken() async {
    token.value = await Storage.getString(StorageKeys.token) ?? '';
  }

  void updateToken(String? value) async {
    final newToken = value ?? '';

    token.value = newToken;
    await Storage.setString(StorageKeys.token, newToken);
  }

  MessageLogic? _getMessageLogic() =>
      messageLogic ??= _findLogic<MessageLogic>();
  MyLogic? _getMyLogic() => myLogic ??= _findLogic<MyLogic>();
  HomeLogic? _getHomeLogic() => homeLogic ??= _findLogic<HomeLogic>();

  Future logout() async {
    updateToken('');
    userInfo.value = {};
    await Storage.clear();
    Get.toNamed(AppRoutes.login);
  }

  Future loadUserInfo({String? id}) async {
    final params = {
      'userId': '1000000000000000001',
    };
    if (id != null) {
      params['userId'] = id;
    }
    final response = await getUserDetailByUserIdApi(params);
    userInfo.value = response;
    update();
    return response;
  }

  /// 通知 Tab 显示（触发 onShow）
  void _notifyTabShow(int index) {
    switch (index) {
      case homeTab:
        _getHomeLogic()?.onShow();
        break;
      case messageTab:
        _getMessageLogic()?.onShow();
        break;
      case myTab:
        _getMyLogic()?.onShow();
        break;
    }
  }

  /// 通知 Tab 隐藏（触发 onHide）
  void _notifyTabHide(int index) {
    switch (index) {
      case homeTab:
        _getHomeLogic()?.onHide();
        break;
      case messageTab:
        _getMessageLogic()?.onHide();
        break;
      case myTab:
        _getMyLogic()?.onHide();
        break;
    }
  }

  /// Lazily find a registered logic; returns null if not registered.
  T? _findLogic<T>() => Get.isRegistered<T>() ? Get.find<T>() : null;
}
