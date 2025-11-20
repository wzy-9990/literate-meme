import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/page/user/login/logic.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<LoginLogic>();
    return Scaffold(
      appBar: const BaseAppBar(
        title: '登录',
      ),
      body: Center(
        child: ElevatedButton(
          child: Text(
            '去登录',
            style: TextStyle(
              fontSize: 12.sp,
            ),
          ),
          onPressed: () {
            logic.loginButtonClick();
          },
        ),
      ),
    );
  }
}
