import 'package:flutter/material.dart';
import 'package:flutter_tem/page/index/message/logic.dart';
import 'package:get/get.dart';

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final logic = Get.find<MessageLogic>();
    return const Center(child: Text('消息'));
  }
}
