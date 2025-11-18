import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseDoubleBackExitWrapper/index.dart';
import 'package:flutter_tem/page/user/login/logic.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<LoginLogic>();
    return BaseDoubleBackExitWrapper(
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            child: Text(
              '登录',
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
            onPressed: () {
              logic.loginButtonClick();
            },
          ),
        ),
      ),
    );
  }
}
