import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/services/index.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class GuideView extends StatefulWidget {
  const GuideView({super.key});

  @override
  State<GuideView> createState() => _GuideViewState();
}

class _GuideViewState extends State<GuideView> {
  int _countdown = 3; // 倒计时秒数
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 开始倒计时
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _navigateToNextPage();
      }
    });
  }

  /// 跳过倒计时，直接跳转
  void _skip() {
    _timer?.cancel();
    _navigateToNextPage();
  }

  /// 导航到下一个页面
  Future<void> _navigateToNextPage() async {
    // 初始化全局配置
    Global.init();

    // 检查是否需要登录
    final requireLogin = dotenv.env['REQUIRE_LOGIN']?.toLowerCase() == 'true';

    if (!requireLogin) {
      // 不需要登录，直接进入首页
      Get.offAllNamed(AppRoutes.index);
      return;
    }

    // 需要登录，检查登录状态
    final token = await Storage.getString(StorageKeys.token);

    if (token != null) {
      // 已登录，跳转到首页
      Get.offAllNamed(AppRoutes.index);
    } else {
      // 未登录，跳转到登录页
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主内容区域
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 应用 Logo 或名称
                Icon(
                  Icons.apps,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  '欢迎使用',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dotenv.env['API_URL'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 右下角跳过按钮
          Positioned(
            right: 20,
            bottom: 50,
            child: GestureDetector(
              onTap: _skip,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _countdown > 0 ? '跳过 $_countdown' : '跳过',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
