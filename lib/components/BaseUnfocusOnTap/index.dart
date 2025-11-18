import 'package:flutter/material.dart';

// 封装点击空白处 unfocus
class BaseUnfocusOnTap extends StatelessWidget {
  final Widget child;
  const BaseUnfocusOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
