import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseDoubleBackExitWrapper/index.dart';
import 'package:flutter_tem/components/BaseUnfocusOnTap/index.dart';
import 'package:flutter_tem/config/easyLoading/index.dart';
import 'package:flutter_tem/config/env/index.dart';
import 'package:get/get.dart';

import 'routers/app_routes.dart';
import 'routers/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  EasyLoadingConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        getPages: AppPages.routes,
        initialRoute: AppRoutes.guide,
        defaultTransition: Transition.cupertino,
        // 主题
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0, // 阴影高度
            surfaceTintColor: Colors.transparent, // 去除 Material 3 的 surface tint 效果
            scrolledUnderElevation: 0, // 滚动时不改变阴影
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent, // 状态栏透明
              statusBarIconBrightness: Brightness.dark, // 状态栏图标深色
            ),
          ),
          // BottomNavigationBar 主题配置较为有限，主要样式在组件中直接设置
          splashColor: Colors.transparent, // 全局禁用水波纹
          highlightColor: Colors.transparent, // 全局禁用高亮
          scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        ),
        builder: (context, child) {
          return BaseUnfocusOnTap(
            child: BaseDoubleBackExitWrapper(
              child: EasyLoading.init()(context, child),
            ),
          );
        },
      ),
    );
  }
}
