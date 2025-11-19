import 'package:flutter/material.dart';

// 封装点击空白处 unfocus
class BaseUnfocusOnTap extends StatelessWidget {
  final Widget child;
  const BaseUnfocusOnTap({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
