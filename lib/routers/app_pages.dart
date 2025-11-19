
import 'package:flutter_tem/page/guide/view.dart';
import 'package:flutter_tem/page/index/binding.dart';
import 'package:flutter_tem/page/index/my/setting/binding.dart';
import 'package:flutter_tem/page/index/my/setting/changePassword/binding.dart';
import 'package:flutter_tem/page/index/my/setting/changePassword/view.dart';
import 'package:flutter_tem/page/index/my/setting/view.dart';
import 'package:flutter_tem/page/index/view.dart';
import 'package:flutter_tem/page/user/login/binding.dart';
import 'package:flutter_tem/page/user/login/view.dart';
import 'package:flutter_tem/page/webview/binding.dart';
import 'package:flutter_tem/page/webview/view.dart';
import 'package:flutter_tem/page/example/pullToRefresh/view.dart';
import 'package:flutter_tem/page/example/imageExample/view.dart';
import 'package:flutter_tem/page/example/permissionExample/view.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.guide, page: () => const GuideView()),
    GetPage(
        name: AppRoutes.login,
        page: () => const LoginView(),
        binding: LoginBinding()),
    GetPage(
      name: AppRoutes.index,
      page: () => const IndexView(),
      binding: BindingsBuilder(() {
        IndexBinding().dependencies();
      }),
    ),
    GetPage(
      name: AppRoutes.mySetting,
      page: () => const MySettingView(),
      binding: MySettingBinding(),
    ),
    GetPage(
      name: AppRoutes.myChangePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.webView,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return WebViewPageView(
          url: args?['url'] ?? '',
          title: args?['title'] ?? '网页',
        );
      },
      binding: WebViewBinding(),
    ),
    GetPage(
      name: AppRoutes.example,
      page: () => const PullToRefreshExampleView(),
    ),
    GetPage(
      name: AppRoutes.imageExample,
      page: () => const ImageExampleView(),
    ),
    GetPage(
      name: AppRoutes.permissionExample,
      page: () => const PermissionExampleView(),
    ),
  ];
}
