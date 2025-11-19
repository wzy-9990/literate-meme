import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// 双击退出
class BaseDoubleBackExitWrapper extends StatefulWidget {
  final Widget child;
  const BaseDoubleBackExitWrapper({required this.child, super.key});

  @override
  State<BaseDoubleBackExitWrapper> createState() =>
      _DoubleBackExitWrapperState();
}

class _DoubleBackExitWrapperState extends State<BaseDoubleBackExitWrapper> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          EasyLoading.showToast('再按一次退出应用');
          return false;
        }
        return true;
      },
      child: widget.child,
    );
  }
}
