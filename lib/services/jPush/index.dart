import 'package:flutter/material.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

///推送工具
class JPushServices {
  JPushServices._internal();

  static final _instance = JPushServices._internal();

  factory JPushServices() => _instance;

  final JPush jPush = JPush();

  Future<void> initJPush() async {
    jPush.addEventHandler(
      //接收通知回调方法
      onReceiveNotification: (message) async {},
      //点击通知回调方法
      onOpenNotification: (message) async {},
      //接收自定义消息回调方法
      onReceiveMessage: (message) async {},
    );

    // jPush.isNotificationEnabled().then((bool value) {
    //   print("通知授权是否打开: $value");
    //   if (!value) {
    //     Get.snackbar(
    //       "提示",
    //       "没有通知权限,点击跳转打开通知设置界面",
    //       duration: const Duration(seconds: 6),
    //       onTap: (_) {
    //         jPush.openSettingsForNotification();
    //       },
    //     );
    //   }
    // }).catchError((onError) {
    //   print("通知授权是否打开: ${onError.toString()}");
    // });

    jPush.enableAutoWakeup(enable: true);
    jPush.setup(
      appKey: '038e7379d0c3945d4607c4a2',
      production: true,
      debug: true,
    );
    jPush.applyPushAuthority(
      const NotificationSettingsIOS(
        sound: true,
        alert: true,
        badge: true,
      ),
    );

    final rid = await jPush.getRegistrationID();
    debugPrint('RegistrationID: $rid');

    setAlias('拼卡拉司机版');
  }

  void setAlias(String aliasStr) {
    jPush.setAlias(aliasStr);
  }
}
