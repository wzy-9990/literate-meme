import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseDoubleBackExitWrapper/index.dart';
import 'package:flutter_tem/components/BaseUnfocusOnTap/index.dart';
import 'package:flutter_tem/config/easyLoading/index.dart';
import 'package:flutter_tem/config/env/index.dart';
import 'package:flutter_tem/config/theme/index.dart';
import 'package:flutter_tem/routers/app_pages.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/helpers/app_icon_manager.dart';
import 'package:flutter_tem/utils/logic/base/mixin/page_visibility_mixin.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load(); // 加载环境变量
  await AppIconManager.checkAndSwitchIcon(); // 启动时检查是否需要切换图标
  EasyLoadingConfig.init(); // 初始化 EasyLoading
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
        // 路由观察器（用于页面可见性监听）
        navigatorObservers: [PageVisibilityObserver.instance],
        // 添加本地化支持
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'), // 中文
          Locale('en', 'US'), // 英文
        ],
        locale: const Locale('zh', 'CN'), // 设置默认语言为中文
        // 主题
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme, // 如需支持深色模式，取消此注释
        // themeMode: ThemeMode.system, // 跟随系统主题1
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
