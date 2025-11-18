import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tem/components/BaseSuperRefreshComponent/components/PullToRefresh/index.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'logic.dart';

class PullToRefreshExampleView extends StatelessWidget {
  const PullToRefreshExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(PullToRefreshExampleLogic());
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试页面'),
      ),
      body: Stack(
        children: [
          Obx(
            () => BasePullToRefreshList(
              refreshController: logic.refreshController,
              onRefresh: logic.onRefresh,
              onLoadMore: logic.onLoadMore,
              children: logic.items
                  .map(
                    (item) => ListTile(
                      title: Text(item),
                      onTap: () {
                        Get.snackbar('提示', '点击了 $item');
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          Obx(
            () {
              return logic.isLoading.value
                  ? const BaseLoading(message: '加载中...')
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
