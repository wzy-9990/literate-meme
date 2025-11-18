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
                          (item) => Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  item['userName']?.toString().substring(0, 1) ??
                                      '?',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    item['userName']?.toString() ?? '未知用户',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4.r),
                                      border: Border.all(
                                        color: Colors.orange.shade200,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      item['position']?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        item['mobile']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item['agentRegion'] != null &&
                                      item['agentRegion'].toString().isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.h),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              item['agentRegion'].toString(),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey[500],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16.sp,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                // 显示更详细的信息
                                Get.dialog(
                                  AlertDialog(
                                    title: Text('用户详情'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildDetailRow(
                                              '姓名', item['userName']),
                                          _buildDetailRow(
                                              '手机号', item['mobile']),
                                          _buildDetailRow(
                                              '职位', item['position']),
                                          _buildDetailRow(
                                              '状态', item['onBoardStatusName']),
                                          _buildDetailRow(
                                              '代理区域', item['agentRegion']),
                                          _buildDetailRow(
                                              '入职日期', item['joiningDate']),
                                          _buildDetailRow('直接邀请人数',
                                              item['directInviteCount']?.toString()),
                                          _buildDetailRow(
                                              '机构', item['organizationName']),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text('关闭'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  // 构建详情行
  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty || value.toString() == 'null') {
      return SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
