import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_tem/components/BaseText/index.dart';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () {
                    return Text(
                      logic.userInfo['userName'].toString(),
                      style: TextStyle(
                          fontSize: 20.sp,
                          color: const Color.fromARGB(255, 21, 141, 73)),
                    );
                  },
                ),
                Obx(
                  () {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: logic.list.map((item) {
                        return BaseText(item['mainText']);
                      }).toList(),
                    );
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
