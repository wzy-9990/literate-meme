import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/base/base_logic.dart';

class HomeLogic extends BaseLogic {
  @override
  void initData() {
    super.initData();
    // 首页初始化逻辑
  }

  openWebView() {
    NavigationUtils.toNamed(AppRoutes.example, arguments: {
      'url': 'https://manager-test.pinduola.cn/manager/index.html#/login',
      'title': '看下',
    });
  }
}
