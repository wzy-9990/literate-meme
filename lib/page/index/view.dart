import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseDoubleBackExitWrapper/index.dart';
import 'package:flutter_tem/page/index/home/view.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/page/index/message/view.dart';
import 'package:flutter_tem/page/index/my/view.dart';
import 'package:get/get.dart';

class IndexView extends GetView<IndexLogic> {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDoubleBackExitWrapper(
      child: Obx(() {
        return Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              MessageView(),
              MyView(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xffFE6601), // 选中颜色
            unselectedItemColor:
                const Color(0xFF000000).withOpacity(0.65), // 未选中颜色
            selectedFontSize: 12,

            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
          ),
        );
      }),
    );
  }
}
