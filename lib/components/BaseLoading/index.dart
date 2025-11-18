import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 页面加载中遮罩层组件
class BaseLoading extends StatelessWidget {
  final String message;

  const BaseLoading({super.key, this.message = "页面加载中..."});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: Colors.white.withOpacity(1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30.w,
                height: 30.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3.w,
                  color: Theme.of(context).hoverColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
