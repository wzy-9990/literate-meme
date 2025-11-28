import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BasePhoneCall/index.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/logic/base/base_logic.dart';
import 'package:flutter_tem/utils/modules/dict/home.dart';
import 'package:get/get.dart';

class HomeLogic extends BaseLogic {
  /// 当前选中的方向（默认取枚举 add_points 对应的值，否则为 1）
  final RxInt selectedDirection =
      ((directionTypeEnum['add_points']?['value'] as int)).obs;
  final RxList<int> selectedDirectionMulti = <int>[].obs;
  final RxBool privacyAgree = false.obs;
  final RxInt tabValue = 1.obs;
  final RxString name = ''.obs;
  final RxString selectValue = ''.obs;
  final RxString selectDate = ''.obs;
  final RxString selected = ''.obs;

  final RxString addressValue = ''.obs;
  final TextEditingController nameController = TextEditingController();

  /// 判断示例表单数据是否为空
  bool get isOperationDataEmpty =>
      name.value.isEmpty &&
      selected.value.isEmpty &&
      selectDate.value.isEmpty &&
      addressValue.value.isEmpty;

  void updateName(String value) {
    name.value = value;
  }

  void updateDate(String value) {
    selectDate.value = value;
  }

  void updateAddress(String value) {
    addressValue.value = value;
  }

  void updateSelectValue(String value) {
    selected.value = value;
  }

  @override
  bool get skipDelayedOnReady => true; // 避免 BaseLogic 的延迟加载与手动刷新重复触发

  @override
  Future<void> onLoad() async {
    debugPrint('📍 首页 - onLoad: 页面首次加载');
  }

  @override
  void onShow() {
    super.onShow(); // 打印日志
    debugPrint('👀 首页 - onShow: 页面显示，执行数据初始化');
    onLoad(); // 每次显示时刷新数据
  }

  @override
  void onHide() {
    super.onHide(); // 打印日志
    debugPrint('🙈 首页 - onHide: 页面隐藏');
  }

  void openWebView() {
    NavigationUtils.toNamed(AppRoutes.webView, arguments: {
      'url': 'https://manager-test.pinduola.cn/manager/index.html#/login',
      'title': '看下',
    });
  }

  void pullToRefreshView() {
    NavigationUtils.toNamed(AppRoutes.example, arguments: {
      'url': 'https://manager-test.pinduola.cn/manager/index.html#/login',
      'title': '看下',
    });
  }

  void imageExampleView() {
    NavigationUtils.toNamed(AppRoutes.imageExample);
  }

  void permissionExampleView() {
    NavigationUtils.toNamed(AppRoutes.permissionExample);
  }

  void uploadExampleView() {
    NavigationUtils.toNamed(AppRoutes.uploadExample);
  }

  void phoneCallExampleView() {
    BasePhoneCall.makePhoneCall(Get.context!, '138-1234-5678');
  }

  void appIconExampleView() {
    NavigationUtils.toNamed(AppRoutes.appIconExample);
  }

  void updateDirection(int value) {
    selectedDirection.value = value;
  }

  void updateDirectionMulti(List<int> values) {
    selectedDirectionMulti.value = values;
  }

  void updatePrivacyAgree(bool agree) {
    privacyAgree.value = agree;
  }

  void updateTabValue(int value) {
    tabValue.value = value;
  }
}
