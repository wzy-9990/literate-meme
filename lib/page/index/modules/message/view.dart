import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseSuperRefreshComponent/components/PullToRefresh/index.dart';
import 'package:flutter_tem/components/BaseTab/index.dart';
import 'package:flutter_tem/page/index/modules/message/logic.dart';
import 'package:get/get.dart';

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<MessageLogic>();
    const tabOptions = [
      BaseTabItem(label: '全部', value: ''),
      BaseTabItem(label: '未读', value: '王'),
      BaseTabItem(label: '已读', value: '张'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
      ),
      body: Column(
        children: [
          Obx(() => BaseTab(
                options: tabOptions,
                value: logic.tabValue.value,
                onChanged: (v) =>
                    logic.changeTab(v.toString(), type: 'message'),
                alignment: MainAxisAlignment.spaceEvenly,
                indicatorColor: Theme.of(context).colorScheme.primary,
              )),
          Divider(height: 1, color: Colors.grey.shade300),
          Expanded(
            child: Obx(
              () => BasePullToRefreshList(
                refreshController: logic.refreshController,
                onRefresh: logic.onRefresh,
                onLoadMore: logic.onLoadMore,
                isLoading: logic.isLoading.value,
                isSearching: logic.isSearching,
                requireAuth: true,
                emptyTitle: '暂无消息',
                emptySubtitle: '稍后再来看看',
                emptyButtonText: '刷新',
                children: logic.items
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            (item['userName'] ?? '消息')
                                .toString()
                                .substring(0, 1),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item['userName']?.toString() ?? '消息标题',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          item['mobile']?.toString() ?? '这是一条消息摘要示例',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Text(
                          item['position']?.toString() ?? '刚刚',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
