import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/permission/index.dart';
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

    // 请求通知权限
    _requestNotificationPermission();

    final rid = await jPush.getRegistrationID();
    debugPrint('RegistrationID: $rid');

    setAlias('拼卡拉司机版');
  }

  /// 请求通知权限
  Future<void> _requestNotificationPermission() async {
    // 检查并请求通知权限
    final granted = await PermissionUtil.requestNotification(
      tip: '需要通知权限以接收订单和消息提醒',
    );

    if (!granted) {
      debugPrint('❌ 通知权限被拒绝');
    } else {
      debugPrint('✅ 通知权限已授予');
    }
  }

  void setAlias(String aliasStr) {
    jPush.setAlias(aliasStr);
  }
}
