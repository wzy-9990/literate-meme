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
    initData();
    _loadToken();
  }

  void initData() {
    debugPrint('tab页面初始化');
    _refreshTab(index: homeTab, force: true); // 消息页首屏不主动加载，等切换到消息时再加载
  }

  void changeTab(int index) {
    if (currentIndex.value == index) {
      _refreshTab(index: index, force: true);
      return;
    }

    currentIndex.value = index;
    _refreshTab(index: index);
  }

  Future<void> _loadToken() async {
    token.value = await Storage.getString(StorageKeys.token) ?? '';
  }

  void updateToken(String? value) async {
    final newToken = value ?? '';
    final wasEmpty = token.value.isEmpty;
    token.value = newToken;
    await Storage.setString(StorageKeys.token, newToken);

    if (newToken.isNotEmpty && wasEmpty) {
      _refreshTab();
    }
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
        if (force || _getMessageLogic() != null) {
          _getMessageLogic()?.initData(); // 消息页保持首屏刷新逻辑
        }
        break;
      case myTab:
        if (force || _getMyLogic() != null) {
          _getMyLogic()?.onLoad();
        }
        break;
      default:
        break;
    }
  }

  /// Lazily find a registered logic; returns null if not registered.
  T? _findLogic<T>() => Get.isRegistered<T>() ? Get.find<T>() : null;
}
