import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 中文版的水滴下拉刷新头部
class ChineseWaterDropHeader extends StatelessWidget {
  const ChineseWaterDropHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return WaterDropHeader(
      complete: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.done,
            color: Colors.grey,
            size: 20.w,
          ),
          SizedBox(width: 15.w),
          Text(
            '刷新成功',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          )
        ],
      ),
      failed: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.close,
            color: Colors.grey,
            size: 20.w,
          ),
          SizedBox(width: 15.w),
          Text(
            '刷新失败',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          )
        ],
      ),
    );
  }
}
