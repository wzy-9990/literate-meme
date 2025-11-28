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

  bool get isLoggedIn => token.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    onLoad();
    _loadToken();
  }

  /// 页面统一初始化入口
  Future<void> onLoad() async {
    debugPrint('tab页面初始化');
    _refreshTab(index: homeTab, force: true); // 消息页首屏不主动加载，等切换到消息时再加载
    _notifyTabShow(homeTab); // 首次进入时通知首页显示
  }

  void changeTab(int index) {
    if (currentIndex.value == index) {
      _refreshTab(index: index, force: true);
      return;
    }

    // 隐藏当前 Tab
    _notifyTabHide(currentIndex.value);

    // 切换 Tab
    currentIndex.value = index;

    // 显示新 Tab
    _notifyTabShow(index);
    _refreshTab(index: index);
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

  void _refreshTab({int? index, bool force = false}) {
    final tab = index ?? currentIndex.value;
    switch (tab) {
      case homeTab:
        _getHomeLogic()?.onLoad();
        break;
      case messageTab:
        _getMessageLogic()?.onLoad(); // 保持消息页手动触发加载的逻辑
        break;
      case myTab:
        _getMyLogic()?.onLoad();
        break;
      default:
        break;
    }
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
