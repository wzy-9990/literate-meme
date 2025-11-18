import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tem/components/BaseSuperRefreshComponent/components/PullToRefresh/index.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'logic.dart';

class PullToRefreshExampleView extends StatefulWidget {
  const PullToRefreshExampleView({super.key});

  @override
  State<PullToRefreshExampleView> createState() =>
      _PullToRefreshExampleViewState();
}

class _PullToRefreshExampleViewState extends State<PullToRefreshExampleView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(PullToRefreshExampleLogic());

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户列表'),
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            padding: EdgeInsets.all(12.w),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '请输入用户名搜索',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                    ),
                    onSubmitted: (value) {
                      // 回车也可以触发搜索
                      logic.search(value);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    logic.search(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
          // 分隔线
          Divider(height: 1.h, color: Colors.grey.shade300),
          // 列表
          Expanded(
            child: Stack(
              children: [
                Obx(
                  () => BasePullToRefreshList(
                    refreshController: logic.refreshController,
                    onRefresh: logic.onRefresh,
                    onLoadMore: logic.onLoadMore,
                    children: logic.items
                        .map(
                          (item) => ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                item['userName']?.toString().substring(0, 1) ??
                                    '?',
                              ),
                            ),
                            title: Text(
                              item['userName']?.toString() ?? '未知用户',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              item['mobile']?.toString() ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Get.snackbar(
                                '用户详情',
                                '用户名: ${item['userName']}\n手机号: ${item['mobile']}',
                              );
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
          ),
        ],
      ),
    );
  }
}
