import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/components/BaseDeveloperOptions/index.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/logic/base/base_logic.dart';
import 'package:get/get.dart';

// ✅ BaseLogic 已自动集成 PageVisibilityMixin，无需重复添加
class MySettingLogic extends BaseLogic {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;

  // 使用 getter 直接引用 indexLogic.userInfo，保持响应式
  RxMap get userInfo => indexLogic.userInfo;

  // 开发者选项
  final developerOptions = BaseDeveloperOptions();

  @override
  Future<void> onLoad() async {
    debugPrint('📍 MySettingLogic - onLoad: 页面首次加载');
    // userInfo 已经通过 getter 引用，无需赋值
    isLoading.value = false;
  }

  @override
  void onShow() {
    super.onShow(); // 打印日志
    debugPrint('👀 MySettingLogic - onShow: 页面显示，刷新用户信息');
    // 从修改密码页面返回时，自动刷新用户信息
    _refreshUserInfoIfNeeded();
  }

  @override
  void onHide() {
    super.onHide(); // 打印日志
    debugPrint('🙈 MySettingLogic - onHide: 页面隐藏');
  }

  /// 根据需要刷新用户信息
  void _refreshUserInfoIfNeeded() {
    // 这里可以添加刷新逻辑，例如：
    // if (indexLogic.isLoggedIn) {
    //   indexLogic.loadUserInfo();
    // }
    debugPrint('🔄 检查是否需要刷新用户信息');
  }

  void logout() async {
    indexLogic.logout();
  }

  void changePassword() async {
    await NavigationUtils.toNamed(
      AppRoutes.myChangePassword,
      callback: (result) async {
        updateUserInfo(result as String);
      },
    );
  }

  void updateUserInfo(String name) async {
    isLoading.value = true;
    await indexLogic.loadUserInfo(id: name);
    isLoading.value = false;
    EasyLoading.showToast('操作成功');
  }

  /// 处理版本号点击（开发者选项入口）
  void onVersionTap() {
    developerOptions.onTap();
  }
}
