import 'package:flutter/material.dart';
import 'package:flutter_tem/api/modules/user.dart';
import 'package:flutter_tem/page/index/modules/home/logic.dart';
import 'package:flutter_tem/page/index/modules/message/logic.dart';
import 'package:flutter_tem/page/index/modules/my/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class IndexLogic extends GetxController {
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
    _getHomeLogic()?.initData();
    // 消息页首屏不主动加载，等切换到消息时再加载
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (currentIndex.value == 0) {
      _getHomeLogic()?.initData();
    } else if (currentIndex.value == 1) {
      _getMessageLogic()?.initData();
    } else if (currentIndex.value == 2) {
      _getMyLogic()?.initData();
    }
  }

  Future<void> _loadToken() async {
    token.value = await Storage.getString(StorageKeys.token) ?? '';
  }

  void updateToken(String? value) async {
    final newToken = value ?? '';
    final wasEmpty = token.value.isEmpty;
    token.value = newToken;
    await Storage.setString(StorageKeys.token, newToken);

    // 登录后，自动刷新消息列表（若已初始化）
    if (newToken.isNotEmpty && wasEmpty) {
      _refreshActiveTab();
    }
  }

  MessageLogic? _getMessageLogic() {
    messageLogic ??=
        Get.isRegistered<MessageLogic>() ? Get.find<MessageLogic>() : null;
    return messageLogic;
  }

  MyLogic? _getMyLogic() {
    myLogic ??= Get.isRegistered<MyLogic>() ? Get.find<MyLogic>() : null;
    return myLogic;
  }

  HomeLogic? _getHomeLogic() {
    homeLogic ??= Get.isRegistered<HomeLogic>() ? Get.find<HomeLogic>() : null;
    return homeLogic;
  }

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

  void _refreshActiveTab() {
    switch (currentIndex.value) {
      case 0:
        _getHomeLogic()?.initData();
        break;
      case 1:
        _getMessageLogic()?.initData();
        break;
      case 2:
        _getMyLogic()?.initData();
        break;
      default:
        break;
    }
  }
}
