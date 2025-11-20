import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_tem/page/index/modules/my/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:get/get.dart';

class MyView extends StatelessWidget {
  const MyView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final logic = Get.find<MyLogic>();
    return SafeArea(
      child: Stack(
        children: [
          GetBuilder<MyLogic>(builder: (myLogic) {
            return Column(
              children: [
                Obx(
                  () {
                    return Text(logic.userInfo['userName'].toString());
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.mySetting);
                  },
                  child: const Text('跳转到设置'),
                ),
              ],
            );
          }),
          Obx(
            () {
              return logic.isLoading.value
                  ? const BaseLoading()
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }
}
